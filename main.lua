--handle blocks seemlessly somehow?? dump all map on screen into table?

dofile("helpers.lua")

love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

math.randomseed(os.time())

local survival = {}

--make time it's own thing
survival.Hunger = math.random(70,100)
survival.Thirst = math.random(50,100)
survival.Fuel   = math.random(30,100)
survival.Meat   = math.random(50,100)
survival.Water  = math.random(50,100)
resource_tick   = 0

map = {}
map.blocksize = 5000 --length and width (don't set above 350 for pathfinding speed)
map.loadedblock = {}
map.tilesize = 32

--player class
player = {}
player.x = 256--position
player.y = 247
player.aimx = 0--aim direction
player.aimy = 0
player.moveaim = {0,0} --the dir player wants to move
player.mcooldown = 0 --cool it down so the player doesn't spam pathfinding
player.path = {}
player.pathcooldown = 0
player.running = false
player.runspeed = 0.25
player.walkspeed = 0.5

--graphics class
graphics = {}

function love.load()
	--keep the multiplier odd to render out all possible tiles
	love.window.setMode( 0, 0, {resizable=true,fullscreen=false} )
	love.window.setTitle("Old School Game")
	
	love.graphics.setNewFont(20)

    graphics.cobble = love.graphics.newImage("tiles/cobble.png")
    graphics.brick = love.graphics.newImage("tiles/brick.png")
    graphics.player = love.graphics.newImage("player.png")
    --graphics.crosshair = love.graphics.newImage("crosshair.png")

	cursor = love.mouse.newCursor( "crosshair.png", 15, 15 )


	love.mouse.setCursor( cursor )
	
	footstep = love.audio.newSource("footstep.wav", "static" )
	moveconfirm = love.audio.newSource("move.ogg", "static" )
	moveno = love.audio.newSource("moveno.mp3", "static" )
	bgmusic = love.audio.newSource("backgroundmusic.mp3", "stream" )
	watchdog = love.audio.newSource("WATCHDOG.wav", "stream" )

	love.generateblock(dt,1,1)
	
end

function love.draw(dt)
	love.rendermap(player.x,player.y)
	love.graphics.draw(graphics.player,graphics.scw,graphics.sch,0,map.tilesize/32,map.tilesize/32)
	--this is a debug to show the center of the screen
	--love.graphics.circle( "fill", graphics.screenw/2, graphics.screenh/2, 3 )
	love.drawcrosshairs()
	
	--debug info
	local lwidth,lheight = love.window.getMode()
	love.graphics.print("This is a proof of concept build.\nCONTROLS\nToggle Fullscreen:~\nQuit:Escape\nRestart Game:Left CTRL\nToggle Run:R", 0,lheight-140)
	love.graphics.print("Move Aim:"..player.moveaim[1]..","..player.moveaim[2],0,0)
	love.graphics.print("Mouse Tile:"..(player.x+mousetilex)..","..(player.y+mousetiley),0,20)
	love.graphics.print("Movement Selection Cooldown:"..player.mcooldown,0,40)
	love.graphics.print("Movement Cooldown:"..player.pathcooldown,0,60)
	love.graphics.print("Running:"..tostring(player.running),0,80)
	love.graphics.print("FPS:"..love.timer.getFPS( ),0,100)
	love.graphics.print("ZOOM:"..map.tilesize,0,120)
	love.drawdebugpath()
end

function love.update(dt)
	--update screen integers 
	graphics.screenh = love.graphics.getHeight()
	graphics.screenw = love.graphics.getWidth()
	graphics.sch = (graphics.screenh/2) - (map.tilesize/2)
	graphics.scw = (graphics.screenw/2) - (map.tilesize/2)
	love.mouseupdate(dt)
	player.movement(dt)
end

--this is a debug to show path
function love.drawdebugpath()
	if table.getn(player.path) > 0 then
		for _,block in pairs(player.path) do
			--block[1] block[2]
			--print(dump(player.path[i]))
			local posx = ((block[1]-player.x+1)*map.tilesize)-map.tilesize + graphics.scw
			local posy = ((block[2]-player.y+1)*map.tilesize)-map.tilesize + graphics.sch
			love.graphics.setColor( 255, 0, 0 )
			love.graphics.rectangle( "line", posx,posy, map.tilesize, map.tilesize)
			love.graphics.setColor(255,255,255)
		end	
	end
end

--this draws the map within the limits of the screen
function love.rendermap(x,y)
	--find the limits of what to render
	local xlimit = math.floor(graphics.scw/map.tilesize)
	local ylimit = math.floor(graphics.sch/map.tilesize + 0.5) --fix weird issue (+ 0.5)
	--check and correct x
	local xlow = player.x-xlimit
	local xhigh = player.x+xlimit
	--xhigh = xhigh - 1 --remove this!!!!!!!!
	--xlow = xlow + 1 --remove this!!!!!!!
	if xlow < 1 then
		xlow = 1
	end
	if xhigh > map.blocksize then
		xhigh = map.blocksize
	end
	
	local ylow = player.y-ylimit
	local yhigh = player.y+ylimit
	--yhigh = yhigh - 1 --remove this !!!!!!!!!!!
	--ylow = ylow + 1 --remove this!!!!!
	if ylow < 1 then
		ylow = 1
	end
	if yhigh > map.blocksize then
		yhigh = map.blocksize
	end
	
	
	for yer = ylow,yhigh do
		for xer = xlow,xhigh do
			local posx = ((xer-x+1)*map.tilesize)-map.tilesize + graphics.scw
			local posy = ((yer-y+1)*map.tilesize)-map.tilesize + graphics.sch
			if map.loadedblock[yer][xer] == 0 then
				love.graphics.draw(graphics.cobble, posx,posy,0,map.tilesize/32,map.tilesize/32) 
			elseif map.loadedblock[yer][xer] == 1 then
				love.graphics.draw(graphics.brick, posx,posy,0,map.tilesize/32,map.tilesize/32) 
			end
		
		end
	end	
end

--generates map block in memory
function love.generateblock(dt)
	map.loadedblock = {}
	for y = 1,map.blocksize do
		table.insert(map.loadedblock, {})
		for x = 1,map.blocksize do
			local value = love.math.noise(x,y )
			
			if value > 0.4 then
				table.insert(map.loadedblock[y],0)
			else
				table.insert(map.loadedblock[y],1)
			end
		end
	end
	--print(dump(map.loadedblock))
end

--this draws the "crosshairs"
function love.drawcrosshairs()
	--love.graphics.setColor( 255, 0, 0 )
	--if player.aimx ~= 0 or player.aimy ~= 0 then
	--	love.graphics.rectangle( "line", graphics.scw+(map.tilesize*player.aimx), graphics.sch+(map.tilesize*player.aimy), map.tilesize, map.tilesize)
	--end
	--love.graphics.setColor( 255, 255, 255 )
	love.graphics.rectangle( "line", graphics.scw+(mousetilex*map.tilesize),graphics.sch+(mousetiley*map.tilesize), map.tilesize, map.tilesize)
	--[[
	if player.moveaim[1] ~= 0 and player.moveaim[2] ~= 0 then
		local posx = ((player.moveaim[1]-player.x+1)*map.tilesize)-map.tilesize + graphics.scw
		local posy = ((player.moveaim[2]-player.y+1)*map.tilesize)-map.tilesize + graphics.sch
		love.graphics.setColor( 255, 0, 0 )
		love.graphics.rectangle( "line", posx,posy, map.tilesize, map.tilesize)
		love.graphics.setColor(255,255,255)
	end
	]]--
end

dofile("controls.lua")
dofile("pathfind.lua")


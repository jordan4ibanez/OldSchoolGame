--handle blocks seemlessly somehow?? dump all map on screen into table?
debug = false

dofile("helpers.lua")

love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

math.randomseed(os.time())


paused = false

local survival = {}

--make time it's own thing
survival.health = math.random(70,100)
survival.hunger = math.random(70,100)
survival.thirst = math.random(50,100)
survival.fuel   = math.random(30,100)
survival.meat   = math.random(50,100)
survival.water  = math.random(50,100)
resource_tick   = 0

map = {}
map.blocksize = 500 --length and width (don't set above 350 for pathfinding speed)
map.loadedblock = {}
map.tilesize = 32

--player class
player = {}
player.x = 255--position
player.y = 247
player.xoffset = 0
player.yoffset = 0
player.aimx = 0--aim direction
player.aimy = 0
player.moveaim = {0,0} --the dir player wants to move
player.mcooldown = 0 --cool it down so the player doesn't spam pathfinding
player.path = {}
player.pathcooldown = 0
player.running  = false
player.sneaking = false
player.runbuffer = false
--speed of movement (higher is faster
player.runspeed  = 0.05
player.walkspeed = 0.025
player.sneakspeed = 0.01

--graphics class
graphics = {}
graphics.fps = 5
graphics.animtimer = 1/graphics.fps
--player gets custom class var (for now) this will be turned into animation class
graphics.playerframe = 0 --frame horizontally
graphics.playerframeset = 0 --frameset (vertically)
graphics.playermaxframes = 3 --counting from 0

--animate the player
function graphics.animateplayer(dt)
	--set speed based on if running
	if player.running == true then
		graphics.fps = 10
	else
		graphics.fps = 5
	end

	--set animation based on direction else idle
	if table.getn(player.path) > 0 then
		if player.x < player.path[1][1] then
			graphics.playerframeset = 1
		elseif player.x > player.path[1][1] then
			graphics.playerframeset = 2
		elseif player.y < player.path[1][2] then
			graphics.playerframeset = 3
		elseif player.y > player.path[1][2] then
			graphics.playerframeset = 4
		end
	else
		graphics.playerframeset = 0
	end
	if dt > 0.035 then
		return
	end
	-- angle = angle + 27.5 * dt
	graphics.animtimer = graphics.animtimer - dt
	if graphics.animtimer <= 0 then
		graphics.animtimer = 1 / graphics.fps
		graphics.playerframe = graphics.playerframe + 1
		if graphics.playerframe > graphics.playermaxframes then
			graphics.playerframe = 0
		end
		local xoffset = 32 * graphics.playerframe
		graphics.playertexture:setViewport(xoffset,graphics.playerframeset * 32, 32, 32)
	end
end

function love.load()
	--keep the multiplier odd to render out all possible tiles
	love.window.setMode( 0, 0, {resizable=true,fullscreen=false} )
	love.window.setTitle("New Rhode Island")
	love.graphics.setNewFont(20)

    graphics.cobble = love.graphics.newImage("tiles/cobble.png")
    graphics.brick = love.graphics.newImage("tiles/brick.png")
    --graphics.crosshair = love.graphics.newImage("crosshair.png")
    graphics.playeratlas = love.graphics.newImage("characters/playertile.png")
    graphics.WATCHDOG = love.graphics.newImage("characters/WATCHDOG.png")
	graphics.playertexture = love.graphics.newQuad(0,0,map.tilesize,map.tilesize,graphics.playeratlas:getDimensions())

    superbigfont = love.graphics.newFont("fonts/SFPixelate.ttf", 100)
    normalfont = love.graphics.newFont("fonts/SFPixelate.ttf", 24)
    love.graphics.setFont(normalfont)

	cursor = love.mouse.newCursor( "crosshair.png", 15, 15 )
	love.mouse.setCursor( cursor )

	footstep = love.audio.newSource("footstep.wav", "static" )
	footstep:setVolume(0.2)
	moveconfirm = love.audio.newSource("move.ogg", "static" )
	moveno = love.audio.newSource("moveno.mp3", "static" )
	watchdog = love.audio.newSource("WATCHDOG.wav", "stream" )
	watchdog:setVolume(0.2)

	bgmusic = love.audio.newSource("sounds/1.mp3", "stream" )

	bgmusic:setLooping(true)
	love.audio.play(bgmusic)

	love.generateblock(dt,1,1)
end

function love.draw(dt)
	if paused == true then
		love.drawpausemenu()
	else

		love.rendermap(player.x,player.y)
		love.drawdebugpath()
		love.graphics.draw(graphics.playeratlas,graphics.playertexture,graphics.scw,graphics.sch,0,map.tilesize/32,map.tilesize/32)
		--this is a debug to show the center of the screen
		--love.graphics.circle( "fill", graphics.screenw/2, graphics.screenh/2, 3 )
		love.drawcrosshairs()

		--debug info
		if debug == true then
			local lwidth,lheight = love.window.getMode()
			love.graphics.print("This is a proof of concept build.\nCONTROLS\nToggle Fullscreen:~\nQuit:Escape\nRestart Game:Left CTRL\nToggle Run:R", 0,lheight-140)
			love.graphics.print("Move Aim:"..player.moveaim[1]..","..player.moveaim[2],0,0)
			love.graphics.print("Mouse Tile:"..(player.x+mousetilex)..","..(player.y+mousetiley),0,20)
			love.graphics.print("Movement Selection Cooldown:"..player.mcooldown,0,40)
			love.graphics.print("Movement Cooldown:"..player.pathcooldown,0,60)
			love.graphics.print("Running:"..tostring(player.running),0,80)
			love.graphics.print("FPS:"..love.timer.getFPS( ),0,100)
			love.graphics.print("ZOOM:"..map.tilesize,0,120)
			love.graphics.print("OFFSETX:"..player.xoffset,0,140)
			love.graphics.print("OFFSETY:"..player.yoffset,0,160)
		end
	end
end

function love.update(dt)
	--update screen integers
	graphics.screenh = love.graphics.getHeight()
	graphics.screenw = love.graphics.getWidth()
	graphics.sch = (graphics.screenh/2) - (map.tilesize/2)
	graphics.scw = (graphics.screenw/2) - (map.tilesize/2)

	--do pause or don't
	if paused == true then

	else
		player.movement(dt)
		love.mouseupdate(dt)
		graphics.animateplayer(dt)
	end
end

--this draws the pausemenu
function love.drawpausemenu()
	local wx,wy = graphics.WATCHDOG:getDimensions()
	love.graphics.draw(graphics.WATCHDOG,0,graphics.screenh-wy)
	love.graphics.setFont(superbigfont)
	love.graphics.print("W.A.T.C.H.D.O.G.",wx+10,graphics.screenh-80)
	love.graphics.setFont(normalfont)
	love.graphics.print("HEALTH:"..survival.health,0,10)
end

--this is a debug to show path
function love.drawdebugpath()

	if table.getn(player.path) > 0 then
		for h,block in pairs(player.path) do
			--block[1] block[2]
			--print(dump(player.path[i]))
			local posx = ((block[1]-player.x+1)*map.tilesize)-map.tilesize + graphics.scw + (player.xoffset*map.tilesize)
			local posy = ((block[2]-player.y+1)*map.tilesize)-map.tilesize + graphics.sch + (player.yoffset*map.tilesize)
			local filler = false
			if h == table.getn(player.path) then
				filler = true
			end
			if debug == true then
				love.graphics.setColor( 255, 0, 0 )
				if filler == true then
					love.graphics.rectangle( "fill", posx,posy, map.tilesize, map.tilesize)
				else
					love.graphics.rectangle( "line", posx,posy, map.tilesize, map.tilesize)
				end
				love.graphics.setColor(255,255,255)
			elseif debug == false then
				love.graphics.setColor( 200, 200, 200)
				if filler == true then
					love.graphics.rectangle( "fill", posx,posy, map.tilesize, map.tilesize)
				else
					love.graphics.rectangle( "line", posx,posy, map.tilesize, map.tilesize)
				end
				love.graphics.setColor(255,255,255)
			end
		end
	end
end

--this draws the map within the limits of the screen
function love.rendermap(x,y)
	--find the limits of what to render
	local xlimit = math.floor(graphics.scw/map.tilesize)+2
	local ylimit = math.floor(graphics.sch/map.tilesize)+2 --fix weird issue (+ 0.5)
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
			local posx = ((xer-x+1)*map.tilesize)-map.tilesize + graphics.scw + (player.xoffset*map.tilesize)
			local posy = ((yer-y+1)*map.tilesize)-map.tilesize + graphics.sch + (player.yoffset*map.tilesize)
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
	local x = graphics.scw+(mousetilex*map.tilesize) + (player.xoffset*map.tilesize)
	local y = graphics.sch+(mousetiley*map.tilesize) + (player.yoffset*map.tilesize)
	love.graphics.rectangle( "line",x,y, map.tilesize, map.tilesize)
	--love.graphics.print(mousetilex.."|"..mousetiley,mousex,mousey)

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
dofile("gui.lua")




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
map.blocksize = 30 --length and width
map.loadedblock = {}
map.tilesize = 32

--player class
player = {}
player.x = 5--position
player.y = 10
player.aimx = 0--aim direction
player.aimy = 0

--graphics class
graphics = {}



function time_tick(dt)

end

function love.load()
	--keep the multiplier odd to render out all possible tiles
	love.window.setMode( 0, 0, {resizable=true,fullscreen=false} )
	
	love.graphics.setNewFont(20)

    graphics.cobble = love.graphics.newImage("cobble_blood_1_new.png")
    graphics.brick = love.graphics.newImage("brick_brown_0.png")
    graphics.player = love.graphics.newImage("player.png")

	footstep = love.audio.newSource("footstep.wav", "static" )

	love.generateblock(dt,1,1)
end

function love.draw(dt)
	love.rendermap(player.x,player.y)
	love.graphics.draw(graphics.player,graphics.scw,graphics.sch)
	--this is a debug to show the center of the screen
	--love.graphics.circle( "fill", graphics.screenw/2, graphics.screenh/2, 3 )
	love.drawcrosshairs()
	
	--debug info
	local lwidth,lheight = love.window.getMode()
	love.graphics.print("This is a proof of concept build.\nCONTROLS\nToggle Fullscreen:~\nQuit:Escape\nRestart Game:Left CTRL", 0,lheight-120)
end

function love.update(dt)
	--update screen integers 
	graphics.screenh = love.graphics.getHeight()
	graphics.screenw = love.graphics.getWidth()
	graphics.sch = (graphics.screenh/2) - (map.tilesize/2)
	graphics.scw = (graphics.screenw/2) - (map.tilesize/2)
end

--this draws the mapblock
function love.rendermap(x,y)
	for yer = 1,map.blocksize do
		for xer = 1,map.blocksize do
			local posx = ((xer-x+1)*map.tilesize)-map.tilesize + graphics.scw
			local posy = ((yer-y+1)*map.tilesize)-map.tilesize + graphics.sch
			if map.loadedblock[tostring(yer)][tostring(xer)] == 0 then
				love.graphics.draw(graphics.cobble, posx,posy) 
			elseif map.loadedblock[tostring(yer)][tostring(xer)] == 1 then
				love.graphics.draw(graphics.brick, posx,posy) 
			end
		
		end
	end
	
end

--generates map block in memory
function love.generateblock(dt,x,y)
	map.loadedblock = {}
	for yer = 1,map.blocksize do
		map.loadedblock[tostring(yer)] = {}
		for xer = 1,map.blocksize do
			--map.loadedblock[yer][xer] =
			local value = love.math.noise(xer,yer )
			if value > 0.4 then
				map.loadedblock[tostring(yer)][tostring(xer)] = 1
			else
				map.loadedblock[tostring(yer)][tostring(xer)] = 0
			end
		end
	end
end

--this draws the "crosshairs"
function love.drawcrosshairs()
	love.graphics.setColor( 255, 0, 0 )
	if player.aimx ~= 0 or player.aimy ~= 0 then
		love.graphics.rectangle( "line", graphics.scw+(map.tilesize*player.aimx), graphics.sch+(map.tilesize*player.aimy), map.tilesize, map.tilesize)
	end
	love.graphics.setColor( 255, 255, 255 )
end


--handle keyboard input
function love.keypressed(key, unicode)
	--use this to call if colliding
	local lastposx = player.x
	local lastposy = player.y
    if key == "up" then
		if player.y > 1 then
			player.y = player.y - 1
		end
	end
	if key == "down" then
		if player.y < map.blocksize then
			player.y = player.y + 1
		end
	end
    
    if key == "left" then
		if player.x > 1 then
			player.x = player.x - 1
		end
	end
	if key == "right" then
		if player.x < map.blocksize then
			player.x = player.x + 1
		end
	end
	
	--simple collision correction
	if map.loadedblock[tostring(player.y)][tostring(player.x)] ~= 0 then
		player.x = lastposx
		player.y = lastposy
	elseif player.x ~= lastposx or player.y ~= lastposy then --play sound
		love.audio.stop(footstep)
		love.audio.play(footstep)
	end


	--aiming
	if key == "w" or key == "s" then
		player.aimx = 0
	end
	if key == "a" or key == "d" then
		player.aimy = 0
	end
	if key == "w" then
		--return if aimed, else aim
		if player.aimy < 0 then
			player.aimy = 0
		else
			player.aimy = -1
		end
	end
	if key == "s" then
		if player.aimy > 0 then
			player.aimy = 0
		else
			player.aimy = 1
		end
	end
	if key == "a" then
		if player.aimx < 0 then
			player.aimx = 0
		else
			player.aimx = -1
		end
	end
	if key == "d" then
		if player.aimx > 0 then
			player.aimx = 0
		else
			player.aimx = 1
		end
	end

	if key == "space" then
		love.breakblock()
	end
	
	--end game
	if key == 'escape' then
		love.event.quit()
	end
	if key == "lctrl" then
		print("Game has been reset")
		love.event.quit("restart")
	end
   --resize window
	if key == "`" then
		local width, height, flags = love.window.getMode( )
		love.window.setMode( width, height, {fullscreen=not flags.fullscreen,resizable=true})
	end 
end


function love.breakblock()
	if player.aimx ~= 0 or player.aimy ~= 0 then
		local y = player.y+player.aimy
		local x = player.x+player.aimx
		
		if x > 0 and x <= map.blocksize and y > 0 and y <= map.blocksize then
			map.loadedblock[tostring(y)][tostring(x)] = 0
		end
	end
end

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
	love.window.setTitle("Old School Game")
	
	love.graphics.setNewFont(20)

    graphics.cobble = love.graphics.newImage("cobble_blood_1_new.png")
    graphics.brick = love.graphics.newImage("brick_brown_0.png")
    graphics.player = love.graphics.newImage("player.png")
    --graphics.crosshair = love.graphics.newImage("crosshair.png")

	cursor = love.mouse.newCursor( "crosshair.png", 15, 15 )


	love.mouse.setCursor( cursor )
	
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
	love.mouseupdate(dt)
end

function love.mouseupdate(dt)
	mousex, mousey = love.mouse.getPosition( )
	
	if mousex and mousey then
		mousetilex = math.floor((mousex-graphics.scw)/map.tilesize)
		mousetiley = math.floor((mousey-graphics.sch)/map.tilesize)
	else
		mousetilex, mousetiley = 0,0
	end

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
	--love.graphics.setColor( 255, 0, 0 )
	--if player.aimx ~= 0 or player.aimy ~= 0 then
	--	love.graphics.rectangle( "line", graphics.scw+(map.tilesize*player.aimx), graphics.sch+(map.tilesize*player.aimy), map.tilesize, map.tilesize)
	--end
	--love.graphics.setColor( 255, 255, 255 )
	print(mousetilex, mousetiley)
	love.graphics.rectangle( "line", graphics.scw+(mousetilex*map.tilesize),graphics.sch+(mousetiley*map.tilesize), map.tilesize, map.tilesize)
end

dofile("controls.lua")


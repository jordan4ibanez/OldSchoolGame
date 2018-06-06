


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
player.aiml = 0--aim direction
player.aimr = 0

--graphics class
graphics = {}



function time_tick(dt)

end

function love.load()
	--keep the multiplier odd to render out all possible tiles
	love.window.setMode( map.tilesize*21, map.tilesize*21 )
	
	love.graphics.setNewFont(20)

    graphics.cobble = love.graphics.newImage("cobble_blood_1_new.png")
    graphics.brick = love.graphics.newImage("brick_brown_0.png")
    graphics.player = love.graphics.newImage("player.png")

	love.generateblock(dt,1,1)
end

function love.draw(dt)
	love.rendermap(player.x,player.y)
	love.graphics.draw(graphics.player,graphics.scw,graphics.sch)
	--this is a debug to show the center of the screen
	--love.graphics.circle( "fill", graphics.screenw/2, graphics.screenh/2, 3 )
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
				love.graphics.draw(graphics.brick, posx,posy) 
			elseif map.loadedblock[tostring(yer)][tostring(xer)] == 1 then
				love.graphics.draw(graphics.cobble, posx,posy) 
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



--handle keyboard input
function love.keypressed(key, unicode)
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

	if key == "w" then
	end
	if key == "s" then
	end
	if key == "a" then
	end
	if key == "d" then
	end

end
 

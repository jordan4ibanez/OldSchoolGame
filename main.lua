
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
map.blocksize = 11 --length and width
map.loadedblock = {}
map.tilesize = 32

player = {}
player.x = 1
player.y = 1

graphics = {}

function time_tick(dt)

end

function love.load()
	love.graphics.setNewFont(20)
	
 
    --if success then
        -- If the game is fused and it's located in C:\Program Files\mycoolgame\,
        -- then we can now load files from that path.
    graphics.cobble = love.graphics.newImage("cobble_blood_1_new.png")
    graphics.brick = love.graphics.newImage("brick_brown_0.png")
    graphics.player = love.graphics.newImage("player.png")
 --   end
	
end

function love.draw(dt)
	--love.graphics.print(tostring(math.maxinteger), 40,50)
	--love.graphics.print(tostring(love.math.noise( 100/map.blocksize,100/map.blocksize)),10,60)
	love.generateblock(dt,1,1)
	love.graphics.draw(graphics.player, (player.x*map.tilesize)-map.tilesize, (player.y*map.tilesize)-map.tilesize)
end

function love.update(dt)

end

--generates map block in memory
function love.generateblock(dt,x,y)
	map.loadedblock = {}
	
	
	for yer = 1,map.blocksize do
		print("test")
		map.loadedblock[tostring(yer)] = {}
		for xer = 1,map.blocksize do
			--map.loadedblock[yer][xer] =
			local value = love.math.noise(xer,yer )
			if value > 0.4 then
				--love.graphics.setColor( 255, 255, 255 )
				map.loadedblock[tostring(yer)][tostring(xer)]
				--love.graphics.draw(graphics.cobble, (xer*map.tilesize)-map.tilesize, (yer*map.tilesize)-map.tilesize)
				--love.graphics.print("O",(xer*17),(yer*17))
			else
				--love.graphics.setColor( 255, 0, 0 )
				love.graphics.draw(graphics.brick, (xer*map.tilesize)-map.tilesize, (yer*map.tilesize)-map.tilesize)
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
    --for a,b in pairs(activities) do
		
		--if b[1] == key then
			--keyer = a
		--end
    --end
end
 

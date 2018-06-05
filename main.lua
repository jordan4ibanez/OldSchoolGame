
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
map.blocksize = 200 --length and width
map.loadedblock = {}

function time_tick(dt)

end

function love.load()
	love.graphics.setNewFont(20)
	
 
    --if success then
        -- If the game is fused and it's located in C:\Program Files\mycoolgame\,
        -- then we can now load files from that path.
    cobble = love.graphics.newImage("cobble_blood_1_new.png")
    brick = love.graphics.newImage("brick_brown_0.png")
 --   end
	
end

function love.draw(dt)
	--love.graphics.print(tostring(math.maxinteger), 40,50)
	--love.graphics.print(tostring(love.math.noise( 100/map.blocksize,100/map.blocksize)),10,60)
	love.generateblock(dt,1,1)
end

function love.update(dt)

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
				--love.graphics.setColor( 255, 255, 255 )
				love.graphics.draw(cobble, xer*32, yer*32)
				--love.graphics.print("O",(xer*17),(yer*17))
			else
				--love.graphics.setColor( 255, 0, 0 )
				love.graphics.draw(brick, xer*32, yer*32)
			end
		end
	end
end


keyer = nil
--handle keyboard input
function love.keypressed(key, unicode)
    -- ignore non-printable characters (see http://www.ascii-code.com/)
    for a,b in pairs(activities) do
		
		if b[1] == key then
			keyer = a
		end
    end
end
 

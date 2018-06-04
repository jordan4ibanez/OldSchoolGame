
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
map.blocksize = 200
map.loadedblock = {}

function time_tick(dt)

end

function love.load()
	love.graphics.setNewFont(20)
end

function love.draw(dt)
	--love.graphics.print(tostring(math.maxinteger), 40,50)
	love.graphics.print(tostring(love.math.noise( 100/map.blocksize,100/map.blocksize)),10,60)

end

function love.update(dt)

end

--generates map block in memory
function love.generateblock(dt,x,y)
	map.loadedblock = {}
	for xer = 1,map.blocksize do
		love.graphics.print(tostring(xer),10,50)
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
 

-- Library setup
-- Calls the grid class
local Grid = require ("jumper.grid")
-- Calls the pathfinder class
local Pathfinder = require ("jumper.pathfinder")




function findpath(start,ending)
	
	-- Value for walkable tiles
	local walkable = 0
	
	--artificially limit the distance to preserve performance
	local tempmap = {}
	local limiter = 50
	
	--add in exception to not crash when out of range (could be used with anti-perk?)
	if math.abs(start[1]-ending[1]) > limiter or math.abs(start[2]-ending[2]) > limiter then
		return(false)
	end
	
	--check and correct x
	local xlow = player.x-limiter
	local xhigh = player.x+limiter
	--xhigh = xhigh - 1 --remove this!!!!!!!!
	--xlow = xlow + 1 --remove this!!!!!!!
	if xlow < 1 then
		xlow = 1
	end
	if xhigh > map.blocksize then
		xhigh = map.blocksize
	end
	
	local ylow = player.y-limiter
	local yhigh = player.y+limiter
	--yhigh = yhigh - 1 --remove this !!!!!!!!!!!
	--ylow = ylow + 1 --remove this!!!!!
	if ylow < 1 then
		ylow = 1
	end
	if yhigh > map.blocksize then
		yhigh = map.blocksize
	end
	
	for y = ylow,yhigh do
		table.insert(tempmap, {})
		for x = xlow,xhigh do
			table.insert(tempmap[y],map.loadedblock[y][x])
		end
	end
	

	-- Creates a grid object
	local grid = Grid(tempmap)

	-- Creates a pathfinder object using Jump Point Search algorithm
	local myFinder = Pathfinder(grid, 'ASTAR', 0)

	-- Define start and goal locations coordinates
	local startx, starty = start[1],start[2]
	local endx, endy = ending[1],ending[2]

	-- Calculates the path, and its length
	local nClock = os.clock()
	local path = myFinder:getPath(startx, starty, endx, endy)

	-- Pretty-printing the results
	if path then
		--print(('Path found! Length: %.2f'):format(path:getLength()))
		--clear path data
		player.path = {}
		if player.pathcooldown == 0 then
			if player.running == true then
				player.pathcooldown = player.runspeed
			else
				player.pathcooldown = player.walkspeed
			end
		end
		for node, count in path:nodes() do
		  --print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
		  table.insert(player.path, {node:getX(), node:getY()})
		end
		--remove the first step because it's the player's position
		table.remove(player.path,1)
		--print(("Elapsed time is: " .. os.clock()-nClock))
		return(true)
	else
		--print("no path found")
		return(false)
	end
end

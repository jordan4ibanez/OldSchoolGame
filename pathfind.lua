

-- Library setup
-- Calls the grid class
local Grid = require ("jumper.grid")
-- Calls the pathfinder class
local Pathfinder = require ("jumper.pathfinder")




function findpath(start,ending)
	--clear path data
	player.path = {}
	player.pathcooldown = 0
	
	-- Value for walkable tiles
	local walkable = 0

	-- Creates a grid object
	local grid = Grid(map.loadedblock)

	-- Creates a pathfinder object using Jump Point Search algorithm
	local myFinder = Pathfinder(grid, 'DIJKSTRA', walkable)

	-- Define start and goal locations coordinates
	local startx, starty = start[1],start[2]
	local endx, endy = ending[1],ending[2]

	-- Calculates the path, and its length
	local path = myFinder:getPath(startx, starty, endx, endy)

	-- Pretty-printing the results
	if path then
	  print(('Path found! Length: %.2f'):format(path:getLength()))
		for node, count in path:nodes() do
		  print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
		  table.insert(player.path, {node:getX(), node:getY()})
		end
		return(true)
	else
		print("no path found")
		return(false)
	end
end

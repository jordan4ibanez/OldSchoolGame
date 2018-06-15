-- Library setup
-- Calls the grid class
local Grid = require ("jumper.grid")
-- Calls the pathfinder class
local Pathfinder = require ("jumper.pathfinder")



--this finds a path on the loaded map
function findpath(start,ending,limiter)
	--add in exception to not crash when out of range (could be used with anti-perk?)
	if math.abs(start[1]-ending[1]) > limiter or math.abs(start[2]-ending[2]) > limiter then
		print("out of range")
		return(false)
	end
	-- Value for walkable tiles
	local walkable = 0
	
	--artificially limit the distance to preserve performance
	local tempmap = {}
	
	local fakey = 1
	local center = 0
	for y = start[2]-limiter,limiter+start[2] do
		table.insert(tempmap, {})
		local fakex = 1
		--can use this for x and y because box
		--this is center of pathfinding
		if center == 0 and fakey > limiter then
			center = fakey
		end
		for x = start[1]-limiter,limiter+start[1] do
			if not map.loadedblock[y] or not map.loadedblock[y][x] then
				--print("fail "..x.." "..y)
				table.insert(tempmap[fakey], -1)
			else
				table.insert(tempmap[fakey], map.loadedblock[y][x])
			end
			fakex = fakex + 1
		end
		fakey = fakey + 1
	end
	
	--find goal on virtual grid
	local goal = {(ending[1]-start[1])+center,(ending[2]-start[2])+center}

	-- Creates a grid object
	--local grid = Grid(map.loadedblock)
	local grid = Grid(tempmap)

	-- Creates a pathfinder object using Jump Point Search algorithm
	local myFinder = Pathfinder(grid, 'ASTAR', 0)

	-- Define start and goal locations coordinates
	local startx, starty = center,center
	local endx, endy = goal[1],goal[2]

	-- Calculates the path, and its length
	--local nClock = os.clock()
	local path = myFinder:getPath(startx, starty, endx, endy)

	--find top left corner of bounding box
	local realstartx = start[1]-center
	local realstarty = start[2]-center

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
			print(('MODIFIED Step: %d - x: %d - y: %d'):format(count, node:getX()+realstartx, node:getY()+realstarty))
			
			table.insert(player.path, {node:getX()+realstartx, node:getY()+realstarty})
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

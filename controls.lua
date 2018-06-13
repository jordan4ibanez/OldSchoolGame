--handle keyboard input
function love.keypressed(key, unicode)
	if key == "space" then
		--bring up WATCHDOG with this
		love.audio.stop(watchdog)
		love.audio.play(watchdog)
	end
	
	--toggle running
	if key == "r" then
		player.running = not player.running
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


function love.breakblock(x,y)	
	if x > 0 and x <= map.blocksize and y > 0 and y <= map.blocksize then
		map.loadedblock[y][x] = 0
	end
end

function love.mouseupdate(dt)
	mousex, mousey = love.mouse.getPosition( )
	local down1 = love.mouse.isDown(1)
	
	--get which tile the player is on
	if mousex and mousey then
		mousetilex = math.floor((mousex-graphics.scw)/map.tilesize)
		mousetiley = math.floor((mousey-graphics.sch)/map.tilesize)
	else
		mousetilex, mousetiley = 0,0
	end
	
	--the movement aim tile
	local oldmove = player.moveaim
	if down1 and player.mcooldown == 0 then
		local newx = player.x+mousetilex
		local newy = player.y+mousetiley
		if newx > 0 and newx <= map.blocksize and newy > 0 and newy <= map.blocksize then
			if map.loadedblock[newy][newx] == 0 then
				player.moveaim = {newx,newy}
				player.mcooldown = 0.5
				--love.breakblock(player.moveaim[1],player.moveaim[2])
			end
		end
	end
	if player.mcooldown > 0 then
		player.mcooldown = player.mcooldown - dt
		if player.mcooldown < 0 then
			player.mcooldown = 0
		end
	end
	if oldmove[1] ~= player.moveaim[1] or oldmove[2] ~= player.moveaim[2] then
		local test = findpath({player.x,player.y},player.moveaim)
		--play sounds for path success and fail
		if test == true then
			love.audio.stop(moveconfirm)
			love.audio.play(moveconfirm)
		else
			love.audio.stop(moveno)
			love.audio.play(moveno)
		end
	end
end


--move the character around
function player.movement(dt)
	if player.pathcooldown > 0 then
		player.pathcooldown = player.pathcooldown - dt
		if player.pathcooldown < 0 then
			player.pathcooldown = 0
		end
	end
	if player.pathcooldown == 0 then
		if table.getn(player.path) > 0 then
			
			--make it so player's walk cycle doesn't get broken
			if player.pathcooldown == 0 then
				if player.running == true then
					player.pathcooldown = player.runspeed
				else
					player.pathcooldown = player.walkspeed
				end
			end
			
			--do this so sounds don't conflict
			if player.x ~= player.path[1][1] or player.y ~= player.path[1][2] then
				player.x = player.path[1][1]
				player.y = player.path[1][2]
				love.audio.stop(footstep)
				love.audio.play(footstep)
			end
			table.remove(player.path,1)
		end
	end
end

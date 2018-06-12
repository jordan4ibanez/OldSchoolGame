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

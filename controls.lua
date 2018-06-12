--handle keyboard input
function love.keypressed(key, unicode)
	--use this to call if colliding
	local lastposx = player.x
	local lastposy = player.y
	
    if key == "w" then
		if player.y > 1 then
			player.y = player.y - 1
		end
	end
	if key == "s" then
		if player.y < map.blocksize then
			player.y = player.y + 1
		end
	end
    
    if key == "a" then
		if player.x > 1 then
			player.x = player.x - 1
		end
	end
	if key == "d" then
		if player.x < map.blocksize then
			player.x = player.x + 1
		end
	end
	
	--simple collision correction
	--if map.loadedblock[player.y][player.x] ~= 0 then
	--	player.x = lastposx
	--	player.y = lastposy
	--elseif player.x ~= lastposx or player.y ~= lastposy then --play sound
	--	love.audio.stop(footstep)
	--	love.audio.play(footstep)
	--end
	


	if key == "space" then
		
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

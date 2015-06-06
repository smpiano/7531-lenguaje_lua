-- Demo para la presentacion de la materia 75.31 "Teoria del Lenguaje", lenguaje LUA
-- FIUBA, 08/06/2015

function love.load()

	-- new table for game data
	game = {} 
	game.state = "mainMenu"
	game.score = 0
	game.highScores = {[1]={name="AAA", score=0, date=os.date("%c")}, [2]={name="BBB", score=0, date=os.date("%c")}, [3]={name="CCC", score=0, date=os.date("%c")}, [4]={name="DDD", score=0, date=os.date("%c")}, [5]={name="EEE", score=0, date=os.date("%c")}}
	
	-- load external graphics
	bgGame = love.graphics.newImage("bg.png")
	
	-- loadSFX
	startSound = love.audio.newSource("sounds/start.wav", "static")
	shotSound = love.audio.newSource("sounds/laser.wav", "static")
	explosionSound = love.audio.newSource("sounds/explosion.wav", "static")
	endSound = love.audio.newSource("sounds/end.wav", "static")
	
	-- loadMusic
	menuMusic = love.audio.newSource("music/menuMusic.wav", "static")
	menuMusic:setLooping(true)
	gameMusic = love.audio.newSource("music/gameMusic.wav", "static")
	gameMusic:setLooping(true)

	menuMusic:play()	
	initGame()
end

function love.update(dt)

	if game.state == "mainMenu" then
		-- main menu

	else

		if game.state == "playGame" then
			-- game action
			-- keyboard actions for player
			if ((love.keyboard.isDown("up")) and (hero.y > 0)) then
				hero.y = hero.y - hero.speed*dt
			else
				if ((love.keyboard.isDown("down")) and (hero.y < (600-hero.height))) then
					hero.y = hero.y + hero.speed*dt
				end
			end

			local remEnemy = {}
			local remShot = {}

			-- update the shots
			for i,v in ipairs(hero.shots) do

				-- move them right right right
				v.x = v.x + dt * 100

				-- mark shots that are not visible for removal
				if v.x > 800 then
					table.insert(remShot, i)
				end
				
				-- check for collision with enemies
				for ii,vv in ipairs(enemies) do
					if CheckCollision(v.x,v.y,5,2,vv.x,vv.y,vv.width,vv.height) then

						-- mark that enemy for removal
						table.insert(remEnemy, ii)
						-- mark the shot to be removed
						table.insert(remShot, i)
							
						local sfx = explosionSound:clone()
						sfx:play()
						
						game.score = game.score + 100;
					end
				end
			end

			-- remove the marked enemies
			for i,v in ipairs(remEnemy) do
				table.remove(enemies, v)
			end

			for i,v in ipairs(remShot) do
				table.remove(hero.shots, v)
			end
				
			-- detect the farther position
			local farthest = 0
			for i,v in ipairs(enemies) do
				if (v.x > farthest) then
					farthest = v.x
				end
			end
				
			--generate more enemies
			if farthest < 700 then
				local newSize = math.random(2,5)
				local isCrazy = true
				if (math.random(0,1)==0) then
					isCrazy = false
				end
				for j=0,newSize do
					generateEnemy(newSize, j, isCrazy, not phase)
				end
			end
			local amplitud = 10
			local angular = (2*math.pi / 20) --2*PI / T

			-- update those evil enemies
			for i,v in ipairs(enemies) do
				-- let them fall down slowly
				--v.x = v.x - dt * 25
				v.x = v.x - dt * 30
				if (v.isCrazy) then
					--v.y = v.y - (amplitud * math.sin( angular * math.abs(v.x-800)))
					if v.phase == false then
						v.y = v.y - (amplitud * math.sin( angular * math.abs(v.x-800)))
						phase = false
					else 
						v.y = v.y - (amplitud * math.cos( angular * math.abs(v.x-800)))
						phase = true
					end
				end

				-- check for collision with left border
				if v.x < 10 then
					-- you lose a life!
					table.remove(enemies, i)
					hero.livesLeft = hero.livesLeft - 1
					local sfx = endSound:clone()
					sfx:play()
					
					if hero.livesLeft < 0 then
						game.state = "gameOver"
					end
				end
			end
				
			if game.state == "gameOver" then
				-- you lose the game!
				table.insert(game.highScores, {name="FFF", score=game.score, date=os.date("%c")})
				table.sort(game.highScores, compareScoresGt)
				gameMusic:stop()
				menuMusic:play()
			end
		else
			-- game over!
		end
	end
end

function love.draw()

	if game.state == "mainMenu" then
		-- main menu
		love.graphics.setBackgroundColor(0, 0, 0)
		love.graphics.print("Bienvenidos! Presione SPACE para jugar...", 350, 300)
	else 
		if game.state == "playGame" then
			-- game action
			love.graphics.reset()
			-- let's draw a background
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(bgGame)

			-- let's draw some ground
			love.graphics.setColor(0,255,0,255)
			love.graphics.rectangle("fill", 0, 0, 10, 600)
	
			-- let's draw our hero
			love.graphics.setColor(255,255,0,255)
			love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)

			-- let's draw our heros shots
			love.graphics.setColor(255,255,255,255)
			for i,v in ipairs(hero.shots) do
				love.graphics.rectangle("fill", v.x, v.y, 5, 2)
			end

			-- let's draw our enemies
			love.graphics.setColor(0,255,255,255)
			for i,v in ipairs(enemies) do
				love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
			end
			
			-- status messages at bottom of screen
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Tu puntaje es: " .. game.score .. ".", 600, 550)
			love.graphics.print("Te quedan " .. hero.livesLeft .. " vidas:", 50, 550)
			for i=0,hero.livesLeft-1 do
				love.graphics.setColor(255,255,0,255)
				love.graphics.rectangle("fill", 175 + i*(hero.width+10), 542, hero.width, hero.height)
			end	
		else
			-- game over!
			love.graphics.reset()
			love.graphics.setBackgroundColor(0, 0, 0)
			love.graphics.print("Fin.", 400, 180)
			love.graphics.print("Perdiste el juego :(", 400, 200)
			love.graphics.print("Presioná SPACE para jugar de nuevo o ESC para salir!", 400, 220)
			love.graphics.print("Tu puntaje es: " .. game.score .. ".", 400, 240)
			love.graphics.print("Tabla de Puntajes", 400, 300)
			for i=1,5 do
				love.graphics.print(game.highScores[i].name, 400, 320 + 20*i)
				love.graphics.print(game.highScores[i].score, 440, 320 + 20*i)
				love.graphics.print(game.highScores[i].date, 480, 320 + 20*i)
			end
		end
	end	
end

function love.keyreleased(key)

	if key == "escape" then
		love.event.quit()
	end
	
	if game.state == "mainMenu" then
		-- main menu
		if (key == " ") then
			game.state = "playGame"
			menuMusic:stop()
			startSound:play()
			gameMusic:play()
		end
	else
		if game.state == "playGame" then
			-- game action

			if (key == " ") then
				shoot()
			end
		else
			-- game over!
			if (key == " ") then
				game.state = "playGame"
				hero = nil
				enemies = nil
				menuMusic:stop()
				startSound:play()
				gameMusic:play()
				initGame()
			end
		end
	end
end

function initGame()

	game.score = 0

	hero = {} -- new table for the hero
	enemies = {}

	hero.x = 10 -- x,y coordinates of the hero
	hero.y = 300
	hero.width = 15
	hero.height = 30
	hero.speed = 150
	hero.livesLeft = 3
	hero.shots = {} -- holds our fired shots

	local size = 8
	for i=0,size do
		generateEnemy(size, i, false, true)
	end	
	phase = true
end

function generateEnemy(size, i, crazy, ph)
	enemy = {}
	enemy.width = 20
	enemy.height = 40
	local aux = 600/math.pow(2,size+1)
	local beforeAux = 600/(size+1)
	enemy.y =  aux + beforeAux * i
	enemy.x = enemy.height + 800
	enemy.isCrazy = crazy
	enemy.phase = ph
	table.insert(enemies, enemy)
end

function shoot()
	local shot = {}
	shot.x = hero.x + hero.width
	shot.y = hero.y + hero.height/2
	local sfx = shotSound:clone()
	sfx:play()
	
	table.insert(hero.shots, shot)
end

-- Collision detection function.
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end

function compareScoresGt(w1,w2)
	if w1.score > w2.score then
		return true
	end
end

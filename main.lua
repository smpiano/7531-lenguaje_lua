-- Demo para la presentacion de la materia 75.31 "Teoria del Lenguaje", lenguaje LUA - GRUPO 3
-- FIUBA, 08/06/2015

function love.load()

	math.randomseed(os.time())

	-- new table for game data
	game = {} 
	game.state = "mainMenu"
	game.playerName = ""
	game.playerNameLocked = false
	game.score = 0
	game.scoreDate = ""
	game.isHighScore = false
	game.highScores = {[1]={name="CPU", score=500, date=os.date("%c")}, [2]={name="CPU", score=400, date=os.date("%c")}, [3]={name="CPU", score=300, date=os.date("%c")}, [4]={name="CPU", score=200, date=os.date("%c")}, [5]={name="CPU", score=100, date=os.date("%c")}}
	
	-- load external graphics
	bgGame = love.graphics.newImage("images/bgGame.png")
	logoFIUBA = love.graphics.newImage("images/fiuba.png")
	
	downArrow = love.graphics.newImage("images/downArrow.png")
	upArrow = love.graphics.newImage("images/upArrow.png")
	spaceKey = love.graphics.newImage("images/spaceKey.png")
	escKey = love.graphics.newImage("images/escKey.png")
	
	logoLUA = love.graphics.newImage("images/logoLUA.png")
	logoLOVE = love.graphics.newImage("images/logoLOVE.png")
	
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
	
	-- loadFont
	oldFont = love.graphics.newFont("fonts/PressStart2P.ttf", 16)
	oldFontSmall = love.graphics.newFont("fonts/PressStart2P.ttf", 12)
	oldFontTitle = love.graphics.newFont("fonts/PressStart2P.ttf", 30)

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
			if ((love.keyboard.isDown("up")) and (player.y > 0)) then
				player.y = player.y - player.speed*dt
			else
				if ((love.keyboard.isDown("down")) and (player.y < (550-player.height))) then
					player.y = player.y + player.speed*dt
				end
			end

			local remEnemy = {}
			local remShot = {}

			-- update the shots
			for i,v in ipairs(player.shots) do

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
				table.remove(player.shots, v)
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
				v.x = v.x - dt * 30
				if v.isCrazy then
					if v.phase == false then
						v.y = v.y - (amplitud * math.sin( angular * math.abs(v.x-800)))
						phase = false
					else 
						v.y = v.y - (amplitud * math.cos( angular * math.abs(v.x-800)))
						phase = true
					end
				end

				-- check for collision with left border or player
				if ((v.x < 5) or (CheckCollision(v.x,v.y,v.width,v.height,player.x,player.y,player.width,player.height) == true)) then
					-- you lose a life!
					table.remove(enemies, i)
					player.livesLeft = player.livesLeft - 1
					local sfx = endSound:clone()
					sfx:play()
					
					if player.livesLeft < 0 then
						game.state = "gameOver"
					end
				end
			end
				
			if game.state == "gameOver" then
				-- you lose the game!
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
		love.graphics.setFont(oldFontTitle)
		love.graphics.setColor(255,0,0,255)
		love.graphics.print("Lenguajes atacan!", 150, 70)
		love.graphics.setFont(oldFont)
		love.graphics.print("Rescatando a LUA", 280, 110)
		love.graphics.setFont(oldFontSmall)
		love.graphics.setColor(0,255,0,255)
		love.graphics.print("Demo lenguaje LUA, GRUPO 3", 170, 200)
		love.graphics.print("75.31 Teoria de Lenguajes", 170, 220)
		love.graphics.print("FIUBA - 08/06/2015", 170, 240)
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(logoFIUBA, 510, 165)

		love.graphics.print("Modo de juego:", 170, 330)
		love.graphics.draw(upArrow, 170, 350)
		love.graphics.draw(downArrow, 170, 400)
		love.graphics.print("Movimiento arriba", 230, 370)
		love.graphics.print("Movimiento abajo", 230, 420)

		love.graphics.draw(spaceKey, 490, 350)
		love.graphics.print("Disparo", 550, 370)
		love.graphics.draw(escKey, 490, 400)
		love.graphics.print("Salir", 550, 420)

		love.graphics.setColor(255,255,0,255)
		love.graphics.setFont(oldFont)
		love.graphics.print("Presiona 'SPACE' para jugar...", 170, 520)
	else 
		if game.state == "playGame" then
			-- game action
			love.graphics.reset()
			love.graphics.setFont(oldFont)
			-- let's draw a background
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(bgGame)

			-- let's draw some ground
			love.graphics.setColor(255,0,0,255)
			love.graphics.rectangle("fill", 0, 0, 5, 600)
	
			-- let's draw our player
			love.graphics.setColor(255,255,0,255)
			love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

			-- let's draw our players shots
			love.graphics.setColor(255,255,255,255)
			for i,v in ipairs(player.shots) do
				love.graphics.rectangle("fill", v.x, v.y, 5, 2)
			end

			-- let's draw our enemies
			love.graphics.setColor(0,255,255,255)
			for i,v in ipairs(enemies) do
				love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
			end
			
			-- status messages at bottom of screen
			love.graphics.setColor(0,0,0,255)
			love.graphics.rectangle("fill", 0, 550, 800, 50)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Tu puntaje es: " .. game.score, 10, 571)
			love.graphics.print("Te quedan " .. player.livesLeft .. " vidas:", 415, 571)
			for i=0,player.livesLeft-1 do
				love.graphics.setColor(255,255,0,255)
				love.graphics.rectangle("fill", 720 + i*(player.width+10), 560, player.width, player.height)
			end	
		else
			-- game over!
			love.graphics.reset()
			love.graphics.setBackgroundColor(0, 0, 0)
			love.graphics.setFont(oldFontTitle)	
			love.graphics.setColor(255,0,0,255)
			love.graphics.print("Game Over", 270, 80)
			love.graphics.setFont(oldFont)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Perdiste el juego :(", 250, 120)
			love.graphics.setColor(255,255,0,255)
			love.graphics.print("'SPACE' para jugar de nuevo...", 100, 200)
			love.graphics.print("'ESC' para salir!", 100, 225)
			love.graphics.setColor(255,255,255,255)			
			love.graphics.print("Tu puntaje es: " .. game.score, 100, 270)
			
			-- highscore prompt and table
			if ((game.score >= game.highScores[5].score) and (game.score ~= 0)) then
				game.isHighScore = true
				love.graphics.setFont(oldFontSmall)
				love.graphics.setColor(0,255,0,255)
				love.graphics.print("Estas entre los mejores! Ingresa tu nombre: " .. game.playerName, 100, 295)
				love.graphics.print("Presiona 'ENTER' para guardar tu nombre.", 100, 310)				
			end
			love.graphics.setFont(oldFontSmall)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Tabla de Puntajes", 200, 370)
			for i=1,5 do
				if ((game.playerName == game.highScores[i].name) and (game.scoreDate == game.highScores[i].date)) then
					love.graphics.setColor(0,255,0,255)
				else
					love.graphics.setColor(255,255,255,255)
				end
				love.graphics.print(game.highScores[i].name, 200, 390 + 20*i)
				love.graphics.print(game.highScores[i].score, 250, 390 + 20*i)
				love.graphics.print(game.highScores[i].date, 340, 390 + 20*i)
			end
			
			-- credits to love and lua!
			love.graphics.setFont(oldFont)
			love.graphics.print("Hecho con:", 50, 550)
			love.graphics.draw(logoLUA, 220, 530)
			love.graphics.draw(logoLOVE, 290, 530)
		end
	end	
end

function inTable(table, item)

	-- search for item in table
	for key, value in pairs(table) do
		if value == item then 
			return key
		end
	end
	
	return false
end

function love.keypressed(key)
	
	local validLetters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
	
	-- player name handling
	if (game.state == "gameOver" and game.playerNameLocked == false and game.isHighScore == true) then
		
		if (key and (inTable(validLetters, key) or (key == "backspace") or (key == "return")) and #game.playerName < 4) then
		
			if (key == "backspace") then
				game.playerName = string.sub(game.playerName, 1, -2)
			else
		
				if (key == "return") then
					
					if (#game.playerName == 3) then
						
						game.playerNameLocked = true
						game.scoreDate = os.date("%c")
						table.insert(game.highScores, {name=game.playerName, score=game.score, date=game.scoreDate})
						table.sort(game.highScores, compareScoresGQt)
					end
				else
		
					if (#game.playerName < 3) then
						game.playerName = string.upper(game.playerName..key)
					end
				end
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
				player = nil
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

	-- game properties
	game.score = 0
	game.scoreDate = ""
	game.isHighScore = false
	game.playerName = ""
	game.playerNameLocked = false

	-- new table for the player
	player = {}
	enemies = {}

	-- x,y coordinates of the player
	player.x = 5
	player.y = 300

	-- size of the player
	player.width = 15
	player.height = 30
	
	-- speed and lives left of the player
	player.speed = 150
	player.livesLeft = 3
	
	-- holds our fired shots
	player.shots = {} 

	-- first batch of enemies!
	local size = 5
	for i=0,size do
		generateEnemy(size, i, false, true)
	end	
	phase = true
end

function generateEnemy(size, i, crazy, ph)
	-- generate an enemy!
	enemy = {}
	enemy.width = 20
	enemy.height = 40
	local aux = 550/math.pow(2,size+1)
	local beforeAux = 550/(size+1)
	enemy.y =  aux + beforeAux * i
	enemy.x = enemy.height + 800
	enemy.isCrazy = crazy
	enemy.phase = ph
	table.insert(enemies, enemy)
end

function shoot()
	local shot = {}
	shot.x = player.x + player.width
	shot.y = player.y + player.height/2
	local sfx = shotSound:clone()
	sfx:play()
	
	table.insert(player.shots, shot)
end

-- Collision detection function
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end

-- Comparison function for sorting highscore table
function compareScoresGQt(w1,w2)
	if w1.score >= w2.score then
		return true
	end
end

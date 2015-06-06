-- Demo para la presentacion de la materia 75.31 "Teoria del Lenguaje", lenguaje LUA
-- FIUBA, 08/06/2015

function love.load()

	game = {} -- new table for game data
	game.state = "mainMenu"
	game.won = false
	game.score = 0
	game.highScores = {[1]={name="AAA", score=0, date=os.date("%c")}, [2]={name="BBB", score=0, date=os.date("%c")}, [3]={name="CCC", score=0, date=os.date("%c")}, [4]={name="DDD", score=0, date=os.date("%c")}, [5]={name="EEE", score=0, date=os.date("%c")}}
	
	bg = love.graphics.newImage("bg.png")
	
	initGame()
end

function love.update(dt)

	if game.state == "mainMenu" then
		-- main menu

	else

		if game.state == "playGame" then
			if (#enemies == 1) then
				-- game action
				-- no bricks left
				-- you win!!!
				game.state = "gameOver"
				game.won = true
				table.insert(game.highScores, {name="FFF", score=game.score, date=os.date("%c")})
				table.sort(game.highScores, compareScoresGt)
				
			else
				-- game action
				-- bricks left
				-- keyboard actions for our hero
				if love.keyboard.isDown("up") then
					hero.y = hero.y - hero.speed*dt
				elseif love.keyboard.isDown("down") then
					hero.y = hero.y + hero.speed*dt
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

				-- update those evil enemies
				for i,v in ipairs(enemies) do
					-- let them fall down slowly
					v.x = v.x - dt * 25

					-- check for collision with ground
					if v.x < 10 then
						-- you lose!!!
						game.state = "gameOver"
					end
				end
				
				if game.state == "gameOver" then
					table.insert(game.highScores, {name="FFF", score=game.score, date=os.date("%c")})
					table.sort(game.highScores, compareScoresGt)
				end
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
			love.graphics.draw(bg)

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
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Tu puntaje es: " .. game.score .. ".", 600, 550)
		else
			-- game over!
			love.graphics.reset()
			love.graphics.setBackgroundColor(0, 0, 0)
			love.graphics.print("Fin.", 400, 180)
			if game.won == true then
				love.graphics.print("GANASTE!", 400, 200)
			else
				love.graphics.print("Perdiste el juego :(", 400, 200)
			end
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
	hero.shots = {} -- holds our fired shots

	for i=0,7 do
		enemy = {}
		enemy.width = 20
		enemy.height = 40
		--enemy.x = i * (enemy.width + 60) + 100
		enemy.y = i * (enemy.height + 40) + 50
		enemy.x = enemy.height + 800
		table.insert(enemies, enemy)
	end	
end

function compareScoresGt(w1,w2)
	if w1.score > w2.score then
		return true
	end
end

function shoot()
	local shot = {}
	shot.x = hero.x + hero.width
	shot.y = hero.y + hero.height/2

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

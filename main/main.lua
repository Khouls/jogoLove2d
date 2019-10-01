function love.load()
	debugText = "" --cria o texto que é imprimido na tela para fins de debugar o código

	--cria os timers

	--cria a função de camera
	camera = {}
		camera.x = 0
		camera.y = 0
		camera.scaleX = 1
		camera.scaleY = 1
		camera.rotation = 0

		function camera:set()
		  love.graphics.push()
		  love.graphics.rotate(-self.rotation)
		  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
		  love.graphics.translate(-self.x, -self.y)
		end

		function camera:unset()
		  love.graphics.pop()
		end

		function camera:move(dx, dy)
		  self.x = self.x + (dx or 0)
		  self.y = self.y + (dy or 0)
		end

		function camera:rotate(dr)
		  self.rotation = self.rotation + dr
		end

		function camera:scale(sx, sy)
		  sx = sx or 1
		  self.scaleX = self.scaleX * sx
		  self.scaleY = self.scaleY * (sy or sx)
		end

		function camera:setPosition(x, y)
		  self.x = x or self.x
		  self.y = y or self.y
		end

		function camera:setScale(sx, sy)
		  self.scaleX = sx or self.scaleX
		  self.scaleY = sy or self.scaleY
		end

	--Fim da criação de câmera

	w = love.graphics.getWidth() --guarda a largura da tela
	h = love.graphics.getHeight() --guarda a altura da tela


	--cria o mundo
	mundo = love.physics.newWorld(0, 500, true)
		--define o callback de beginContact no mundo (vai ser usado para fazer o pulo)
		mundo:setCallbacks(beginContact)


	--cria o jogador
	player = {}
		--cria os atributos padrão pra física
		player.body = love.physics.newBody(mundo, w/2, h/2, "dynamic")
		player.body:setFixedRotation(true)
		player.shape = love.physics.newRectangleShape(40,40)
		player.fixture = love.physics.newFixture(player.body, player.shape)
		player.fixture:setUserData("Jogador")

		--cria os atalhos pra x e y do jogador
		player.x = player.body:getX()
		player.y = player.body:getY()

		--cria os atributos específicos para as diversas funções
		player.speed = 500
		player.podePular = false

	terreno = {} --array contendo todos os terrenos

		terreno.chao = {}
		terreno.chao.body = love.physics.newBody(mundo, w/2, h/2 + 50, "static")
		terreno.chao.shape = love.physics.newRectangleShape(w, 5)
		terreno.chao.fixture = love.physics.newFixture(terreno.chao.body, terreno.chao.shape)
		terreno.chao.fixture:setUserData("Chão")


end

function love.update(dt)
	mundo:update(dt)

	--faz a movimentação
	player.x = player.body:getX()
	player.y = player.body:getY()

	if love.keyboard.isDown("left") then
		player.body:setX(player.x - player.speed * dt)
	end

	if love.keyboard.isDown("right") then
		player.body:setX(player.x + player.speed * dt)
	end

end

function love.keypressed(key)
	if key == "up" and player.podePular then
		player.body:applyLinearImpulse(0,-600)
		player.podePular = false
	end

	if key == "escape" then love.event.push("quit") end --fecha o programa se apertar esc

end

function love.draw()
    camera:set()

    camera:setPosition(player.x -w/2, player.y-h/2)

		love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))

		love.graphics.line(w/2, -9000, w/2, 9000)

		for i,v in pairs(terreno) do
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end

		camera:unset()

		love.graphics.print(debugText)

end

function beginContact(obj1, obj2, objContact)

		debugText = obj1:getUserData() .. ", " .. obj2:getUserData()

		--for k,v in pairs(terreno) do
			if (obj1:getUserData() == "Jogador") then
				player.podePular = true

			end
	--	end

end

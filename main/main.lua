function love.load()
	debugText = "" --texto que vai ser usado pra debugar o código e ver as colisões
	grav = 500

	love.window.setMode(960,640,nil)


	math.randomseed(os.time())
	math.random()
	math.random()
	math.random()

	tree = love.graphics.newImage("tree.png")
	treeW, treeH = tree:getDimensions()
	img = love.graphics.newImage("maxresdefault.jpg")



	--cria a função de camera
	camera = {}
		camera.layers = {}
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

		function camera:newLayer(scale, func)
	  		table.insert(self.layers, { draw = func, scale = scale })
  			table.sort(self.layers, function(a, b) return a.scale < b.scale end)
		end

		function camera:draw()
		 local bx, by = self.x, self.y
		  for _, v in ipairs(self.layers) do
		    self.x = bx * v.scale
		    self.y = by * v.scale
				camera:set()
				v.draw()
				camera:unset()

		  end

		end

	--finalização da câmera

	w = love.graphics.getWidth() --guarda a largura da tela
	h = love.graphics.getHeight() --guarda a altura da tela


	--cria o mundo
	mundo = love.physics.newWorld(0, grav, true)
	mundo:setCallbacks(beginContact, endContact)

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
		player.speed = 5
		player.fallingSpeed = 0
		player.canDoubleJump = false
		player.onPlataform = false
		player.velX = 0
		player.velY = 0

		--liga o player
		player.body:setAwake(true)
		player.body:setActive(true)


	terreno = {} --array contendo todos os terrenos

		terreno.chao = {}
		terreno.chao.body = love.physics.newBody(mundo, w/2, h+500, "static")
		terreno.chao.shape = love.physics.newRectangleShape(w/2, 2*h)
		terreno.chao.fixture = love.physics.newFixture(terreno.chao.body, terreno.chao.shape)



	--layer 1 vai ser do player e do terreno

	--desenha player e terreno
	camera:newLayer(1, function()
		love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
		for i,v in pairs(terreno) do
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
   	 	love.graphics.print(debugText)

	end)

	--desenha o fundo
	camera:newLayer(0.3, function()
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(img, -100, -100)

	end)

	--desenha as árvores da frente
	posArvores = {}
	for i=-600,600,(treeW*0.8+50) do
		ar = {}

		for j=-1,3 do
			table.insert(ar,-i)
		end

		table.insert(posArvores, ar)
	end


	for i,v in ipairs(posArvores) do
		camera:newLayer(i+0.5, function()
			for k,v1 in ipairs(v) do
				love.graphics.draw(tree, v1+500*(k-1), 100, 0, 0.8,0.8)
			end
		end)
	end
end


function love.update(dt)
	--out of bounds
	if player.y >= 10000 or player.x <= -10000 then
		print("oof")
		player.body:setPosition(w/2,h/2)
	end

  	camera:setPosition(player.x, player.y)
  	camera:move(-w/2, -h/2)
	

	mundo:update(dt)

	--faz a movimentação
	player.x, player.y = player.body:getPosition()

	player.velX, player.velY = player.body:getLinearVelocity()


	if (not player.onPlataform) then
		player.body:applyForce(0,grav)

	end

	if love.keyboard.isDown("left") then
		player.body:setX(player.x - player.speed)
		player.body:setAwake(true)
	end

	if love.keyboard.isDown("right") then
		player.body:setX(player.x + player.speed)
		player.body:setAwake(true)
	end

end

function love.keypressed(key)
	if key == "up" and player.onPlataform then
		player.body:setLinearVelocity(player.velX,0)
		player.body:applyLinearImpulse(0,-600)
		player.onPlataform = false
	
	elseif key == "up" and player.canDoubleJump then
		player.body:setLinearVelocity(player.velX,0)
		player.body:applyLinearImpulse(0,-600)
		player.canDoubleJump = false
		player.onPlataform = false	
	end

	 
	if key == "'" then
		love.load()
	elseif key == 'escape' then
		love.event.push('q')
	end

end

function love.draw()
	camera:draw()

end

function beginContact(obj1, obj2, collObj)

	--debugText = obj1:getUserData() .. " ," .. obj2:getUserData()

	if (obj1:getUserData() == "Jogador") then
		player.canDoubleJump = true
		player.onPlataform = true
	end
end

function endContact(obj1, obj2, collObj)


end

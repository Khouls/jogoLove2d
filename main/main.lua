function love.load()
	w = love.graphics.getWidth()
	h = love.graphics.getHeight()


	--cria o mundo
	mundo = love.physics.newWorld(0, 500, true)

	--cria o jogador
	player = {}
		--cria os atributos padrão pra física
		player.body = love.physics.newBody(mundo, w/2, h/2, "dynamic")
		player.shape = love.physics.newRectangleShape(40,40)
		player.fixture = love.physics.newFixture(player.body, player.shape)
		
		--cria os atalhos pra x e y do jogador
		player.x = player.body:getX()
		player.y = player.body:getY()

		--cria os atributos específicos para as diversas funções
		player.speed = 5

	terreno = {}
		terreno.chao = {}
		terreno.chao.body = love.physics.newBody(mundo, w/2, h/2 + 50, "static")
		terreno.chao.shape = love.physics.newRectangleShape(w, 5)
		terreno.chao.fixture = love.physics.newFixture(terreno.chao.body, terreno.chao.shape)



end

function love.update(dt)
	mundo:update(dt)

	--faz a movimentação
	player.x = player.body:getX()
	player.y = player.body:getY()

	if love.keyboard.isDown("left") then
		player.body:setX(player.x - player.speed)
	end

	if love.keyboard.isDown("right") then
		player.body:setX(player.x + player.speed)
	end

end

function love.keypressed(key)
	if key == "up" then
		player.body:applyLinearImpulse(0,-600)
		print("pulou")
	end

	 if key == "escape" then love.event.push("quit") end

end

function love.draw()
	love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))


	for i,v in pairs(terreno) do
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
	end
	
end

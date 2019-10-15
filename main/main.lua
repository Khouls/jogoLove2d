-- TODO: Fazer o shader em outro arquivo
local shader_code = [[
#define NUM_LIGHTS 32
struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};
extern Light lights[NUM_LIGHTS];
extern int num_lights;
extern vec2 screen;
const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);
    vec2 norm_screen = screen_coords / screen;
    vec3 diffuse = vec3(0);
    for (int i = 0; i < num_lights; i++) {
        Light light = lights[i];
        vec2 norm_pos = light.position / screen;
        float distance = length(norm_pos - norm_screen) * light.power;
        float attenuation = 1.0 / (constant + (linear * distance) + (quadratic * (distance * distance)));
        diffuse += light.diffuse * attenuation;
    }
    diffuse = clamp(diffuse, 0.0, 1.0);
    return pixel * vec4(diffuse, 1.0);
}
]]

local shader = nil
num_lights = 90 --numero máximo de luzes que vão existir no shader

lights = { --array contendo as luzes
  {0, 0, 1,  30}, --luz do player
  {300,300,1.1, 10000} --x,y,layer, power

}




function love.load()
  shader = love.graphics.newShader(shader_code)
	debugText = "" --texto que vai ser usado pra debugar o código e ver as colisões
	grav = 700

	love.window.setMode(960,640,nil)


	w = love.graphics.getWidth() --guarda a largura da tela
	h = love.graphics.getHeight() --guarda a altura da tela

  lights[1][1], lights[1][2] = w/2, h/2

	math.randomseed(os.time())
	math.random()
	math.random()
	math.random()


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

      --[[
      love.graphics.setShader(shader)
      shader:send("screen", {
          love.graphics.getWidth(),
          love.graphics.getHeight()
      })

      shader:send("num_lights", num_lights)

      for i,v in ipairs(lights) do
        local strLight = "lights[" .. i-1 .. "]"

        shader:send(strLight .. ".position", {
            v[1];
            v[2]
        })

        shader:send(strLight ..".diffuse", {
            1.0, 0.6, 0.0
        })

        shader:send(strLight .. ".power", v[4])

     end
     --]]

		 local bx, by = self.x, self.y
		  for layer, v in ipairs(self.layers) do
		    --self.x = bx * v.scale
		    --self.y = by * v.scale

        camera:set()
        v.draw()
				camera:unset()

		  end
      --love.graphics.setShader()

		end


	--finalização da câmera


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
		player.speed = 350
		player.fallingSpeed = 0
		player.canDoubleJump = false
		player.onPlataform = false
		player.xSpeed = 0
		player.ySpeed = 0

		--liga o player
		player.body:setAwake(true)
		player.body:setActive(true)


	terreno = {} --array contendo todos os terrenos

		terreno.chao = {}
		terreno.chao.body = love.physics.newBody(mundo, w/2, h+500, "static")
		terreno.chao.shape = love.physics.newRectangleShape(w/2, 2*h)
		terreno.chao.fixture = love.physics.newFixture(terreno.chao.body, terreno.chao.shape)
		terreno.chao.fixture:setUserData("Chão")


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
  bg =  love.graphics.newImage("maxresdefault.jpg")
	camera:newLayer(0.3, function()
    love.graphics.draw(bg, -300, 100)
	end)

  --desenha o layer 2
  layer2 = love.graphics.newImage("layer2.png")
  camera:newLayer(2, function()
    love.graphics.draw(layer2, -400, -100)
  end)
end


function love.update(dt)
  debugText= love.timer.getFPS()
	--out of bounds
	if player.y >= 10000 or player.x <= -10000 then
		player.body:setPosition(w/2,h/2)
	end

  	camera:setPosition(player.x, player.y)
  	camera:move(-w/2, -h/2)


	mundo:update(dt)

	--faz a movimentação
	player.x, player.y = player.body:getPosition()
	player.xSpeed, player.ySpeed = player.body:getLinearVelocity()

  --anda pra esquerda
	if love.keyboard.isDown("left") then
		player.body:setX(player.x - (player.speed * dt))
		player.body:setAwake(true)
	end

  --anda pra direita
	if love.keyboard.isDown("right") then
		player.body:setX(player.x + (player.speed * dt))
		player.body:setAwake(true)
	end
  --faz ele planar
	if (love.keyboard.isDown("up") and not (player.canDoubleJump) and player.ySpeed > 0) then
		player.body:setLinearVelocity(player.xSpeed, (player.ySpeed*0.95))
	end

end

function love.keypressed(key)
	if key == "up" and player.onPlataform then
		player.body:setLinearVelocity(player.xSpeed,0)
		player.body:applyLinearImpulse(0,-600)
		player.onPlataform = false

	elseif key == "up" and player.canDoubleJump then
		player.body:setLinearVelocity(player.xSpeed,0)
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
	love.graphics.print(debugText, 0, 0, 0, 4, 4)
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

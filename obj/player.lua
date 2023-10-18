Player = class('Player',Entity)


function Player:initialize(params)
  self.layer = 0
  self.uplayer = 0
  self.spr = {
    idle = sprites.player.idle,
    happy = sprites.player.happy,
    miss = sprites.player.miss
  }
  self.x=0
  self.y=0
  self.bobi=0
  self.angle = 0
  self.angleprevframe = 0
	self.cumulativeangle = nil
  self.extend = 0
  self.paddle_size = 70
  self.handle_size = 10
  self.paddle_width = 10
  self.paddle_distance = 25
  self.cmode = not love.joystick.getJoysticks()[1]
  self.cemotion = "idle"
  self.emotimer = 0
  self.lookradius = 5
  self.maxouchpulse = 0.2
  self.ouchpulse = 0
  self.ouchtime = 15
	
  Entity.initialize(self,params)
end

function Player:update(dt)
  prof.push("player update")
  self.angle = self.angle % 360
  self.emotimer = self.emotimer - 1
  if self.emotimer <= 0 then
    self.cemotion = "idle"
  end
  if maininput:pressed("a") then
    self.cmode = not self.cmode
  end
  if not cs.autoplay then
    if self.cmode then
      self.angleprevframe = self.angle --this way obj.angleprevframe is always 1 frame behind obj.angle
			self.angle = 0-math.deg(math.atan2(self.y - mouse.ry, mouse.rx - self.x)) +90
    else
      if maininput:down("left") and not love.joystick.getJoysticks()[1] then
        self.angle = self.angle - 7
      elseif maininput:down("right") and not love.joystick.getJoysticks()[1] then
        self.angle = self.angle + 7
      elseif love.joystick.getJoysticks()[1] then
        self.angleprevframe = self.angle
        self.angle = math.deg(math.atan2(love.joystick.getJoysticks()[1]:getAxis(2), love.joystick.getJoysticks()[1]:getAxis(1)))+90
      end
			
    end
  end
	if self.cumulativeangle then
		self.cumulativeangle = self.cumulativeangle + helpers.angdelta(self.angleprevframe,(self.angle+360)%360)
	else
		self.cumulativeangle = self.angle
	end
  self.bobi = self.bobi + 0.03*dt
  prof.pop("player update")
end

function Player:draw()
	
		
	outline(function()
		love.graphics.setLineWidth(2)

		-- draw the paddle
		love.graphics.push()
			love.graphics.translate(self.x, self.y)
			love.graphics.rotate((self.angle - 90) * math.pi / 180)

			--HANDLE
			--fill in handle
			color()
			local dist = self.paddle_distance + cs.extend + self.paddle_width * 0.5
			local x1 = dist * math.cos(self.handle_size * math.pi / 180)
			local y1 = dist * math.sin(self.handle_size * math.pi / 180)
			local x2 = dist * math.cos(-self.handle_size * math.pi / 180)
			local y2 = dist * math.sin(-self.handle_size * math.pi / 180)
			
			love.graphics.polygon('fill',0,0, x1,y1, x2,y2)
			color('black')
			-- draw handle lines
			love.graphics.line(0,0, x1,y1)
			love.graphics.line(0,0, x2,y2)

			
			
			--PADDLE
			local paddle_angle = self.paddle_size / 2
			local paddlepoly = {}
			local segments = 10
			local function addvert(pos)
				table.insert(paddlepoly,pos[1])
				table.insert(paddlepoly,pos[2])
			end
			for i=0,segments-1 do
				addvert(helpers.rotate((self.paddle_distance + cs.extend), helpers.lerp(paddle_angle, -paddle_angle, i/(segments-1))+90,0,0))
			end
			
			for i=0,segments-1 do
				addvert(helpers.rotate((self.paddle_distance + cs.extend)+ self.paddle_width, helpers.lerp(paddle_angle, -paddle_angle, 1-i/(segments-1))+90,0,0))
			end
			
			color()
			for i,v in ipairs(love.math.triangulate(paddlepoly)) do
				love.graphics.polygon('fill',v)
			end
			
			color('black')
			love.graphics.polygon('line',paddlepoly)
		love.graphics.pop()

		love.graphics.push()
			-- scaling circle and face for hurt animation
			local ouchpulsescale = 1 + self.ouchpulse
			love.graphics.scale(ouchpulsescale)

			-- adjusting x and y so they're unaffected by scaling
			local finalx = self.x / ouchpulsescale
			local finaly = self.y / ouchpulsescale

			-- draw the circle
			color('white')
			love.graphics.circle("fill",finalx,finaly,16+cs.extend/2+(math.sin(self.bobi))/2)
			color('black')
			love.graphics.circle("line",finalx,finaly,16+cs.extend/2+(math.sin(self.bobi))/2)

			-- draw the eyes
			color('white')
			-- determine x and y offsets of the eyes
			local eyex = (self.lookradius) * math.cos((self.angle - 90) * math.pi / 180)
			local eyey = (self.lookradius) * math.sin((self.angle - 90) * math.pi / 180)
			love.graphics.draw(self.spr[self.cemotion],finalx + eyex,finaly + eyey,0,1,1,16,16)
		love.graphics.pop()
	end, cs.outline)
	
end


function Player:hurtpulse()
  self.ouchpulse = self.maxouchpulse
  flux.to(self,self.ouchtime,{ouchpulse=0}):ease("outSine")
end


return Player
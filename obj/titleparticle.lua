Titleparticle = class('Titleparticle',Entity)


function Titleparticle:initialize(params)
	
	self.layer = -10 -- lower layers draw first
	self.uplayer = 9 -- lower uplayer updates first
	self.x=-100
	self.y=-100
	self.dx = 1
	self.dy = 1
	
  Entity.initialize(self,params)
	
	local sprv = math.random(0,7)
	if sprv <= 5 then
		self.spr = sprites.beat.square
	elseif sprv <= 6 then
		self.spr = sprites.beat.inverse
	else
		self.spr = sprites.beat.hold
	end
end

function Titleparticle:update(dt)
  prof.push("titleparticle update")
  self.x = self.x + self.dx*dt
  self.y = self.y + self.dy*dt
  if self.y >= 300 then self.delete = true end -- i do not trust my deleting code at all
  prof.pop("titleparticle update")

end


function Titleparticle:draw()
  prof.push("titleparticle draw")
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.spr,self.x,self.y,0,1,1,8,8)
  prof.pop("titleparticle draw")
end


return Titleparticle
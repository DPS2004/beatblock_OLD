Hitpart = class('Hitpart',Entity)


function Hitpart:initialize(params)
	self.layer = -2
	self.uplayer = 9
	self.x = 0
	self.y = 0
	self.rad = 9
	
  Entity.initialize(self,params)
	
end

function Hitpart:update(dt)
  self.rad = self.rad - dt
  if self.rad <= 0 then
    self.delete = true
  end
end


function Hitpart:draw()
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0,0,0,1)
  love.graphics.circle("line",self.x,self.y,self.rad)
end


return Hitpart
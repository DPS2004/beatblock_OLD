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
  prof.push('hitpart update')
  self.rad = self.rad - dt
  if self.rad <= 0 then
    self.delete = true
  end
  prof.pop('hitpart update')
end


function Hitpart:draw()
  prof.push('hitpart draw')
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0,0,0,1)
  love.graphics.circle("line",self.x,self.y,self.rad)
  prof.pop('hitpart draw')
end


return Hitpart
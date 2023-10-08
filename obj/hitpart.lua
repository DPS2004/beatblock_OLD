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
	
	outline(function()
		love.graphics.setLineWidth(1)
		color(1)
		love.graphics.circle("line",self.x,self.y,self.rad)
	end, cs.outline)
  prof.pop('hitpart draw')
end


return Hitpart
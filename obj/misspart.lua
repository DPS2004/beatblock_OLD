Misspart = class('Misspart',Entity)


function Misspart:initialize(params)
	self.layer = -2
	self.uplayer = 9
	self.x = project.res.cx
	self.y = project.res.cy
	self.ox = self.x
	self.oy = self.y
	self.angle = 0
	self.distance = 42
	self.spr = love.graphics.newImage("assets/game/square.png")
	
  Entity.initialize(self,params)
	
end



function Misspart:update(dt)
  prof.push('misspart update')
  flux.to(self,15,{distance=0}):ease("outExpo"):oncomplete(function(f) self.delete=true end)
  local p1 = helpers.rotate(self.distance+cs.extend,self.angle,self.ox,self.oy)
  self.x = p1[1]
  self.y = p1[2]
  prof.pop('misspart update')
end


function Misspart:draw()
  prof.push('misspart draw')
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.spr,self.x,self.y,0,1,1,8,8)
  prof.pop('misspart draw')
end


return Misspart
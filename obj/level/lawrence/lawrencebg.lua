LawrenceBG = class('LawrenceBG',Entity)

function LawrenceBG:initialize(params)
  
  self.layer = -99 -- lower layers draw first
  self.uplayer = 99 --lower uplayer updates first
  self.x = 0
  self.y = 0
  
  self.sinetimer = 0
  
  self.r = 0
  
  self.spr = {}
	self.spr.gear = love.graphics.newImage('assets/level/lawrence/gear.png')
  
  Entity.initialize(self,params)

end


function LawrenceBG:update(dt)
  prof.push("LawrenceBG update")
  self.sinetimer = self.sinetimer + dt/60
  self.r = math.sin(self.sinetimer)*20
  prof.pop("LawrenceBG update")
end

function LawrenceBG:draw()
  prof.push("LawrenceBG draw")
  color(3)
  love.graphics.draw(self.spr.gear,self.x,self.y,math.rad(self.r),0.5,0.5,256,256)
  prof.pop("LawrenceBG draw")
end

return LawrenceBG
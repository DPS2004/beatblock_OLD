LawrenceBG = class('LawrenceBG',Entity)

function LawrenceBG:initialize(params)
  
  self.layer = -99 -- lower layers draw first
  self.uplayer = 99 --lower uplayer updates first
  self.x = 0
  self.y = 0
  
  self.sinetimer = 0
  
  self.r = 0
	self.playeroffset = 0
	
	self.rotatemix = 0
  
  self.spr = {}
	self.spr.gear = love.graphics.newImage('assets/level/lawrence/gear.png')
	self.spr.ring = love.graphics.newImage('assets/level/lawrence/ring.png')
  
  Entity.initialize(self,params)

end

function LawrenceBG:resetplayerrot()
	self.playeroffset = (math.floor(cs.p.cumulativeangle / 360) * -360) + 720
end

function LawrenceBG:update(dt)
  prof.push("LawrenceBG update")
  self.sinetimer = self.sinetimer + dt/60
	
  self.r = (1 - self.rotatemix) * math.sin(self.sinetimer)*20 + (self.rotatemix) * (cs.p.cumulativeangle + self.playeroffset)
	
  prof.pop("LawrenceBG update")
end

function LawrenceBG:draw()
  prof.push("LawrenceBG draw")
  color(3)
  love.graphics.draw(self.spr.ring,self.x,self.y,math.rad(self.r/2),0.25,0.25,256,256)
  love.graphics.draw(self.spr.gear,self.x,self.y,math.rad(self.r/4),0.5,0.5,256,256)
  love.graphics.draw(self.spr.ring,self.x,self.y,math.rad(self.r/8),1,1,256,256)
  prof.pop("LawrenceBG draw")
end

return LawrenceBG
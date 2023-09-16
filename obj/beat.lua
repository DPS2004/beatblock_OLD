Beat = class('Beat',Entity)

--all other beat types will now be separate selfects.

function Beat:initialize(params)
	self.layer = -1
	self.uplayer = 3
	
	self.x = project.res.cx
	self.y = project.res.cy
	
  self.angle = 0
	self.endangle = 0
	
	self.smult = 1
	
	self.hb = 0 --hit beat?
	
	self.movetime = 0 --remaining time to hit
	
	self.progress = 0
	
  Entity.initialize(self,params)
	
	self.startangle = self.startangle or self.angle
	self.endangle = self.endangle or self.angle
	self.spinease = self.spinease or 'linear'
	
  self.spr = sprites.beat.square
	
	if self.movetime == 0 then
    self.movetime = self.hb - cs.cbeat
  end
	
	self.ox = self.x
	self.oy = self.y
	
end
--[[
local self = {
  layer = -1,
  uplayer = 3,
  slice = false,
  x=screencenter.x,
  y=screencenter.y,
  angle=0,
  startangle=0,
  smult2=1,
  endangle=0,
  hb=0,
  movetime=0,
  smult=1,
  randomvalue=math.random(),
  inverse = false,
  hityet = false,
  hold = false,
  mine = false,
  side = false,
  sidehityet = false,
  minehold = false,
  ringcw = false,
  ringccw = false,
  spr = sprites.beat.square,
  spr2 = sprites.beat.inverse,
  spr3 = sprites.beat.hold,
  spr4 = sprites.beat.mine,
  spr5 = sprites.beat.side,
  spr6 = sprites.beat.minehold,
  spr7 = sprites.beat.ringcw,
  spr8 = sprites.beat.ringccw
}
self.ox = self.x
self.oy = self.y
]]--


function Beat:updateprogress()
  -- Progress is a number from 0 (spawn) to 1 (paddle)
  self.progress = 1 - ((self.hb - cs.cbeat) / self.movetime)
end

function Beat:updateangle()
	-- Interpolate angle between startangle and endangle based on progress. Beat should be at endangle when it hits the paddle.
  if (self.hb - cs.cbeat) > 0 then --only clamp when moving towards point
    if self.spinease == "linear" then --haha wow this should not be using an if statement???
      self.angle = helpers.clamp(helpers.lerp(self.startangle, self.endangle, self.progress), self.startangle, self.endangle) % 360
    elseif self.spinease == "inExpo"  then
      --print(2 ^ (10 * (progress - 1)))
      self.angle = helpers.clamp(helpers.lerp(self.startangle, self.endangle, 2 ^ (10 * (self.progress - 1))), self.startangle, self.endangle) % 360
    end
  end
end

function Beat:getpositions()
	return helpers.rotate((self.hb - cs.cbeat)*cs.level.properties.speed*self.smult+cs.extend+cs.length,self.angle,self.ox,self.oy)
end

function Beat:update(dt)
  
  self:updateprogress()


  self:updateangle()
  
  local p1 = nil --position 1
  local p2 = nil --position 2
  
	p1 = self:getpositions()
	
  self.x = p1[1]
  self.y = p1[2]  

  if (self.hb - cs.cbeat) <= 0 then
		if helpers.angdistance(self.endangle,cs.p.angle) <= cs.p.paddle_size / 2 then 
			em.init("hitpart",{x=self.x,y=self.y})
			self.delete = true
			pq = pq .. "   player hit!"
			cs.hits = cs.hits + 1
			cs.combo = cs.combo + 1
			if cs.beatsounds then
				te.play(sounds.click,"static")
			end
			if cs.p.cemotion == "miss" then
				cs.p.emotimer = 0
				cs.p.cemotion = "idle"
			end
		else
			local mp = em.init("misspart",screencenter.x,screencenter.x)
			mp.angle = self.angle
			mp.distance = (self.hb - cs.cbeat)*cs.level.properties.speed+cs.length
			mp.spr = (self.inverse and not self.slice and self.spr2) or (self.spr) --Determine which sprite the misspart should use
			mp.update()
			self.delete = true
			pq = pq .. "   player missed!"
			cs.misses = cs.misses + 1
			cs.combo = 0
			cs.p.emotimer = 100
			cs.p.cemotion = "miss"

			cs.p.hurtpulse()
		end
	end
end

function Beat:draw()
	color()
	love.graphics.draw(self.spr,self.x,self.y,0,1,1,8,8)
end

return Beat
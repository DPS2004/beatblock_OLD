Beat = class('Beat',Entity)

--all other beat types will now be separate selfects.

function Beat:initialize(params)
	self.name = 'beat'
	
	self.layer = -1
	self.uplayer = 3
	
	self.x = project.res.cx
	self.y = project.res.cy
	
  self.angle = 0
	
	self.smult = 1
	
	self.hb = 0 --hit beat?
	
	self.movetime = 0 --remaining time to hit
	
	self.progress = 0
	
	self.hityet = false
	
  self.spr = sprites.beat.square
	
	self.spinease = 'linear'
	
  Entity.initialize(self,params)
	
	self.startangle = self.startangle or self.angle
	self.endangle = self.endangle or self.angle
	
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

function Beat:updatepositions()
	local p1, p2 = self:getpositions()
	
  self.x = p1[1]
  self.y = p1[2]  
	if p2 then
		self.x2 = p2[1]
		self.y2 = p2[2]
	end
end

function Beat:checkifactive()
	return ((self.hb - cs.cbeat) <= 0)
end

function Beat:checktouchingpaddle(a)
	return (helpers.angdistance(a,cs.p.angle) <= cs.p.paddle_size / 2)
end


function Beat:onhit()
	self:makeparticles(true)
	pq = pq .. "   player hit " ..self.name.."!"
	cs.hits = cs.hits + 1
	cs.combo = cs.combo + 1
	if cs.beatsounds then
		te.play(sounds.click,"static")
	end
	if cs.p.cemotion == "miss" then
		cs.p.emotimer = 0
		cs.p.cemotion = "idle"
	end
	self.delete = true
end

function Beat:onmiss()
	self:makeparticles(false)
	pq = pq .. "   player missed " ..self.name.."!"
	cs.misses = cs.misses + 1
	cs.combo = 0
	cs.p.emotimer = 100
	cs.p.cemotion = "miss"

	cs.p:hurtpulse()
	self.delete = true
end

function Beat:makeparticles(hit)
	if hit then
		em.init("hitpart",{x=self.x,y=self.y})
	else
		em.init("misspart",{
			x = project.res.cx,
			y = project.res.cy,
			angle = self.angle,
			distance = cs.length,
			spr = self.spr
		})
	end
end

function Beat:update(dt)
  prof.push('beat update')
	
  self:updateprogress()
  self:updateangle()
  
	self:updatepositions()

  if self:checkifactive() then
		if self:checktouchingpaddle(self.endangle) then 
			self:onhit()
		else
			self:onmiss()
		end
	end
	
  prof.pop('beat update')
end

function Beat:draw()
  prof.push('beat draw')
	color()
	love.graphics.draw(self.spr,self.x,self.y,0,1,1,8,8)
  prof.push('beat draw')
end

return Beat
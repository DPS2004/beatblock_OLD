Block = class('Block',Entity)

--all other beat types will now be separate selfects.

function Block:initialize(params)
	self.name = 'block'
	
	self.layer = 1
	self.uplayer = 3
	
	self.x = project.res.cx
	self.y = project.res.cy
	
  self.angle = 0
	
	self.smult = 1
	
	self.hb = 0 --hit beat?
	
	self.movetime = 0 --remaining time to hit
	
	self.progress = 0
	
	self.hityet = false
	
  self.spr = sprites.note.square
	
	self.spinease = 'linear'
	
	self.inverse = false
	
  Entity.initialize(self,params)
	
	if self.inverse then
		self.positionoffset = 24
		self.spr = sprites.note.inverse
		self.layer = 1
	else
		self.positionoffset = 0
	end
	
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
  spr = sprites.note.square,
  spr2 = sprites.note.inverse,
  spr3 = sprites.note.hold,
  spr4 = sprites.note.mine,
  spr5 = sprites.note.side,
  spr6 = sprites.note.minehold,
  spr7 = sprites.note.ringcw,
  spr8 = sprites.note.ringccw
}
self.ox = self.x
self.oy = self.y
]]--


function Block:updateprogress()
  -- Progress is a number from 0 (spawn) to 1 (paddle)
  self.progress = 1 - ((self.hb - cs.cbeat) / self.movetime)
end

function Block:updateangle()
	-- Interpolate angle between startangle and endangle based on progress. Block should be at endangle when it hits the paddle.
  if (self.hb - cs.cbeat) > 0 then --only clamp when moving towards point
    if self.spinease == "linear" then --haha wow this should not be using an if statement???
			--todo: all the other eases
      self.angle = helpers.clamp(helpers.lerp(self.startangle, self.endangle, self.progress), self.startangle, self.endangle)
    elseif self.spinease == "inExpo"  then
      --print(2 ^ (10 * (progress - 1)))
      self.angle = helpers.clamp(helpers.lerp(self.startangle, self.endangle, 2 ^ (10 * (self.progress - 1))), self.startangle, self.endangle)
    end
  end
end

function Block:getpositions()
	local invmul = 1
	if self.inverse then
		invmul = -1
	end
	return helpers.rotate(((self.hb - cs.cbeat)*cs.level.properties.speed*self.smult*invmul)+cs.extend+cs.length-self.positionoffset,self.angle,self.ox,self.oy)
end

function Block:updatepositions()
	local p1, p2 = self:getpositions()
	
  self.x = p1[1]
  self.y = p1[2]  
	if p2 then
		self.x2 = p2[1]
		self.y2 = p2[2]
	end
end

function Block:checkifactive()
	return ((self.hb - cs.cbeat) <= 0)
end

function Block:checktouchingpaddle(a)
	return (helpers.angdistance(a,cs.p.angle) <= cs.p.paddle_size / 2)
end


function Block:onhit(mine)
	self:makeparticles(true)
	if mine then
		pq = pq .. "   player dodged " ..self.name.."!"
	else
		pq = pq .. "   player hit " ..self.name.."!"
	end
	cs.hits = cs.hits + 1
	cs.combo = cs.combo + 1
	if cs.beatsounds and (not mine) then
		te.play(sounds.click,"static")
	end
	if cs.p.cemotion == "miss" then
		cs.p.emotimer = 0
		cs.p.cemotion = "idle"
	end
	self.delete = true
end

function Block:onmiss(mine)
	self:makeparticles(false)
	if mine then
		pq = pq .. "   player hit " ..self.name.."!"
		if cs.beatsounds then
			te.play(sounds.mine,"static")
		end
	else
		pq = pq .. "   player missed " ..self.name.."!"
	end
		
	cs.misses = cs.misses + 1
	cs.combo = 0
	cs.p.emotimer = 100
	cs.p.cemotion = "miss"

	cs.p:hurtpulse()
	self.delete = true
end

function Block:makeparticles(hit)
	if hit then
		em.init("hitpart",{x=self.x,y=self.y})
	else
		em.init("misspart",{
			x = project.res.cx,
			y = project.res.cy,
			angle = self.angle,
			distance = cs.length - self.positionoffset,
			spr = self.spr
		})
	end
end

function Block:update(dt)
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

function Block:draw()
  prof.push('beat (generic) draw')
	outline(function()
		color()
		local xscale = cs.vfx.xscale or 1
		local yscale = cs.vfx.yscale or 1
		love.graphics.draw(self.spr,self.x,self.y,0,xscale,yscale,8,8)
	end, cs.outline)
  prof.push('beat (generic) draw')
end

return Block
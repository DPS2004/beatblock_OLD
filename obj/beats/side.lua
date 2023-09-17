Side = class ('Side', Beat)

function Side:initialize(params)
	
	self.sidehityet = false
	self.timingwindow = 200
	
	Beat.initialize(self,params)
	
	self.name = 'side'
	self.positionoffset = 10
	self.spr = sprites.beat.side
end

function Side:update(dt) --This has not been cleaned up enough yet!!!
  prof.push('side update')
	
  self:updateprogress()
  self:updateangle()
  
	self:updatepositions()
	
	local timeuntil = self.hb - cs.cbeat --positive = hasnt arrived yet, negative = has arrived
	local twindow = Gamemanager:mstobeat(self.timingwindow/2) -- should be ~1/4 of a beat at lawrence's BPM
	
	if helpers.angdistance(self.angle,cs.p.angle) <= cs.p.paddle_size / 2 and helpers.angdistance(self.angle,cs.p.angleprevframe) > cs.p.paddle_size / 2 and math.abs(timeuntil) <= twindow then
		self.sidehityet = true
	elseif helpers.angdistance(self.angle,cs.p.angle) > cs.p.paddle_size / 2 and helpers.angdistance(self.angle,cs.p.angleprevframe) > cs.p.paddle_size / 2 and 60 > helpers.angdistance(self.angle,cs.p.angle) and 60 > helpers.angdistance(self.angle,cs.p.angleprevframe) then
		if self.angle - cs.p.angleprevframe > 0 or self.angle - cs.p.angleprevframe < -180 then
			if self.angle - cs.p.angle < 0 or self.angle - cs.p.angle > 180 then
				self.sidehityet = true
			end
		else
			if self.angle - cs.p.angle > 0 or self.angle - cs.p.angle < -180 then
				self.sidehityet = true
			end
		end
	end
	if self.sidehityet == true and timeuntil <= 0 then
		self:onhit()
	elseif timeuntil < twindow*-1 then --if it is not hit at all
		self:onmiss()
	elseif helpers.angdistance(self.angle,cs.p.angle) <= cs.p.paddle_size / 2 and helpers.angdistance(self.angle,cs.p.angleprevframe) <= cs.p.paddle_size / 2 and timeuntil <= 0 then --if the beat is hit head on
		self:onmiss(true)
	end
	
	prof.pop('side update')
	
end

function Side:draw()
	prof.push('side draw')
	color()
	love.graphics.draw(self.spr,self.x,self.y,math.rad(self.angle),1,1,12,10)
	prof.pop('side draw')
end

return Side
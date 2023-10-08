Side = class ('Side', Beat)

function Side:initialize(params)
	
	self.sidehityet = false
	self.timingwindow = 200
	self.skipoverwindow = 90 -- changed from 60, now you simply have to be on the same side
	
	Beat.initialize(self,params)
	
	self.name = 'side'
	self.positionoffset = 10
	self.spr = sprites.beat.side
end

function Side:update(dt) --todo: split this into functions, so other beat types can use this code
  prof.push('side update')
	
  self:updateprogress()
  self:updateangle()
  
	self:updatepositions()
	
	local timeuntil = self.hb - cs.cbeat --positive = hasnt arrived yet, negative = has arrived
	local twindow = Gamemanager:mstobeat(self.timingwindow/2) -- should be ~1/4 of a beat at lawrence's BPM
	
	
	local nowdistance = helpers.angdistance(self.angle,cs.p.angle) 
	local prevdistance = helpers.angdistance(self.angle,cs.p.angleprevframe)
	
	local hitthisframe = (nowdistance <= cs.p.paddle_size / 2) -- if the player is currently hitting the sidebeat
	local hitlastframe = (prevdistance <= cs.p.paddle_size / 2) --if the player was hitting the sidebeat last frame
	
	local nowleft = ((self.angle - cs.p.angle) < 0 or (self.angle - cs.p.angle) > 180) 
	local prevleft = ((self.angle - cs.p.angleprevframe) < 0 or (self.angle - cs.p.angleprevframe) > 180) 
	
	local active = math.abs(timeuntil) <= twindow
	
	if not self.sidehityet and active then
		if hitthisframe and (not hitlastframe) then
			self.sidehityet = true
		end
		if (not hitthisframe) and (not hitlastframe) and nowdistance <= self.skipoverwindow and prevdistance <= self.skipoverwindow then -- this accounts for situations where the player skips over the note
			if prevleft then --was the player to the left of the note last frame?
				if not nowleft then --is the player to the right of the note this frame? (left to right)
					self.sidehityet = true
				end
			else
				if nowleft then --is the player to the left of the note this frame? (right to left)
					self.sidehityet = true
				end
			end
		end
	end
	
	if timeuntil <= 0 then -- don't "judge" the player until the beat has passed
		if self.sidehityet == true then
			self:onhit() 
		else
			if timeuntil < twindow*-1 then --if it is not hit at all
				self:onmiss()
			elseif hitthisframe and hitlastframe then --if the beat is hit head on
				self:onmiss(true)
			end
		end
	end
	
	prof.pop('side update')
	
end

function Side:draw()
	prof.push('side draw')
	outline(function()
		color()
		love.graphics.draw(self.spr,self.x,self.y,math.rad(self.angle),1,1,12,10)
	end, cs.outline)
	prof.pop('side draw')
end

return Side
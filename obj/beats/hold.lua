Hold = class ('Hold', Beat)

function Hold:initialize(params)
	
	self.angle2 = 0 
	self.holdease = nil
	self.smult2 = 1
	self.minestripe = false
	
	Beat.initialize(self,params)
	self.name = 'hold'
	self.x2 = self.x
	self.y2 = self.y
	
	self.spr = sprites.beat.hold
end

function Hold:getpositions()
	return Beat.getpositions(self), helpers.rotate((self.hb - cs.cbeat+self.duration)*cs.level.properties.speed*self.smult*self.smult2+cs.extend+cs.length,self.angle2,self.ox,self.oy)
end

function Hold:updateduringhit()
	self.angle = helpers.interpolate(self.endangle,self.angle2,((self.hb - cs.cbeat)*-1)/self.duration, self.holdease)
	local p1 = helpers.rotate(cs.extend+cs.length,self.angle,self.ox,self.oy)
	self.x = p1[1]
	self.y = p1[2]  
end

function Hold:update(dt)
  prof.push('hold update')
	
	self:updateprogress()
	self:updateangle()
	
	self:updatepositions()
	
	if self:checkifactive() then
		
		self:updateduringhit()
		
		if self:checktouchingpaddle(self.angle) then 
			if self.hityet == false then
				self.hityet = true
				pq = pq .. "   started hitting hold"
				if cs.beatsounds then
					te.play(sounds.hold,"static")
				end
				self:makeparticles(true)
			end
			
			if ((self.hb - cs.cbeat)*-1)/self.duration >= 1 then
				self:onhit()
			end
			
		else
			self:onmiss()
		end
	end
	
	
  prof.pop('hold update')
end

function Hold.drawhold(ox, oy, x, y, x2, y2, completion, endangle, angle2, segments, sprite, holdease, htype)
	local newhold = {
		ox = ox, 
		oy = oy,
		x = x,
		y = y,
		x2 = x2,
		y2 = y2,
		endangle = endangle,
		angle2 = angle2 ,
		segments = segments,
		holdease = holdease
	}
	if htype == 'hold' then
		newhold.minestripe = false
		newhold.spr = sprites.beat.hold
	else
		newhold.minestripe = true
		newhold.spr = sprites.beat.minehold
	end
	
	Hold.draw(newhold, completion)
end

function Hold:draw(completion)
  prof.push('hold draw')
	completion = completion or  math.max(0, (cs.cbeat - self.hb) / self.duration)

  -- distances to the beginning and the end of the hold
  local len1 = helpers.distance({self.ox, self.oy}, {self.x, self.y})
  local len2 = helpers.distance({self.ox, self.oy}, {self.x2, self.y2})
  local points = {}

  -- how many segments to draw
  -- based on the beat's angles by default, but can be overridden in the json
  if self.segments == nil then
    if self.holdease == "linear" then
      self.segments = (math.abs(self.angle2 - self.endangle) / 8 + 1)
    else
      self.segments = (math.abs(self.angle2 - self.endangle) + 1)
    end
  end
  for i = 0, self.segments do
    local t = i / self.segments
    local angle_t = t * (1 - completion) + completion
    -- coordinates of the next point
    local nextAngle = math.rad(helpers.interpolate(self.endangle, self.angle2, angle_t, self.holdease) - 90)
    local nextDistance = helpers.lerp(len1, len2, t)
    points[#points+1] = math.cos(nextAngle) * nextDistance + self.ox
    points[#points+1] = math.sin(nextAngle) * nextDistance + self.oy
  end

  -- idk why but sometimes the last point doesn't reach the end of the slider
  -- so add it manually if needed
  if (points[#points] ~= self.y2) then
    points[#points+1] = self.x2
    points[#points+1] = self.y2
  end

  -- need at least 2 points to draw a line ,
  if #points >= 4 then
    -- draw the black outline
    color('black')
    love.graphics.setLineWidth(16)
    love.graphics.line(points)
    -- draw a white line, to make the black actually look like an outline
    color()
    love.graphics.setLineWidth(12)
    love.graphics.line(points)
    --the added line for mine holds
    if self.minestripe then
      color('black')
      love.graphics.setLineWidth(10)
      love.graphics.line(points)
			color()
    end
  else
		error('not enough points!')
	end

  -- draw beginning and end of hold
  love.graphics.draw(self.spr,self.x,self.y,0,1,1,8,8)
  love.graphics.draw(self.spr,self.x2,self.y2,0,1,1,8,8)
	
  prof.pop('hold draw')
end

return Hold
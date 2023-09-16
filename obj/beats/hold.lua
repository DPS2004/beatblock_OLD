Hold = class ('Hold', Beat)

function Hold:initialize(params)
	
	self.angle2 = 0 
	self.holdease = 'linear'
	self.smult2 = 1
	
	Beat.initialize(self,params)
	
	self.x2 = self.x
	self.y2 = self.y
	
	self.spr = sprites.beat.hold
end

function Hold:getpositions()
	return Beat.getpositions(self), helpers.rotate((self.hb - cs.cbeat+self.duration)*cs.level.properties.speed*self.smult*self.smult2+cs.extend+cs.length,self.angle2,self.ox,self.oy)
end

function Hold:update(dt)
  prof.push('hold update')
	
	self:updateprogress()
	self:updateangle()
	
	local p1,p2 = self:getpositions()
	
  self.x = p1[1]
  self.y = p1[2]  
  self.x2 = p2[1]
  self.y2 = p2[2]  
	
	if (self.hb - cs.cbeat) <= 0 then
		if helpers.angdistance(self.angle,cs.p.angle) <= cs.p.paddle_size / 2 then 
			if self.hityet == false then
				self.hityet = true
				pq = pq .. "   started hitting hold"
				if cs.beatsounds then
				te.play(sounds.hold,"static")
				end
			end
			--em.init("hitpart",obj.x,obj.y)
			--print(helpers.angdistance(obj.angle,cs.p.angle).. " is less than " .. cs.p.paddle_size / 2)
			self.angle = helpers.interpolate(self.endangle,self.angle2,((self.hb - cs.cbeat)*-1)/self.duration, self.holdease)
			
			
			p1 = helpers.rotate(cs.extend+cs.length,self.angle,self.ox,self.oy)
			self.x = p1[1]
			self.y = p1[2]  
			
			if ((self.hb - cs.cbeat)*-1)/self.duration >= 1 then
				self:makeparticles(true)
				pq = pq .. "   finished hold!"
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
		else
			self:makeparticles(false)
			pq = pq .. "   player missed hold!"
			cs.misses = cs.misses + 1
			cs.combo = 0
			cs.p.emotimer = 100
			cs.p.cemotion = "miss"

			cs.p:hurtpulse()
			self.delete = true
		end
		
		--[[
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
			local mp = em.init("misspart",{
				x = project.res.cx,
				y = project.res.cy,
				angle = self.angle,
				distance = (self.hb - cs.cbeat)*cs.level.properties.speed+cs.length,
				spr = self.spr
			})
			mp:update(dt)
			self.delete = true
			pq = pq .. "   player missed!"
			cs.misses = cs.misses + 1
			cs.combo = 0
			cs.p.emotimer = 100
			cs.p.cemotion = "miss"

			cs.p:hurtpulse()
		end
		]]--
	end
	
	
  prof.pop('hold update')
end

return Hold
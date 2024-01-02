Minehold = class ('Minehold', Hold)

function Minehold:initialize(params)
	
	
	Hold.initialize(self,params)
	
	self.minestripe = true
	
	self.name = 'mine'
	
	self.spr = sprites.note.minehold
end


function Minehold:update(dt)
  prof.push('minehold update')
	
	self:updateprogress()
	self:updateangle()
	
	self:updatepositions()
	
	if self:checkifactive() then
		
		self:updateduringhit()
		
		if self:checktouchingpaddle(self.angle) then 
			self:onmiss(true)
			
		else
			if ((self.hb - cs.cbeat)*-1)/self.duration >= 1 then
				self:onhit(true)
			end
		end
	end
	
	
  prof.pop('minehold update')
end

return Minehold
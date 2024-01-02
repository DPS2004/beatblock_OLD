Mine = class ('Mine', Block)

function Mine:initialize(params)
	
	
	Block.initialize(self,params)
	
	self.name = 'mine'
	
	self.spr = sprites.note.mine
end

function Mine:update(dt)
  prof.push('mine update')
	
  self:updateprogress()
  self:updateangle()
  
	self:updatepositions()

  if self:checkifactive() then
		if self:checktouchingpaddle(self.endangle) then
			self:onmiss(true)
		else
			self:onhit(true)
		end
	end
	
  prof.pop('mine update')
end

return Mine
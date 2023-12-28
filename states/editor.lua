local st = Gamestate:new('editor')

st:setinit(function(self)
  --em.init('templateobj',{x=128,y=72})
	
  self.gm = em.init("gamemanager")

  self.canv = love.graphics.newCanvas(project.res.x,project.res.y)

  self.level = Levelmanager:loadlevel(clevel)
	self.editmode = true
  self.gm:resetlevel()
	
	self.holdentitydraw = true
end)


function st:leave()
  entities = {}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end

function st.resume()

end


st:setupdate(function(self,dt)
  if not paused then
		--self.gm:update(dt)
		
		
    if maininput:pressed("back") then
			self:leave()
      cs = bs.load('songselect')
			cs:init()
    end
		
		
		
		
  end
end)



st:setfgdraw(function(self)

  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
  love.graphics.setCanvas(self.canv)
  
	if self.editmode then
		self.gm:draw()
		
	else
	
	end
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canv)
  if pq ~= "" then
    print(helpers.round(self.cbeat*8,true)/8 .. pq)
  end

end)


return st
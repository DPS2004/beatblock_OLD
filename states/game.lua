local st = Gamestate:new('game')

st:setinit(function(self)
	
  self.gm = em.init("gamemanager")

  self.canv = love.graphics.newCanvas(gameWidth,gameHeight)

  self.level = dpf.loadjson(clevel .. "level.json")
  self.gm.resetlevel()
  self.gm.on = true
	
	self.holdentitydraw = true
end)


function st:leave()
  entities = {}
  if st.source ~= nil then
    st.source:stop()
    st.source = nil
  end
  st.sounddata = nil
end

function st:gotoresults()
	cs = bs.load('results')
	--transfer data
	cs.level = self.level
	cs.misses = self.misses
	cs.maxhits = self.maxhits
	
	self:leave()
	cs:init()
	
end

function st.resume()

end


st:setupdate(function(self,dt)
  if not paused then
		self.gm:update(dt)
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
  
		self.gm:draw()
    --helpers.drawgame()
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canv)
  if pq ~= "" then
    print(helpers.round(self.cbeat*8,true)/8 .. pq)
  end

end)


return st
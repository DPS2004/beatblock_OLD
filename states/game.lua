local st = Gamestate:new('game')

st:setinit(function(self)
	
  self.gm = em.init("gamemanager")

  self.canv = love.graphics.newCanvas(project.res.x,project.res.y)

  self.level = dpf.loadjson(clevel .. "level.json")
	if self.level.properties.formatversion then
		if self.level.properties.formatversion >= 1 then
			self.chart = dpf.loadjson(clevel .. "chart.json")
		end
	end
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
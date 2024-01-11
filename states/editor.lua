local st = Gamestate:new('editor')

st:setinit(function(self)
  --em.init('templateobj',{x=128,y=72})
	
  self.gm = em.init("gamemanager")

  self.canv = love.graphics.newCanvas(project.res.x,project.res.y)

  self.level, self.forcesaveboth = Levelmanager:loadlevel(clevel)
	self.editmode = true
  self.gm:resetlevel()
	
	self.holdentitydraw = true

	self.zoom = self.level.properties.speed or 40
	self.editorbeat = 0
	self.drawdistance = 10

	self.keybinds = {}
	
	--just save chart
	self:addkeybind(function()
			local upgraded = Levelmanager:savelevel(self.level,clevel, self.forcesaveboth)
			if upgraded then
				self.forcesaveboth = false
				print("NOTICE: upgraded format of level.")
			end
			self.p:hurtpulse()
		end,
		'just save chart',
		'ctrl','alt','s'
	)
	
	--save both files
	self:addkeybind(function()
			if not maininput:down('alt') then
				Levelmanager:savelevel(self.level,clevel,true)
				
				self.forcesaveboth = false
				self.p:hurtpulse()
			end
		end,
		'save both files',
		'ctrl','s'
	)
	
	
end)

function st:beattoradius(b)
	local currentbeat = self.editorbeat
	return ((b - currentbeat)*self.zoom)+cs.p.paddle_width + cs.p.paddle_distance
	
end

function st:getposition(a,b)
	return helpers.rotate(self:beattoradius(b),a,project.res.cx,project.res.cy)
end


function st:leave()
  entities = {}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end

function st:addkeybind(func,name,k1,k2,k3)
	table.insert(self.keybinds,{func = func, name = name, k1 = k1, k2 = k2, k3 = k3})
end

function st:checkkeybinds()
	for i,v in ipairs(self.keybinds) do
		if v.k1 and v.k2 and v.k3 then
			if maininput:down(v.k1) and maininput:down(v.k2) and maininput:pressed(v.k3) then
				print('pressed keybind ' .. v.name)
				v.func()
			end
		elseif v.k1 and v.k2 then
			if maininput:down(v.k1) and maininput:pressed(v.k2) then
				print('pressed keybind ' .. v.name)
				v.func()
			end
		else
			if maininput:pressed(v.k1) then
				print('pressed keybind ' .. v.name)
				v.func()
			end
		end
	end
end

st:setupdate(function(self,dt)
  if not paused then
		
		if self.editmode then
			self:checkkeybinds()
			
			if maininput:pressed("back") then
				self:leave()
				cs = bs.load('songselect')
				cs:init()
			end
			
		else
			self.gm:update(dt)
			
			--[[
			if maininput:pressed("back") then
				self:leave()
				cs = bs.load('songselect')
				cs:init()
			end
			]]--
		end
		
		
		
		
  end
end)



st:setfgdraw(function(self)
	--imgui
	if project.useimgui then
		imgui.SetNextWindowPos(950, 50, "ImGuiCond_Once")
		imgui.SetNextWindowSize(250, 600, "ImGuiCond_Once")
		imgui.Begin("Event Editor")
			imgui.Text("Select an event to edit it")
			--self.zoom = imgui.SliderInt("Zoom level", self.zoom, 0, 100);
		
		imgui.End()
	end
  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
  love.graphics.setCanvas(self.canv)
  
	if self.editmode then
		love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
		
		--draw beat lines
		color('black')
		
		love.graphics.setLineWidth(2)
		
		for i=0, self.drawdistance do
			love.graphics.circle("line",project.res.cx,project.res.cy,self:beattoradius(math.ceil(self.editorbeat) + i))
		end
		color()
		
		em.draw() --draw player
		
		for i,v in ipairs(self.level.events) do --draw events
			if v.time >= self.editorbeat and v.time <= self.editorbeat + self.drawdistance then
				if Event.editordraw[v.type] then
					Event.editordraw[v.type](v)
				else
					--fallback
					local pos = self:getposition(v.angle,v.time)
					
					love.graphics.draw(sprites.editor.genericevent,pos[1],pos[2],0,1,1,8,8)
				end
			end
		end
	else
		
		self.gm:draw()
	end
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canv)
  if pq ~= "" then
    print(helpers.round(self.cbeat*8,true)/8 .. pq)
  end

end)


return st
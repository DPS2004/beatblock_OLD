local st = Gamestate:new('editor')

st:setinit(function(self)
  --em.init('templateobj',{x=128,y=72})
	
  self.gm = em.init("gamemanager")

  self.canv = love.graphics.newCanvas(project.res.x,project.res.y)

  self.level, self.forcesaveboth = Levelmanager:loadlevel(clevel)
	self.editmode = true
  self.gm:resetlevel()
	
	self.holdentitydraw = true
	
	shuv.showbadcolors = true

	self.zoom = self.level.properties.speed or 40
	
	self.lasteditorbeat = 0
	self.editorbeat = 0
	self.drawdistance = 10
	
	self.anglesnapvalues = {8,12,16,24,32}
	self.anglesnap = 3
	
	self.beatsnapvalues = {1,2,3,4,6,8,12,16}
	self.beatsnap = 2
	
	self.cursorbeat = 0
	self.cursorangle = 0
	
	self.selectedevent = nil
	self.overlappingevents = nil
	
	self.multiselectstart = nil
	self.multiselectend = nil
	self.multiselect = nil
	
	self.copy = nil
	self.copysize = nil
	
	self.overlappingeventsdialogue = false
	
	self.placeevent = ""
	
	self.eventpalette = {
		{
			name = 'Notes',
			content = {
				'block',
				'hold',
				'inverse',
				'mine',
				'minehold',
			}
		},
		{
			name = 'VFX',
			content = {
			}
		},
		{
			name = 'Other',
			content = {
				'play',
				'showresults'
			}
		},
	}
	
	for i,v in pairs(self.eventpalette) do
		table.insert(v.content,1,'')
	end
	

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
	--copy
	self:addkeybind(function()
			if self.multiselect then
				self.copy = helpers.copy(self.multiselect.events)
				for i,v in ipairs(self.copy) do
					v.time = v.time - self.multiselectstart
				end
				self.copysize = self.multiselectend - self.multiselectstart
				self.p:hurtpulse()
			end
		end,
		'copy',
		'ctrl','c'
	)
	--paste
	self:addkeybind(function()
			if self.copy then
				local newevents = helpers.copy(self.copy)
				
				self.selectedevent = nil
				self.multiselect = {}
				self.multiselect.events = {}
				self.multiselect.eventtypes = {}
				
				for i,v in ipairs(newevents) do
					v.time = v.time + self.cursorbeat
					table.insert(self.level.events,v)
					table.insert(self.multiselect.events,v)
					self.multiselect.eventtypes[v.type] = true
				end
				self.multiselectstart = self.cursorbeat
				self.multiselectend = self.cursorbeat + self.copysize
				
				self.p:hurtpulse()
			end
		end,
		'paste',
		'ctrl','v'
	)
	
	
end)

function st:beattoradius(b)
	local currentbeat = self.editorbeat
	return ((b - currentbeat)*self.zoom)+cs.p.paddle_width + cs.p.paddle_distance
	
end

function st:snapbeat(b)
	if self.beatsnap == 0 then
		return b
	end
	return helpers.round(b*self.beatsnapvalues[self.beatsnap]) / self.beatsnapvalues[self.beatsnap]
end

function st:snapangle(a)
	if self.anglesnap == 0 then
		return a
	end
	return helpers.round(a/(360/self.anglesnapvalues[self.anglesnap])) * (360/self.anglesnapvalues[self.anglesnap])
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
			
			self.cursorangle = (helpers.anglepoints(project.res.cx,project.res.cy,mouse.rx,mouse.ry) + 360) % 360
			self.cursorbeat = math.max((math.sqrt((mouse.rx-project.res.cx)^2+(mouse.ry-project.res.cy)^2) - self:beattoradius(self.editorbeat))/self.zoom, 0) + self.editorbeat
			
			self.cursorangle = self:snapangle(self.cursorangle)
			self.cursorbeat = self:snapbeat(self.cursorbeat)
			if self.cursorbeat < self.editorbeat then
				self.cursorbeat = self.cursorbeat + (1/self.beatsnapvalues[self.beatsnap])
			end
			
			if mouse.sy ~= 0 then
				if maininput:down('ctrl') then
					self.zoom = math.min(math.max(self.zoom+mouse.sy*2,20),100)
				else
					self.lasteditorbeat = self.editorbeat
					self.editorbeat = math.max(self.editorbeat + (mouse.sy * 2) / self.zoom,0)
					if self.beatsnap ~= 0 then
						local snappedbeat = self:snapbeat(self.editorbeat)
						if math.abs(self.editorbeat-snappedbeat) <= 0.05 and math.abs(self.editorbeat-snappedbeat) <= math.abs(self.lasteditorbeat-snappedbeat)then
							self.editorbeat = snappedbeat
						end
					end
				end
			end
			
			if mouse.pressed == -1 then -- on mouse release
				if maininput:down('shift') then --multiselect 
					if (not self.multiselectstart) and (not self.multiselectend) then
						self.multiselectstart = self.cursorbeat
					else
						if not self.multiselectend then
							self.multiselectend = self.cursorbeat
							if self.multiselectend < self.multiselectstart then
								self.multiselectstart, self.multiselectend = self.multiselectend, self.multiselectstart
							end
							
							self.selectedevent = nil
							self.multiselect = {}
							self.multiselect.events = {}
							self.multiselect.eventtypes = {}
							for i,v in ipairs(self.level.events) do
								if v.time >= self.multiselectstart and v.time <= self.multiselectend then 
									table.insert(self.multiselect.events,v)
									self.multiselect.eventtypes[v.type] = true
								end
							end
							
						else
							self.multiselectstart = self.cursorbeat
							self.multiselectend = nil
							self.multiselect = nil
						end
					end
				else --select/place
					self.multiselectstart, self.multiselectend, self.multiselect = nil,nil,nil
					self.overlappingevents = {}
					for i,v in ipairs(self.level.events) do
						if v.time >= self.editorbeat and v.time <= self.editorbeat + self.drawdistance then
							--this should be customizable per-event type like editordraw and editorproperties for holds
							
							local pos = self:getposition(v.angle,v.time)
							if helpers.collide(
								{x = mouse.rx, y = mouse.ry, width = 0, height = 0},
								{x = pos[1] - 8, y = pos[2] - 8, width = 16, height = 16}
							) then
							
								table.insert(self.overlappingevents,i)
								
							end
							
						end
					end
					if #self.overlappingevents == 1 then
						self.selectedevent = self.level.events[self.overlappingevents[1]]
						print('selected ' .. Event.info[self.selectedevent.type].name .. ' event. ' .. self.selectedevent.angle .. '|'.. self.selectedevent.time)
						self.overlappingeventsdialogue = false
					elseif #self.overlappingevents >= 2 then
						print('overlapping events!!')
						self.overlappingeventsdialogue = true
					end
					
					if #self.overlappingevents == 0 then
						--place new event
						if self.placeevent ~= '' then
							table.insert(self.level.events,{type = self.placeevent, time = self.cursorbeat, angle = self.cursorangle})
							self.selectedevent = self.level.events[#self.level.events]
						end
					end
				end
				
			end
			
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
			
			if self.multiselect then
				imgui.Text('Selecting ' .. #self.multiselect.events .. ' events')
				imgui.Separator()
				imgui.Text('Types:')
				for k,_ in pairs(self.multiselect.eventtypes) do
					if imgui.Button('Only##'..k) then
						
						local newevents = {}
						for i,v in ipairs(self.multiselect.events) do
							if v.type == k then
								table.insert(newevents,v)
							end
						end
						
						self.multiselect.events = newevents
						
						self.multiselect.eventtypes = {}
						self.multiselect.eventtypes[k] = true
					end
					imgui.SameLine()
					if imgui.Button('Remove##'..k) then
						
						local newevents = {}
						for i,v in ipairs(self.multiselect.events) do
							if v.type ~= k then
								table.insert(newevents,v)
							end
						end
						
						self.multiselect.events = newevents
						
						self.multiselect.eventtypes[k] = nil
					end
					imgui.SameLine()
					imgui.Text(Event.info[k].name)
					
				end
				
				imgui.Separator()
				local beatstep = 0.01
				local anglestep = 1
				if self.beatsnap ~= 0 then
					beatstep = 1/self.beatsnapvalues[self.beatsnap]
				end
				if self.anglesnap ~= 0 then
					anglestep = 360/self.anglesnapvalues[self.anglesnap]
				end
				
				local deltaangle = 0
				local deltabeat = 0
				local deltascale = 1
				imgui.Text('Rotate all')
				imgui.SameLine()
				if imgui.Button('-##angleminus') then
					deltaangle = deltaangle - anglestep
				end
				imgui.SameLine()
				if imgui.Button('+##angleplus')  then
					deltaangle = deltaangle + anglestep
				end
				
				imgui.Text('Retime all')
				imgui.SameLine()
				if imgui.Button('-##beatminus') then
					deltabeat = deltabeat - beatstep
				end
				imgui.SameLine()
				if imgui.Button('+##beatplus')  then
					deltabeat = deltabeat + beatstep
				end
				
				imgui.Separator()
				
				if imgui.Button('Flip Horiz') then
					deltascale = -1
				end
				imgui.SameLine()
				if imgui.Button('Flip Vert') then
					deltascale = -1
					deltaangle = -180
				end
				
				
				if deltaangle ~= 0 or deltabeat ~= 0 or deltascale ~= 1 then
					for i,v in ipairs(self.multiselect.events) do
						v.angle = v.angle * deltascale + deltaangle
						v.time = v.time + deltabeat
					end
					self.multiselectstart = self.multiselectstart + deltabeat
					self.multiselectend = self.multiselectend + deltabeat
				end
				
				if #self.multiselect.events == 0 then
					self.multiselect = nil
					self.multiselectstart = nil
					self.multiselectend = nil
				end
				
			elseif self.selectedevent then
				imgui.Text("Editing " .. Event.info[self.selectedevent.type].name)
				imgui.Separator()
				
				--default properties that all events have
				local beatstep = 0.01
				local anglestep = 1
				if self.beatsnap ~= 0 then
					beatstep = 1/self.beatsnapvalues[self.beatsnap]
				end
				if self.anglesnap ~= 0 then
					anglestep = 360/self.anglesnapvalues[self.anglesnap]
				end
				Event.property(self.selectedevent, 'decimal', 'time', 'Beat to activate on', {step = beatstep})
				Event.property(self.selectedevent, 'decimal', 'angle', 'Angle to activate at', {step = anglestep})
				
				if Event.editorproperties[self.selectedevent.type] then
					Event.editorproperties[self.selectedevent.type](self.selectedevent)
				end
				imgui.Separator()
				if imgui.Button('Delete event') then
					for i,v in ipairs(self.level.events) do
						if v == self.selectedevent then
							table.remove(self.level.events,i)
							print('deleted event')
							self.selectedevent = nil
							break
						end
					end
				end
				
			else
				imgui.Text("Select an event to edit it")
				
				--self.zoom = imgui.SliderInt("Zoom level", self.zoom, 0, 100);
				
				
			end
		
		
		imgui.SetNextWindowPos(0, 50, "ImGuiCond_Once")
		imgui.SetNextWindowSize(150, 300, "ImGuiCond_Once")
		imgui.Begin("Event palette")
			self.placeevent = imgui.InputText("##placeevent",self.placeevent,9999)
			if imgui.BeginTabBar("Event Type") then

				for i, tab in pairs(self.eventpalette) do
					
					if imgui.BeginTabItem(tab.name) then
						
						
						if imgui.ListBoxHeader('##tab'..tab.name) then
							for ii, v in ipairs(tab.content) do
								local displayeventname = 'None'
								local eventname = v
								if v ~= '' then
									displayeventname = Event.info[v].name
								end
								
								local selected = (self.placeevent == eventname)
								
								if imgui.Selectable(displayeventname, selected) then
									self.placeevent = eventname
								end
								
								if selected then
									imgui.SetItemDefaultFocus()
								end
								
							end
							imgui.ListBoxFooter()
						end
						
						
						imgui.EndTabItem()
					end
				end
			
				imgui.EndTabBar()
			end
		
		if self.overlappingeventsdialogue then
			self.overlappingeventsdialogue = imgui.Begin("Overlapping events!",true)
			
			imgui.Text("Select which event to edit:")
			imgui.Separator()
			for i,v in ipairs(self.overlappingevents) do
				local e = self.level.events[v]
				if imgui.Selectable(Event.info[e.type].name .. ' (ID '.. v..')') then
					self.overlappingeventsdialogue = false
					self.selectedevent = self.level.events[v]
				end
			end
		end
		
		
		imgui.End()
		
		imgui.SetNextWindowPos(0, 630, "ImGuiCond_Once")
		imgui.SetNextWindowSize(150, 90, "ImGuiCond_Once")
		imgui.Begin("Snap")
			--angle
			local anglesnaptext = 'None'
			
			if imgui.Button('-##angleminus') then
				self.anglesnap = self.anglesnap - 1 
			end
			imgui.SameLine()
			if imgui.Button('+##angleplus')  then
				self.anglesnap = self.anglesnap + 1 
			end
			
			if self.anglesnap == -1 then
				self.anglesnap = #self.anglesnapvalues
			elseif self.anglesnap > #self.anglesnapvalues then
				self.anglesnap = 0
			end
			
			if self.anglesnap ~= 0 then
				anglesnaptext = '1/' .. self.anglesnapvalues[self.anglesnap]
			end
			
			imgui.SameLine()
			imgui.Text("Angle: " .. anglesnaptext)
			imgui.Separator()
			
			--beat
			local beatsnaptext = 'None'
			
			if imgui.Button('-##beatminus') then
				self.beatsnap = self.beatsnap - 1 
			end
			imgui.SameLine()
			if imgui.Button('+##beatplus')  then
				self.beatsnap = self.beatsnap + 1 
			end
			
			if self.beatsnap == -1 then
				self.beatsnap = #self.beatsnapvalues
			elseif self.beatsnap > #self.beatsnapvalues then
				self.beatsnap = 0
			end
			
			if self.beatsnap ~= 0 then
				beatsnaptext = '1/' .. self.beatsnapvalues[self.beatsnap]
			end
			
			imgui.SameLine()
			imgui.Text("Beat: " .. beatsnaptext)
		imgui.End()
	end
  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
  love.graphics.setCanvas(self.canv)
  
	if self.editmode then
		love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
		
		
		love.graphics.setLineWidth(2)
		love.graphics.setColor(0.75,0.75,0.75,1)
		--draw angle snap lines
		if self.anglesnap ~= 0 then
			for i=0,self.anglesnapvalues[self.anglesnap] - 1 do
				local pos = helpers.rotate(400,i*(360/self.anglesnapvalues[self.anglesnap]),project.res.cx,project.res.cy)
				love.graphics.line(project.res.cx,project.res.cy,pos[1],pos[2])
			end
		end
		
		--draw beat lines / beat snap
		
		
		
		for i=0, self.drawdistance do
			color('black')
			love.graphics.circle("line",project.res.cx,project.res.cy,self:beattoradius(math.ceil(self.editorbeat) + i))
			if self.beatsnap ~= 0 then
				
				love.graphics.setColor(0.75,0.75,0.75,1)
				for ii=1,self.beatsnapvalues[self.beatsnap]-1 do
					local snaprad = self:beattoradius(math.floor(self.editorbeat) + i + (ii / self.beatsnapvalues[self.beatsnap]))
					if snaprad > self:beattoradius(self.editorbeat) then
						love.graphics.circle("line",project.res.cx,project.res.cy,snaprad)
					end
				end
			end
		end
		
		color('black')
		love.graphics.circle("line",project.res.cx,project.res.cy,self:beattoradius(self.editorbeat))
		
		
		--multiselect
		love.graphics.setColor(0,1,0,1)
		if self.multiselectstart then
			love.graphics.circle("line",project.res.cx,project.res.cy,self:beattoradius(math.max(self.multiselectstart, self.editorbeat)))
		end
		if self.multiselectend then
			love.graphics.circle("line",project.res.cx,project.res.cy,self:beattoradius(math.max(self.multiselectend, self.editorbeat)))
		end
		
		
		color()
		em.draw() --draw player
		
		for i,v in ipairs(self.level.events) do --draw events
			if v.time >= self.editorbeat and v.time <= self.editorbeat + self.drawdistance then
				
				local pos = self:getposition(v.angle,v.time)
				if Event.editordraw[v.type] then
					Event.editordraw[v.type](v)
				else
					--fallback
					
					love.graphics.draw(sprites.editor.genericevent,pos[1],pos[2],0,1,1,8,8)
				end
				if self.multiselect then
					for ii,vv in ipairs(self.multiselect.events) do
						if v == vv then
							love.graphics.draw(sprites.editor.selected,pos[1],pos[2],0,1,1,11,11)
						end
					end
				end
			end
		end
		--redraw selected event on top
		if self.selectedevent and self.editorbeat <= self.selectedevent.time then
			local pos = self:getposition(self.selectedevent.angle,self.selectedevent.time)
			if Event.editordraw[self.selectedevent.type] then
				Event.editordraw[self.selectedevent.type](self.selectedevent)
			else
				--fallback
				love.graphics.draw(sprites.editor.genericevent,pos[1],pos[2],0,1,1,8,8)
			end
			love.graphics.draw(sprites.editor.selected,pos[1],pos[2],0,1,1,11,11)
		end
		
		
		--draw cursor event
		if self.placeevent ~= '' and not imgui.GetWantCaptureMouse() then
			love.graphics.setColor(1,1,1,0.5)
			local pos = self:getposition(self.cursorangle,self.cursorbeat)
			if Event.editordraw[self.placeevent] then
				Event.editordraw[self.placeevent]({time = self.cursorbeat, angle = self.cursorangle, iscursor = true})
			else
				--fallback
				love.graphics.draw(sprites.editor.genericevent,pos[1],pos[2],0,1,1,8,8)
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
local st = Gamestate:new('editor_old')


st:setinit(function(self)
  --self.p = em.init("player",{x=project.res.cx,y=project.res.cy})
  self.gm = em.init("gamemanager",{x=project.res.cx,y=project.res.cy})
	
  if clevel == nil then
    self.level = {
      bpm = 100,
      events = {},
      offset = 0,
      startbeat = 0,
    }
  else
    self.level = dpf.loadjson(clevel.."level.json",{})
  end
	
  self.editmode = true
	
  self.gm:resetlevel()

  self.canv = love.graphics.newCanvas(project.res.x,project.res.y)





  --Editor-specific
  self.beatcirclestartrad = 85 --Starting radius of the first beatcircle (the distance of one beat out from the center)
  self.beatcircleminrad = 35 --Minimum radius of a beatcircle to be drawn
  self.beatcirclemaxrad = 800 --Maximum radius of a beatcircle to be drawn
  self.beatcircledistance = 5 --The distance between beat circles

  self.cursortype = "beat"
  self.beatsnap = 0.5
  self.degreesnap = 15
  self.degreesnaptextbox = false
  self.degreesnaptypedtext = ""
  self.cursorpos = {angle = 0, beat = 0}
  self.scrollpos = 0 --Where you are in the song
  self.scrollzoom = 1
  self.scrolldir = 0 --Used for mouse scrolling
  self.beatcircles = {}
  
  --for dragging events
  self.draggingeventindex = nil
  self.draggingeventpart = nil
  
  self.draggingeventmoved = false
  self.openpup = false
  
  --for editor UI
  self.cursoruiindex = nil --the area the cursor is in
  self.cursorpresseduiindex = nil --the area the cursor was in when it was pressed
  self.currenttab = "tab1" --the current tab
  self.currentpaletteindex = "palette1" --the current palette index
  self.editorsuppression = false
  self.moduleindex = nil --the currently editing field (modules)
  self.editingtext = nil
  self.resetsuppressionnextframe = false
  
  self.selectedeventindex = nil
  
  --self.state = "free" --r MAKE SURE TO CHECK FOR THE FREE STATE BEFORE ADDING A NEW KEYBIND (free state means a text box isn't currently selected or anything)

  for i=1,5000,1 do
    self.beatcircles[i] = 1
  end
	
	self.holdentitydraw = true
	shuv.showbadcolors = true
end)


function st:leave()
  entities = {}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end


function st:playlevel()
  self.editmode = false
  self.gm:resetlevel()
  --self.gm.on = true
end

function st:stoplevel()
  self.editmode = true
  self.startbeat = 0
  self.gm:resetlevel()
  --self.gm.on = false
  
  entities = {self.p}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end



function st:savelevel()
	--does not account for new format
  dpf.savejson(clevel.."level.json",self.level)
end


--"module" stuff, was originally in update
--editor UI
--module functions
function st:newmodule(eventid,modifyingvariable,moduletype,posy)
	if helpers.tablematch(moduletype,{"textinput", "numberinput", "textinputwithtoggle", "numberinputwithtoggle"}) then
		--if the cursor is hovering over the textbox, set self.cursoruiindex to "module" .. modifyingvariable .. "textbox"
		if helpers.inrect(350,397,posy+20-9,posy+32-9,mouse.rx,mouse.ry) then
			self.cursoruiindex = "module" .. modifyingvariable .. "textbox"
		end
		--if the textbox is being edited, set self.editingtext to self.level.events[eventid][modifyingvariable] if self.editingtext is nil, else self.editingtext = self.editingtext .. tinput
		if self.moduleindex == "module" .. modifyingvariable .. "textbox" then
			if self.editingtext == nil then
				self.editingtext = tostring(self.level.events[eventid][modifyingvariable])
			end
			self.editingtext = self.editingtext .. tinput
			if maininput:pressed("backspace") then
				self.editingtext = string.sub(self.editingtext,1,-2)
			end
			self.editorsuppression = true
			--if the textbox is being edited and the mouse is pressed outside of the textbox, set self.level.events[eventid][modifyingvariable] to self.editingtext, then set self.editingtext to nil
			if (self.cursoruiindex ~= self.moduleindex and maininput:released("mouse1")) or maininput:pressed("back") or maininput:pressed("accept") then
				if moduletype == "numberinput" or moduletype == "numberinputwithtoggle" then
					self.level.events[eventid][modifyingvariable] = tonumber(self.editingtext)
				else
					self.level.events[eventid][modifyingvariable] = self.editingtext
				end
				self.editingtext = nil
				self.moduleindex = nil
				self.resetsuppressionnextframe = true
			end
		end
	elseif moduletype == "easing" then
	end
end

function st:drawmodule(eventid,modifyingvariable,moduletype,posy,header)
	love.graphics.setFont(fonts.main)
	--draw the header
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf(header, 351, posy-2, project.res.cx * 2, "left", 0, 1, 1)
	love.graphics.setColor(1, 1, 1, 1)
	if helpers.tablematch(moduletype,{"textinput", "numberinput", "textinputwithtoggle", "numberinputwithtoggle"}) then
		--draw the textbox
		love.graphics.draw(sprites.editor.TextBox,350,posy+11)
		--check if a textbox is being edited, and if so if the textbox being edited is this one
		if self.moduleindex == "module" .. modifyingvariable .. "textbox" and self.editingtext ~= nil then
			--if so, draw the current text
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(self.editingtext .. "|", 352, posy+9, project.res.cx * 2, "left", 0, 1, 1)
			love.graphics.setColor(1, 1, 1, 1)
		--elsewise, draw the current value
		else
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(tostring(self.level.events[eventid][modifyingvariable]), 352, posy+9, project.res.cx * 2, "left", 0, 1, 1)
			love.graphics.setColor(1, 1, 1, 1)
		end
		
	elseif moduletype == "easing" then
	end
	love.graphics.setFont(fonts.digitaldisco)
end

function st:eventsintab(tab)
	if tab == "tab1" then
		return 1 --the number of events in tab 1
	elseif tab == "tab2" then
		return 6 --the number of events in tab 2
	elseif tab == "tab3" then
		return 1 --the number of events in tab 3
	elseif tab == "tab4" then
		return 1 --the number of events in tab 4
	end
end--what.



--The radius of beatcircle [beat]
function st:beattoscrollrad(beat)
  return self.beatcirclestartrad - (self.scrollpos - self.beatcircledistance * beat) * (self.scrollzoom * 10)
end

--Find the beat that's nearest to the given radius
function st:scrollradtobeat(rad, snap)
  local nearestbeat = 0
  --Should beat snap be taken into account?
  local snapfactor = (snap and self.beatsnap) or 0
  while self:beattoscrollrad(nearestbeat + snapfactor)  < rad do
    nearestbeat = nearestbeat + self.beatsnap
  end
  return nearestbeat
end

--Delete the first event that overlaps the cursor's current position
function st:deleteeventatcursor()
  local delindex = nil
  for i,v in ipairs(self.level.events) do
    if v.type ~= "hold" and v.type ~= "minehold" then
      if v.time == self.cursorpos.beat then
        local evangle = v.endangle or v.angle or nil
        if evangle ~= nil then
          if v.type == "sliceinvert" then
            evangle = evangle + 180
          end
          if evangle % 360 == self.cursorpos.angle % 360  then
            delindex = i
            break
          end
        end
      end
    else
      if v.time == self.cursorpos.beat then
        local evangle = v.angle1 or nil
        if evangle ~= nil and evangle % 360 == self.cursorpos.angle % 360 then
          delindex = i
          break
        end
      elseif v.time + v.duration == self.cursorpos.beat then
        local evangle = v.angle2 or nil
        if evangle ~= nil and evangle % 360 == self.cursorpos.angle % 360 then
          delindex = i
          break
        end
      end
    end
    
  end
  
  --added line: deselect deleted event
  self.selectedeventindex = nil

  if delindex ~= nil then
    table.remove(self.level.events, delindex)
  end
end
--find the first event at the cursor
function st:findeventatcursor()
  local returndex = nil
  for i,v in ipairs(self.level.events) do
    if v.type ~= "hold" and v.type ~= "minehold" then
      if v.time == self.cursorpos.beat then
      
        local evangle = v.endangle or v.angle or nil
        if evangle ~= nil then
          if v.type == "sliceinvert" then
            evangle = evangle + 180
          end
          if evangle % 360 == self.cursorpos.angle % 360  then
            returndex = i
            break
          end
        end
      end
    else
      if v.time == self.cursorpos.beat then
        local evangle = v.angle1 or nil
        if evangle ~= nil and evangle % 360 == self.cursorpos.angle % 360 then
          returndex = i
          break
        end
      elseif v.time + v.duration == self.cursorpos.beat then
        local evangle = v.angle2 or nil
        if evangle ~= nil and evangle % 360 == self.cursorpos.angle % 360 then
          returndex = i
          break
        end
      end
    end
    
  end

  return returndex
end
--determine if a hold on the cursor is a hold start or hold end
function st:findholdtypeatcursor()
  local returndex = nil
  for i,v in ipairs(self.level.events) do
    if v.type ~= "hold" and v.type ~= "minehold" then
      returndex = nil
    else
      if v.time == self.cursorpos.beat then
        local evangle = v.angle1 or nil
        if evangle ~= nil and evangle % 360 == self.cursorpos.angle % 360 then
          returndex = "holdstart"
          break
        end
      elseif v.time + v.duration == self.cursorpos.beat then
        local evangle = v.angle2 or nil
        if evangle ~= nil and evangle % 360 == self.cursorpos.angle % 360 then
          returndex = "holdend"
          break
        end
      end
    end
    
  end

  return returndex
end

--Add an event of type [type] at the cursor's current position
function st:addeventatcursor(type)
  local newevent = {time = self.cursorpos.beat, type = type}
  if type == "beat" or type == "inverse" or type == "slice" or type == "sliceinvert" or type == "mine" or type == "side" then
    local evangle = self.cursorpos.angle
    if type == "sliceinvert" then
      evangle = (evangle + 180) % 360 --Sliceinverts are weird
    end
    newevent.angle = evangle
    newevent.endangle = evangle
    newevent.speedmult = 1
  elseif type == "hold" or "minehold" then
    --Barebones hold addition. Need to be able to set both angles
    newevent.angle1 = self.cursorpos.angle
    newevent.angle2 = self.cursorpos.angle
    newevent.duration = 1
    newevent.speedmult = 1
  end

  table.insert(self.level.events, 1, newevent)
  
  --added line: select new event
  self.selectedeventindex = self:findeventatcursor()  
end

st:setupdate(function(self,dt)
  if not paused then
    if maininput:pressed("back") then
      if self.editmode and self.selectedeventindex == nil then
        paused = true
        local pup = em.init("popup",{
					x=project.res.cx,
					y=project.res.cy,
					text = loc.get("savewarning"),
					w=200,
					h=100
				})
        pup:newbutton({x=100,y=50,w=50,h=16,text=loc.get("save"),onclick = function() self:savelevel() paused = false pup.delete = true self:leave() cs = bs.load('songselect') cs:init() end})
        pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("dontsave"),onclick = function() paused = false pup.delete = true self:leave() cs = bs.load('songselect') cs:init() end})
        pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
      else
        self:stoplevel()
      end
    end

    --Below only applies while in edit mode
    if self.editmode then
      --local mouseX = love.mouse.getX()/shuv.scale
      --local mouseY = love.mouse.getY()/shuv.scale
    
      local mouseangle = (math.deg(math.atan2(mouse.ry - project.res.cy, mouse.rx - project.res.cx)) + 90)
      local mouserad = helpers.distance({project.res.cx, project.res.cy}, {mouse.rx, mouse.ry})
    
      --The angle that's nearest to the cursor
      local nearestangle = math.floor((mouseangle / self.degreesnap) + 0.5) * self.degreesnap
    
      self.cursorpos.angle = nearestangle % 360
      self.cursorpos.beat = self:scrollradtobeat(mouserad+10, true)
			--move to play mode
      if maininput:pressed("p") and self.editingtext == nil then
        if maininput:down("shift") then
          self.startbeat = self:scrollradtobeat((self.beatcircleminrad + self.beatcirclestartrad) * self.scrollzoom, false)
        else
          self.startbeat = 0
        end
        self:playlevel()
      end
      

      --Hotkeys
			--Pretty much this whole block should get rewritten!!!!!!!
      if maininput:down("ctrl") then
        if maininput:pressed("r") then
          print("ctrl+r")
          paused = true

          local pup = em.init("popup",{
						x = project.res.cx,
						y = project.res.cy,
						text = loc.get("refreshwarning"),
						w=200,
						h=100
					})
          pup:newbutton({x=100,y=90,w=16,h=16,text=loc.get("ok"),onclick = function() cs.level = dpf.loadjson(clevel.."level.json",{}) paused = false pup.delete = true end})
          pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
        end
        if maininput:pressed("s") then
          self:savelevel()
          self.p.hurtpulse() --Little animation to confirm that you indeed saved
        end
        --zoom
        if self.scrolldir == 1 then
          self.scrollzoom = self.scrollzoom + 0.5
        end
        if self.scrolldir == -1 then
          self.scrollzoom = self.scrollzoom - 0.5
        end
      elseif self.editingtext == nil then
        -- Set type of event on cursor
        if maininput:pressed("k1") then
          self.cursortype = "beat"
        end
      
        if maininput:pressed("k2") then
          self.cursortype = "inverse"
        end
      
        if maininput:pressed("k3") then
          self.cursortype = "hold"
        end
      
        if maininput:pressed("k4") then
          self.cursortype = "slice"
        end
      
        if maininput:pressed("k5") then
          self.cursortype = "sliceinvert"
        end
      
        if maininput:pressed("k6") then
          self.cursortype = "mine"
        end
      
        if maininput:pressed("k7") then
          self.cursortype = "side"
        end
      
        if maininput:pressed("k8") then
          self.cursortype = "minehold"
        end

        --Set zoom
        if maininput:pressed("up") then
          self.scrollzoom = self.scrollzoom + 0.5
        end
      
        if maininput:pressed("down") then
          self.scrollzoom = self.scrollzoom - 0.5
        end
				
        --change hold easing with , and . and /
				local chold = self:findholdtypeatcursor()
				if chold then
					local cevent = self.level.events[self:findeventatcursor()]
					if maininput:pressed("comma") then
						if cevent.holdease ~= "InQuad" then
							cevent.holdease = "InQuad"
						else
							cevent.holdease = "Linear"
						end
					end
					
					if maininput:pressed("period") then
						if cevent.holdease ~= "OutQuad" then
							cevent.holdease = "OutQuad"
						else
							cevent.holdease = "Linear"
						end
					end
					
					if maininput:pressed("slash") then
						if cevent.holdease ~= "InOutQuad" then
							cevent.holdease = "InOutQuad"
						else
							cevent.holdease = "Linear"
						end
					end
				end

        --Beat snap
        if maininput:pressed("minus") then
          if self.beatsnap == 1 then
            self.beatsnap = 0.5
          elseif self.beatsnap == 0.5 then
            self.beatsnap = 0.3333
          elseif self.beatsnap == 0.3333 then
            self.beatsnap = 0.25
          elseif self.beatsnap == 0.25 then
            self.beatsnap = 0.1666
          elseif self.beatsnap == 0.1666 then
            self.beatsnap = 0.125
          end
        end

        if maininput:pressed("plus") then
          if self.beatsnap == 0.125 then
            self.beatsnap = 0.1666
          elseif self.beatsnap == 0.1666 then
            self.beatsnap = 0.25
          elseif self.beatsnap == 0.25 then
            self.beatsnap = 0.3333
          elseif self.beatsnap == 0.3333 then
            self.beatsnap = 0.5
          elseif self.beatsnap == 0.5 then
            self.beatsnap = 1
          end
        end

        --Angle snap
        if maininput:pressed("rightbracket") then
          if self.degreesnap == 5 then
            self.degreesnap = 5.625
          elseif self.degreesnap == 5.625 then
            self.degreesnap = 7.5
          elseif self.degreesnap == 7.5 then
            self.degreesnap = 11.25
          elseif self.degreesnap == 11.25 then
            self.degreesnap = 15
          elseif self.degreesnap == 15 then
            self.degreesnap = 22.5
          elseif self.degreesnap == 22.5 then
            self.degreesnap = 30
          elseif self.degreesnap == 30 then
            self.degreesnap = 45
          elseif self.degreesnap == 45 then
            self.degreesnap = 90
          elseif self.degreesnap == 90 then
            self.degreesnaptextbox = true
          else
            self.degreesnap = 90
          end
        end

        if maininput:pressed("leftbracket") then
          if self.degreesnap == 90 then
            self.degreesnap = 45
          elseif self.degreesnap == 45 then
            self.degreesnap = 30
          elseif self.degreesnap == 30 then
            self.degreesnap = 22.5
          elseif self.degreesnap == 22.5 then
            self.degreesnap = 15
          elseif self.degreesnap == 15 then
            self.degreesnap = 11.25
          elseif self.degreesnap == 11.25 then
            self.degreesnap = 7.5
          elseif self.degreesnap == 7.5 then
            self.degreesnap = 5.625
          else
            self.degreesnap = 5
          end
        end

        if maininput:pressed("back") then
          self.selectedeventindex = nil
        end

        --Adding/deleting/dragging events
        if maininput:pressed("mouse1") and not self.editorsuppression then
          self.draggingeventindex = self:findeventatcursor()
          self.draggingeventpart = self:findholdtypeatcursor()
        end
				local draggingevent = nil
				if self.draggingeventindex then
					draggingevent = self.level.events[self.draggingeventindex]
				end

        if maininput:down("mouse1") and self.draggingeventindex and not self.editorsuppression then
					
          if not helpers.tablematch(draggingevent.type,{'hold','minehold'}) then
            
            local endangle = draggingevent.endangle
            local startbeat = draggingevent.time
            
            if draggingevent.type ~= "sliceinvert" then
              --editing not holds nor sliceinverts
              draggingevent.endangle = self.cursorpos.angle
              draggingevent.time = self.cursorpos.beat
            else
              --editing sliceinverts
              draggingevent.endangle = -(180 - self.cursorpos.angle)
              draggingevent.time = self.cursorpos.beat
            end

            if (endangle ~= draggingevent.endangle) or (startbeat ~= draggingevent.time) then
              self.draggingeventmoved = true
            end

          else

            --holds
            local angle1 = draggingevent.angle1
            local angle2 = draggingevent.angle2
            local startbeat = draggingevent.time
            local duration = draggingevent.duration

            if self.draggingeventpart == "holdstart" then
              --editing hold starts
              if (angle1 % 360) ~= self.cursorpos.angle then 
                if math.abs(self.cursorpos.angle - (angle1 % 360)) > 180 then
                  if (self.cursorpos.angle - (angle1 % 360)) < 0 then
                    angle1 = angle1 + 360 + self.cursorpos.angle - (angle1 % 360)
                  else
                    angle1 = angle1 - 360 + self.cursorpos.angle - (angle1 % 360)
                  end
                else
                  angle1 = angle1 + self.cursorpos.angle - (angle1 % 360)
                end
              end

              duration = duration + startbeat - self.cursorpos.beat
              startbeat = self.cursorpos.beat
              if duration < 0 then
                angle2, angle1 = angle1, angle2
                startbeat = startbeat + duration
                duration = -duration
                self.draggingeventpart = "holdend"
              end

            else
              --editing hold ends
              if (angle2 % 360) ~= self.cursorpos.angle then 
                if math.abs(self.cursorpos.angle - (angle2 % 360)) > 180 then
                  if (self.cursorpos.angle - (angle2 % 360)) < 0 then
                    angle2 = angle2 + 360 + self.cursorpos.angle - (angle2 % 360)
                  else
                    angle2 = angle2 - 360 + self.cursorpos.angle - (angle2 % 360)
                  end
                else
                  angle2 = angle2 + self.cursorpos.angle - (angle2 % 360)
                end
              end

              duration = self.cursorpos.beat - startbeat
              if duration < 0 then
                angle2, angle1 = angle1, angle2
                startbeat = startbeat + duration
                duration = -duration
                self.draggingeventpart = "holdstart"
              end
            end

            if
            (draggingevent.angle1 ~= angle1) or
            (draggingevent.angle2 ~= angle2) or
            (draggingevent.time ~= startbeat) or
            (draggingevent ~= duration) then
              self.draggingeventmoved = true
            end

            draggingevent.angle1 = angle1
            draggingevent.angle2 = angle2
            draggingevent.time = startbeat
            draggingevent.duration = duration

          end

        end

        if maininput:released("mouse1") and not self.editorsuppression then
          if self.draggingeventindex then

            --change the angle of angle1 and angle2 until angle1 is between 0 and 360 degrees
            if self.draggingeventpart == "holdstart" or self.draggingeventpart == "holdend" then
              while draggingevent.angle1 >= 360 do
                draggingevent.angle1 = draggingevent.angle1 - 360
                draggingevent.angle2 = draggingevent.angle2 - 360
              end
              while draggingevent.angle1 < 0 do
                draggingevent.angle1 = draggingevent.angle1 + 360
                draggingevent.angle2 = draggingevent.angle2 + 360
              end
            end
						--currently dragging event wasn't moved? select the event!
						if self.draggingeventmoved == false then
							self.selectedeventindex = self.draggingeventindex
						else
							self.draggingeventmoved = false
						end

						self.draggingeventindex = nil
						self.draggingeventpart = nil

          else
            self:deleteeventatcursor()
            self:addeventatcursor(self.cursortype)
          end
        end
      
        if maininput:released("mouse2") and not self.editorsuppression then
          self:deleteeventatcursor()
        end
        -- edit events with e or mid click
        if maininput:pressed("e") or maininput:pressed("mouse3") or self.openpup == true then
          self.openpup = false
          self.eventindex = self:findeventatcursor()
          if self.eventindex then
            if helpers.tablematch(self.level.events[self.eventindex].type,{'hold','minehold'}) then
              paused = true
              local pos = helpers.rotate(self:beattoscrollrad(self.cursorpos.beat), self.cursorpos.angle, project.res.cx, project.res.cy)
              local pup = em.init("popup",{
								x=project.res.cx,
								y=project.res.cy,
								text = loc.get("editwhat"),
								w = 200,
								h = 170
							})
              pup:newbutton({x=100,y=40,w=50,h=16,text=loc.get("angle1"),onclick = function() 
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("angle1") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].angle1),y=50,show=true,numberonly=true, allowminus=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].angle1 = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=60,w=50,h=16,text=loc.get("angle2"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("angle2") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].angle2),y=50,show=true,numberonly=true, allowminus=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].angle2 = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
                pup:newbutton({x=100,y=80,w=50,h=16,text=loc.get("holdease"),onclick = function()   
                  pup.h = 100 
                  pup.text = loc.get("editing") .. " " .. loc.get("holdease") .. ":"
                  pup.buttons = {}
                  pup.textinput= {text=tostring(self.level.events[self.eventindex].holdease or ""),y=50,show=true,numberonly=false}
                  pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].holdease =   pup.textinput.text paused = false pup.delete = true end})
                  pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=100,w=50,h=16,text=loc.get("duration"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("duration") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].duration),y=50,show=true,numberonly=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].duration = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=120,w=50,h=16,text=loc.get("time"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("time") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].time),y=50,show=true,numberonly=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].time = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=140,w=100,h=16,text=loc.get("speedmult"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("speedmult") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].speedmult),y=50,show=true,numberonly=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].speedmult = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=160,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
            elseif self.level.events[self.eventindex].type == "beat" or self.level.events[self.eventindex].type == "slice" or self.level.events[self.eventindex].type == "sliceinvert" or self.level.events[self.eventindex].type == "inverse" or self.level.events[self.eventindex].type == "mine" or self.level.events[self.eventindex].type == "side" then
paused = true
              local pos = helpers.rotate(self:beattoscrollrad(self.cursorpos.beat), self.cursorpos.angle, project.res.cx, project.res.cy)
              local pup = em.init("popup",{
								x = project.res.cx,
								y = project.res.cy,
								text = loc.get("editwhat"),
								w = 200,
								h=150,
							})
              pup:newbutton({x=100,y=60,w=60,h=16,text=loc.get("startangle"),onclick = function() 
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("startangle") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].angle),y=50,show=true,numberonly=true, allowminus=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].angle = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=80,w=50,h=16,text=loc.get("endangle"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("endangle") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].endangle or self.level.events[self.eventindex].angle),y=50,show=true,numberonly=true, allowminus=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].endangle = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=100,w=50,h=16,text=loc.get("time"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("time") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].time),y=50,show=true,numberonly=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].hb = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=120,w=100,h=16,text=loc.get("speedmult"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("speedmult") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(self.level.events[self.eventindex].speedmult),y=50,show=true,numberonly=true}
                pup:newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[self.eventindex].speedmult = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup:newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup:newbutton({x=100,y=140,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
            
              
            end
            
          end
        end
      end
    

      
        
      if self.resetsuppressionnextframe then
        self.editorsuppression = false
          self.resetsuppressionnextframe = false
        end
      self.cursoruiindex = nil
      
      if self.selectedeventindex == nil then
        self.editingtext = nil
      end
      
      local regspace = 23 --this is just for spacing out modules
      
      --place the modules
      if self.selectedeventindex ~= nil then
        local et = self.level.events[self.selectedeventindex].type
				if helpers.tablematch(et,{'beat','inverse','side','mine','slice','sliceinvert'}) then
          self:newmodule(self.selectedeventindex,"time","numberinput",28)
          self:newmodule(self.selectedeventindex,"endangle","numberinput",28 + regspace)
          self:newmodule(self.selectedeventindex,"angle","numberinput",28 + (2*regspace))
          self:newmodule(self.selectedeventindex,"speedmult","numberinput",28 + (3*regspace))
        elseif helpers.tablematch(et,{'hold','minehold'}) then
          self:newmodule(self.selectedeventindex,"time","numberinput",28)
          self:newmodule(self.selectedeventindex,"duration","numberinput",28 + regspace)
          self:newmodule(self.selectedeventindex,"angle1","numberinput",28 + (2*regspace))
          self:newmodule(self.selectedeventindex,"angle2","numberinput",28 + (3*regspace))
          self:newmodule(self.selectedeventindex,"holdease","textinput",28 + (4*regspace))
          self:newmodule(self.selectedeventindex,"speedmult","numberinput",28 + (5*regspace))
        end
      end
      
      --figure out what tab the cursor is over
      for i=1,4,1 do
        if helpers.inrect((25*i)-24,(25*i)+1,1,26,mouse.rx,mouse.ry) then
          self.cursoruiindex = "tab" .. tostring(i)
        end
      end
      
      --figure out what palette event the cursor is over
      for i=1,self:eventsintab(self.currenttab),1 do
        if i % 2 == 1 then
          if helpers.inrect(1,26,(25*((i+1)/2))+1,(25*((i+1)/2))+26,mouse.rx,mouse.ry) then
            self.cursoruiindex = "palette" .. tostring(i)
          end
        elseif i % 2 == 0 then
          if helpers.inrect(26,51,(25*(i/2))+1,(25*(i/2))+26,mouse.rx,mouse.ry) then
            self.cursoruiindex = "palette" .. tostring(i)
          end
        end
      end
      
      --play button
      if helpers.inrect(306,346,206,238,mouse.rx,mouse.ry) then
        self.cursoruiindex = "playlevel"
      end
      
      --is the cursor over a bar?
      if self.cursoruiindex == nil then
        if helpers.inrect(1,51,1,238,mouse.rx,mouse.ry) or helpers.inrect(348,398,1,238,mouse.rx,mouse.ry) then
          self.cursoruiindex = "bar"
        end
      end

      if maininput:pressed("mouse1") then
        self.cursorpresseduiindex = self.cursoruiindex
        if self.cursoruiindex ~= nil then
          self.editorsuppression = true
        end
      end

      if maininput:released("mouse1") then
        if self.cursoruiindex == self.cursorpresseduiindex and self.cursoruiindex ~= nil then
          --code for making the buttons do stuff
          if string.sub(self.cursoruiindex,1,3) == "tab" then
            self.currenttab = self.cursoruiindex
            self.currentpaletteindex = "palette1"
          elseif string.sub(self.cursoruiindex,1,7) == "palette" then
            self.currentpaletteindex = self.cursoruiindex
          elseif string.sub(self.cursoruiindex,1,6) == "module" then
            self.moduleindex = self.cursoruiindex
          elseif self.cursoruiindex == "playlevel" then
            self:playlevel()
          end
        elseif self.cursoruiindex == nil then
          self.resetsuppressionnextframe = true
        end
        self.cursorpresseduiindex = nil
      end
      
      if self.cursoruiindex ~= nil and not maininput:down("mouse1") then
        self.editorsuppression = true
      elseif not maininput:down("mouse1") and not self.resetsuppressionnextframe then
        self.editorsuppression = false
      end
      
      --TABS AND PALETTE
      --Events on tab 1
      if self.currenttab == "tab1" then

      --Events on tab 2
      elseif self.currenttab == "tab2" then
        if self.currentpaletteindex == "palette1" then
          self.cursortype = "beat"
        elseif self.currentpaletteindex == "palette2" then
          self.cursortype = "inverse"
        elseif self.currentpaletteindex == "palette3" then
          self.cursortype = "side"
        elseif self.currentpaletteindex == "palette4" then
          self.cursortype = "mine"
        elseif self.currentpaletteindex == "palette5" then
          self.cursortype = "hold"
        elseif self.currentpaletteindex == "palette6" then
          self.cursortype = "minehold"
        end
      elseif self.currenttab == "tab3" then
      elseif self.currenttab == "tab4" then
      end

      --Scroll through level
      self.scrollzoom = helpers.clamp(self.scrollzoom, 0.5, 3)
      
      if self.scrolldir == 1 and not maininput:down("ctrl") then
        if not maininput:down("shift") then
          self.scrollpos = self.scrollpos + 0.5 / self.scrollzoom
        else
          self.scrollpos = self.scrollpos + 5 / self.scrollzoom
        end
      end
    
      if self.scrolldir == -1 and not maininput:down("ctrl") then
        if not maininput:down("shift") then
          self.scrollpos = self.scrollpos - 0.5 / self.scrollzoom
        else
          self.scrollpos = self.scrollpos - 5 / self.scrollzoom
        end
      end
    
      if self.scrollpos < 0 then
        self.scrollpos = 0
      end
    
      if self.scrolldir ~= 0 then
        self.scrolldir = 0
      end
      
      --Scale editor circles based on scroll position and zoom level
      for i,v in ipairs(self.beatcircles) do
        self.beatcircles[i] = self:beattoscrollrad(i - 1)
      end
    
      
    end
		if not self.editmode then
			self.gm:update(dt)
		end
  end
end)


st:setfgdraw(function(self)
  love.graphics.setFont(fonts.digitaldisco)

  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
  love.graphics.setCanvas(self.canv)
    
    self.gm:draw()
    --Only draw the following while in edit mode
    if self.editmode then
      --Beatcircles
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.setLineWidth(2)
      love.graphics.circle("line",project.res.cx,project.res.cy,self.beatcircleminrad)
      for i,v in ipairs(self.beatcircles) do
        if self.beatcircles[i] > self.beatcirclemaxrad then
          break
        end

        if self.beatcircles[i] >= self.beatcircleminrad then
          --Circle
          love.graphics.circle("line",project.res.cx,project.res.cy,self.beatcircles[i])

          --Snap circles
          if i ~= 1 then
            love.graphics.setColor(0, 0, 0, 0.25)
            local snapcircles = math.floor((1 / self.beatsnap) + 0.5)
            for j=1, snapcircles - 1, 1 do
              local snapcirclerad = self:beattoscrollrad(i - 1 - self.beatsnap * j)
              if snapcirclerad >= self.beatcircleminrad then
                love.graphics.circle("line", project.res.cx, project.res.cy, snapcirclerad)
              end
            end
          end

          --Beat number
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.printf(tostring(i), 0, project.res.cy - self.beatcircles[i] - 15, project.res.cx * 2, "center", 0, 1, 1)
        end
      end

      --Snap lines
      love.graphics.setColor(1, 1, 1, 0.25)
      local snaplines = math.floor((360 / self.degreesnap) + 0.5)
      for j=1, snaplines, 1 do
        local snaplinestart = helpers.rotate(math.max(self.beatcircles[1], self.beatcircleminrad), j * self.degreesnap, project.res.cx, project.res.cy)
        local snaplineend = helpers.rotate(self.beatcirclemaxrad, j * self.degreesnap, project.res.cx, project.res.cy)
        love.graphics.line(snaplinestart[1], snaplinestart[2], snaplineend[1], snaplineend[2])
      end

      --Events
      love.graphics.setColor(1, 1, 1, 1)
      for i,v in ipairs(self.level.events) do
        local evrad = self:beattoscrollrad(v.time)
        --Events only drawn if they would appear on screen (i.e. not inside the player at the center or off-screen)
        if evrad <= self.beatcirclemaxrad then
          if evrad >= self.beatcircleminrad then
            if v.type == "beat" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, project.res.cx, project.res.cy)
              love.graphics.draw(sprites.beat.square,pos[1],pos[2],0,1,1,8,8)
  
            elseif v.type == "inverse" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, project.res.cx, project.res.cy)
              love.graphics.draw(sprites.beat.inverse,pos[1],pos[2],0,1,1,8,8)
  
            elseif v.type == "slice" or v.type == "sliceinvert" then
              local angle = v.endangle or v.angle
              local invert = v.type == "sliceinvert"
              helpers.drawslice(project.res.cx, project.res.cy, evrad, angle, invert, 1)

            elseif v.type == "mine" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, project.res.cx, project.res.cy)
              love.graphics.draw(sprites.beat.mine,pos[1],pos[2],0,1,1,8,8)

            elseif v.type == "side" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, project.res.cx, project.res.cy)
              love.graphics.draw(sprites.beat.side,pos[1],pos[2],0,1,1,12,10)

            end
          end
  
          if v.type == "hold" or v.type == "minehold" then
            local evrad2 = self:beattoscrollrad(v.time + v.duration)
            if evrad2 >= self.beatcircleminrad then
              local evrad1 = (evrad >= self.beatcircleminrad and evrad) or self.beatcircleminrad
              local angle1 = v.angle1
              local angle2 = v.angle2
              local pos1 = helpers.rotate(evrad1, angle1, project.res.cx, project.res.cy)
              local pos2 = helpers.rotate(evrad2, angle2, project.res.cx, project.res.cy)
              local completion = math.max(0, (cs.cbeat - 0 ) / v.duration)
              if v.type == "hold" then
                Hold.drawhold(project.res.cx, project.res.cy, pos1[1], pos1[2], pos2[1], pos2[2], completion, angle1, angle2, v.segments, sprites.beat.hold, v.holdease, v.type)
              else
                Hold.drawhold(project.res.cx, project.res.cy, pos1[1], pos1[2], pos2[1], pos2[2], completion, angle1, angle2, v.segments, sprites.beat.minehold, v.holdease, v.type)
              end
            end
          end
        end
      end

      --Cursor
      love.graphics.setColor(1, 1, 1, 0.5)
      local cursorrad = self:beattoscrollrad(self.cursorpos.beat)
      if cursorrad >= self.beatcircleminrad and not self.editorsuppression then
        local angle = self.cursorpos.angle
        local pos = helpers.rotate(cursorrad, angle, project.res.cx, project.res.cy)
        
        if self.cursortype == "beat" then
          love.graphics.draw(sprites.beat.square, pos[1], pos[2],0,1,1,8,8)
        elseif self.cursortype == "inverse" then
          love.graphics.draw(sprites.beat.inverse, pos[1], pos[2],0,1,1,8,8)
        elseif self.cursortype == "mine" then
          love.graphics.draw(sprites.beat.mine, pos[1], pos[2],0,1,1,8,8)
        elseif self.cursortype == "side" then
          love.graphics.draw(sprites.beat.side, pos[1], pos[2],0,1,1,12,10)
        elseif self.cursortype == "hold" then
          love.graphics.draw(sprites.beat.hold, pos[1], pos[2],0,1,1,8,8)
        elseif self.cursortype == "minehold" then
          love.graphics.draw(sprites.beat.minehold, pos[1], pos[2],0,1,1,8,8)
        elseif self.cursortype == "slice" or self.cursortype == "sliceinvert" then
          local sliceangle = angle
          local invert = self.cursortype == "sliceinvert"
          -- I have no idea why it does this
          if invert then
            sliceangle = (sliceangle + 180) % 360
          end
          helpers.drawslice(project.res.cx, project.res.cy, cursorrad, sliceangle, invert, 0.5)
        end
      end

      --editor UI (drawing)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(sprites.editor.Square,1,1)
      love.graphics.draw(sprites.editor.Square,26,1)
      love.graphics.draw(sprites.editor.Square,51,1)
      love.graphics.draw(sprites.editor.Square,76,1)
      love.graphics.draw(sprites.editor.Rect51x26,348,1)
      love.graphics.draw(sprites.editor.Palette,1,26)
      love.graphics.draw(sprites.editor.Palette,348,26)
      love.graphics.draw(sprites.editor.Rect41x33,306,206)
      love.graphics.draw(sprites.editor.PlaySymbol,312,212)
      
      --draw modules
      local regspace = 23 --this is just for spacing out modules
      
      --place the modules
      if self.selectedeventindex ~= nil then
        local et = self.level.events[self.selectedeventindex].type
        if et=="beat" or et=="inverse" or et=="side" or et=="mine" or et=="slice" or et=="sliceinvert" then
          self:drawmodule(self.selectedeventindex,"time","numberinput",28,"Time")
          self:drawmodule(self.selectedeventindex,"endangle","numberinput",28 + regspace,"HitAngle")
          self:drawmodule(self.selectedeventindex,"angle","numberinput",28 + (2*regspace),"StartAngle")
          self:drawmodule(self.selectedeventindex,"speedmult","numberinput",28 + (3*regspace),"SpeedMult")
        elseif et=="hold" or et=="minehold" then
          self:drawmodule(self.selectedeventindex,"time","numberinput",28,"Time")
          self:drawmodule(self.selectedeventindex,"duration","numberinput",28 + regspace,"Duration")
          self:drawmodule(self.selectedeventindex,"angle1","numberinput",28 + (2*regspace),"Angle1")
          self:drawmodule(self.selectedeventindex,"angle2","numberinput",28 + (3*regspace),"Angle2")
          self:drawmodule(self.selectedeventindex,"holdease","textinput",28 + (4*regspace),"HoldEase")
          self:drawmodule(self.selectedeventindex,"speedmult","numberinput",28 + (5*regspace),"SpeedMult")
        end
      end
      
      for i=1,4,1 do
        if tonumber(string.sub(self.currenttab,4,4)) == i then --helpers.inrect((25*i)-24,(25*i)+1,1,26,mouse.rx,mouse.ry)
          love.graphics.draw(sprites.editor.Selected,(25*i)-22,3)
        end
      end
      
      for i=1,self:eventsintab(self.currenttab),1 do
        if tonumber(string.sub(self.currentpaletteindex,8,8)) == i then
          if i % 2 == 1 then
            love.graphics.draw(sprites.editor.Selected,3,(25*((i+1)/2))+3)
          elseif i % 2 == 0 then
            love.graphics.draw(sprites.editor.Selected,28,(25*(i/2))+3)
          end
        end
      end
      
      --TABS AND PALETTE (drawing)
      love.graphics.draw(sprites.beat.square,39,14,0,1,1,8,8)
        --Events on tab 1
        if self.currenttab == "tab1" then

        --Events on tab 2
        elseif self.currenttab == "tab2" then
          love.graphics.draw(sprites.beat.square,14,39,0,1,1,8,8)
          love.graphics.draw(sprites.beat.inverse,39,39,0,1,1,8,8)
          love.graphics.draw(sprites.beat.side,14,64,0,1,1,12,10)
          love.graphics.draw(sprites.beat.mine,39,64,0,1,1,8,8)
          love.graphics.draw(sprites.beat.hold,14,89,0,1,1,8,8)
          love.graphics.draw(sprites.beat.minehold,39,89,0,1,1,8,8)
        elseif self.currenttab == "tab3" then
        elseif self.currenttab == "tab4" then
        end
      
      --modules
      if self.selectedeventindex ~= nil then
        if self.level.events[self.selectedeventindex].type == "beat" then
          love.graphics.draw(sprites.beat.square,373,14,0,1,1,8,8)
        elseif self.level.events[self.selectedeventindex].type == "inverse" then
          love.graphics.draw(sprites.beat.inverse,373,14,0,1,1,8,8)
        elseif self.level.events[self.selectedeventindex].type == "side" then
          love.graphics.draw(sprites.beat.side,373,14,0,1,1,12,10)
        elseif self.level.events[self.selectedeventindex].type == "mine" then
          love.graphics.draw(sprites.beat.mine,373,14,0,1,1,8,8)
        elseif self.level.events[self.selectedeventindex].type == "hold" then
          love.graphics.draw(sprites.beat.hold,373,14,0,1,1,8,8)
        elseif self.level.events[self.selectedeventindex].type == "minehold" then
          love.graphics.draw(sprites.beat.minehold,373,14,0,1,1,8,8)
        end
      end
      
      --debug
      --love.graphics.setColor(0, 0, 0, 1)
      --love.graphics.printf(tostring(self.cursoruiindex), 0, 60, project.res.cx * 2, "center", 0, 1, 1)
      --love.graphics.printf(self.currenttab, 0, 40, project.res.cx * 2, "center", 0, 1, 1)
      --love.graphics.printf(self.currentpaletteindex, 0, 20, project.res.cx * 2, "center", 0, 1, 1)
      --love.graphics.printf(tostring(self.selectedeventindex), 0, 80, project.res.cx * 2, "center", 0, 1, 1)
      --love.graphics.printf(tostring(self.editingtext), 0, 100, project.res.cx * 2, "center", 0, 1, 1)

      --r my bad implementation of the textbox
      --if self.degreesnaptextbox == true then
      --  love.graphics.setColor(1, 0, 0, 1)
      --  love.graphics.print("New angle snap:",30,10)
      --  love.graphics.print(self.degreesnaptypedtext,30,30)
      --end
    end
  if self.editmode then
    em.draw() --??
  end
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canv)
  if pq ~= "" then
    print(helpers.round(self.cbeat*6,true)/6 .. pq)
  end

end)
--move this elsewhere
function love.wheelmoved(x, y)
  if (y > 0) then
    cs.scrolldir = 1
  elseif (y < 0) then
    cs.scrolldir = -1
  else
    cs.scrolldir = 0
  end
end



return st
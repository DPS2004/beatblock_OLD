local st = {
  sprbeat = love.graphics.newImage("assets/game/square.png"),
  sprinverse = love.graphics.newImage("assets/game/inverse.png"),
  sprhold = love.graphics.newImage("assets/game/hold.png")
}
function st.init()

end


function st.enter(prev)
  st.p = em.init("player",screencenter.x,screencenter.y)
  st.gm = em.init("gamemanager",screencenter.x,screencenter.y)
  st.gm.init(st)
  if clevel == nil then
    st.level = {
      bpm = 100,
      events = {},
      offset = 0,
      startbeat = 0,
    }
  else
    st.level = dpf.loadjson(clevel.."level.json",{})
  end
  st.gm.resetlevel()

  st.canv = love.graphics.newCanvas(gameWidth,gameHeight)





  --Editor-specific
  st.beatcirclestartrad = 85 --Starting radius of the first beatcircle (the distance of one beat out from the center)
  st.beatcircleminrad = 35 --Minimum radius of a beatcircle to be drawn
  st.beatcirclemaxrad = 800 --Maximum radius of a beatcircle to be drawn
  st.beatcircledistance = 5 --The distance between beat circles

  st.cursortype = "beat"
  st.beatsnap = 0.5
  st.degreesnap = 15
  st.degreesnaptextbox = false
  st.degreesnaptypedtext = ""
  st.cursorpos = {angle = 0, beat = 0}
  st.scrollpos = 0 --Where you are in the song
  st.scrollzoom = 1
  st.scrolldir = 0 --Used for mouse scrolling
  st.beatcircles = {}
  st.editmode = true
  
  --for dragging events
  st.draggingeventindex = nil
  st.draggingeventpart = nil
  
  st.draggingeventmoved = false
  st.openpup = false
  
  --st.state = "free" --r MAKE SURE TO CHECK FOR THE FREE STATE BEFORE ADDING A NEW KEYBIND (free state means a text box isn't currently selected or anything)

  for i=1,5000,1 do
    st.beatcircles[i] = 1
  end
end


function st.leave()
  entities = {}
  if st.source ~= nil then
    st.source:stop()
    st.source = nil
  end
  st.sounddata = nil
end


function st.resume()

end


function st.update()
  if not paused then
    if maininput:pressed("back") then
      if st.editmode then
        paused = true
        local pup = em.init("popup",screencenter.x,screencenter.y)
        pup.text = loc.get("savewarning")
        pup.w=200
        pup.h=100
        pup.newbutton({x=100,y=50,w=50,h=16,text=loc.get("save"),onclick = function() st.savelevel() helpers.swap(states.songselect) paused = false pup.delete = true end})
        pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("dontsave"),onclick = function() helpers.swap(states.songselect) paused = false pup.delete = true end})
        pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
      else
        st.stoplevel()
      end
    end

    --Below only applies while in edit mode
    if st.editmode then
      local mouseX = love.mouse.getX()/shuv.scale
      local mouseY = love.mouse.getY()/shuv.scale
    
      local mouseangle = (math.deg(math.atan2(mouseY - screencenter.y, mouseX - screencenter.x)) + 90)
      local mouserad = helpers.distance({screencenter.x, screencenter.y}, {mouseX, mouseY})
    
      --The angle that's nearest to the cursor
      local nearestangle = math.floor((mouseangle / st.degreesnap) + 0.5) * st.degreesnap
    
      st.cursorpos.angle = nearestangle % 360
      st.cursorpos.beat = st.scrollradtobeat(mouserad+10, true)
      if maininput:pressed("p") then
        if maininput:down("shift") then
          st.startbeat = st.scrollradtobeat((st.beatcircleminrad + st.beatcirclestartrad) * st.scrollzoom, false)
        else
          st.startbeat = 0
        end
        st.playlevel()
      end
      
      if maininput:down("ctrl") then
        if maininput:pressed("r") then
          print("ctrl+r")
          paused = true

          local pup = em.init("popup",screencenter.x,screencenter.y)
          pup.text = loc.get("refreshwarning")
          pup.w=200
          pup.h=100
          pup.newbutton({x=100,y=90,w=16,h=16,text=loc.get("ok"),onclick = function() cs.level = dpf.loadjson(clevel.."level.json",{}) paused = false pup.delete = true end})
          pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
        end
        if maininput:pressed("s") then
          st.savelevel()
          st.p.hurtpulse() --Little animation to confirm that you indeed saved
        end
      else
        -- Set type of event on cursor
        if maininput:pressed("k1") then
          st.cursortype = "beat"
        end
      
        if maininput:pressed("k2") then
          st.cursortype = "inverse"
        end
      
        if maininput:pressed("k3") then
          st.cursortype = "hold"
        end
      
        if maininput:pressed("k4") then
          st.cursortype = "slice"
        end
      
        if maininput:pressed("k5") then
          st.cursortype = "sliceinvert"
        end
      
        if maininput:pressed("k6") then
          st.cursortype = "mine"
        end
      
        if maininput:pressed("k7") then
          st.cursortype = "side"
        end
      
        if maininput:pressed("k8") then
          st.cursortype = "minehold"
        end

        --Set zoom
        if maininput:pressed("up") then
          st.scrollzoom = st.scrollzoom + 0.5
        end
      
        if maininput:pressed("down") then
          st.scrollzoom = st.scrollzoom - 0.5
        end

        --the
        if maininput:pressed("comma") and st.findholdtypeatcursor() ~= nil then
          if st.level.events[st.findeventatcursor()].holdease ~= "InQuad" then
            st.level.events[st.findeventatcursor()].holdease = "InQuad"
          else
            st.level.events[st.findeventatcursor()].holdease = "Linear"
          end
        end
        
        if maininput:pressed("period") and st.findholdtypeatcursor() ~= nil then
          if st.level.events[st.findeventatcursor()].holdease ~= "OutQuad" then
            st.level.events[st.findeventatcursor()].holdease = "OutQuad"
          else
            st.level.events[st.findeventatcursor()].holdease = "Linear"
          end
        end

        --Beat snap
        if maininput:pressed("minus") then
          if st.beatsnap == 1 then
            st.beatsnap = 0.5
          elseif st.beatsnap == 0.5 then
            st.beatsnap = 0.3333
          elseif st.beatsnap == 0.3333 then
            st.beatsnap = 0.25
          elseif st.beatsnap == 0.25 then
            st.beatsnap = 0.1666
          elseif st.beatsnap == 0.1666 then
            st.beatsnap = 0.125
          end
        end

        if maininput:pressed("plus") then
          if st.beatsnap == 0.125 then
            st.beatsnap = 0.1666
          elseif st.beatsnap == 0.1666 then
            st.beatsnap = 0.25
          elseif st.beatsnap == 0.25 then
            st.beatsnap = 0.3333
          elseif st.beatsnap == 0.3333 then
            st.beatsnap = 0.5
          elseif st.beatsnap == 0.5 then
            st.beatsnap = 1
          end
        end

        --Angle snap
        if maininput:pressed("rightbracket") then
          if st.degreesnap == 5 then
            st.degreesnap = 5.625
          elseif st.degreesnap == 5.625 then
            st.degreesnap = 7.5
          elseif st.degreesnap == 7.5 then
            st.degreesnap = 11.25
          elseif st.degreesnap == 11.25 then
            st.degreesnap = 15
          elseif st.degreesnap == 15 then
            st.degreesnap = 22.5
          elseif st.degreesnap == 22.5 then
            st.degreesnap = 30
          elseif st.degreesnap == 30 then
            st.degreesnap = 45
          elseif st.degreesnap == 45 then
            st.degreesnap = 90
          elseif st.degreesnap == 90 then
            st.degreesnaptextbox = true
          else
            st.degreesnap = 90
          end
        end

        if maininput:pressed("leftbracket") then
          if st.degreesnap == 90 then
            st.degreesnap = 45
          elseif st.degreesnap == 45 then
            st.degreesnap = 30
          elseif st.degreesnap == 30 then
            st.degreesnap = 22.5
          elseif st.degreesnap == 22.5 then
            st.degreesnap = 15
          elseif st.degreesnap == 15 then
            st.degreesnap = 11.25
          elseif st.degreesnap == 11.25 then
            st.degreesnap = 7.5
          elseif st.degreesnap == 7.5 then
            st.degreesnap = 5.625
          else
            st.degreesnap = 5
          end
        end

        

        --Adding/deleting/dragging events
        if maininput:pressed("mouse1") then
          st.draggingeventindex = st.findeventatcursor()
          st.draggingeventpart = st.findholdtypeatcursor()
        end

        if maininput:down("mouse1") and st.draggingeventindex then

          if st.level.events[st.draggingeventindex].type ~= "hold" and st.level.events[st.draggingeventindex].type ~= "minehold" then
            
            local endangle = st.level.events[st.draggingeventindex].endangle
            local startbeat = st.level.events[st.draggingeventindex].time
            
            if st.level.events[st.draggingeventindex].type ~= "sliceinvert" then
              --editing not holds nor sliceinverts
              st.level.events[st.draggingeventindex].endangle = st.cursorpos.angle
              st.level.events[st.draggingeventindex].time = st.cursorpos.beat
            else
              --editing sliceinverts
              st.level.events[st.draggingeventindex].endangle = -(180 - st.cursorpos.angle)
              st.level.events[st.draggingeventindex].time = st.cursorpos.beat
            end

            if (endangle ~= st.level.events[st.draggingeventindex].endangle) or (startbeat ~= st.level.events[st.draggingeventindex].time) then
              st.draggingeventmoved = true
            end

          else

            --holds
            local angle1 = st.level.events[st.draggingeventindex].angle1
            local angle2 = st.level.events[st.draggingeventindex].angle2
            local startbeat = st.level.events[st.draggingeventindex].time
            local duration = st.level.events[st.draggingeventindex].duration

            if st.draggingeventpart == "holdstart" then
              --editing hold starts
              if (angle1 % 360) ~= st.cursorpos.angle then 
                if math.abs(st.cursorpos.angle - (angle1 % 360)) > 180 then
                  if (st.cursorpos.angle - (angle1 % 360)) < 0 then
                    angle1 = angle1 + 360 + st.cursorpos.angle - (angle1 % 360)
                  else
                    angle1 = angle1 - 360 + st.cursorpos.angle - (angle1 % 360)
                  end
                else
                  angle1 = angle1 + st.cursorpos.angle - (angle1 % 360)
                end
              end

              duration = duration + startbeat - st.cursorpos.beat
              startbeat = st.cursorpos.beat
              if duration < 0 then
                angle2, angle1 = angle1, angle2
                startbeat = startbeat + duration
                duration = -duration
                st.draggingeventpart = "holdend"
              end

            else
              --editing hold ends
              if (angle2 % 360) ~= st.cursorpos.angle then 
                if math.abs(st.cursorpos.angle - (angle2 % 360)) > 180 then
                  if (st.cursorpos.angle - (angle2 % 360)) < 0 then
                    angle2 = angle2 + 360 + st.cursorpos.angle - (angle2 % 360)
                  else
                    angle2 = angle2 - 360 + st.cursorpos.angle - (angle2 % 360)
                  end
                else
                  angle2 = angle2 + st.cursorpos.angle - (angle2 % 360)
                end
              end

              duration = st.cursorpos.beat - startbeat
              if duration < 0 then
                angle2, angle1 = angle1, angle2
                startbeat = startbeat + duration
                duration = -duration
                st.draggingeventpart = "holdstart"
              end
            end

            if
            (st.level.events[st.draggingeventindex].angle1 ~= angle1) or
            (st.level.events[st.draggingeventindex].angle2 ~= angle2) or
            (st.level.events[st.draggingeventindex].time ~= startbeat) or
            (st.level.events[st.draggingeventindex].duration ~= duration) then
              st.draggingeventmoved = true
            end

            st.level.events[st.draggingeventindex].angle1 = angle1
            st.level.events[st.draggingeventindex].angle2 = angle2
            st.level.events[st.draggingeventindex].time = startbeat
            st.level.events[st.draggingeventindex].duration = duration

          end

        end

        if maininput:released("mouse1") then
          if st.draggingeventindex then

            --change the angle of angle1 and angle2 until angle1 is between 0 and 360 degrees
            if st.draggingeventpart == "holdstart" or st.draggingeventpart == "holdend" then
              while st.level.events[st.draggingeventindex].angle1 >= 360 do
                st.level.events[st.draggingeventindex].angle1 = st.level.events[st.draggingeventindex].angle1 - 360
                st.level.events[st.draggingeventindex].angle2 = st.level.events[st.draggingeventindex].angle2 - 360
              end
              while st.level.events[st.draggingeventindex].angle1 < 0 do
                st.level.events[st.draggingeventindex].angle1 = st.level.events[st.draggingeventindex].angle1 + 360
                st.level.events[st.draggingeventindex].angle2 = st.level.events[st.draggingeventindex].angle2 + 360
              end
            end

          --currently dragging event wasn't moved? open the popup!
          if st.draggingeventmoved == false then
            st.openpup = true
          else
            st.draggingeventmoved = false
          end

          st.draggingeventindex = nil
          st.draggingeventpart = nil

          else
            st.deleteeventatcursor()
            st.addeventatcursor(st.cursortype)
          end
        end
      
        if maininput:released("mouse2") then
          st.deleteeventatcursor()
        end
        -- edit events with e or mid click
        if maininput:pressed("e") or maininput:pressed("mouse3") or st.openpup == true then
          st.openpup = false
          st.eventindex = st.findeventatcursor()
          if st.eventindex then
            if st.level.events[st.eventindex].type == "hold" or "minehold" then
              paused = true
              local pos = helpers.rotate(st.beattoscrollrad(st.cursorpos.beat), st.cursorpos.angle, screencenter.x, screencenter.y)
              local pup = em.init("popup",screencenter.x,screencenter.y)
              pup.text = loc.get("editwhat")
              pup.w = 200
              pup.h=170
              pup.newbutton({x=100,y=40,w=50,h=16,text=loc.get("angle1"),onclick = function() 
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("angle1") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].angle1),y=50,show=true,numberonly=true, allowminus=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].angle1 = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=60,w=50,h=16,text=loc.get("angle2"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("angle2") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].angle2),y=50,show=true,numberonly=true, allowminus=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].angle2 = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
                pup.newbutton({x=100,y=80,w=50,h=16,text=loc.get("holdease"),onclick = function()   
                  pup.h = 100 
                  pup.text = loc.get("editing") .. " " .. loc.get("holdease") .. ":"
                  pup.buttons = {}
                  pup.textinput= {text=tostring(st.level.events[st.eventindex].holdease),y=50,show=true,numberonly=false}
                  pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].holdease =   pup.textinput.text paused = false pup.delete = true end})
                  pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=100,w=50,h=16,text=loc.get("duration"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("duration") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].duration),y=50,show=true,numberonly=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].duration = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=120,w=50,h=16,text=loc.get("time"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("time") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].time),y=50,show=true,numberonly=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].time = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=140,w=100,h=16,text=loc.get("speedmult"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("speedmult") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].speedmult),y=50,show=true,numberonly=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].speedmult = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=160,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
            elseif st.level.events[st.eventindex].type == "beat" or st.level.events[st.eventindex].type == "slice" or st.level.events[st.eventindex].type == "sliceinvert" or st.level.events[st.eventindex].type == "inverse" or st.level.events[st.eventindex].type == "mine" or st.level.events[st.eventindex].type == "side" then
paused = true
              local pos = helpers.rotate(st.beattoscrollrad(st.cursorpos.beat), st.cursorpos.angle, screencenter.x, screencenter.y)
              local pup = em.init("popup",screencenter.x,screencenter.y)
              pup.text = loc.get("editwhat")
              pup.w = 200
              pup.h=150
              pup.newbutton({x=100,y=60,w=60,h=16,text=loc.get("startangle"),onclick = function() 
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("startangle") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].angle),y=50,show=true,numberonly=true, allowminus=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].angle = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=80,w=50,h=16,text=loc.get("endangle"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("endangle") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].endangle or st.level.events[st.eventindex].angle),y=50,show=true,numberonly=true, allowminus=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].endangle = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=100,w=50,h=16,text=loc.get("time"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("time") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].time),y=50,show=true,numberonly=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].hb = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=120,w=100,h=16,text=loc.get("speedmult"),onclick = function()   
                pup.h = 100 
                pup.text = loc.get("editing") .. " " .. loc.get("speedmult") .. ":"
                pup.buttons = {}
                pup.textinput= {text=tostring(st.level.events[st.eventindex].speedmult),y=50,show=true,numberonly=true}
                pup.newbutton({x=100,y=90,w=50,h=16,text=loc.get("ok"),onclick = function() cs.level.events[st.eventindex].speedmult = tonumber(pup.textinput.text) paused = false pup.delete = true end})
                pup.newbutton({x=100,y=70,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
              end})
              pup.newbutton({x=100,y=140,w=50,h=16,text=loc.get("cancel"),onclick = function() paused = false pup.delete = true end})
            
              
            end
            
          end
        end
      end
    

      --Scroll through level
      if st.scrolldir == 1 then
        st.scrollpos = st.scrollpos + 0.5 / st.scrollzoom
      end
    
      if st.scrolldir == -1 then
        st.scrollpos = st.scrollpos - 0.5 / st.scrollzoom
      end
    
      if st.scrollpos < 0 then
        st.scrollpos = 0
      end
    
      st.scrollzoom = helpers.clamp(st.scrollzoom, 0.5, 3)
    
      if st.scrolldir ~= 0 then
        st.scrolldir = 0
      end
      
      --Scale editor circles based on scroll position and zoom level
      for i,v in ipairs(st.beatcircles) do
        st.beatcircles[i] = st.beattoscrollrad(i - 1)
      end
    
      
    end

    flux.update(1)
    em.update(dt)
  end
end


function st.draw()
  love.graphics.setFont(font1)
  shuv.start()

  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)
  love.graphics.setCanvas(st.canv)
    
    helpers.drawgame()
    --Only draw the following while in edit mode
    if st.editmode then
      --Beatcircles
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.setLineWidth(2)
      love.graphics.circle("line",screencenter.x,screencenter.y,st.beatcircleminrad)
      for i,v in ipairs(st.beatcircles) do
        if st.beatcircles[i] > st.beatcirclemaxrad then
          break
        end

        if st.beatcircles[i] >= st.beatcircleminrad then
          --Circle
          love.graphics.circle("line",screencenter.x,screencenter.y,st.beatcircles[i])

          --Snap circles
          if i ~= 1 then
            love.graphics.setColor(0, 0, 0, 0.25)
            local snapcircles = math.floor((1 / st.beatsnap) + 0.5)
            for j=1, snapcircles - 1, 1 do
              local snapcirclerad = st.beattoscrollrad(i - 1 - st.beatsnap * j)
              if snapcirclerad >= st.beatcircleminrad then
                love.graphics.circle("line", screencenter.x, screencenter.y, snapcirclerad)
              end
            end
          end

          --Beat number
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.printf(tostring(i), 0, screencenter.y - st.beatcircles[i] - 15, screencenter.x * 2, "center", 0, 1, 1)
        end
      end

      --Snap lines
      love.graphics.setColor(1, 1, 1, 0.25)
      local snaplines = math.floor((360 / st.degreesnap) + 0.5)
      for j=1, snaplines, 1 do
        local snaplinestart = helpers.rotate(math.max(st.beatcircles[1], st.beatcircleminrad), j * st.degreesnap, screencenter.x, screencenter.y)
        local snaplineend = helpers.rotate(st.beatcirclemaxrad, j * st.degreesnap, screencenter.x, screencenter.y)
        love.graphics.line(snaplinestart[1], snaplinestart[2], snaplineend[1], snaplineend[2])
      end

      --Events
      love.graphics.setColor(1, 1, 1, 1)
      for i,v in ipairs(st.level.events) do
        local evrad = st.beattoscrollrad(v.time)
        --Events only drawn if they would appear on screen (i.e. not inside the player at the center or off-screen)
        if evrad <= st.beatcirclemaxrad then
          if evrad >= st.beatcircleminrad then
            if v.type == "beat" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, screencenter.x, screencenter.y)
              love.graphics.draw(st.sprbeat,pos[1],pos[2],0,1,1,8,8)
  
            elseif v.type == "inverse" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, screencenter.x, screencenter.y)
              love.graphics.draw(st.sprinverse,pos[1],pos[2],0,1,1,8,8)
  
            elseif v.type == "slice" or v.type == "sliceinvert" then
              local angle = v.endangle or v.angle
              local invert = v.type == "sliceinvert"
              helpers.drawslice(screencenter.x, screencenter.y, evrad, angle, invert, 1)

            elseif v.type == "mine" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, screencenter.x, screencenter.y)
              love.graphics.draw(sprites.beat.mine,pos[1],pos[2],0,1,1,8,8)

            elseif v.type == "side" then
              local angle = v.endangle or v.angle
              local pos = helpers.rotate(evrad, angle, screencenter.x, screencenter.y)
              love.graphics.draw(sprites.beat.side,pos[1],pos[2],0,1,1,12,10)

            end
          end
  
          if v.type == "hold" or v.type == "minehold" then
            local evrad2 = st.beattoscrollrad(v.time + v.duration)
            if evrad2 >= st.beatcircleminrad then
              local evrad1 = (evrad >= st.beatcircleminrad and evrad) or st.beatcircleminrad
              local angle1 = v.angle1
              local angle2 = v.angle2
              local pos1 = helpers.rotate(evrad1, angle1, screencenter.x, screencenter.y)
              local pos2 = helpers.rotate(evrad2, angle2, screencenter.x, screencenter.y)
              local completion = math.max(0, (cs.cbeat - 0 ) / v.duration)
              if v.type == "hold" then
                helpers.drawhold(screencenter.x, screencenter.y, pos1[1], pos1[2], pos2[1], pos2[2], completion, angle1, angle2, v.segments, st.sprhold, v.holdease, v.type)
              else
                helpers.drawhold(screencenter.x, screencenter.y, pos1[1], pos1[2], pos2[1], pos2[2], completion, angle1, angle2, v.segments, sprites.beat.minehold, v.holdease, v.type)
              end
            end
          end
        end
      end

      --Cursor
      love.graphics.setColor(1, 1, 1, 0.5)
      local cursorrad = st.beattoscrollrad(st.cursorpos.beat)
      if cursorrad >= st.beatcircleminrad then
        local angle = st.cursorpos.angle
        local pos = helpers.rotate(cursorrad, angle, screencenter.x, screencenter.y)
        
        if st.cursortype == "beat" then
          love.graphics.draw(st.sprbeat, pos[1], pos[2],0,1,1,8,8)
        elseif st.cursortype == "inverse" then
          love.graphics.draw(st.sprinverse, pos[1], pos[2],0,1,1,8,8)
        elseif st.cursortype == "mine" then
          love.graphics.draw(sprites.beat.mine, pos[1], pos[2],0,1,1,8,8)
        elseif st.cursortype == "side" then
          love.graphics.draw(sprites.beat.side, pos[1], pos[2],0,1,1,12,10)
        elseif st.cursortype == "hold" then
          love.graphics.draw(st.sprhold, pos[1], pos[2],0,1,1,8,8)
        elseif st.cursortype == "minehold" then
          love.graphics.draw(sprites.beat.minehold, pos[1], pos[2],0,1,1,8,8)
        elseif st.cursortype == "slice" or st.cursortype == "sliceinvert" then
          local sliceangle = angle
          local invert = st.cursortype == "sliceinvert"
          -- I have no idea why it does this
          if invert then
            sliceangle = (sliceangle + 180) % 360
          end
          helpers.drawslice(screencenter.x, screencenter.y, cursorrad, sliceangle, invert, 0.5)
        end
      end

      --r my bad implementation of the textbox
      if st.degreesnaptextbox == true then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("New angle snap:",30,10)
        love.graphics.print(st.degreesnaptypedtext,30,30)
      end
    end
  if st.editmode then
    em.draw()
  end
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
  end

  shuv.finish()

end

function love.wheelmoved(x, y)
  if (y > 0) then
    st.scrolldir = 1
  elseif (y < 0) then
    st.scrolldir = -1
  else
    st.scrolldir = 0
  end
end

--The radius of beatcircle [beat]
function st.beattoscrollrad(beat)
  return st.beatcirclestartrad - (st.scrollpos - st.beatcircledistance * beat) * (st.scrollzoom * 10)
end

--Find the beat that's nearest to the given radius
function st.scrollradtobeat(rad, snap)
  local nearestbeat = 0
  --Should beat snap be taken into account?
  local snapfactor = (snap and st.beatsnap) or 0
  while st.beattoscrollrad(nearestbeat + snapfactor)  < rad do
    nearestbeat = nearestbeat + st.beatsnap
  end
  return nearestbeat
end

--Delete the first event that overlaps the cursor's current position
function st.deleteeventatcursor()
  local delindex = nil
  for i,v in ipairs(st.level.events) do
    if v.type ~= "hold" and v.type ~= "minehold" then
      if v.time == st.cursorpos.beat then
        local evangle = v.endangle or v.angle or nil
        if evangle ~= nil then
          if v.type == "sliceinvert" then
            evangle = evangle + 180
          end
          if evangle % 360 == st.cursorpos.angle % 360  then
            delindex = i
            break
          end
        end
      end
    else
      if v.time == st.cursorpos.beat then
        local evangle = v.angle1 or nil
        if evangle ~= nil and evangle % 360 == st.cursorpos.angle % 360 then
          delindex = i
          break
        end
      elseif v.time + v.duration == st.cursorpos.beat then
        local evangle = v.angle2 or nil
        if evangle ~= nil and evangle % 360 == st.cursorpos.angle % 360 then
          delindex = i
          break
        end
      end
    end
    
  end

  if delindex ~= nil then
    table.remove(st.level.events, delindex)
  end
end
--find the first event at the cursor
function st.findeventatcursor()
  local returndex = nil
  for i,v in ipairs(st.level.events) do
    if v.type ~= "hold" and v.type ~= "minehold" then
      if v.time == st.cursorpos.beat then
      
        local evangle = v.endangle or v.angle or nil
        if evangle ~= nil then
          if v.type == "sliceinvert" then
            evangle = evangle + 180
          end
          if evangle % 360 == st.cursorpos.angle % 360  then
            returndex = i
            break
          end
        end
      end
    else
      if v.time == st.cursorpos.beat then
        local evangle = v.angle1 or nil
        if evangle ~= nil and evangle % 360 == st.cursorpos.angle % 360 then
          returndex = i
          break
        end
      elseif v.time + v.duration == st.cursorpos.beat then
        local evangle = v.angle2 or nil
        if evangle ~= nil and evangle % 360 == st.cursorpos.angle % 360 then
          returndex = i
          break
        end
      end
    end
    
  end

  return returndex
end
--determine if a hold on the cursor is a hold start or hold end
function st.findholdtypeatcursor()
  local returndex = nil
  for i,v in ipairs(st.level.events) do
    if v.type ~= "hold" and v.type ~= "minehold" then
      returndex = nil
    else
      if v.time == st.cursorpos.beat then
        local evangle = v.angle1 or nil
        if evangle ~= nil and evangle % 360 == st.cursorpos.angle % 360 then
          returndex = "holdstart"
          break
        end
      elseif v.time + v.duration == st.cursorpos.beat then
        local evangle = v.angle2 or nil
        if evangle ~= nil and evangle % 360 == st.cursorpos.angle % 360 then
          returndex = "holdend"
          break
        end
      end
    end
    
  end

  return returndex
end

--Add an event of type [type] at the cursor's current position
function st.addeventatcursor(type)
  local newevent = {time = st.cursorpos.beat, type = type}
  if type == "beat" or type == "inverse" or type == "slice" or type == "sliceinvert" or type == "mine" or type == "side" then
    local evangle = st.cursorpos.angle
    if type == "sliceinvert" then
      evangle = (evangle + 180) % 360 --Sliceinverts are weird
    end
    newevent.angle = evangle
    newevent.endangle = evangle
    newevent.speedmult = 1
  elseif type == "hold" or "minehold" then
    --Barebones hold addition. Need to be able to set both angles
    newevent.angle1 = st.cursorpos.angle
    newevent.angle2 = st.cursorpos.angle
    newevent.duration = 1
    newevent.speedmult = 1
  end

  table.insert(st.level.events, 1, newevent)
end

function st.playlevel()
  st.editmode = false
  st.gm.resetlevel()
  st.gm.on = true
end

function st.stoplevel()
  st.editmode = true
  st.startbeat = 0
  st.gm.resetlevel()
  st.gm.on = false
  
  entities = {st.p, st.gm}
  if st.source ~= nil then
    st.source:stop()
    st.source = nil
  end
  st.sounddata = nil
end

function st.savelevel()
  dpf.savejson(clevel.."level.json",st.level)
end


return st
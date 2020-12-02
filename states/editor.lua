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

  st.canv = love.graphics.newCanvas(400,240)

  if clevel == nil then
    st.level = {
      bpm = 100,
      events = {},
      offset = 0,
      startbeat = 0,
    }
  else
    st.level = json.decode(helpers.read(clevel.."level.json"))
  end

  st.offset = st.level.properties.offset
  st.startbeat = st.level.properties.startbeat or 0
  st.cbeat = 0-st.offset +st.startbeat
  st.autoplay = false
  st.length = 42
  st.pt = 0
  st.bg = love.graphics.newImage("assets/bgs/nothing.png")
  
  st.on = true
  st.beatsounds = false
  st.extend = 0

  st.vfx = {}
  st.vfx.hom = false
  st.vfx.homint = 20000
  st.lastsigbeat = math.floor(st.cbeat)

  --Editor-specific
  st.beatcirclestartrad = 85 --Starting radius of the first beatcircle (the distance of one beat out from the center)
  st.beatcircleminrad = 35 --Minimum radius of a beatcircle to be drawn
  st.beatcirclemaxrad = 800 --Maximum radius of a beatcircle to be drawn
  st.beatcircledistance = 5 --The distance between beat circles

  st.cursortype = "beat"
  st.beatsnap = 0.5
  st.degreesnap = 15
  st.degreesnaptextbox = false
  st.degreetypedtext = ""
  st.cursorpos = {angle = 0, beat = 0}
  st.scrollpos = 0 --Where you are in the song
  st.scrollzoom = 1
  st.scrolldir = 0 --Used for mouse scrolling
  st.beatcircles = {}
  st.editmode = true

  for i=1,500,1 do
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
  maininput:update()
  lovebird.update()

  if maininput:pressed("back") then
    if st.editmode then
      helpers.swap(states.songselect)
    else
      st.stoplevel()
    end
  end

  --Below only applies while in edit mode
  if st.editmode then
    if maininput:pressed("p") then
      if maininput:down("shift") then
        st.startbeat = st.scrollradtobeat((st.beatcircleminrad + st.beatcirclestartrad) * st.scrollzoom, false)
      else
        st.startbeat = 0
      end
      st.playlevel()
    end

    if maininput:down("ctrl") then
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

      --Set zoom
      if maininput:pressed("up") then
        st.scrollzoom = st.scrollzoom + 0.5
      end
    
      if maininput:pressed("down") then
        st.scrollzoom = st.scrollzoom - 0.5
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
          st.degreesnap = 10
        elseif st.degreesnap == 10 then
          st.degreesnap = 15
        elseif st.degreesnap == 15 then
          st.degreesnap = 20
        elseif st.degreesnap == 20 then
          st.degreesnap = 30
        elseif st.degreesnap == 30 then
          st.degreesnap = 45
        elseif st.degreesnap == 45 then
          st.degreesnap = 60
        elseif st.degreesnap == 60 then
          st.degreesnap = 90
        elseif st.degreesnap == 90 then
          st.degreesnaptextbox = true
        else
          st.degreesnap = 90
        end
      end

      if maininput:pressed("leftbracket") then
        if st.degreesnap == 90 then
          st.degreesnap = 60
        elseif st.degreesnap == 60 then
          st.degreesnap = 45
        elseif st.degreesnap == 45 then
          st.degreesnap = 30
        elseif st.degreesnap == 30 then
          st.degreesnap = 20
        elseif st.degreesnap == 20 then
          st.degreesnap = 15
        elseif st.degreesnap == 15 then
          st.degreesnap = 10
        else
          st.degreesnap = 5
        end
      end

      if maininput:pressed("enter") and st.degreesnaptextbox == true then
        st.degreesnaptextbox = false
        st.degreesnap = tonumber (st.degreetypedtext)
      end
      if st.degreesnap == nil then --r TODO: display error "Invalid angle snap! Enter a number."
        st.degreesnap = 60
      end

      if st.degreesnaptextbox == true then
        function love.textinput(t)
          if t=="1" or t=="2" or t=="3" or t=="4" or t=="5" or t=="6" or t=="7" or t=="8" or t=="9" or t=="0" or t=="." then
            st.degreetypedtext = st.degreetypedtext .. t
          end
        end
      else
        love.textinput = nil
      end

      --Adding/deleting events
      if maininput:released("mouse1") then
        --Extremely simple. Want to make it so you can drag pre-existing events later, but for now it just deletes what's already there
        st.deleteeventatcursor()
        st.addeventatcursor(st.cursortype)
      end
    
      if maininput:released("mouse2") then
        st.deleteeventatcursor()
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
  
    local mouseX = love.mouse.getX()/shuv.scale
    local mouseY = love.mouse.getY()/shuv.scale
  
    local mouseangle = (math.deg(math.atan2(mouseY - screencenter.y, mouseX - screencenter.x)) + 90)
    local mouserad = helpers.distance({screencenter.x, screencenter.y}, {mouseX, mouseY})
  
    --The angle that's nearest to the cursor
    local nearestangle = math.floor((mouseangle / st.degreesnap) + 0.5) * st.degreesnap
  
    st.cursorpos.angle = nearestangle % 360
    st.cursorpos.beat = st.scrollradtobeat(mouserad, true)
  end

  flux.update(1)
  em.update(dt)
end


function st.draw()
  shuv.start()

  love.graphics.rectangle("fill",0,0,400,240)
  love.graphics.setCanvas(st.canv)
    
    if not st.vfx.hom then
      love.graphics.clear()
    end
    
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)

    if st.vfx.hom then
      for i=0,st.vfx.homint do
        love.graphics.points(math.random(0,400),math.random(0,240))
      end
    end
    love.graphics.draw(st.bg)
    em.draw()

    --Only draw the following while in edit mode
    if st.editmode then
      --Beatcircles
      love.graphics.setColor(0, 0, 0, 1)
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
            end
          end
  
          if v.type == "hold" then
            local evrad2 = st.beattoscrollrad(v.time + v.duration)
            if evrad2 >= st.beatcircleminrad then
              local evrad1 = (evrad >= st.beatcircleminrad and evrad) or st.beatcircleminrad
              local angle1 = v.angle1
              local angle2 = v.angle2
              local pos1 = helpers.rotate(evrad1, angle1, screencenter.x, screencenter.y)
              local pos2 = helpers.rotate(evrad2, angle2, screencenter.x, screencenter.y)
              helpers.drawhold(screencenter.x, screencenter.y, pos1[1], pos1[2], pos2[1], pos2[2], angle1, angle2, v.segments, st.sprhold)
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
        elseif st.cursortype == "hold" then
          love.graphics.draw(st.sprhold, pos[1], pos[2],0,1,1,8,8)
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
      if st.beatsnaptextbox == true then
        love.graphics.print("New angle snap:",30,10) --r PLEASE HELP ME WHY ISNT THE TEXT SHOWING AAAAAAAAA
        love.graphics.print(st.degreetypedtext,200,200)
      end
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
  while st.beattoscrollrad(nearestbeat + snapfactor) < rad do
    nearestbeat = nearestbeat + st.beatsnap
  end
  return nearestbeat
end

--Delete the first event that overlaps the cursor's current position
function st.deleteeventatcursor()
  local delindex = nil
    for i,v in ipairs(st.level.events) do
      if v.type ~= "hold" then
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

  --Add an event of type [type] at the cursor's current position
  function st.addeventatcursor(type)
    local newevent = {time = st.cursorpos.beat, type = type}
    if type == "beat" or type == "inverse" or type == "slice" or type == "sliceinvert" then
      local evangle = st.cursorpos.angle
      if type == "sliceinvert" then
        evangle = (evangle + 180) % 360 --Sliceinverts are weird
      end
      newevent.angle = evangle
      newevent.endangle = evangle
      newevent.speedmult = 1
    elseif type == "hold" then
      --Barebones hold addition. Need to be able to set both angles
      newevent.angle1 = st.cursorpos.angle
      newevent.angle2 = st.cursorpos.angle + 45
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
    helpers.write("output.json",json.encode(st.level))
  end


return st
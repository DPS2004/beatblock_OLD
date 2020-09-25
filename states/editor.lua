local st = {
  sprbeat = love.graphics.newImage("assets/game/square.png"),
  sprinverse = love.graphics.newImage("assets/game/inverse.png"),
  sprhold = love.graphics.newImage("assets/game/hold.png")
}
function st.init()

end


function st.enter(prev)
  st.p = em.init("player",200,120)
  st.gm = em.init("gamemanager",200,120)
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
    st.level = json.decode(helpers.read(clevel))
  end

  st.offset = st.level.offset
  st.startbeat = st.level.startbeat or 0
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
    helpers.swap(states.songselect)
  end

  if st.scrolldir == 1 then
    st.scrollpos = st.scrollpos + 0.5 / st.scrollzoom
  end

  if st.scrolldir == -1 then
    st.scrollpos = st.scrollpos - 0.5 / st.scrollzoom
  end

  if st.scrollpos < 0 then
    st.scrollpos = 0
  end

  if maininput:pressed("up") then
    st.scrollzoom = st.scrollzoom + 0.5
  end

  if maininput:pressed("down") then
    st.scrollzoom = st.scrollzoom - 0.5
  end

  st.scrollzoom = helpers.clamp(st.scrollzoom, 0.5, 3)

  if st.scrolldir ~= 0 then
    st.scrolldir = 0
  end
  
  --Scale editor circles based on scroll position and zoom level
  for i,v in ipairs(st.beatcircles) do
    st.beatcircles[i] = st.beattoscrollrad(i - 1)
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
      love.graphics.circle("line",200,120,st.beatcircleminrad)
      for i,v in ipairs(st.beatcircles) do
        if st.beatcircles[i] > st.beatcirclemaxrad then
          break
        end
        if st.beatcircles[i] >= st.beatcircleminrad then
          love.graphics.circle("line",200,120,st.beatcircles[i])
          love.graphics.printf(tostring(i), 0, 120 - st.beatcircles[i] - 15, 400, "center", 0, 1, 1)
        end
      end
      
      --Events
      love.graphics.setColor(1, 1, 1, 1)
      for i,v in ipairs(st.level.events) do
        local evrad = st.beattoscrollrad(v.time)
        --Events only drawn if they would appear on screen (i.e. not inside the player at the center or off-screen)
        if evrad > st.beatcirclemaxrad then
          break
        end
        if evrad >= st.beatcircleminrad then
          if v.type == "beat" then
            local angle = v.endangle or v.angle
            local pos = helpers.rotate(evrad, angle, 200, 120)
            love.graphics.draw(st.sprbeat,pos[1],pos[2],0,1,1,8,8)

          elseif v.type == "inverse" then
            local angle = v.endangle or v.angle
            local pos = helpers.rotate(evrad, angle, 200, 120)
            love.graphics.draw(st.sprinverse,pos[1],pos[2],0,1,1,8,8)

          elseif v.type == "slice" or v.type == "sliceinvert" then
            local angle = v.endangle or v.angle
            local invert = v.type == "sliceinvert"
            helpers.drawslice(200, 120, evrad, angle, invert)
          end
        end

        if v.type == "hold" then
          local evrad2 = st.beattoscrollrad(v.time + v.duration)
          if evrad2 >= st.beatcircleminrad then
            local evrad1 = (evrad >= st.beatcircleminrad and evrad) or st.beatcircleminrad
            local angle1 = v.angle1
            local angle2 = v.angle2
            local pos1 = helpers.rotate(evrad1, angle1, 200, 120)
            local pos2 = helpers.rotate(evrad2, angle2, 200, 120)
            helpers.drawhold(200, 120, pos1[1], pos1[2], pos2[1], pos2[2], angle1, angle2, v.segments, st.sprhold)
          end
        end
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

function st.beattoscrollrad(beat)
  return st.beatcirclestartrad - (st.scrollpos - st.beatcircledistance * beat) * (st.scrollzoom * 10)
end


return st
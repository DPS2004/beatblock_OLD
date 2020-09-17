local st = {}
function st.init()
  st.p = em.init("player",200,120)

  st.canv = love.graphics.newCanvas(400,240)
  st.level = json.decode(helpers.read("inversetest.json"))
  st.offset = st.level.offset
  st.cbeat = -1-st.offset
  st.length = 42
  st.pt = 0
  st.on = true
  st.beatsounds = false
  st.extend = 0
  for i,v in ipairs(st.level.events) do
    v.played = false
  end
  st.vfx = {}
  st.vfx.hom = false
  st.vfx.homint = 20000
  st.lastsigbeat = math.floor(st.cbeat)


end

function st.enter(prev)
  

  
end
function st.leave()
  
end

function st.resume()
  
end
function st.update()
  pq = ""
  maininput:update()
  lovebird.update()
  st.cbeat = st.cbeat + (st.level.bpm/60) * love.timer.getDelta()
  st.pt = st.pt + (st.level.bpm/60) * love.timer.getDelta()




   
  -- read the level
  for i,v in ipairs(st.level.events) do
    
    
    
  -- preload events such as beats
    if v.time <= st.cbeat+st.offset and v.played == false then
      

      if v.type == "beat" then
        v.played = true
        local newbeat = em.init("beat",200,120)
        newbeat.angle = v.angle
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        pq = pq .. "    ".. "spawn here!"
      end
      if v.type == "inverse" then
        v.played = true
        local newbeat = em.init("inverse",200,120)
        newbeat.angle = v.angle
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        pq = pq .. "    ".. "inverse here!"
        newbeat.update()
      end
      
    end
    -- load other events on the beat
    if v.time <= st.cbeat and v.played == false then
      v.played = true
      if v.type == "play" then
        te.play(v.file,"stream")
        pq = pq .. "    ".. "now playing ".. v.file
      end
      if v.type == "multipulse" then
                pq = pq.. "    pulsing, generating other pulses"
        st.extend = 10 
        flux.to(st,10,{extend=0}):ease("linear")
        for i=1,v.reps do
          table.insert(st.level.events,{type="singlepulse",time=v.time+v.delay*i,played=false})

        end
      end
      if v.type == "singlepulse" then
        st.extend = 10
        flux.to(st,10,{extend=0}):ease("linear")
        pq = pq.. "    pulsing"
      end
      if v.type == "hom" then
        st.vfx.hom = v.enable
        st.vfx.homint = v.intensity
        if st.vfx.hom then
          pq = pq .. "    ".. "Hall Of Mirrors enabled"
        else
          pq = pq .. "    ".. "Hall Of Mirrors disabled"
        end
      end
      if v.type == "circle" then
        pq = pq .. "    ".. "circle spawned"
        local nc = em.init("circlevfx",v.x,v.y)
        nc.delt = v.delta
      end
      
    end
  end

  if maininput:pressed("back") then
    table.insert(st.level.events,{time=helpers.round((st.cbeat-0.25)/st.level.increment,true)*st.level.increment,type="placeholder"})
  end
  if maininput:pressed("x") then
    table.insert(st.level.events,{time=helpers.round((st.cbeat-0.25)/st.level.increment,true)*st.level.increment,type="beat",angle=0,speedmult=1})
  end
  if maininput:pressed("c") then
    table.insert(st.level.events,{time=helpers.round((st.cbeat-0.25)/st.level.increment,true)*st.level.increment,type="cirlce",delta=10,x=200,y=120})
  end
  if maininput:pressed("s") then
    helpers.write("output.json",json.encode(st.level))
  end
  
  
  flux.update(1)
  em.update(dt)

  
  

  
  
end
function st.draw()
  --push:start()
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
    em.draw()
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  --push:finish()
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
  end
  shuv.finish()
end
return st
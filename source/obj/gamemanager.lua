function gamemanager()
  local obj = {
    layer = 1,
    uplayer = -9999,
    x=0,
    y=0,
    currst=nil,
    songfinished = false
  }

  function obj.init(newst)
    obj.currst = newst
  end

  function obj.resetlevel()
    obj.currst.offset = obj.currst.level.properties.offset
    obj.currst.startbeat = obj.currst.startbeat or 0
    obj.currst.cbeat = 0-obj.currst.offset +obj.currst.startbeat
    obj.currst.autoplay = false
    obj.currst.length = 42
    obj.currst.pt = 0
    obj.currst.bg = gfx.image.new("assets/bgs/nothing.png")
  
    obj.currst.misses= 0
    obj.currst.hits = 0
    obj.currst.combo = 0
    obj.currst.maxhits = 0
    for i,v in ipairs(obj.currst.level.events) do
      if v.type == "beat" or v.type == "slice" or v.type == "sliceinvert" or v.type == "inverse" or v.type == "hold" or v.type == "mine" or v.type == "side" or v.type == "minehold" or v.type == "ringcw" or v.type == "ringccw" then
        obj.currst.maxhits += obj.currst.maxhits
      end
    end
  
    obj.currst.on = true
  
    obj.currst.beatsounds = true
    obj.currst.extend = 0
    for i,v in ipairs(obj.currst.level.events) do
      v.played = false
      v.autoplayed = false
    end
    obj.currst.vfx = {}
    obj.currst.vfx.hom = false
    obj.currst.vfx.bgnoise = {enable=false,image=gfx.image.new("assets/game/noise/0noiseatlas.png"),r=1,b=1,g=1}
    obj.currst.lastsigbeat = math.floor(obj.currst.cbeat)
  end

  function obj.update(dt)
    if not obj.on then
      return
    end
  
    pq = ""
  
    -- read the level
    for i,v in ipairs(obj.currst.level.events) do
    -- preload events such as beats
      if v.time <= obj.currst.cbeat+obj.currst.offset and v.played == false then
        if v.type == "play" and obj.currst.sounddata == nil then
          obj.currst.level.bpm = v.bpm
          obj.currst.sounddata = (clevel..v.file)
         pq = pq .. "      loaded sounddata"
  
        end
        if v.type == "beat" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.angle = v.angle
          newbeat.startangle = v.angle
          newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.spinease = v.spinease or "linear" -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
        if v.type == "slice" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.angle = v.angle
          newbeat.slice = true
          newbeat.startangle = v.angle
          newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
        if v.type == "sliceinvert" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.angle = v.angle
          newbeat.slice = true
          newbeat.inverse = true
          newbeat.startangle = v.angle
          newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
        if v.type == "inverse" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.angle = v.angle
          newbeat.startangle = v.angle
          newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          newbeat.inverse = true
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
        if v.type == "hold" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.segments = v.segments or nil
          newbeat.hold = true
          newbeat.duration = v.duration
          newbeat.holdease = v.holdease or nil
          newbeat.startangle = v.angle1
          newbeat.angle = v.angle1
          newbeat.angle1 = v.angle1
          newbeat.angle2 = v.angle2 or v.angle1
          newbeat.endangle = v.endangle or v.angle1 -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          pq = pq .. "    ".. "hold spawn here! holdease: " .. tostring(newbeat.holdease) .. ", segments: " .. tostring(newbeat.segments)
          
          newbeat.update()
        end
        if v.type == "minehold" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.segments = v.segments or nil
          newbeat.minehold = true
          newbeat.duration = v.duration
          newbeat.holdease = v.holdease or nil
          newbeat.startangle = v.angle1
          newbeat.angle = v.angle1
          newbeat.angle1 = v.angle1
          newbeat.angle2 = v.angle2 or v.angle1
          newbeat.endangle = v.endangle or v.angle1 -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          pq = pq .. "    ".. "mine hold here!"
          
          newbeat.update()
        end
        if v.type == "mine" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.angle = v.angle
          newbeat.startangle = v.angle
          newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.spinease = v.spinease or "linear" -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          newbeat.mine=true
          pq = pq .. "    ".. "mine here!"
          newbeat.update()
        end
        if v.type == "side" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.angle = v.angle
          newbeat.startangle = v.angle
          newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.spinease = v.spinease or "linear" -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          newbeat.side=true
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
        if v.type == "ringcw" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.spinrate = v.spinrate or 1 -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.spinease = v.spinease or "linear" -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          newbeat.ringcw=true
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
        if v.type == "ringccw" then
          v.played = true
          local newbeat = em.init("beat",screencenter.x,screencenter.y)
          newbeat.spinrate = v.spinrate or 1 -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.spinease = v.spinease or "linear" -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
          newbeat.hb = v.time
          newbeat.smult = v.speedmult
          newbeat.ringccw=true
          pq = pq .. "    ".. "spawn here!"
          newbeat.update()
        end
  
      end
            -- autoplay
        if v.time-0.05 <= obj.currst.cbeat and obj.currst.autoplay and v.autoplayed == false then
          if v.type == "beat" or v.type == "inverse" then
            v.autoplayed = true
            if obj.currst.ce ~= nil then
              obj.currst.ce:stop()
              obj.currst.ce = nil
            end
            obj.currst.ce = flux.to(obj.currst.p,0,{angle = v.angle}):ease("outExpo")
            pq = pq..("     easing to "..v.angle)
          end
        end
  
      -- load other events on the beat
      if v.time <= obj.currst.cbeat and v.played == false then
        v.played = true
        if v.type == "play" then
          obj.currst.sounddata = snd.sampleplayer.new(obj.currst.sounddata, 2)
          obj.currst.source = pdbpm:newTrack(obj.currst.sounddata)
          obj.currst.source:load(obj.currst.sounddata)
          obj.currst.source:setBPM(v.bpm)
          obj.currst.source:setLooping(false)
          obj.currst.source:play()
          obj.currst.source:on("end", function(f) print("song finished!!!!!!!!!!") obj.songfinished = true end)
          obj.currst.source:setBeat(obj.currst.cbeat)
          pq = pq .. "    ".. "now playing ".. v.file
        end
        if v.type == "setBPM" then
          obj.currst.source:setBPM(v.bpm, v.time)
          pq = pq .. "    set bpm to "..v.bpm .. " !!"
        end
  
        if v.type == "width" then
          flux.to(obj.currst.p,v.duration,{paddle_size=v.newwidth}):ease("linear")
          pq = pq.. "    width set to " .. v.newwidth
        end
  
        if v.type == "multipulse" then
          pq = pq.. "    pulsing, generating other pulses"
          obj.currst.extend = 10
          flux.to(obj.currst,10,{extend=0}):ease("linear")
          for i=1,v.reps do
            table.insert(obj.currst.level.events,{type="singlepulse",time=v.time+v.delay*i,played=false})
          end
        end
  
        if v.type == "singlepulse" then
          obj.currst.extend = 10
          flux.to(obj.currst,10,{extend=0}):ease("linear")
          pq = pq.. "    pulsing"
        end
  
        if v.type == "setbg" then
          obj.currst.bg = gfx.image.new("assets/bgs/".. v.file)
          pq = pq.. "     set bg to " .. v.file
        end
  
        if v.type == "hom" then
          obj.currst.vfx.hom = v.enable
  
          if v.enable then
            pq = pq .. "    ".. "Hall Of Mirrors enabled"
          else
            pq = pq .. "    ".. "Hall Of Mirrors disabled"
          end
        end
        if v.type == "bgnoise" then
          obj.currst.vfx.bgnoise.enable = v.enable
          if v.enable then
            obj.currst.vfx.bgnoise.image = gfx.image.new("assets/game/noise/" .. v.filename)
            obj.currst.vfx.bgnoise.r = v.r or 1
            obj.currst.vfx.bgnoise.g = v.g or 1
            obj.currst.vfx.bgnoise.b = v.b or 1
            obj.currst.vfx.bgnoise.a = v.a or 1
          else
            obj.currst.vfx.bgnoise.image = gfx.image.new("assets/game/noise/0noiseatlas.png")
            obj.currst.vfx.bgnoise.r = 1
            obj.currst.vfx.bgnoise.g = 1
            obj.currst.vfx.bgnoise.b = 1
            obj.currst.vfx.bgnoise.a = 0
          end
          if v.enable then
            pq = pq .. "    ".. "BG Noise enabled with filename of " .. v.filename
          else
            pq = pq .. "    ".. "BG Noise disabled"
          end
        end
  
        if v.type == "circle" then
          pq = pq .. "    ".. "circle spawned"
          local nc = em.init("circlevfx",v.x,v.y)
          nc.delt = v.delta
        end
        if v.type == "square" then
          pq = pq .. "    ".. "square spawned"
          local nc = em.init("squarevfx",v.x,v.y)
          nc.r = v.r
          nc.dx = v.dx
          nc.dy = v.dy
          nc.dr = v.dr
          nc.life = v.life
          nc.update()
        end
        if v.type == "showresults" then
          flux.to(obj.currst.p,60,{ouchpulse=300,lookradius=0}):ease("inExpo"):oncomplete(function(f) Noble.transition(ResultsScene)end )
  
        end
        if v.type == "lua" then
          pq = pq .. "    ".. "ran lua code"
          local code = loadstring(v.code) -- NOOOOOO YOU CANT RUN ARBITRARY CODE THATS A SECURITY RISK
          code()  --haha loadstring go brrr
        end
      end
    end
    
    if obj.currst.source == nil or obj.songfinished then
      obj.currst.cbeat = obj.currst.cbeat + (obj.currst.level.bpm/60) * dt
    else
      obj.currst.source:update(dt)
      local b,sb = obj.currst.source:getBeat(1)
      obj.currst.cbeat = b+sb
      --print(b+sb)
    end
    if obj.currst.combo >= math.floor(obj.currst.maxhits / 4) then
      obj.currst.p.cemotion = "happy"
      obj.currst.p.emotimer = 2
      --print("player should be happy")
    end
  
  end
  
  
  function obj.draw()
  
  end

  return obj
end

return gamemanager
Gamemanager = class('Gamemanager',Entity)


function Gamemanager:initialize(params)
	
	self.skiprender = true
	self.skipupdate = true
  self.layer = 1
  self.uplayer = -9999
  self.x=0
  self.y=0
  self.songfinished = false
	
  Entity.initialize(self,params)
	
	cs.p = em.init("player",{x=project.res.cx,y=project.res.cy})
end


function Gamemanager:resetlevel()
  cs.offset = cs.level.properties.offset
  cs.startbeat = cs.startbeat or 0
  cs.cbeat = 0-cs.offset +cs.startbeat
  cs.autoplay = false
  cs.length = 42
  cs.pt = 0
  cs.bg = love.graphics.newImage("assets/bgs/nothing.png")  

  cs.misses= 0
  cs.hits = 0
  cs.combo = 0
  cs.maxhits = 0
  for i,v in ipairs(cs.level.events) do
    if v.type == "beat" or v.type == "slice" or v.type == "sliceinvert" or v.type == "inverse" or v.type == "hold" or v.type == "mine" or v.type == "side" or v.type == "minehold" or v.type == "ringcw" or v.type == "ringccw" then
      cs.maxhits = cs.maxhits + 1
    end
  end

  cs.on = true

  cs.beatsounds = true
  cs.extend = 0
  for i,v in ipairs(cs.level.events) do
    v.played = false
    v.autoplayed = false
  end
  cs.vfx = {}
  cs.vfx.hom = false
  cs.vfx.bgnoise = {enable=false,image=love.graphics.newImage("assets/game/noise/0noiseatlas.png"),r=1,b=1,g=1}
  cs.lastsigbeat = math.floor(cs.cbeat)
end


function Gamemanager:update(dt)
	prof.push("gamemanager update")
  if not self.on then
    return
  end

  pq = ""
  

  -- read the level
	
	
  for i,v in ipairs(cs.level.events) do
  -- preload events such as beats
    if v.time <= cs.cbeat+cs.offset and v.played == false then
      if v.type == "play" and cs.sounddata == nil then
        cs.level.bpm = v.bpm
        cs.sounddata = love.sound.newSoundData(clevel..v.file)
        
       pq = pq .. "      loaded sounddata"

      end
      if v.type == "beat" then
        v.played = true
        local newbeat = em.init("beat",{
					x=project.res.cx,
					y=project.res.cy,
					angle = v.angle,
					endangle = v.endangle,
					spinease = v.spinease,
					hb = v.time,
					smult = v.speedmult
				})
        pq = pq .. "    ".. "spawn here!"
        newbeat:update(dt)
      end
			--[[
      if v.type == "slice" then
        v.played = true
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        pq = pq .. "    ".. "hold spawn here!"
                newbeat.update()
      end
      if v.type == "minehold" then
        v.played = true
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
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
        local newbeat = em.init("beat",project.res.cx,project.res.cy)
        newbeat.spinrate = v.spinrate or 1 -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.spinease = v.spinease or "linear" -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        newbeat.ringccw=true
        pq = pq .. "    ".. "spawn here!"
        newbeat.update()
      end
			]]--

    end
          -- autoplay
      if v.time-0.05 <= cs.cbeat and cs.autoplay and v.autoplayed == false then
        if v.type == "beat" or v.type == "inverse" then
          v.autoplayed = true
          if cs.ce ~= nil then
            cs.ce:stop()
            cs.ce = nil
          end
          cs.ce = flux.to(cs.p,0,{angle = v.angle}):ease("outExpo")
          pq = pq..("     easing to "..v.angle)
          
        end
      end


    -- load other events on the beat
    if v.time <= cs.cbeat and v.played == false then
      
      v.played = true
      if v.type == "setBPM" then
        cs.source:setBPM(v.bpm, v.time)
        pq = pq .. "    set bpm to "..v.bpm .. " !!"
      end
      if v.type == "play" then
        cs.source = lovebpm.newTrack()
          :load(cs.sounddata)
          :setBPM(v.bpm)
          :setLooping(false)
          :play()
          :on("end", function(f) print("song finished!!!!!!!!!!") self.songfinished = true end)
        
        cs.source:setBeat(cs.cbeat)
        pq = pq .. "    ".. "now playing ".. v.file
      end
      
      if v.type == "width" then

        
        flux.to(cs.p,v.duration,{paddle_size=v.newwidth}):ease("linear")
        pq = pq.. "    width set to " .. v.newwidth
      end
      
      if v.type == "multipulse" then
        pq = pq.. "    pulsing, generating other pulses"
        cs.extend = 10
        flux.to(cs,10,{extend=0}):ease("linear")
        for i=1,v.reps do
          table.insert(cs.level.events,{type="singlepulse",time=v.time+v.delay*i,played=false})
        end
      end

      if v.type == "singlepulse" then
        cs.extend = 10
        flux.to(cs,10,{extend=0}):ease("linear")
        pq = pq.. "    pulsing"
      end
      
      if v.type == "setbg" then
        cs.bg = love.graphics.newImage("assets/bgs/".. v.file)
        pq = pq.. "     set bg to " .. v.file
      end

      if v.type == "hom" then
        cs.vfx.hom = v.enable

        if v.enable then
          pq = pq .. "    ".. "Hall Of Mirrors enabled"
        else
          pq = pq .. "    ".. "Hall Of Mirrors disabled"
        end
      end
      if v.type == "bgnoise" then
        cs.vfx.bgnoise.enable = v.enable
        if v.enable then
          cs.vfx.bgnoise.image = love.graphics.newImage("assets/game/noise/" .. v.filename)
          cs.vfx.bgnoise.r = v.r or 1
          cs.vfx.bgnoise.g = v.g or 1
          cs.vfx.bgnoise.b = v.b or 1
          cs.vfx.bgnoise.a = v.a or 1
        else
          cs.vfx.bgnoise.image = love.graphics.newImage("assets/game/noise/0noiseatlas.png")
          cs.vfx.bgnoise.r = 1
          cs.vfx.bgnoise.g = 1
          cs.vfx.bgnoise.b = 1
          cs.vfx.bgnoise.a = 0
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
        flux.to(cs.p,60,{ouchpulse=300,lookradius=0}):ease("inExpo"):oncomplete(function(f) 
					cs = bs.load('results')
					cs:init()
				end )
        
      end
      if v.type == "lua" then
        pq = pq .. "    ".. "ran lua code"
        local code = loadstring(v.code) -- NOOOOOO YOU CANT RUN ARBITRARY CODE THATS A SECURITY RISK
        code()  --haha loadstring go brrr
      end
    end
  end
  
  if cs.source == nil or self.songfinished then
    cs.cbeat = cs.cbeat + (cs.level.bpm/60) * love.timer.getDelta()
  else
    cs.source:update()
    local b,sb = cs.source:getBeat(1)
    cs.cbeat = b+sb
    --print(b+sb)
  end
  if cs.combo >= math.floor(cs.maxhits / 4) then
    cs.p.cemotion = "happy"
    cs.p.emotimer = 2
    --print("player should be happy")
  end
	
  prof.pop("gamemanager update")
end


function Gamemanager:draw()
	prof.push("gamemanager draw")
  if not cs.vfx.hom then
    love.graphics.clear()
  end
  
  love.graphics.setBlendMode("alpha")
  color()

  --if cs.vfx.hom then
    --for i=0,cs.vfx.homint do
      --love.graphics.points(math.random(0,400),math.random(0,240))
    --end 
    
  --end
  --ouch the lag
  if cs.vfx.bgnoise.enable then
    love.graphics.setColor(cs.vfx.bgnoise.r,cs.vfx.bgnoise.g,cs.vfx.bgnoise.b,cs.vfx.bgnoise.a)
    love.graphics.draw(cs.vfx.bgnoise.image,math.random(-2048+gameWidth,0),math.random(-2048+gameHeight,0))
  end
  love.graphics.draw(cs.bg)

  color()
  em.draw()
	color('black')
  --love.graphics.print(cs.hits.." / " .. (cs.misses+cs.hits),10,10)
  if cs.combo >= 10 then
    love.graphics.setFont(fonts.digitaldisco)
    love.graphics.print(cs.combo..loc.get("combo"),10,220)
  end
  color()
	prof.pop("gamemanager draw")

end


return Gamemanager
Gamemanager = class('Gamemanager',Entity)

Event = {}
Event.onload = {}
Event.onoffset = {}
Event.onbeat = {}
Event.info = {}

Event.editordraw = {}
Event.editorproperties = {}

Event.eases = {
	'linear',
	'inSine', 'outSine', 'inOutSine',
	'inQuad', 'outQuad', 'inOutQuad', 
	'inCubic', 'outCubic', 'inOutCubic',
	'inQuart', 'outQuart', 'inOutQuart',
	'inQuint', 'outQuint', 'inOutQuint',
	'inExpo', 'outExpo', 'inOutExpo',
	'inCirc', 'outCirc', 'inOutCirc',
	'inElastic', 'outElastic', 'inOutElastic',
	'inBack', 'outBack', 'inOutBack'
}

function Event.property(event,propertytype, propertyname, tooltip, properties)
	properties = properties or {}
	local enabled = true
	
	if properties.optional then
		enabled = imgui.Checkbox('##checkbox'..propertyname,(event[propertyname] ~= nil))
		imgui.SameLine()
		
		if enabled then
			if event[propertyname] == nil then
				event[propertyname] = properties.default
			end
		else
			event[propertyname] = nil
		end
	else
		if event[propertyname] == nil then
			event[propertyname] = properties.default
		end
	end
	
	if enabled then
		if propertytype == 'decimal' then
			imgui.PushItemWidth(100)
			event[propertyname] = imgui.InputFloat(propertyname, event[propertyname], properties.step or 0.01, properties.stepspeed or 1, properties.decimalsize or 3)
			imgui.PopItemWidth()
		end
		if propertytype == 'int' then
			imgui.PushItemWidth(100)
			event[propertyname] = imgui.InputInt(propertyname, event[propertyname])
			imgui.PopItemWidth()
		end
		if propertytype == 'string' then
			imgui.PushItemWidth(100)
			event[propertyname] = imgui.InputText(propertyname, event[propertyname],9999)
			imgui.PopItemWidth()
		end
		if propertytype == 'ease' then
			local comboselection = 0
			for i,v in ipairs(Event.eases) do
				if v == event[propertyname] then
					comboselection = i
				end
			end
			
			imgui.PushItemWidth(100)
			comboselection = imgui.Combo(propertyname, comboselection, Event.eases, #Event.eases);
			event[propertyname] = Event.eases[comboselection]
			imgui.PopItemWidth()
		end
	else
		imgui.Text(propertyname)
	end
	
	
	if properties.default then
		tooltip = tooltip .. '\nDefault value: ' .. properties.default
	end
	
	helpers.imguihelpmarker(tooltip)
end


local elist = {}

local function findfiles(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	for i,v in ipairs(files) do
		if v ~= '_TEMPLATE.lua' then
			local path = dir..'/'..v
			local info = love.filesystem.getInfo(path)
			if info.type == 'file' then
				table.insert(elist,path)
			elseif info.type == 'directory' then
				findfiles(path)
			end
		end
	end
end

findfiles('levelformat/events')

for i,v in ipairs(elist) do
	local info, onload, onoffset, onbeat, editordraw, editorproperties = dofile(v)
	local etype = ''
	if onload then
		Event.onload[info.event] = onload
		etype = etype .. ' onload'
	end
	if onoffset then
		Event.onoffset[info.event] = onoffset
		etype = etype .. ' onoffset'
	end
	if onbeat then
		Event.onbeat[info.event] = onbeat
		etype = etype .. ' onbeat'
	end
	
	Event.editordraw[info.event] = editordraw
	Event.editorproperties[info.event] = editorproperties
	
	Event.info[info.event] = info
	print('loaded event "'..info.name..'" ('..info.event..etype..')')
end

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
	pq = ""
  cs.offset = cs.level.properties.offset
	cs.songoffset = 0
  cs.startbeat = cs.startbeat or project.startbeat or 0
  cs.cbeat = 0-cs.offset +cs.startbeat
  cs.autoplay = false
  cs.length = 42 --TODO: remove this and rely only on player size
  cs.pt = 0
  cs.bg = love.graphics.newImage("assets/bgs/nothing.png")  
	cs.bgcolor = 'white'
  cs.misses= 0
  cs.hits = 0
  cs.combo = 0
  cs.maxhits = 0
	cs.outline = -1
	cs.p.paddle_size = 70
	
	--deal with new level format
	cs.playevents = {}
	--[[
	if cs.chart then
		for i,v in ipairs(cs.chart) do
			table.insert(cs.playevents,v)
		end
	end
	]]
	for i,v in ipairs(cs.level.events) do
		table.insert(cs.playevents,v)
	end
	--from now on cs.level.events should be cs.playevents
	
  for i,v in ipairs(cs.playevents) do
    --if v.type == "beat" or v.type == "slice" or v.type == "sliceinvert" or v.type == "inverse" or v.type == "hold" or v.type == "mine" or v.type == "side" or v.type == "minehold" or v.type == "ringcw" or v.type == "ringccw" then
		if Event.info[v.type] and Event.info[v.type].hits then
      cs.maxhits = cs.maxhits + Event.info[v.type].hits
    end
  end
  --cs.on = true

  cs.beatsounds = true
  cs.extend = 0
  for i,v in ipairs(cs.playevents) do
    v.play_onload = nil
		v.play_onoffset = nil
		v.play_onbeat = nil
  end
  cs.vfx = {}
  cs.vfx.hom = false
	cs.vfx.xscale = 1
	cs.vfx.yscale = 1
  cs.vfx.bgnoise = {enable=false,image=nil,r=1,g=1,b=1,a=1}
  cs.lastsigbeat = math.floor(cs.cbeat)
	
	if not cs.editmode then
		--onload pass
		print('running onload events...')
		local oltotal = 0
		for i,v in ipairs(cs.playevents) do
			if Event.onload[v.type] then
				if (not v.play_onload) then
					Event.onload[v.type](v)
					v.play_onload = true
					oltotal = oltotal + 1
				end
			end
		end
		rw:play(cs.cbeat)
		print('ran ' .. oltotal .. ' events')
	end
end

function Gamemanager:beattoms(beat,bpm) --you gotta Trust me that the numbers check out here
	bpm = bpm or cs.level.bpm
	return beat * (60000/bpm)
end

function Gamemanager:mstobeat(ms,bpm)
	bpm = bpm or cs.level.bpm
	return ms / (60000/bpm) 
end

function Gamemanager:gradecalc(pct) --idk where else to put this, but it shouldn't go into helpers because its so game specific.
  local lgrade = ""
  local lgradepm = ""
  
  if pct == 100 then
    lgrade = "s"
  elseif pct >= 90 then
    lgrade = "a"
  elseif pct >= 80 then
    lgrade = "b"
  elseif pct >= 70 then
    lgrade = "c"
  elseif pct >= 60 then
    lgrade = "d"
  else
    lgrade = "f"
  end
  lgradepm = "none"
  if lgrade ~= "s" and lgrade ~= "f" then
    if pct % 10 <= 3 then
      lgradepm = "minus"
    elseif pct % 10 >= 7 then
      lgradepm = "plus"
    end
  end
  return lgrade, lgradepm
end


function Gamemanager:update(dt)
	--IMPORTANT:
	--The way that this is set up will 100% be a performance bottleneck in the future.
	--But for now, it works well enough, even on stuff like Waves From Nothing (jit is amazing!)
	--If more complicated levels start chugging, this is where you will want to optimize.
	prof.push("gamemanager update")

  pq = ""
  if cs.source == nil or self.songfinished then
    cs.cbeat = cs.cbeat + (cs.level.bpm/60) * love.timer.getDelta()
  else
    cs.source:update()
    local b,sb = cs.source:getBeat(1)
    cs.cbeat = b+sb + cs.songoffset
    --print(b+sb)
  end

  -- read the level
	
	
  for i,v in ipairs(cs.playevents) do -- onoffset + onbeat pass
  -- preload events such as beats
    if Event.onoffset[v.type] then 
			if v.time <= cs.cbeat+cs.offset and (not v.play_onoffset) then
				Event.onoffset[v.type](v)
				v.play_onoffset = true
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
		
    -- load other events on the beat
		if Event.onbeat[v.type] then
			if v.time <= cs.cbeat and (not v.play_onbeat) then
				Event.onbeat[v.type](v)
				v.play_onbeat = true
			end
		end
		
		--[[
    if v.time <= cs.cbeat and v.played == false then
      
      v.played = true
      

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
			
			
      if v.type == "lua" then
        pq = pq .. "    ".. "ran lua code"
        local code = loadstring(v.code) -- NOOOOOO YOU CANT RUN ARBITRARY CODE THATS A SECURITY RISK
        code()  --haha loadstring go brrr
      end
    end
		]]--
  end
  
  rw:update(cs.cbeat)
  if cs.combo >= math.floor(cs.maxhits / 4) then
    cs.p.cemotion = "happy"
    cs.p.emotimer = 2
    --print("player should be happy")
  end
	
  prof.pop("gamemanager update")
end


function Gamemanager:draw()
	prof.push("gamemanager draw")
	
  color(cs.bgcolor)
  if not cs.vfx.hom then
    love.graphics.clear()
		love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
  end
  
  love.graphics.setBlendMode("alpha")

  --if cs.vfx.hom then
    --for i=0,cs.vfx.homint do
      --love.graphics.points(math.random(0,400),math.random(0,240))
    --end 
    
  --end
  --ouch the lag
  if cs.vfx.bgnoise.enable then
    love.graphics.setColor(cs.vfx.bgnoise.r,cs.vfx.bgnoise.g,cs.vfx.bgnoise.b,cs.vfx.bgnoise.a)
    love.graphics.draw(cs.vfx.bgnoise.image,math.random(-2048+project.res.x,0),math.random(-2048+project.res.y,0))
  end
  love.graphics.draw(cs.bg)
	
	if cs.drawvideobg then
		love.graphics.setShader(shaders.videoshader)
		love.graphics.draw(cs.videobg)
		love.graphics.setShader()
	end

  color()
  em.draw()
	color('black')
  --love.graphics.print(cs.hits.." / " .. (cs.misses+cs.hits),10,10)
  if cs.combo >= 10 then
    love.graphics.setFont(fonts.digitaldisco)
		outline(function()
			love.graphics.print(cs.combo..loc.get("combo"),10,220)
		end, cs.outline)
  end
  color()
	prof.pop("gamemanager draw")

end


return Gamemanager
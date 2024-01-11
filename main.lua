function love.load()

  dofile = function(fname) return love.filesystem.load(fname)() end
  
  dt = 1
  
  freeze = 0
  
  -- set rescaling filter
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  love.graphics.setLineStyle("rough")
  love.graphics.setLineJoin("miter")
  
  fonts ={
    main = love.graphics.newFont("assets/fonts/Axmolotl.ttf", 16),
    digitaldisco = love.graphics.newFont("assets/DigitalDisco-Thin.ttf", 16)
  }
  
  -- font is https://tepokato.itch.io/axolotl-font
  
  for i,v in ipairs(fonts) do
    v:setFilter("nearest", "nearest",0)
  end
  
  love.graphics.setFont(fonts.main)
  
  -- import libraries
  
	--imgui
	if project.useimgui then
		print('importing imgui')
		imgui = require "imgui"
	end

  -- lovebpm, syncs stuff to music
  lovebpm = require "lib.lovebpm"


  -- json handler
  json = require "lib.json" -- i would use a submodule, but the git repo has .lua in the name??????
  
  -- custom functions, snippets, etc
  helpers = require "lib.helpers"
  
  -- quickly load json files
  dpf = require "lib.dpf"
  
  -- localization
  loc = require "lib.loc"
  loc.load("data/localization.json")
  

  -- manages gamestates
  bs = require "lib.basestate"

  -- baton, manages input handling
  baton = require "lib/baton/baton"

  if project.res.useshuv then
    shuv = require "lib.shuv"
    shuv.init(project)
    --shuv.hackyfix()
  end
  -- what it says on the tin
  utf8 = require("utf8")


  -- deeper, modification of deep, queue functions, now with even more queue
  deeper = require "lib/deeper/deeper"

  -- tesound, sound playback
  te = require"lib.tesound"


  -- jprof, profiling
  
  PROF_CAPTURE = project.doprofile
  
  prof = require "lib/profiling/jprof"
  
  prof.enabled(project.doprofile)
  
  if project.doprofile then
    print("profiling enabled!")
  end

  -- lovebird, debugging console
  if (not project.release)  then 
    lovebird = require "lib/lovebird/lovebird"
  else
    lovebird = require "lib.lovebirdstripped"
  end

  -- entity manager
  em = require "lib.entityman"

  -- spritesheet manager
  ez = require "lib.ezanim_rewrite"

  -- tween manager
  flux = require "lib/flux/flux"
  
  rw = require "lib/ricewine"
  
  
  
  class = require "lib/middleclass/middleclass"
  
  Gamestate = class('Gamestate')
  
  function Gamestate:initialize(name)
    self.name = name or 'newstate'
    self.updatefunc = function() end
    self.bgdrawfunc = function() end
    self.fgdrawfunc = function() end
  end
  
  function Gamestate:setinit(initfunc)
    self.initfunc = initfunc
  end
    
  function Gamestate:setupdate(updatefunc)
    self.updatefunc = updatefunc
  end
  
  function Gamestate:setbgdraw(drawfunc)
    self.bgdrawfunc = drawfunc
  end
  
  function Gamestate:setfgdraw(drawfunc)
    self.fgdrawfunc = drawfunc
  end
  
  function Gamestate:init(...)
    self:initfunc(...)
  end
  
  function Gamestate:update(dt)
		if project.useimgui then
			if not imgui.GetWantCaptureKeyboard() then
				maininput:update()
			end
			if not imgui.GetWantCaptureMouse() then
				helpers.updatemouse()
			end
		else
			
			maininput:update()
			helpers.updatemouse()
		end
    lovebird.update()
    
    prof.push("gamestate update")
    self:updatefunc(dt)
    prof.pop("gamestate update")
    
		--[[
    prof.push("ricewine update")
    rw:update()
    prof.pop("ricewine update")
    ]]--
    prof.push("flux update")
    flux.update(dt)
    prof.pop("flux update")
    
    prof.push("entityman update")
    em.update(dt)
    prof.pop("entityman update")
    
		mouse.sx, mouse.sy = 0,0
		
    te.cleanup()
  end
  
  
  function Gamestate:draw()
    if project.res.useshuv then
      shuv.start()
    end
    
    prof.push("bg draw")
    self:bgdrawfunc()
    prof.pop("bg draw")
    
		if not self.holdentitydraw then
			prof.push("entityman draw")
			em.draw()
			prof.pop("entityman draw")
		end
    
    prof.push("fg draw")
    self:fgdrawfunc()
    prof.pop("fg draw")
    
    love.graphics.setColor(1,1,1,1)
    
    if project.res.useshuv then
      shuv.finish()
    end
  end
  
  
  
  Entity = class('Entity')
  
  
  function Entity:initialize(params)
    params = params or {}
    self.layer = self.layer or 0
    self.uplayer = self.uplayer or 0
    self.delete = false
    
    for k,v in pairs(params) do
      self[k] = v
    end
  end
  
  function Entity:update(dt)
  end
  function Entity:draw(dt)
  end
  
  
  
  love.window.setTitle(project.name)
  paused = false

  --load sprites

  sprites = require('preload.sprites')
  
  -- make ezanim templates
  animations = require('preload.animations')

  
  -- make quads
  
  quads = require('preload.quads')
  
  
  -- load shaderss
  
  shaders = require('preload.shaders')
  
  --colors
  colors = require('preload.colors')
	
	--sounds
  sounds = require('preload.sounds')
	
  
  function color(c)
    c = c or 'white'
    love.graphics.setColor(colors[c])    
  end

  --outline helpers
	outline_canvas = love.graphics.newCanvas(project.res.x,project.res.y)
  function outline(func, col)
		if col then
			
			local oldcanvas = love.graphics.getCanvas()
			love.graphics.setCanvas(outline_canvas)
			love.graphics.clear()
			
			func()
			
			love.graphics.setCanvas(oldcanvas)
			
			shaders.outline:send('gameWidth', project.res.x)
			shaders.outline:send('gameHeight', project.res.y)
			shaders.outline:send('c', col)
			love.graphics.setShader(shaders.outline)
			love.graphics.draw(outline_canvas)
			love.graphics.setShader()
		else
			func()
		end
	end
  
  
  

  print("setting up controls")

  
  
  maininput = baton.new {
    controls = project.ctrls,
    pairs = {
      udlr = {"up", "down","left", "right"}
    },
      joystick = love.joystick.getJoysticks()[1],
  }
  
  
  -- load savefile
  local defaultsave = dpf.loadjson(project.defaultsaveloc)
    
  if project.nosaves then
    savedata = defaultsave
  else
    savedata = dpf.loadjson(project.saveloc,defaultsave)
  end
  
  
  
  
  
  
  sdfunc = {}
  function sdfunc.save()
    dpf.savejson(project.saveloc,savedata)
  end
  
  function sdfunc.updatevol()
    if project.name ~= 'roomedit' then
      te.volume('sfx',savedata.options.audio.sfxvolume/10)
      te.volume('music',savedata.options.audio.sfxvolume/10)
    end
  end
  
  sdfunc.updatevol()
  sdfunc.save()

  entities = {}
  -- load entities
  dofile('preload/entities.lua')
  
  -- load states

  dofile('preload/states.lua')
  
  
  -- load levels
  
  
  
  toswap = nil
  newswap = false
  
  cs = bs.load(project.initstate)
	cs:init()
  
end


function love.update(d)
  prof.push("frame")

	if project.frameadvance then
		maininput:update()
		lovebird.update()
	end
  if (not project.frameadvance) or maininput:pressed("k1") or maininput:down("k2") then
    debugprint = true

    if project.res.useshuv then
      shuv.check()
    end
    if not project.acdelt then
      dt = 1
    else
      dt = d * 60
    end
    if dt >=6 then
      dt = 6
    end
    
    if freeze <= 0 then
      cs:update(dt)
    else
      freeze = freeze - dt
    end
    
    
  end
end

function love.draw()
	if project.useimgui then
		imgui.NewFrame()
	end
	
  cs:draw()
  debugprint = false
  prof.pop("frame")
	if project.useimgui then
		imgui.End()
		imgui.Render()
	end
end


---IMGUI STUFF
function love.textinput(t)
	if project.useimgui then
		imgui.TextInput(t)
		if not imgui.GetWantCaptureKeyboard() then
			tinput = t
		end
	else
		tinput = t
	end
end

if project.useimgui then
	function love.keypressed(key)
			imgui.KeyPressed(key)
	end

	function love.keyreleased(key)
			imgui.KeyReleased(key)
	end

	function love.mousemoved(x, y)
		imgui.MouseMoved(x, y)
	end

	function love.mousepressed(x, y, button)
		imgui.MousePressed(button)
	end

	function love.mousereleased(x, y, button)
		imgui.MouseReleased(button)
	end

	function love.wheelmoved(x, y)
		mouse.sx, mouse.sy = x, y
		imgui.WheelMoved(y)
	end
end


function love.quit()
  if project.doprofile then
    print('saving profile')
    prof.write("prof.mpack")
  end
	if project.useimgui then
		imgui.ShutDown()
	end
end
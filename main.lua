function love.load()
  dt = 1
  clevel = "cannery.json"
  gamename = "BeatBlock"
  crankymode = true
  release = false
  ismobile = false
  mobileoverride = false
  if love.system.getOS( ) == "Android" or mobileoverride then
    ismobile = true
    
  end
  pressed = 0
  mx,my = 0,0
  ispush = false
  screencenter = {x = 200, y = 120}
  -- font is https://tepokato.itch.io/axolotl-font
  -- https://www.dafont.com/digital-disco.font
  font = love.graphics.newFont("assets/DigitalDisco-Thin.ttf", 16)
  font:setFilter("nearest", "nearest",0)
  love.graphics.setFont(font)
  -- accurate deltatime
  acdelt = true
  love.graphics.setDefaultFilter("nearest","nearest")

  -- import libraries
  -- gamestate, manages gamestates
  gs = require "lib.gamestate"

  -- baton, manages input handling
  baton = require "lib.baton"

  -- lovebpm, syncs stuff to music
  lovebpm = require "lib.lovebpm"

  shuv = require "lib.shuv"
  shuv.init()

  -- custom functions, snippets, etc
  helpers = require "lib.helpers"
  -- push, graphics helper, makes screen resolution stuff easy
  if ispush then
    push = require "lib.push"
  else
    push = require "lib.pushstripped"
    love.window.setMode(400,240)
  end

  -- deeper, modification of deep, queue functions, now with even more queue
  deeper = require "lib.deeper"

  -- tesound, sound playback
  te = require"lib.tesound"

  -- json handler
  json = require "lib.json"

  -- lovebird,debugging console
  if (not release) or ismobile then 
    lovebird = require "lib.lovebird"
  else
    lovebird = require "lib.lovebirdstripped"
  end

  -- entity manager
  em = require "lib.entityman"

  -- spritesheet manager
  ez = require "lib.ezanim"

  -- tween manager
  flux = require "lib.flux"

  -- set size of window
  windowWidth, windowHeight = 800, 480
  
  -- set rescaling filter
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- set line style
  love.graphics.setLineStyle("rough")
  love.graphics.setLineJoin("miter")

  -- set game canvas size
  gameWidth, gameHeight = 400,240
  
  -- send these arguments to push
  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
    fullscreen = release,
    resizable = false,
    pixelperfect = true
    })
  push:setBorderColor{0,0,0}
  love.window.setTitle(gamename)
  paused = false

  -- start colors table with default colors
  colors = {
    {1,1,1},
    {0,0,0},
    {1,0,77/255},
    {1,0,0}
  }
  --load sprites into memory, so that we are not loading 50 bajillion copies of the beats in a level
  sprites = {
    beat= {
      square = love.graphics.newImage("assets/game/square.png"),
      inverse = love.graphics.newImage("assets/game/inverse.png"),
      hold = love.graphics.newImage("assets/game/hold.png")
    },
    player = {
      idle = love.graphics.newImage("assets/game/cranky/idle.png"),
      happy = love.graphics.newImage("assets/game/cranky/happy.png"),
      miss = love.graphics.newImage("assets/game/cranky/miss.png")
    },
    songselect = {
      fg = love.graphics.newImage("assets/game/selectfg.png")
    }
  }

  --setup input
  maininput = baton.new {
      controls = {
        left = {"key:left",  "axis:leftx-", "button:dpleft"},
        right = {"key:right",  "axis:leftx+", "button:dpright"},
        up = {"key:up", "key:w", "axis:lefty-", "button:dpup"},
        down = {"key:down", "key:s", "axis:lefty+", "button:dpdown"},
        accept = {"key:space", "key:return", "button:a"},
        back = {"key:escape", "button:b"},
        ctrl = {"key:lctrl", "key:rctrl"},
        shift = {"key:lshift", "key:rshift"},
        plus = {"key:+", "key:="},
        minus = {"key:-"},
        leftbracket = {"key:["},
        rightbracket = {"key:]"},
        s = {"key:s"},
        x = {"key:x"},
        a = {"key:a"},
        c = {"key:c"},
        e = {"key:e"},
        p = {"key:p"},
        k1 = {"key:1"},
        k2 = {"key:2"},
        k3 = {"key:3"},
        k4 = {"key:4"},
        k5 = {"key:5"},
        f5 = {"key:f5"},
        mouse1 = {"mouse:1"},
        mouse2 = {"mouse:2"}
      },
      pairs = {
        lr = {"left", "right", "up", "down"}
      },
        joystick = love.joystick.getJoysticks()[1],
    }

  entities = {}
  -- init states
  toswap = nil
  newswap = false
  states = {
    songselect = require "states.songselect",
    game = require "states.game",
    --rdconvert = require "states.rdconvert",
    editor = require "states.editor",
    results = require "states.results",
  }

  gs.registerEvents()
  gs.switch(states.songselect)
end


function love.update(d)
  cs = gs.current()
  shuv.check()
  if not acdelt then
    dt = 1
  else
    dt = d * 60
  end
  if dt >=2 then
    dt = 2
  end
end


function love.resize(w, h)
  push:resize(w, h)
end
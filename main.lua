function love.load()
  dt = 1
  clevel = "cannery.json"
  gamename = "BeatBlock"
  crankymode = true
  release = false
  ismobile = false
  pressed = 0
  mx,my = 0,0
  ispush = false
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
  if not release then 
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

  --setup input
  maininput = baton.new {
      controls = {
        left = {"key:left",  "axis:leftx-", "button:dpleft"},
        right = {"key:right",  "axis:leftx+", "button:dpright"},
        up = {"key:up", "key:w", "axis:lefty-", "button:dpup"},
        down = {"key:down", "key:s", "axis:lefty+", "button:dpdown"},
        accept = {"key:space", "button:a"},
        back = {"key:escape", "button:b"},
        s = {"key:s"},
        x = {"key:x"},
        a = {"key:a"},
        c = {"key:c"},
        e = {"key:e"},
        k1 = {"key:1"},
        k2 = {"key:2"},
        k3 = {"key:3"}
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
    rdconvert = require "states.rdconvert",
    editor = require "states.editor"
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
function love.load()
  dt = 1
  clevel = "cannery.json"
  gamename = "BeatBlock"

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
  
  -- uh oh stinky
  dpf = require "lib.dpf"

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
      fg = love.graphics.newImage("assets/game/selectfg.png"),
      grades = {
        fnone = love.graphics.newImage("assets/results/small/fnone.png"),
        snone = love.graphics.newImage("assets/results/small/snone.png"),
        anone = love.graphics.newImage("assets/results/small/anone.png"),
        bnone = love.graphics.newImage("assets/results/small/bnone.png"),
        cnone = love.graphics.newImage("assets/results/small/cnone.png"),
        dnone = love.graphics.newImage("assets/results/small/dnone.png"),

        aplus = love.graphics.newImage("assets/results/small/aplus.png"),
        bplus = love.graphics.newImage("assets/results/small/bplus.png"),
        cplus = love.graphics.newImage("assets/results/small/cplus.png"),
        dplus = love.graphics.newImage("assets/results/small/dplus.png"),

        aminus = love.graphics.newImage("assets/results/small/aminus.png"),
        bminus = love.graphics.newImage("assets/results/small/bminus.png"),
        cminus = love.graphics.newImage("assets/results/small/cminus.png"),
        dminus = love.graphics.newImage("assets/results/small/dminus.png")

      }
    },
    results = {
      grades = {
        a = love.graphics.newImage("assets/results/big/a.png"),
        b = love.graphics.newImage("assets/results/big/b.png"),
        c = love.graphics.newImage("assets/results/big/c.png"),
        d = love.graphics.newImage("assets/results/big/d.png"),
        f = love.graphics.newImage("assets/results/big/f.png"),
        plus = love.graphics.newImage("assets/results/big/plus.png"),
        minus = love.graphics.newImage("assets/results/big/minus.png"),
        none = love.graphics.newImage("assets/results/big/none.png"),
        s = love.graphics.newImage("assets/results/big/s.png")
      }
    },
    title = {
      logo = love.graphics.newImage("assets/title/logo.png"),
      spacetostart = love.graphics.newImage("assets/title/spacetostart.png")
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
        pause = {"key:tab"},
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
    title = require "states.title",
    game = require "states.game",
    --rdconvert = require "states.rdconvert",
    editor = require "states.editor",
    results = require "states.results",
  }

  gs.registerEvents()
  gs.switch(states.title)
end


function love.update(d)
  maininput:update()
  lovebird.update()
  if maininput:pressed("pause") then
    paused = not paused
    if cs.source then
      if paused then
        cs.source:pause()
      else
        cs.source:play()

      end
    end
  end
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
  if paused then

    em.update(dt) -- for text boxes

  end
    
end


function love.resize(w, h)
  push:resize(w, h)
end
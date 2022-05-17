import("conf")
import("CoreLibs/object")
import("CoreLibs/graphics")
import("lib/noble/Noble")

-- Clear console for easier debugging
playdate.clearConsole()

-- alias playdate.graphics and playdate.sound
gfx = playdate.graphics
snd = playdate.sound

-- implement delta time as dt
lastFrame = playdate.getCurrentTimeMilliseconds()
updateDt = function ()
  dt = (playdate.getCurrentTimeMilliseconds() - lastFrame) / 1000
  lastFrame = playdate.getCurrentTimeMilliseconds()
end

clevel = "cannery.json"
gamename = "BeatBlock"
cs = nil

-- if love.system.getOS( ) == "Android" or mobileoverride then
--   ismobile = true
-- end

pressed = 0
mx,my = 0,0
ispush = false
screencenter = {x = gameWidth/2, y = gameHeight/2}

-- font is https://tepokato.itch.io/axolotl-font
-- https://www.dafont.com/digital-disco.font
Axolotl12 = gfx.font.new("assets/fonts/Axolotl-12")
DigitalDisco12 = gfx.font.new("assets/fonts/DigitalDisco-12")
DigitalDisco16 = gfx.font.new("assets/fonts/DigitalDisco-16")
DigitalDisco24 = gfx.font.new("assets/fonts/DigitalDisco-24")
gfx.setFont(DigitalDisco16)

-- accurate deltatime
acdelt = true

-- import libraries

-- custom functions, snippets, etc
helpers = import "lib/helpers"

-- quickly load json files
-- dpf = import "lib/dpf"

-- gamestate, manages gamestates
-- gs = import "lib/gamestate"

-- baton, manages input handling
baton = import "lib/baton"

-- lovebpm, syncs stuff to music
pdbpm = import "lib/pdbpm"

-- shuv = import "lib/shuv"
-- shuv.init()

-- what it says on the tin
-- utf8 = import("utf8")
-- push, graphics helper, makes screen resolution stuff easy
if ispush then
  push = import "lib/push"
else
  push = import "lib/pushstripped"
end

-- deeper, modification of deep, queue functions, now with even more queue
deeper = import "lib/deeper"

-- tesound, sound playback
te = import"lib/tesound"

-- spritesheet manager
ez = import "lib/ezanim"

-- tween manager
flux = import "lib/flux"
paused = false

-- start colors table with default colors


--load sprites into memory, so that we are not loading 50 bajillion copies of the beats in a level
sprites = {
  beat= {
    square = gfx.image.new("assets/game/square"),
    inverse = gfx.image.new("assets/game/inverse"),
    hold = gfx.image.new("assets/game/hold"),
    mine = gfx.image.new("assets/game/mine"),
    side = gfx.image.new("assets/game/side"),
    minehold = gfx.image.new("assets/game/minehold"),
    ringcw = gfx.image.new("assets/game/ringcw"),
    ringccw = gfx.image.new("assets/game/ringccw")
  },
  player = {
    idle = gfx.image.new("assets/game/cranky/idle"),
    happy = gfx.image.new("assets/game/cranky/happy"),
    miss = gfx.image.new("assets/game/cranky/miss")
  },
  songselect = {
    fg = gfx.image.new("assets/game/selectfg"),
    grades = {
      fnone = gfx.image.new("assets/results/small/fnone"),
      snone = gfx.image.new("assets/results/small/snone"),
      anone = gfx.image.new("assets/results/small/anone"),
      bnone = gfx.image.new("assets/results/small/bnone"),
      cnone = gfx.image.new("assets/results/small/cnone"),
      dnone = gfx.image.new("assets/results/small/dnone"),

      aplus = gfx.image.new("assets/results/small/aplus"),
      bplus = gfx.image.new("assets/results/small/bplus"),
      cplus = gfx.image.new("assets/results/small/cplus"),
      dplus = gfx.image.new("assets/results/small/dplus"),

      aminus = gfx.image.new("assets/results/small/aminus"),
      bminus = gfx.image.new("assets/results/small/bminus"),
      cminus = gfx.image.new("assets/results/small/cminus"),
      dminus = gfx.image.new("assets/results/small/dminus")
    }
  },
  results = {
    grades = {
      a = gfx.image.new("assets/results/big/a"),
      b = gfx.image.new("assets/results/big/b"),
      c = gfx.image.new("assets/results/big/c"),
      d = gfx.image.new("assets/results/big/d"),
      f = gfx.image.new("assets/results/big/f"),
      plus = gfx.image.new("assets/results/big/plus"),
      minus = gfx.image.new("assets/results/big/minus"),
      none = gfx.image.new("assets/results/big/none"),
      s = gfx.image.new("assets/results/big/s")
    }
  },
  title = {
    logo = gfx.image.new("assets/title/logo")
  }
}

--load select sounds
sounds = {
  click = snd.sampleplayer.new("assets/click.wav"),
  hold = snd.sampleplayer.new("assets/hold1.wav"),
  mine = snd.sampleplayer.new("assets/mine.wav")
}

--setup input
ctrls = {
      left = playdate.kButtonLeft,
      right = playdate.kButtonRight,
      up = playdate.kButtonUp,
      down = playdate.kButtonDown,
      accept = playdate.kButtonA,
      back = {"key:escape", "button:b"},
      ctrl = {},
      shift = {"key:lshift", "key:rshift"},
      backspace = {"key:backspace"},
      plus = {"key:+", "key:="},
      minus = {"key:-"},
      leftbracket = {"key:["},
      rightbracket = {"key:]"},
      comma = {"key:,"},
      period = {"key:."},
      slash = {"key:/"},
      s = {"key:s"},
      x = {"key:x"},
      a = {"key:a"},
      c = {"key:c"},
      e = {"key:e"},
      p = {"key:p"},
      r = {"key:r"},
      pause = {"key:tab"},
      k1 = {"key:1"},
      k2 = {"key:2"},
      k3 = {"key:3"},
      k4 = {"key:4"},
      k5 = {"key:5"},
      k6 = {"key:6"},
      k7 = {"key:7"},
      k8 = {"key:8"},
      f4 = {"key:f4"},
      f5 = {"key:f5"},
      mouse1 = {"mouse:1"},
      mouse2 = {"mouse:2"},
      mouse3 = {"mouse:3"}
    }

    -- if love.system.getOS() == "OS X" then --appease eventual mac users
    --   ctrls.ctrl = {"key:rgui","key:lgui"}
    -- else
      ctrls.ctrl = {"key:rctrl","key:lctrl"}
    -- end

-- maininput = baton.new {
--     controls = ctrls,
--     pairs = {
--       lr = {"left", "right", "up", "down"}
--     },
--       joystick = love.joystick.getJoysticks()[1],
--   }

maininput = {}

-- Just pressed this frame
maininput.pressed = function (key)
  return playdate.buttonJustPressed(ctrls[key])
end

maininput.down = function (key)
  return playdate.buttonIsPressed(ctrls[key])
end

-- entity manager
em = import "lib/entityman"
entities = {}

-- init states (Noble Scenes)
import "states/template"
import "states/songselect"
import "states/title"
import "states/game"
-- rdconvert = import "states/rdconvert"
-- editor = import "states/editor"
import "states/results"

Noble.new(TitleScene)

GameScene = {}

class("GameScene").extends(NobleScene)
SongSelectScene.backgroundColor = Graphics.kColorWhite

local screenwidth, screenheight = playdate.display.getWidth(), playdate.display.getHeight()

function GameScene:init()
  GameScene.super.init(self)
  cs = Noble.currentScene()
end

function GameScene:enter(prev)
  GameScene.super.enter(self)
  cs = Noble.currentScene()
  self.p = em.init("player", screenwidth/2, screenheight/2)
  self.gm = em.init("gamemanager", screenwidth/2, screenheight/2)
  self.gm.init(self)

  self.level = json.decodeFile(clevel .. "level.json")
  self.gm.resetlevel()
  self.gm.on = true
end


function GameScene:leave()
  GameScene.super.exit(self)
  entities = {}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end


function GameScene:resume()

end


function GameScene:update()
  updateDt()
  if not paused then
    if maininput.pressed("back") then
      Noble.transition(SongSelectScene)
    end
    --if maininput.pressed("a") then
      --helpers.swap(states.rdconvert)
    --end

    flux.update(1)
    em.update(dt)
  end
end


function GameScene:draw()
  
  -- draw game to canvas
  gfx.pushContext()
  self.drawgame()
  
  -- draw canvas to screen
  gfx.popContext()

  if pq ~= "" then
    print(helpers.round(self.cbeat*8,true)/8 .. pq)
  end

end



function GameScene.drawgame()

  gfx.clear()
  gfx.setColor(playdate.graphics.kColorBlack)
  
  if cs.vfx.hom then
    for i=0,10 do --cs.vfx.homint do
      gfx.drawPixel(math.random(0,400),math.random(0,240))
    end
  end

  --ouch the lag
  -- if cs.vfx.bgnoise.enable then
  --   love.graphics.setColor(cs.vfx.bgnoise.r,cs.vfx.bgnoise.g,cs.vfx.bgnoise.b,cs.vfx.bgnoise.a)
  --   love.graphics.draw(cs.vfx.bgnoise.image,math.random(-2048+gameWidth,0),math.random(-2048+gameHeight,0))
  -- end
  -- love.graphics.draw(cs.bg)

  gfx.setColor(1)
  em.draw()
  gfx.setColor(0)

  gfx.drawText(cs.hits.." / " .. (cs.misses+cs.hits),10,10)
  if cs.combo >= 2 then
    gfx.setFont(DigitalDisco16)
    gfx.drawText(cs.combo .. gfx.getLocalizedText("combo"),10,220)
  end
  gfx.setColor(1)
end



return Game
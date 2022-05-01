TitleScene = {}

class("TitleScene").extends(NobleScene)
-- TitleScene.baseColor = Graphics.kColorWhite

function TitleScene:init()
  TitleScene.super.init(self)
  self.inputHandler = { --TODO: replace this with a Baton reimplementation that supports playdate
    AButtonDown = function()
      Noble.transition(SongSelectScene)
    end
  }
  self.pstext = gfx.getLocalizedText("pressspace")
  self.textWidth = Axolotl12:getTextWidth(self.pstext)
end

function TitleScene:enter()
  TitleScene.super.enter(self)
  cs = Noble.currentScene()

  self.i = 0

end

function TitleScene:update()

  -- updateDt()

  self.i = self.i + 1

  if self.i % 2 == 0 then
    local nc = em.init("titleparticle", math.random(-8, 408), -8)
    nc.dx = (math.random() * 2) - 1
    nc.dy = 2 + math.random() * 2


  end

  em.update(dt)
  flux.update(dt)


end

function TitleScene:draw()

  em.draw()

  -- TODO FONTS
  gfx.setFont(DigitalDisco16)

  sprites.title.logo:draw(32,32+math.sin(self.i*0.03)*10) -- TODO: actually animate this
  -- make text bold by drawing the sprite far too many times
  -- for a=128,130 do
  --   for b=155,157 do
  --     gfx.drawText(self.pstext,a,b)
  --   end
  -- end

  gfx.drawText(self.pstext, 129, 156)
end

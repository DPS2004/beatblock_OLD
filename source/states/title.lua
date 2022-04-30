TitleScene = {
  i = 0
}
class("TitleScene").extends(NobleScene)
TitleScene.baseColor = Graphics.kColorWhite

function TitleScene:init()
	TitleScene.super.init(self)

  TitleScene.inputHandler = {
    AButtonDown = function ()
      Noble.transition(songSelectScene)
    end
  }
  TitleScene.pstext = gfx.getLocalizedText("pressspace")
  TitleScene.textWidth = font2:getTextWidth(TitleScene.pstext)
end

function TitleScene:enter()
	TitleScene.super.enter(self)

  TitleScene.i=0

end

function TitleScene:update()

  -- updateDt()



  TitleScene.i = TitleScene.i + 1

  if TitleScene.i %2 == 0 then
    local nc = em.init("titleparticle",math.random(-8,408),-8)
    nc.dx = (math.random() *2) -1
    nc.dy = 2+ math.random()*2


  end
  -- flux.update(1)
  em.update(1)
  em.draw()

  -- TODO FONTS
  gfx.setFont(font1)

  sprites.title.logo:draw(32,32+math.sin(TitleScene.i*0.03)*10) -- TODO: actually animate this
  -- make text bold by drawing the sprite far too many times
  -- for a=128,130 do
  --   for b=155,157 do
  --     gfx.drawText(TitleScene.pstext,a,b)
  --   end
  -- end

  gfx.drawText(TitleScene.pstext,129,156)


end


-- return st
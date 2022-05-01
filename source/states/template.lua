TemplateScene = {}

class("TemplateScene").extends(NobleScene)
TemplateScene.baseColor = Graphics.kColorWhite

function TemplateScene:init()
	TemplateScene.super.init(self)

end

function TemplateScene:enter(prev)
	TemplateScene.super.enter(self)
end

function TemplateScene:exit(prev)
	TemplateScene.super.exit(self)
end




function TemplateScene:update()
  -- do things here
  em.update(dt)
  flux.update(dt)
end


function TemplateScene:draw()

  em.draw()
  
  gfx.drawText("Hello from template Scene!",129,156)
  
end


local shuv = {
  scale = 1,
  update = true,
  fullscreen = false
}


function shuv.init()
  shuv.canvas = love.graphics.newCanvas(gameWidth,gameHeight)
  if ismobile or is3ds then shuv.scale = 1 end
  
end


function shuv.check()
  if not ismobile then
    if maininput:pressed("f4") then
      if not shuv.fullscreen then
        love.window.setFullscreen(true)
        shuv.scale = love.graphics.getHeight() / gameHeight
        shuv.update = true
        shuv.fullscreen = true
      else
        love.window.setFullscreen(false)
        shuv.scale = 1
        shuv.update = true
        shuv.fullscreen = false
        love.window.setMode(gameWidth*shuv.scale, gameHeight*shuv.scale)
      end
    end
    if maininput:pressed("f5") then
      
      shuv.scale = shuv.scale + 1
      if shuv.scale > 3 then
        shuv.scale = 1
      end
      shuv.fullscreen = false
      shuv.update = true
      love.window.setMode(gameWidth*shuv.scale, gameHeight*shuv.scale)
    end
  end

  if shuv.update then
    shuv.update = false
    
    if ismobile then
      love.window.setMode(0,0)
      love.window.setFullscreen(true)
      shuv.scale = love.graphics.getHeight() / gameHeight
    elseif shuv.fulscreen == false then
      love.window.setMode(gameWidth*shuv.scale, gameHeight*shuv.scale)
    end
    
  end
end


function shuv.start(screen)
  love.graphics.setColor(1, 1, 1, 1)
  if not is3ds then
    love.graphics.setCanvas(shuv.canvas)
    love.graphics.setBlendMode("alpha", "premultiplied")
  else
    if screen == "bottom" then
      return
    end
  end
end


function shuv.finish()
  if not is3ds then
    love.graphics.setCanvas()
    love.graphics.draw(shuv.canvas,0,0,0,shuv.scale,shuv.scale)
  end
  helpers.doswap()
  tinput = ""
end

return shuv
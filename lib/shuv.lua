local shuv = {
  scale = 2,
  update = true
}


function shuv.init()
  shuv.canvas = love.graphics.newCanvas(gameWidth,gameHeight)
  if ismobile then shuv.scale = 1 end
  
end


function shuv.check()
  if not ismobile then
    if maininput:pressed("f5") then
      shuv.scale = shuv.scale + 1
      if shuv.scale > 3 then
        shuv.scale = 1
      end
      shuv.update = true
    end
  end

  if shuv.update then
    shuv.update = false
    
    if ismobile then
      love.window.setMode(0,0)
      love.window.setFullscreen(true)
      shuv.scale = love.graphics.getHeight() / gameHeight
    else
      love.window.setMode(gameWidth*shuv.scale, gameHeight*shuv.scale)
    end
  end
end


function shuv.start()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setBlendMode("alpha", "premultiplied")
end


function shuv.finish()
  love.graphics.setCanvas()
  love.graphics.draw(shuv.canvas,0,0,0,shuv.scale,shuv.scale)
  helpers.doswap()
end

return shuv
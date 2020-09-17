local shuv = {
  scale = 1,
  update = false}
function shuv.init()
  shuv.canvas = love.graphics.newCanvas(400,240)
  
  
end
function shuv.check()
    if maininput:pressed("k1") then
    shuv.scale = 1
    shuv.update = true
  elseif maininput:pressed("k2") then
    shuv.scale = 2
    shuv.update = true
  elseif maininput:pressed("k3") then
    shuv.scale = 3
    shuv.update = true
  end
  if shuv.update then
    shuv.update = false
    love.window.setMode(400*shuv.scale, 240*shuv.scale)
    
  end
end
function shuv.start()
  love.graphics.setCanvas(shuv.canvas)

end

function shuv.finish()
  love.graphics.setCanvas()
  love.graphics.draw(shuv.canvas,0,0,0,shuv.scale,shuv.scale)
  helpers.doswap()
end





return shuv
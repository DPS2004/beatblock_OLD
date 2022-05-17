function squarevfx()
  local obj = {
    layer = -10,
    uplayer = 9,
    x=screencenter.x,
    y=screencenter.y,
    r = 4,
    dx = 1,
    dy = 1,
    dr = 1,
    life = 100
  }
  
  function obj.update(dt)
    obj.x = obj.x + obj.dx
    obj.y = obj.y + obj.dy
    obj.r = obj.r + obj.dr
    obj.life = obj.life -1
    if obj.life <= 0 then obj.delete = true end
  end
  
  function obj.draw()
    gfx.setLineWidth(1)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(obj.x -obj.r,obj.y-obj.r,obj.r*2,obj.r*2)
  end
  
  return obj
end

return squarevfx
function hitpart()
  local obj = {
    layer = -2,
    uplayer = 9,
    x=0,
    y=0,
    rad=9
  }
  
  
  function obj.update(dt)
    obj.rad = obj.rad - 1
    if obj.rad <= 0 then
      obj.delete = true
    end
  end
  
  
  function obj.draw()
    gfx.setLineWidth(1)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawCircleAtPoint(obj.x,obj.y,obj.rad)
  end
  
  
  return obj
end

return hitpart
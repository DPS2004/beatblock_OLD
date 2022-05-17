function circlevfx()
local obj = {
  layer = -10,
  uplayer = 9,
  x=screencenter.x,
  y=screencenter.y,
  rad=1,
  setup = false,
  delt = 5,
  }
  
  
  function obj.update(dt)
    if not obj.setup then
      obj.setup = true
      if obj.delt > 0 then
        obj.rad = 1
      else
        obj.rad = 250
      end
    end
    obj.rad = obj.rad + obj.delt
    if obj.rad > 510 or obj.rad <= 0 then
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

return circlevfx
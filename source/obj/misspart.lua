function misspart()
  local obj = {
    layer = -2,
    uplayer = 9,
    x=screencenter.x,
    y=screencenter.y,
    ox=screencenter.x,
    oy=screencenter.y,
    angle=0,
    distance=42,
    spr = gfx.image.new("assets/game/square.png")
  }
  
  
  function obj.update(dt)
    flux.to(obj,15,{distance=0}):ease("outExpo"):oncomplete(function(f) obj.delete=true end)
    local p1 = helpers.rotate(obj.distance+cs.extend,obj.angle,obj.ox,obj.oy)
    obj.x = p1[1]
    obj.y = p1[2]
  end
  
  
  function obj.draw()
    --gfx.setColor(1)
    obj.spr:draw(obj.x,obj.y)--,0,1,1,16,16)
  
  end
  
  
  return obj
end

return misspart
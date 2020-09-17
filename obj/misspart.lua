local obj = {
  layer = -2,
  uplayer = 9,
  x=200,
  y=120,
  ox=200,
  oy=120,
  angle=0,
  distance=42,
  spr = love.graphics.newImage("assets/game/square.png")
}


function obj.update(dt)
  flux.to(obj,15,{distance=0}):ease("outExpo"):oncomplete(function(f) obj.delete=true end)
  local p1 = helpers.rotate(obj.distance+cs.extend,obj.angle,obj.ox,obj.oy)
  obj.x = p1[1]
  obj.y = p1[2]
end


function obj.draw()
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(obj.spr,obj.x,obj.y,0,1,1,8,8)

end


return obj
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
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0,0,0,1)
  love.graphics.circle("line",obj.x,obj.y,obj.rad)
end


return obj
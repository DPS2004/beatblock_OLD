local obj = {
  layer = -10,
  uplayer = 9,
  x=-100,
  y=-100,
  r = 4,
  dx = 1,
  dy = 1,
  dr = 1,
  life = 100,
  spr = nil
}
local sprv = math.random(0,7)
if sprv <= 5 then
  obj.spr = sprites.beat.square
elseif sprv <= 6 then
  obj.spr = sprites.beat.inverse
else
  obj.spr = sprites.beat.hold
end

function obj.update(dt)
  obj.x = obj.x + obj.dx
  obj.y = obj.y + obj.dy
  if obj.y >= 300 then obj.delete = true end
end


function obj.draw()
  -- love.graphics.setColor(1,1,1,1)
  obj:draw(obj.x-8,obj.y-8)
  -- love.graphics.draw(obj.spr,obj.x,obj.y,0,1,1,8,8)

end

return obj
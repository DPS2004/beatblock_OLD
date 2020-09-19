local helpers = {}


function helpers.collide( a, b )
   local overlap = false
   if not( a.x + a.width < b.x  or b.x + b.width < a.x  or
           a.y + a.height < b.y or b.y + b.height < a.y ) then
      overlap = true
   end
   return overlap
end


function helpers.rotate(rad, angle, x, y)
  return({
    (rad * math.cos((90 - angle) * math.pi / 180))+x,
    (0 - rad * math.sin((90 - angle) * math.pi / 180))+y
  })
end


function helpers.color(c)
  love.graphics.setColor(colors[c])
end


function helpers.read(path)
  local content = love.filesystem.read(path) -- r read mode and b binary mode
  return content
end


function helpers.write(path, data)
  love.filesystem.write(path,data)
end


function helpers.round(i,fb)
  fb = fb or false
  if i % 1 > 0.5 then
    return math.ceil(i)
  elseif i % 1 < 0.5 then
    return math.floor(i)
  elseif fb then
    return math.floor(i)
  else
    return i
  end
end


function helpers.distance(p,q)
  return(math.sqrt(((q[1])-(p[1]))^2+((q[2])-(p[2]))^2))
end


function helpers.angdistance(x,y)
  return 180 - math.abs(math.abs((x%360) - (y%360)) - 180)
end


function helpers.swap(tsw)
  toswap = tsw
  newswap = true
end


function helpers.updatemouse()
  if pressed == -1 then
    pressed = 0
  end
  if love.mouse.isDown(1) then
    pressed = pressed + 1
  elseif pressed >=1 then
    pressed = -1
  else
    pressed = 0
  end
  mx = helpers.round(((love.mouse.getX()/love.graphics.getWidth())*160),true)
  my = helpers.round(((love.mouse.getY()/love.graphics.getHeight())*90),true)
  print('fps:'..love.timer.getFPS())
end


function helpers.clamp(val, lower, upper)
  if lower > upper then lower, upper = upper, lower end
  return math.max(lower, math.min(upper, val))
end


function helpers.doswap()
  if newswap then
    gs.switch(toswap)
    newswap = false
  end
end

function helpers.lerp(a, b, t)
  return a + (b - a) * t

end
function helpers.anglepoints(x,y,a,b)
  return math.deg(math.atan2(x-a,y-b))*-1

end

return helpers
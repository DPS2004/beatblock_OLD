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
  
  return({(rad * math.cos((90 - angle) * math.pi / 180))+x, (0 - rad * math.sin((90 - angle) * math.pi / 180))+y})
  
  
end

function helpers.color(c)
  love.graphics.setColor(colors[c])
end

function helpers.read(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end
function helpers.write(path, data)
    local file = io.open(path, "w") -- r read mode and b binary mode
    local content = file:write(data)
    file:close()
    return content
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
function helpers.makeline(x1, y1, x2, y2)
  local linepoints = {}
  delta_x = x2 - x1
  ix = delta_x > 0 and 1 or -1
  delta_x = 2 * math.abs(delta_x)
 
  delta_y = y2 - y1
  iy = delta_y > 0 and 1 or -1
  delta_y = 2 * math.abs(delta_y)
 
  table.insert(linepoints,{x1,y1})
 
  if delta_x >= delta_y then
    err = delta_y - delta_x / 2
 
    while x1 ~= x2 do
      if (err > 0) or ((err == 0) and (ix > 0)) then
        err = err - delta_x
        y1 = y1 + iy
      end
 
      err = err + delta_y
      x1 = x1 + ix
 
      table.insert(linepoints,{x1,y1})
    end
  else
    err = delta_x - delta_y / 2
 
    while y1 ~= y2 do
      if (err > 0) or ((err == 0) and (iy > 0)) then
        err = err - delta_y
        x1 = x1 + ix
      end
 
      err = err + delta_x
      y1 = y1 + iy
 
      table.insert(linepoints,{x1,y1})
    end
  end
  return linepoints
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
  --print('mousex:'..love.mouse.getX())
  --print('mousey:'..love.mouse.getY())
  --print('mx:'..mx)
  --print('my:'..my)
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

return helpers
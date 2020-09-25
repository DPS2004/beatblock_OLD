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

function helpers.drawhold(xo, yo, x1, y1, x2, y2, a1, a2, segments, sprhold)

  -- distances to the beginning and the end of the hold
  local len1 = helpers.distance({xo, yo}, {x1, y1})
  local len2 = helpers.distance({xo, yo}, {x2, y2})
  local points = {}

  -- how many segments to draw
  -- based on the beat's angles by default, but can be overridden in the json
  if segments == nil then
    segments = (math.abs(a2 - a1) / 8 + 1)
  end
  for i = 0, segments, 1 do
    local t = i / segments

    -- coordinates of the next point
    local nextAngle = math.rad(helpers.lerp(a1, a2, t) - 90)
    local nextDistance = helpers.lerp(len1, len2, t)
    points[#points+1] = math.cos(nextAngle) * nextDistance + 200
    points[#points+1] = math.sin(nextAngle) * nextDistance + 120
  end

  -- idk why but sometimes the last point doesn't reach the end of the slider
  -- so add it manually if needed
  if (points[#points] ~= y2) then
    points[#points+1] = x2
    points[#points+1] = y2
  end

  -- need at least 2 points to draw a line ,
  if #points >= 4 then
    -- draw the black outline
    helpers.color(2)
    love.graphics.setLineWidth(16)
    love.graphics.line(points)
    -- draw a white line, to make the black actually look like an outline
    helpers.color(1)
    love.graphics.setLineWidth(12)
    love.graphics.line(points)
  end
  helpers.color(1)

  -- draw beginning and end of hold
  love.graphics.draw(sprhold,x1,y1,0,1,1,8,8)
  love.graphics.draw(sprhold,x2,y2,0,1,1,8,8)
end

function helpers.drawslice (ox, oy, rad, angle, inverse)
  local p = {}
  if inverse then
    p = helpers.rotate(-rad,angle,ox,oy)
  else
    p = helpers.rotate(rad,angle,ox,oy)
  end
  love.graphics.setColor(0,0,0,1)
  love.graphics.setLineWidth(2)
  love.graphics.push()
  love.graphics.translate(p[1], p[2])
  love.graphics.rotate((angle - 90) * math.pi / 180)

  -- draw the lines connecting the player to the paddle
  love.graphics.line(
    0, 0,
    (cs.p.paddle_distance + cs.extend) * math.cos(15 * math.pi / 180),
    (cs.p.paddle_distance + cs.extend) * math.sin(15 * math.pi / 180)
  )
  love.graphics.line(
    0, 0,
    (cs.p.paddle_distance + cs.extend) * math.cos(-15 * math.pi / 180),
    (cs.p.paddle_distance + cs.extend) * math.sin(-15 * math.pi / 180)
  )

  -- draw the paddle
  local paddle_angle = 30 / 2 * math.pi / 180
  love.graphics.arc('line', 'open', 0, 0, (cs.p.paddle_distance + cs.extend), paddle_angle, -paddle_angle)
  love.graphics.arc('line', 'open', 0, 0, (cs.p.paddle_distance + cs.extend) + cs.p.paddle_width, paddle_angle, -paddle_angle)
  love.graphics.line(
    (cs.p.paddle_distance + cs.extend) * math.cos(paddle_angle),
    (cs.p.paddle_distance + cs.extend) * math.sin(paddle_angle),
    ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.cos(paddle_angle),
    ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.sin(paddle_angle)
  )
  love.graphics.line(
    (cs.p.paddle_distance + cs.extend) * math.cos(-paddle_angle),
    (cs.p.paddle_distance + cs.extend) * math.sin(-paddle_angle),
    ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.cos(-paddle_angle),
    ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.sin(-paddle_angle)
  )
  love.graphics.pop()

  helpers.color(1)
  love.graphics.circle("fill",p[1],p[2],4+cs.extend/2)
  helpers.color(2)
  love.graphics.circle("line",p[1],p[2],4+cs.extend/2)

  helpers.color(1)
 -- love.graphics.draw(cs.p.spr[cs.p.cemotion],obj.x,obj.y,0,1,1,16,16)

  return p[1], p[2]
end

return helpers
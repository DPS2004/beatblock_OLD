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

helpers.eases = {
  ["Linear"] = function (t)
    return t
  end,

  ["InQuad"] = function (t)
    return math.pow(t, 2)
  end,

  ["OutQuad"] = function (t)
    return 1 - math.pow(1 - t, 2)
  end,

  ["InCubic"] = function (t)
    return math.pow(t, 3)
  end,

  ["OutCubic"] = function (t)
    return 1 - math.pow(1 - t, 3)
  end,

  ["InQuart"] = function (t)
    return math.pow(t, 4)
  end,

  ["OutQuart"] = function (t)
    return 1 - math.pow(1 - t, 4)
  end,

  ["InQuint"] = function (t)
    return math.pow(t, 5)
  end,

  ["OutQuint"] = function (t)
    return 1 - math.pow(1 - t, 5)
  end,

  ["InExpo"] = function (t)
    return math.pow(2, (10 * (t - 1)))
  end,

  ["OutExpo"] = function (t)
    return 1 - math.pow(2, (10 * (-t)))
  end,
  
  ["InSine"] = function (t)
    return 1 - math.cos(t * (math.pi * .5))
  end,

  ["OutSine"] = function (t)
    return math.cos((1 - t) * (math.pi * .5))
  end,

  ["InCirc"] = function (t)
    return 1 - math.sqrt(1 - (math.pow(t, 2)))
  end,

  ["OutCirc"] = function (t)
    return math.sqrt(1 - (math.pow(1 - t, 2)))
  end,

  ["InBack"] = function (t)
    return math.pow(t, 2) * (2.7 * t - 1.7)
  end,

  ["OutBack"] = function (t)
    return 1 - math.pow(1 - t, 2) * (2.7 * (1 - t) - 1.7)
  end,

  ["InElastic"] = function (t)
    return -(2^(10 * (t - 1)) * math.sin((t - 1.075) * (math.pi * 2) / .3))
  end,

  ["OutElastic"] = function (t)
    return 1 + (2^(10 * (-t)) * math.sin(((1 - t) - 1.075) * (math.pi * 2) / .3))
  end
}

function helpers.interpolate(a, b, t, ease)
  local q
  if helpers.eases[ease] then
    q = helpers.eases[ease] (t)
  else
    q = helpers.eases["Linear"] (t)
  end

  return helpers.lerp (a, b, q)
end

function helpers.anglepoints(x,y,a,b)
  return math.deg(math.atan2(x-a,y-b))*-1
end

function helpers.drawhold(xo, yo, x1, y1, x2, y2, completion, a1, a2, segments, sprhold, ease, holdtype)
  local interp = ease or "Linear"
  local colortype = holdtype or "hold"

  -- distances to the beginning and the end of the hold
  local len1 = helpers.distance({xo, yo}, {x1, y1})
  local len2 = helpers.distance({xo, yo}, {x2, y2})
  local points = {}

  -- how many segments to draw
  -- based on the beat's angles by default, but can be overridden in the json
  if segments == nil then
    if interp == "Linear" then
      segments = (math.abs(a2 - a1) / 8 + 1)
    else
      segments = (math.abs(a2 - a1) + 1)
    end
  end
  for i = 0, segments do
    local t = i / segments
    local angle_t = t * (1 - completion) + completion
    -- coordinates of the next point
    local nextAngle = math.rad(helpers.interpolate(a1, a2, angle_t, interp) - 90)
    local nextDistance = helpers.lerp(len1, len2, t)
    points[#points+1] = math.cos(nextAngle) * nextDistance + screencenter.x
    points[#points+1] = math.sin(nextAngle) * nextDistance + screencenter.y
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
    --the added line for mine holds
    if colortype ~= "hold" then
      helpers.color(2)
      love.graphics.setLineWidth(10)
      love.graphics.line(points)
    end
  end
  helpers.color(1)

  -- draw beginning and end of hold
  love.graphics.draw(sprhold,x1,y1,0,1,1,8,8)
  love.graphics.draw(sprhold,x2,y2,0,1,1,8,8)
end

function helpers.drawslice (ox, oy, rad, angle, inverse, alpha)
  local p = {}
  if inverse then
    p = helpers.rotate(-rad,angle,ox,oy)
  else
    p = helpers.rotate(rad,angle,ox,oy)
  end
  love.graphics.setColor(0,0,0,alpha)
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
function helpers.drawgame()
  
  if not cs.vfx.hom then
    love.graphics.clear()
  end
  
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(1, 1, 1, 1)

  --if cs.vfx.hom then
    --for i=0,cs.vfx.homint do
      --love.graphics.points(math.random(0,400),math.random(0,240))
    --end 
    
  --end
  --ouch the lag
  if cs.vfx.bgnoise.enable then
    love.graphics.setColor(cs.vfx.bgnoise.r,cs.vfx.bgnoise.g,cs.vfx.bgnoise.b,cs.vfx.bgnoise.a)
    love.graphics.draw(cs.vfx.bgnoise.image,math.random(-2048+gameWidth,0),math.random(-2048+gameHeight,0))
  end
  love.graphics.draw(cs.bg)

  helpers.color(1)
  em.draw()
  helpers.color(2)
  --love.graphics.print(cs.hits.." / " .. (cs.misses+cs.hits),10,10)
  if cs.combo >= 10 then
    love.graphics.setFont(font1)
    love.graphics.print(cs.combo..loc.get("combo"),10,220)
  end
  helpers.color(1)
end

function helpers.rliid(fname)

  local fname2 = ""
  local offset = 0
  if string.sub(fname,-1) == "/" then
    fname = string.sub(fname,1,-2)
  end
  fname2 = fname:match(".*/(.*)")
  if fname2 then
    fname = string.sub(fname,1,-(string.len(fname2)+1))
    return fname
  else
    return ""
  end
end
function helpers.gradecalc(pct)
  local lgrade = ""
  local lgradepm = ""
  
  if pct == 100 then
    lgrade = "s"
  elseif pct >= 90 then
    lgrade = "a"
  elseif pct >= 80 then
    lgrade = "b"
  elseif pct >= 70 then
    lgrade = "c"
  elseif pct >= 60 then
    lgrade = "d"
  else
    lgrade = "f"
  end
  lgradepm = "none"
  if lgrade ~= "s" and lgrade ~= "f" then
    if pct % 10 <= 3 then
      lgradepm = "minus"
    elseif pct % 10 >= 7 then
      lgradepm = "plus"
    end
  end
  return lgrade, lgradepm
end

function helpers.isanglebetween(a1,a2,a3)
  --make a1 and a2 positive
  while a1 < 0 or a2 < 0 do
    a1 = a1 + 360
    a2 = a2 + 360
  end
  --make sure either a1 or a2 are below 360 degrees
  while a1 > 360 and a2 > 360 do
    a1 = a1 - 360
    a2 = a2 - 360
  end
  --if the distance between a1 and a2 is 360+ degrees, a3 will always be between the two no matter what
  if math.abs(a2-a1) >= 360 then
    return true
  end
  --make sure a2 is greater than a1 (such that if one of the two are over 360 degrees, it'll be a2)
  if a1 > a2 then
    a1, a2 = a2, a1
  end
  --i dont even know how to explain this, but basically this offsets everything to turn the situation into another one with an identical answer where a1 and a2 are both between 0 and 360
  if a2 > 360 then
    a1 = a1 - a2 + 360
    a3 = a3 - a2 + 360
    a2 = 360
  end
  --make sure a3 is between 0 and 360
  a3 = a3 % 360
  --finally determine if a3 is between a1 and a2
  if a2 > a3 and a3 > a1 then
    return true
  else
    return false
  end
end
--check if cursor is inside of (or on) a rectangle (x1 is left, x2 is right, y1 is top, y2 is bottom)
function helpers.iscursorinrectangle(x1,x2,y1,y2,cursorx,cursory)
  if x2 >= cursorx and cursorx >= x1 and y2 >= cursory and cursory >= y1 then
    return true
  else
    return false
  end
end
--check if cursor is inside of (or on) an ellipse
function helpers.iscursorinellipse(x1,x2,y1,y2,cursorx,cursory)
end
return helpers
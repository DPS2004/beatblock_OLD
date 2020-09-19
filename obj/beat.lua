local obj = {
  layer = -1,
  uplayer = 3,
  x=200,
  y=120,
  angle=0,
  startangle=0,
  smult2=1,
  endangle=0,
  hb=0,
  movetime=0,
  smult=1,
  inverse = false,
  hityet = false,
  hold = false,
  spr = love.graphics.newImage("assets/game/square.png"),
  spr2 = love.graphics.newImage("assets/game/inverse.png"),
  spr3 = love.graphics.newImage("assets/game/hold.png")
}
obj.ox = obj.x
obj.oy = obj.y


function obj.update(dt)
  if obj.inverse then
    obj.layer = 1
  end
  -- How long it takes to move from beat spawn to hitting the paddle
  if obj.movetime == 0 then
    obj.movetime = obj.hb - cs.cbeat
  end
  

  -- Progress is a number from 0 (spawn) to 1 (paddle)
  local progress = 1 - ((obj.hb - cs.cbeat) / obj.movetime)

  -- Interpolate angle between startangle and endangle based on progress. Beat should be at endangle when it hits the paddle.
  if (obj.hb - cs.cbeat) > 0 then --only clamp when moving towards point
    obj.angle = helpers.clamp(helpers.lerp(obj.startangle, obj.endangle, progress), obj.startangle, obj.endangle) % 360
  end
  
  local p1 = nil
  local p2 = nil
  
  if obj.inverse then
    p1 = helpers.rotate(((obj.hb - cs.cbeat)*cs.level.speed*obj.smult*-1)+cs.extend+cs.length-24,obj.angle,obj.ox,obj.oy)
  elseif not obj.hold then
    p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.speed*obj.smult+cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
  elseif obj.hold then
    p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.speed*obj.smult+cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
    p2 = helpers.rotate((obj.hb - cs.cbeat+obj.duration)*cs.level.speed*obj.smult*obj.smult2+cs.extend+cs.length,obj.angle2,obj.ox,obj.oy)
    obj.x2 = p2[1]
    obj.y2 = p2[2]
    
  end
  obj.x = p1[1]
  obj.y = p1[2]  

  if (obj.hb - cs.cbeat) <= 0 then
    if obj.hold == false then
      if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 then 
        em.init("hitpart",obj.x,obj.y)
        obj.delete = true
        pq = pq .. "   player hit!"
        if cs.beatsounds then
          te.play("click.ogg","static")
        end
        if cs.p.cemotion == "miss" then
          cs.p.emotimer = 0
          cs.p.cemotion = "idle"
        end
      else
        local mp = em.init("misspart",200,120)
        mp.angle = obj.angle
        mp.distance = (obj.hb - cs.cbeat)*cs.level.speed+cs.length
        mp.update()
        obj.delete = true
        pq = pq .. "   player missed!"
        cs.p.emotimer = 100
        cs.p.cemotion = "miss"
      end
    else
      if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 then 
        if obj.hityet == false then
          obj.hityet = true
          pq = pq .. "   started hitting hold"
          te.play("click.ogg","static")
        end
        --em.init("hitpart",obj.x,obj.y)
        --print(helpers.angdistance(obj.angle,cs.p.angle).. " is less than " .. cs.p.paddle_size / 2)
        obj.angle = helpers.lerp(obj.endangle,obj.angle2,((obj.hb - cs.cbeat)*-1)/obj.duration)
        
        
        p1 = helpers.rotate(cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
        p2 = helpers.rotate((obj.hb - cs.cbeat+obj.duration)*cs.level.speed*obj.smult*obj.smult2+cs.extend+cs.length,obj.angle2,obj.ox,obj.oy)
        obj.x2 = p2[1]
        obj.y2 = p2[2]
        obj.x = p1[1]
        obj.y = p1[2]  
        
        if ((obj.hb - cs.cbeat)*-1)/obj.duration >= 1 then
          pq = pq .. "   finished hold!"
          if cs.beatsounds then
            te.play("click.ogg","static")
          end
          if cs.p.cemotion == "miss" then
            cs.p.emotimer = 0
            cs.p.cemotion = "idle"
            
          end
          obj.delete = true
          em.init("hitpart",obj.x,obj.y)
        end
      else
        local mp = em.init("misspart",200,120)
        mp.angle = obj.angle
        mp.distance = (obj.hb - cs.cbeat)*cs.level.speed+cs.length
        mp.update()
        obj.delete = true
        pq = pq .. "   player missed!"
        cs.p.emotimer = 100
        cs.p.cemotion = "miss"
      end
      
    end
  
  end

end

function obj.draw()
  love.graphics.setColor(1,1,1,1)
  if not obj.hold then
    if obj.inverse then
      love.graphics.draw(obj.spr2,obj.x,obj.y,0,1,1,8,8)
    else
      love.graphics.draw(obj.spr,obj.x,obj.y,0,1,1,8,8)
    end
  else

    -- distances to the beginning and the end of the hold
    local len1 = helpers.distance({obj.ox, obj.oy}, {obj.x, obj.y})
    local len2 = helpers.distance({obj.ox, obj.oy}, {obj.x2, obj.y2})
    local points = {}

    -- how many segments to draw
    -- based on the beat's angles by default, but can be overridden in the json
    local segments = obj.segments or (math.abs(obj.angle2 - obj.angle) / 8 + 1)
    for i = 0, segments, 1 do
      local t = i / segments

      -- coordinates of the next point
      local nextAngle = math.rad(helpers.lerp(obj.angle, obj.angle2, t) - 90)
      local nextDistance = helpers.lerp(len1, len2, t)
      points[#points+1] = math.cos(nextAngle) * nextDistance + obj.ox
      points[#points+1] = math.sin(nextAngle) * nextDistance + obj.oy
    end

    -- idk why but sometimes the last point doesn't reach the end of the slider
    -- so add it manually if needed
    if (points[#points] ~= obj.y2) then
      points[#points+1] = obj.x2
      points[#points+1] = obj.y2
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
    love.graphics.draw(obj.spr3,obj.x,obj.y,0,1,1,8,8)
    love.graphics.draw(obj.spr3,obj.x2,obj.y2,0,1,1,8,8)
  end

end
return obj
function beat()
  local obj = {
    layer = -1,
    uplayer = 3,
    slice = false,
    x=screencenter.x,
    y=screencenter.y,
    angle=0,
    startangle=0,
    smult2=1,
    endangle=0,
    hb=0,
    movetime=0,
    smult=1,
    randomvalue=math.random(),
    inverse = false,
    hityet = false,
    hold = false,
    mine = false,
    side = false,
    sidehityet = false,
    minehold = false,
    ringcw = false,
    ringccw = false,
    spr = sprites.beat.square,
    spr2 = sprites.beat.inverse,
    spr3 = sprites.beat.hold,
    spr4 = sprites.beat.mine,
    spr5 = sprites.beat.side,
    spr6 = sprites.beat.minehold,
    spr7 = sprites.beat.ringcw,
    spr8 = sprites.beat.ringccw
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
      if obj.spinease == "linear" then
        obj.angle = helpers.clamp(helpers.lerp(obj.startangle, obj.endangle, progress), obj.startangle, obj.endangle) % 360
      elseif obj.spinease == "inExpo"  then
        --print(2 ^ (10 * (progress - 1)))
        obj.angle = helpers.clamp(helpers.lerp(obj.startangle, obj.endangle, 2 ^ (10 * (progress - 1))), obj.startangle, obj.endangle) % 360
      end
    end
    
    local p1 = nil
    local p2 = nil
    
    if obj.inverse then
      p1 = helpers.rotate(((obj.hb - cs.cbeat)*cs.level.properties.speed*obj.smult*-1)+cs.extend+cs.length-24,obj.angle,obj.ox,obj.oy)
    elseif obj.side then
      p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.properties.speed*obj.smult+cs.extend+cs.length-10,obj.angle,obj.ox,obj.oy)
    elseif not obj.hold and not obj.minehold then
      p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.properties.speed*obj.smult+cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
    elseif obj.hold or obj.minehold then
      p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.properties.speed*obj.smult+cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
      p2 = helpers.rotate((obj.hb - cs.cbeat+obj.duration)*cs.level.properties.speed*obj.smult*obj.smult2+cs.extend+cs.length,obj.angle2,obj.ox,obj.oy)
      obj.x2 = p2[1]
      obj.y2 = p2[2]
      
    end
    obj.x = p1[1]
    obj.y = p1[2]  
  
    if (obj.hb - cs.cbeat) <= 0 and not obj.side and not obj.ringcw and not obj.ringccw then
      if not obj.mine then
        if not obj.hold and not obj.minehold then
          if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 then 
            em.init("hitpart",obj.x,obj.y)
            obj.delete = true
            pq = pq .. "   player hit!"
            cs.hits = cs.hits + 1
            cs.combo = cs.combo + 1
            if cs.beatsounds then
              te.play(sounds.click,"static")
            end
            if cs.p.cemotion == "miss" then
              cs.p.emotimer = 0
              cs.p.cemotion = "idle"
            end
          else
            local mp = em.init("misspart",screencenter.x,screencenter.x)
            mp.angle = obj.angle
            mp.distance = (obj.hb - cs.cbeat)*cs.level.properties.speed+cs.length
            mp.spr = (obj.inverse and not obj.slice and obj.spr2) or (obj.spr) --Determine which sprite the misspart should use
            mp.update()
            obj.delete = true
            pq = pq .. "   player missed!"
            cs.misses = cs.misses + 1
            cs.combo = 0
            cs.p.emotimer = 100
            cs.p.cemotion = "miss"
            
            cs.p.hurtpulse()
          end
        elseif obj.hold then
          if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 then 
            if obj.hityet == false then
              obj.hityet = true
              pq = pq .. "   started hitting hold"
              if cs.beatsounds then
              te.play(sounds.hold) --,"static")
              end
            end
            --em.init("hitpart",obj.x,obj.y)
            --print(helpers.angdistance(obj.angle,cs.p.angle).. " is less than " .. cs.p.paddle_size / 2)
            obj.angle = helpers.interpolate(obj.endangle,obj.angle2,((obj.hb - cs.cbeat)*-1)/obj.duration, obj.holdease)
            
            
            p1 = helpers.rotate(cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
            p2 = helpers.rotate((obj.hb - cs.cbeat+obj.duration)*cs.level.properties.speed*obj.smult*obj.smult2+cs.extend+cs.length,obj.angle2,obj.ox,obj.oy)
            obj.x2 = p2[1]
            obj.y2 = p2[2]
            obj.x = p1[1]
            obj.y = p1[2]  
            
            if ((obj.hb - cs.cbeat)*-1)/obj.duration >= 1 then
              pq = pq .. "   finished hold!"
              cs.hits = cs.hits + 1
              cs.combo = cs.combo + 1
              if cs.beatsounds then
                te.play(sounds.click,"static")
              end
              if cs.p.cemotion == "miss" then
                cs.p.emotimer = 0
                cs.p.cemotion = "idle"
                
              end
              obj.delete = true
              em.init("hitpart",obj.x,obj.y)
            end
          else
            local mp = em.init("misspart",screencenter.x,screencenter.x)
            mp.angle = obj.angle
            mp.distance = (obj.hb - cs.cbeat)*cs.level.properties.speed+cs.length
            mp.spr = obj.spr3 --Set the miss part's sprite to that of a hold
            mp.update()
            obj.delete = true
            pq = pq .. "   player missed hold!"
            cs.misses = cs.misses + 1
            cs.combo = 0
            cs.p.emotimer = 100
            cs.p.cemotion = "miss"
            
            cs.p.hurtpulse()
          end
          
        --mine hold
        elseif obj.minehold then
          
          local hitminehold = nil
          --avoiding mine hold, duration is not 0
          if helpers.angdistance(obj.angle,cs.p.angle) >= cs.p.paddle_size / 2 and obj.duration ~= 0 then 
            if obj.hityet == false then
              obj.hityet = true
              pq = pq .. "   started mine hold"
            end
            --em.init("hitpart",obj.x,obj.y)
            --print(helpers.angdistance(obj.angle,cs.p.angle).. " is less than " .. cs.p.paddle_size / 2)
            obj.angle = helpers.interpolate(obj.endangle,obj.angle2,((obj.hb - cs.cbeat)*-1)/obj.duration, obj.holdease)
            
            p1 = helpers.rotate(cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
            p2 = helpers.rotate((obj.hb - cs.cbeat+obj.duration)*cs.level.properties.speed*obj.smult*obj.smult2+cs.extend+cs.length,obj.angle2,obj.ox,obj.oy)
            obj.x2 = p2[1]
            obj.y2 = p2[2]
            obj.x = p1[1]
            obj.y = p1[2]  
            
            if ((obj.hb - cs.cbeat)*-1)/obj.duration >= 1 then
              hitminehold = false
            end
          
          --failed mine hold, duration is not 0
          elseif obj.duration ~= 0 then
            hitminehold = true
            
          --duration is 0
          elseif obj.duration == 0 then
            if helpers.isanglebetween(obj.endangle, obj.angle2, cs.p.angle) == false and helpers.angdistance(obj.endangle,cs.p.angle) > cs.p.paddle_size / 2 and helpers.angdistance(obj.angle2,cs.p.angle) > cs.p.paddle_size / 2 then
              hitminehold = false
            else
              hitminehold = true
            end
          end
          
          if hitminehold == true then
            local mp = em.init("misspart",screencenter.x,screencenter.x)
            mp.angle = obj.angle
            mp.distance = (obj.hb - cs.cbeat)*cs.level.properties.speed+cs.length
            mp.spr = obj.spr6 --Set the miss part's sprite to that of a mine hold
            mp.update()
            obj.delete = true
            pq = pq .. "   player hit mine hold!"
            cs.misses = cs.misses + 1
            cs.combo = 0
            cs.p.emotimer = 100
            cs.p.cemotion = "miss"
            if cs.beatsounds then
              te.play(sounds.mine,"static")
            end
            cs.p.hurtpulse()
          elseif hitminehold == false then
            pq = pq .. "   finished mine hold!"
            cs.hits = cs.hits + 1
            cs.combo = cs.combo + 1
            if cs.p.cemotion == "miss" then
              cs.p.emotimer = 0
              cs.p.cemotion = "idle"
            end
            obj.delete = true
            em.init("hitpart",obj.x,obj.y)
          end
          
          
        end
  
      elseif obj.mine then
        
        --mine
        if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 then 
          -- mine is hit
          
          local mp = em.init("misspart",screencenter.x,screencenter.x)
          mp.angle = obj.angle
          mp.distance = (obj.hb - cs.cbeat)*cs.level.properties.speed+cs.length
          mp.spr = obj.spr4 --Determine which sprite the misspart should use
          mp.update()
          obj.delete = true
          pq = pq .. "   player hit mine!"
          cs.misses = cs.misses + 1
          cs.combo = 0
          cs.p.emotimer = 100
          cs.p.cemotion = "miss"
          if cs.beatsounds then
            te.play(sounds.mine) --,"static")
          end
  
          cs.p.hurtpulse()
        else
          em.init("hitpart",obj.x,obj.y)
          obj.delete = true
          pq = pq .. "   player missed mine!"
          cs.hits = cs.hits + 1
          cs.combo = cs.combo + 1
          if cs.p.cemotion == "miss" then
            cs.p.emotimer = 0
            cs.p.cemotion = "idle"
          end
        end
      end
    elseif obj.side then
      --side notes
      if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 and helpers.angdistance(obj.angle,cs.p.angleprevframe) > cs.p.paddle_size / 2 and math.abs(obj.hb - cs.cbeat) <= 1/4 then
        obj.sidehityet = true
      elseif helpers.angdistance(obj.angle,cs.p.angle) > cs.p.paddle_size / 2 and helpers.angdistance(obj.angle,cs.p.angleprevframe) > cs.p.paddle_size / 2 and 60 > helpers.angdistance(obj.angle,cs.p.angle) and 60 > helpers.angdistance(obj.angle,cs.p.angleprevframe) then
        if obj.angle - cs.p.angleprevframe > 0 or obj.angle - cs.p.angleprevframe < -180 then
          if obj.angle - cs.p.angle < 0 or obj.angle - cs.p.angle > 180 then
            obj.sidehityet = true
          end
        else
          if obj.angle - cs.p.angle > 0 or obj.angle - cs.p.angle < -180 then
            obj.sidehityet = true
          end
        end
      end
      if obj.sidehityet == true and cs.cbeat >= obj.hb then
        em.init("hitpart",obj.x,obj.y)
        obj.delete = true
        pq = pq .. "   player hit!"
        cs.hits = cs.hits + 1
        cs.combo = cs.combo + 1
        if cs.beatsounds then
          te.play(sounds.click,"static")
        end
        if cs.p.cemotion == "miss" then
          cs.p.emotimer = 0
          cs.p.cemotion = "idle"
        end
      elseif obj.hb - cs.cbeat < -1/4 then
        local mp = em.init("misspart",screencenter.x,screencenter.x)
        mp.angle = obj.angle
        mp.distance = (obj.hb - cs.cbeat)*cs.level.properties.speed+cs.length
        mp.spr = obj.spr5 --Determine which sprite the misspart should use
        mp.update()
        obj.delete = true
        pq = pq .. "   player missed!"
        cs.misses = cs.misses + 1
        cs.combo = 0
        cs.p.emotimer = 100
        cs.p.cemotion = "miss"
        cs.p.hurtpulse()
      elseif helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 and helpers.angdistance(obj.angle,cs.p.angleprevframe) <= cs.p.paddle_size / 2 and (obj.hb - cs.cbeat) <= 0 then
        local mp = em.init("misspart",screencenter.x,screencenter.x)
        mp.angle = obj.angle
        mp.distance = (obj.hb - cs.cbeat)*cs.level.properties.speed+cs.length
        mp.spr = obj.spr5 --Determine which sprite the misspart should use
        mp.update()
        obj.delete = true
        pq = pq .. "   player missed!"
        cs.misses = cs.misses + 1
        cs.combo = 0
        cs.p.emotimer = 100
        cs.p.cemotion = "miss"
        cs.p.hurtpulse()
        if cs.beatsounds then
          te.play(sounds.mine,"static")
        end
      end
    elseif obj.ringcw or obj.ringccw then
      --ring notes
      --if the player starts moving too early, that's fine; they'll still hit the note from moving correctly anyways. issue is if the player's a bit late
      --for this reason if you're not moving you don't actually miss until 1/4 a beat later
      local status = nil
      local direction = 1
      if obj.ringccw then
        direction = -1
      end
      if ((cs.p.angle - cs.p.angleprevframe) * direction > 0 or (cs.p.angle - cs.p.angleprevframe - 180) * direction > 0) and (obj.hb - cs.cbeat) <= 0 then
        status = "hit"
      elseif ((cs.p.angle - cs.p.angleprevframe) * direction < 0 and (cs.p.angle - cs.p.angleprevframe - 180) * direction > 0) and (obj.hb - cs.cbeat) <= 0 then
        status = "wrongdir"
      elseif obj.hb - cs.cbeat < -1/4 then
        status = "miss"
      end
      if status == "hit" then
        --TODO: add hit particle for rings
        obj.delete = true
        pq = pq .. "   player hit!"
        cs.hits = cs.hits + 1
        cs.combo = cs.combo + 1
        if cs.beatsounds then
          te.play(sounds.click,"static")
        end
        if cs.p.cemotion == "miss" then
          cs.p.emotimer = 0
          cs.p.cemotion = "idle"
        end
      elseif status == "wrongdir" or status == "miss" then
        obj.delete = true
        pq = pq .. "   player missed!"
        cs.misses = cs.misses + 1
        cs.combo = 0
        cs.p.emotimer = 100
        cs.p.cemotion = "miss"
        cs.p.hurtpulse()
        if cs.beatsounds then
          te.play(sounds.mine, "static")
        end
      end
      
    end
    
  end
  
  function obj.draw()  
    if not obj.slice then
      gfx.setColor(0)
      if not obj.hold and not obj.minehold then
        local scaleval = ((obj.hb-cs.cbeat)*cs.level.properties.speed*obj.smult)/37+1.25
        if obj.inverse then
          obj.spr2:draw(math.floor(obj.x), math.floor(obj.y))--,0,1,1,16,16)
        elseif obj.mine then
          obj.spr4:draw(math.floor(obj.x), math.floor(obj.y))--,0,1,1,16,16)
        elseif obj.side then
          --obj.spr5:draw(obj.x,obj.y,math.rad(obj.angle),1,1,12,10)
          obj.spr5:drawRotated(math.floor(obj.x), math.floor(obj.y), obj.angle)--,0,1,1,24,20)
        elseif obj.ringcw then
          obj.spr7:draw(200,120,math.rad(30*obj.spinrate*(cs.cbeat-obj.hb)+(360*obj.randomvalue)),scaleval,scaleval,39,39)
        elseif obj.ringccw then
          obj.spr8:draw(200,120,math.rad(-30*obj.spinrate*(cs.cbeat-obj.hb)+(360*obj.randomvalue)),scaleval,scaleval,39,39)
        else
          obj.spr:draw(math.floor(obj.x), math.floor(obj.y)) --,0,1,1,16,16)
        end
      elseif obj.hold then
        local completion = math.max(0, (cs.cbeat - obj.hb) / obj.duration)
        obj.drawhold(obj.ox, obj.oy, obj.x, obj.y, obj.x2, obj.y2, completion, obj.angle1, obj.angle2, obj.segments, obj.spr3, obj.holdease, "hold")
      elseif obj.minehold then
        local completion = math.max(0, (cs.cbeat - obj.hb) / obj.duration)
        obj.drawhold(obj.ox, obj.oy, obj.x, obj.y, obj.x2, obj.y2, completion, obj.angle1, obj.angle2, obj.segments, obj.spr6, obj.holdease, "minehold")
      end
    else
      obj.x, obj.y = obj.drawslice(obj.ox, obj.oy, (obj.hb - cs.cbeat)*cs.level.properties.speed*obj.smult, obj.angle, obj.inverse, 1)
    end
  end
  
  function obj.drawhold(xo, yo, x1, y1, x2, y2, completion, a1, a2, segments, sprhold, ease, holdtype)
    
    local interp = ease or "Linear"
    local colortype = holdtype or "hold"
  
    -- distances to the beginning and the end of the hold
    local len1 = helpers.distance({xo, yo}, {x1, y1})
    local len2 = helpers.distance({xo, yo}, {x2, y2})
  
    -- how many segments to draw
    -- based on the beat's angles by default, but can be overridden in the json
    if interp == "Linear" then
      segments = 1
    elseif segments == nil then
      segments = math.floor(math.abs(a2 - a1)/3) -- /3 to reduce segments - 4 is a bit jagged but 3 looks okay?
    end
    
    -- make an open polygon (line) to hold all the points connecting segments - there should be 1 more point than n segments
    local hold_line_m = playdate.geometry.polygon.new(segments + 1)
    
    for i = 1, segments do
      
      local t = i / segments
      local angle_t = t * (1 - completion) + completion
      
      -- coordinates of the next point
      local nextAngle = math.rad(helpers.interpolate(a1, a2, angle_t, interp) - 90)
      local nextDistance = helpers.lerp(len1, len2, t)

      hold_line_m:setPointAt(i+1, 
        math.cos(nextAngle) * nextDistance + screencenter.x, 
        math.sin(nextAngle) * nextDistance + screencenter.y
      ) 
    end
    
    -- add the start point
    hold_line_m:setPointAt(1, x1, y1)
  
    -- idk why but sometimes the last point doesn't reach the end of the slider
    -- so add it manually if needed
    --if hold_line_m:getPointAt(hold_line_m:count()).y ~= y2 then
    -- if lastY ~= y2 then
    --   hold_line_m:setPointAt(hold_line_m:count() + 1, x2, y2)
    -- end
    -- if (points[#points] ~= y2) then
    --   points[#points+1] = x2
    --   points[#points+1] = y2
    -- end
    
    if segments >= 1 then
      playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
      if colortype == "hold" then
        playdate.graphics.setLineWidth(12)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(hold_line_m)
        playdate.graphics.setLineWidth(8)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawPolygon(hold_line_m)
      elseif colortype == "minehold" then 
        playdate.graphics.setLineWidth(12)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(hold_line_m)
        playdate.graphics.setLineWidth(8)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawPolygon(hold_line_m)
        playdate.graphics.setLineWidth(4)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(hold_line_m)
      else
        gfx.setLineWidth(4)
        gfx.drawPolygon(hold_line_m)
      end
    end
    
    gfx.setColor(0)
    
    -- draw beginning and end of hold
    sprhold:drawCentered(math.floor(x1), math.floor(y1))
    sprhold:drawCentered(math.floor(x2), math.floor(y2))
  end
  
  function obj.drawslice (ox, oy, rad, angle, inverse, alpha)
    local p = {}
    if inverse then
      p = helpers.rotate(-rad,angle,ox,oy)
    else
      p = helpers.rotate(rad,angle,ox,oy)
    end
    gfx.setColor(0)
    gfx.setLineWidth(2)
    -- gfx.pushContext() -- TEMP REMOVED
    --love.graphics.translate(p[1], p[2]) -- TEMP REMOVED
    --love.graphics.rotate((angle - 90) * math.pi / 180) -- TEMP REMOVED
  
    -- draw the lines connecting the player to the paddle
    gfx.drawLine(
      0, 0,
      (cs.p.paddle_distance + cs.extend) * math.cos(15 * math.pi / 180),
      (cs.p.paddle_distance + cs.extend) * math.sin(15 * math.pi / 180)
    )
    gfx.drawLine(
      0, 0,
      (cs.p.paddle_distance + cs.extend) * math.cos(-15 * math.pi / 180),
      (cs.p.paddle_distance + cs.extend) * math.sin(-15 * math.pi / 180)
    )
  
    -- draw the paddle
    local paddle_angle = 30 / 2 * math.pi / 180
    gfx.drawArc(0, 0, (cs.p.paddle_distance + cs.extend), paddle_angle, -paddle_angle)
    gfx.drawArc(0, 0, (cs.p.paddle_distance + cs.extend) + cs.p.paddle_width, paddle_angle, -paddle_angle)
    gfx.drawLine(
      (cs.p.paddle_distance + cs.extend) * math.cos(paddle_angle),
      (cs.p.paddle_distance + cs.extend) * math.sin(paddle_angle),
      ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.cos(paddle_angle),
      ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.sin(paddle_angle)
    )
    gfx.drawLine(
      (cs.p.paddle_distance + cs.extend) * math.cos(-paddle_angle),
      (cs.p.paddle_distance + cs.extend) * math.sin(-paddle_angle),
      ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.cos(-paddle_angle),
      ((cs.p.paddle_distance + cs.extend) + cs.p.paddle_width) * math.sin(-paddle_angle)
    )
    -- gfx.popContext()  -- TEMP REMOVED
  
    gfx.setColor(1)
    gfx.fillCircleAtPoint(p[1],p[2],4+cs.extend/2)
    gfx.setColor(0)
    gfx.drawCircleAtPoint(p[1],p[2],4+cs.extend/2)
  
    gfx.setColor(1)
    cs.p.spr[cs.p.cemotion]:draw(obj.x,obj.y)
  
    return p[1], p[2]
  end
  
  return obj
end

return beat
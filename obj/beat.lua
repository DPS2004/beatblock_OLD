local obj = {
  layer = -1,
  uplayer = 3,
  x=200,
  y=120,
  angle=0,
  startangle=0,
  endangle=0,
  hb=0,
  movetime=0,
  smult=1,
  spr = love.graphics.newImage("assets/game/square.png"),
}
obj.ox = obj.x
obj.oy = obj.y


function obj.update(dt)
  -- How long it takes to move from beat spawn to hitting the paddle
  if obj.movetime == 0 then
    obj.movetime = obj.hb - cs.cbeat
  end

  -- Progress is a number from 0 (spawn) to 1 (paddle)
  local progress = 1 - ((obj.hb - cs.cbeat) / obj.movetime)

  -- Interpolate angle between startangle and endangle based on progress. Beat should be at endangle when it hits the paddle.
  obj.angle = helpers.clamp(helpers.lerp(obj.startangle, obj.endangle, progress), obj.startangle, obj.endangle) % 360

  local p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.speed*obj.smult+cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
  obj.x = p1[1]
  obj.y = p1[2]
  if (obj.hb - cs.cbeat) < 0 then
    if helpers.angdistance(obj.angle,cs.p.angle) <= cs.p.paddle_size / 2 then --TODO REPLACE WITH PLAYER PADDLE SIZE
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
  end
end


function obj.draw()
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(obj.spr,obj.x,obj.y,0,1,1,8,8)

end
return obj
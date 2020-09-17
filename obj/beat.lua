local obj = {
  layer = -1,
  uplayer = 3,
  x=200,
  y=120,
  angle=0,
  hb=0,
  smult=1,
  spr = love.graphics.newImage("assets/game/square.png")
}
obj.ox = obj.x
obj.oy = obj.y


function obj.update(dt)
  obj.angle = obj.angle % 360
  local p1 = helpers.rotate((obj.hb - cs.cbeat)*cs.level.speed*obj.smult+cs.extend+cs.length,obj.angle,obj.ox,obj.oy)
  obj.x = p1[1]
  obj.y = p1[2]
  if (obj.hb - cs.cbeat) < 0 then
    if helpers.angdistance(obj.angle,cs.p.angle) <=35 then
      em.init("hitpart",obj.x,obj.y)
      obj.delete = true
      pq = pq .. "   player hit!"
      if cs.beatsounds then
      te.play("click.ogg","static")
      end

    else
      local mp = em.init("misspart",200,120)
      mp.angle = obj.angle
      mp.distance = (obj.hb - cs.cbeat)*cs.level.speed+cs.length
      mp.update()
      obj.delete = true
      pq = pq .. "   player missed!"
      
    end
  end
end

function obj.draw()
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(obj.spr,obj.x,obj.y,0,1,1,8,8)

end
return obj
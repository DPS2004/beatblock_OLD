local obj = {
  layer = 0,
  uplayer = 0,
  x=0,
  dead=false,
  y=0,
  name="pninja",
  width = 8,
  height = 10,
  showline = false,
  angle = 0,
  rotation = 4,
  deadtimer = 0,
  health = 1,
}
obj.spr = ez.newanim(ez.newtemplate("game/ninja.png",8,0))

function obj.update(dt)
  if not ismobile then
  if maininput:pressed("accept") then
    obj.rotation = obj.rotation * -1
    
  end
  end
  if obj.health == 11 and not obj.dead then
    obj.dead = true
    em.init("pcorpse",obj.x,obj.y)
  end
  if obj.dead then 
    for i,v in ipairs(entities) do
      if v.name == "enemy" then
        v.hit=true
        
      end
    end
    obj.showline = false
    obj.deadtimer = obj.deadtimer + 1*dt
    if obj.deadtimer >= 200 then
      helpers.swap(states.menu)
      
    end
  else
    if not ismobile then
      if maininput:down("accept") then
        obj.showline = true
        obj.angle = obj.angle + obj.rotation*dt
      else
        obj.showline = false
      end
      if maininput:released("accept") then
        local nst = em.init("star",obj.x,obj.y)
        nst.vx = (3 * math.cos((90 - obj.angle) * math.pi / 180))
        nst.vy = (0 - 3 * math.sin((90 - obj.angle) * math.pi / 180))
        local delt = helpers.rotate(-1,obj.angle,obj.x,obj.y)
        obj.x = delt[1]
        obj.y = delt[2]
      end
    else
      if pressed >= 1 then
        
        obj.showline = true
        obj.angle = obj.angle + obj.rotation*dt
      else
        obj.showline = false
      end
      if pressed == -1 then
        local nst = em.init("star",obj.x,obj.y)
        nst.vx = (3 * math.cos((90 - obj.angle) * math.pi / 180))
        nst.vy = (0 - 3 * math.sin((90 - obj.angle) * math.pi / 180))
        local delt = helpers.rotate(-1,obj.angle,obj.x,obj.y)
        obj.x = delt[1]
        obj.y = delt[2]
        obj.rotation = obj.rotation * -1
      end
    end
    ez.animupdate(obj.spr)
    obj.layer = 0 - obj.y
  end
  
end

function obj.draw()
  obj.spr.f = obj.health
  love.graphics.setColor(1,0,0)
  if obj.showline then
    love.graphics.points((4 * math.cos((90 - obj.angle) * math.pi / 180))+obj.x-0.5,(0 - 4 * math.sin((90 - obj.angle) * math.pi / 180))+obj.y+0.5)
    love.graphics.points((6 * math.cos((90 - obj.angle) * math.pi / 180))+obj.x-0.5,(0 - 6 * math.sin((90 - obj.angle) * math.pi / 180))+obj.y+0.5)
    love.graphics.points((8 * math.cos((90 - obj.angle) * math.pi / 180))+obj.x-0.5,(0 - 8 * math.sin((90 - obj.angle) * math.pi / 180))+obj.y+0.5)
    love.graphics.points((10 * math.cos((90 - obj.angle) * math.pi / 180))+obj.x-0.5,(0 - 10 * math.sin((90 - obj.angle) * math.pi / 180))+obj.y+0.5)
    love.graphics.points((12 * math.cos((90 - obj.angle) * math.pi / 180))+obj.x-0.5,(0 - 12 * math.sin((90 - obj.angle) * math.pi / 180))+obj.y+0.5) 
  end
  love.graphics.setColor(1,1,1)
  ez.animdraw(obj.spr,helpers.round(obj.x-4,true),helpers.round(obj.y-5,true))
end
return obj
local obj = {
  layer = -3,
  uplayer = 3,
  x=0,
  y=0,
  name = "enemy",
  width = 8,
  height = 10,
  hit=false,
  pointvalue = 100,
  dead=false,
  delete=false,
  spr = ez.newanim(templates.enemy)
  
}


function obj.update(dt)
  if not obj.dead then
    ez.animupdate(obj.spr)
    if not obj.hit then
      obj.x = obj.x + obj.vx*dt
      obj.y = obj.y + obj.vy *dt
    else
      obj.x = obj.x + (obj.vx * -2)*dt
      obj.y = obj.y + (obj.vy * -2)*dt
    end
  end
  obj.layer = 0 - obj.y
  if obj.x < -4 or obj.x > 164 or obj.y < -5 or obj.y > 95 then
    print("ninja out of bounds!")
    print(obj.x)
    print(obj.y)
    print(obj.vx)
    print(obj.vy)
    obj.delete = true
  end
    if helpers.collide(states.assault.pn,obj) and obj.hit == false then
      obj.hit = true
      obj.pointvalue = 200
      states.assault.pn.health = states.assault.pn.health+1
      
    end
  
  
end

function obj.draw()
  ez.animdraw(obj.spr,obj.x-4, obj.y-5)
  


end
return obj
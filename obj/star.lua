local obj = {
  layer = -1,
  uplayer = 1,
  kills = 0,
  x=0,
  y=0,
  width = 8,
  height = 8,
  name="star",
  vx=0,
  vy=0,
  spr = love.graphics.newImage("assets/game/star.png"),
  delete = false
}


function obj.update(dt)
  obj.x = obj.x + obj.vx *dt
  obj.y = obj.y + obj.vy *dt
  obj.layer = 0 - obj.y
  for i,v in ipairs(entities) do
    if v.name == "enemy" then
      if helpers.collide({x=obj.x-4,y=obj.y-4,width=8,height=8},{x=v.x-5,y=v.y-4,width=8,height=10}) then
        em.init("corpse",v.x,v.y)
        obj.kills = obj.kills + 1
        states.assault.score = states.assault.score + v.pointvalue + (obj.kills - 1)*100
        v.delete = true
      end

    end
  
  
  
  end
  if obj.x < -8 or obj.x > 160 or obj.y < -8 or obj.y > 90 then
    delete = true
    
  end
  

  
end

function obj.draw()
love.graphics.draw(obj.spr,obj.x-4,obj.y-4)

end
return obj
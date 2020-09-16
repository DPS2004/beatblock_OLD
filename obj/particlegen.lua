local obj = {
  layer = 999,
  uplayer = 3,
  density = 5,
  life = 10,
  length = 10,
  keep = true,
  color = 2,
  speed = 1,
  particles = {},
  countdown = 10,
  delete = false
}


function obj.update(dt)

  for i=1,obj.density do
    local np = {}
    np.x = obj.x
    np.y = obj.y
    np.l = obj.length
    np.v = helpers.rotate(obj.speed,math.random(1,360),0,0)
    table.insert(obj.particles,np)
  end
  
  
end

function obj.draw()
  love.graphics.setColor(colors[obj.color])
  obj.life = obj. life - 1
  for i,v in ipairs(obj.particles) do
    v.x = v.x + v.v[1]
    v.y = v.y + v.v[2]
    v.l = v.l - 1
    love.graphics.points(v.x,v.y)
    if v.l <=0 then
      table.remove(obj.particles, i)
    end
  end
  if obj.life <=0 then 
    obj.density = 0
    obj.countdown = obj.countdown - 1
    if obj.countdown <=0 then
      obj.delete = true
    end
  end
    



end
return obj
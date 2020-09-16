local obj = {
  layer = 999,
  uplayer = 3,
  density = 5,
  life = 10,
  speed = 1,
  particles = {}
}


function obj.update(dt)
  obj.life = obj. life - 1
  for i=1,density do
    local np = {}
    np.x = obj.x
    np.y = obj.y
    np.v = helpers.rotate(speed,math.random(1,360),0,0)
    table.insert(obj.particles,np)
  end

  
end

function obj.draw()


end
return obj
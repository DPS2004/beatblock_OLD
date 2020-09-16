local sweep = {
  active = false,
  i = 0,
  dots = {},
  nextstate = states.menu
}
function sweep.reset()
  sweep.active = false
  sweep.i = 0
  sweep.dots = {}
  
end
function sweep.activate(nx)

  sweep.active = true
  sweep.nextstate = nx
end


function sweep.update(dt)
  dt = 1
  if sweep.active then
    i = i + 1
    if i % 1 == 0 then
      table.insert(sweep.dots,{
        x = love.math.random(0,160),
        y = love.math.random(0,90),
        size = 1
      })
    end
    for i,v in ipairs(sweep.dots) do
      v.size = v.size + 1
      if v.size >= 100 then
        sweep.active = false
        gs.switch(sweep.nextstate)
      end
    end
  else
    i = 0
    sweep.dots = {}
  end


end

function sweep.draw()

  love.graphics.setColor(colors[2])
  for i,v in ipairs(sweep.dots) do
    love.graphics.circle("fill",v.x,v.y,v.size)

  end
  love.graphics.setColor(colors[1])
end
return sweep
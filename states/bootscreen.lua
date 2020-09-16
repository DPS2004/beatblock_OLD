local st = {}
function st.init()
  st.cat = {
    gr = love.graphics.newImage("assets/bootscreen/cat.png"),
    x = 80,
    y = 100
  }
  st.bubbletabby = {
    gr = love.graphics.newImage("assets/bootscreen/BUBBLETABBY(16x17).png"),
    quads = {},
    stretch = 69,
    y = 120
  
}
  local code = love.filesystem.load("obj/bootscreen/sweep.lua")
  
  st.sweeper= code()
  for i = 1, 11 do
    st.bubbletabby.quads[i] = love.graphics.newQuad(i*16-16,0,16,17,st.bubbletabby.gr:getDimensions())
  end
  st.sweep = false
end

function st.enter(prev)
  st.cat.y = 100
  st.i = 0
  
  
end
function st.leave()
  
end

function st.resume()
  
end
function st.update(d)
  lovebird.update()


  st.i = st.i + dt
  if st.i < 56 then
    st.cat.y = st.cat.y - dt
    st.bubbletabby.y = st.bubbletabby.y - dt
    st.bubbletabby.stretch = st.bubbletabby.stretch - dt
  end
  if st.i > 200 and not st.sweep then
    st.sweep = true

    st.sweeper.activate(states.menu)
  end
  
  
  
  st.sweeper.update(dt)
    
  
  
end
function st.draw()
  push:start()
  love.graphics.setColor(1,0,77/255)
  love.graphics.circle("line", st.cat.x, st.cat.y, math.sin(st.i/10)+10)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(st.cat.gr,st.cat.x,st.cat.y,0,1,1,8,8)
  for di = 1,11 do
    love.graphics.draw(st.bubbletabby.gr,st.bubbletabby.quads[di],(di-6)*st.bubbletabby.stretch+82,st.bubbletabby.y+math.sin(st.i/10+di/2)*3,0,1,1,8,8)
  end
  st.sweeper.draw()
  push:finish()
end
return st
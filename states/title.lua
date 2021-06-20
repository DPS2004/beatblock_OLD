local st = {}
function st.init()

end

function st.enter(prev)
  st.i=0
  st.pstext = loc.get("pressspace")
end


function st.leave()

end


function st.resume()

end


function st.update()
  if not paused then
    st.i = st.i + 1

    if st.i %2 == 0 then
      local nc = em.init("titleparticle",math.random(-8,408),-8)
      nc.dx = (math.random() *2) -1
      nc.dy = 2+ math.random()*2
    end
    flux.update(1)
    em.update(dt)
    if maininput:pressed("accept") or maininput:pressed("mouse1") then
      print(love.filesystem.getSaveDirectory())
      helpers.swap(states.songselect)
    end
  end
end


function st.draw(screen)
    
  love.graphics.setFont(font1)
  --push:start()
  shuv.start(screen)
  love.graphics.setColor(1,1,1)

  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)
  

  em.draw()
  love.graphics.draw(sprites.title.logo,32,32+math.sin(st.i*0.03)*10) -- TODO: actually animate this
  for a=128,130 do
    for b=155,157 do
      love.graphics.print(st.pstext,a,b)
    end
  end
  love.graphics.setColor(0,0,0)
  love.graphics.print(st.pstext,129,156)
  love.graphics.setColor(1,1,1)
  shuv.finish()
end


return st
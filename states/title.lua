local st = {}
function st.init()

end

function st.enter(prev)
  st.i=0
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
    if maininput:pressed("accept") then
      helpers.swap(states.songselect)
    end
  end
end


function st.draw()
  love.graphics.setFont(font1)
  --push:start()
  shuv.start()
  love.graphics.setColor(1,1,1)

  love.graphics.rectangle("fill",0,0,400,240)
  

  em.draw()
  love.graphics.draw(sprites.title.logo,32,32+math.sin(st.i*0.03)*10) -- TODO: actually animate this
  love.graphics.draw(sprites.title.spacetostart)
  shuv.finish()
end


return st
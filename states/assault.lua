local st = {}
function st.init()

end

function st.enter(prev)
  st.pn = em.init("pninja",80,44)
  st.spawntimer = 0
  st.spawnrate = 300
  st.ninjaspeed = 0.1
  st.score = 0
  
end
function st.leave()
  
end

function st.resume()
  
end
function st.update(d)
  
  
  helpers.updatemouse()
  if not ismobile then
    maininput:update()
  end
  lovebird.update()
  
  st.spawntimer = st.spawntimer - 1 *dt
  if st.spawntimer <= 0 then 

    st.spawntimer = st.spawntimer + st.spawnrate
    if st.spawnrate > 60 then
      st.spawnrate = st.spawnrate - 8
      st.ninjaspeed = st.ninjaspeed +0.004
    end
    local spawnloc = math.random(0,3)
    local newninja = nil
    if spawnloc == 0 then
      newninja = em.init("enemy",-4,math.random(-5,95))
    elseif spawnloc == 1 then
      newninja = em.init("enemy",math.random(-4,164),-5)
    elseif spawnloc == 2 then
      newninja = em.init("enemy",164,math.random(-5,95))
    else
      newninja = em.init("enemy",math.random(-4,164),95)
    end
    print(newninja.x)
    print(newninja.y)
    newninja.vx = (st.pn.x - newninja.x) / math.sqrt(((st.pn.x - newninja.x)^2)+((st.pn.y-newninja.y)^2)) * st.ninjaspeed *2
    newninja.vy = (st.pn.y - newninja.y) / math.sqrt(((st.pn.x- newninja.x)^2)+((st.pn.y-newninja.y)^2)) * st.ninjaspeed *2
  end

  
  
  
  flux.update(dt)
  em.update(dt)
  

  
  
end
function st.draw()
  push:start()
  love.graphics.rectangle("fill",0,0,160,90)

  em.draw()
  love.graphics.setColor(0,0,0)
  love.graphics.print(st.score,1,-4)
  if st.score == 0 then
    if ismobile then
      love.graphics.print("press and release",38,10)
    else
      love.graphics.print("press and release space",25,10)
    end
    love.graphics.print("to shoot a star!",40,20)
    
  end
  love.graphics.setColor(1,1,1)
  push:finish()

end
return st
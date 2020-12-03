local st = {}
function st.init()

end


function st.enter(prev)
  st.p = em.init("player",screencenter.x,screencenter.y)
  st.gm = em.init("gamemanager",screencenter.x,screencenter.y)
  st.gm.init(st)

  st.canv = love.graphics.newCanvas(400,240)

  st.level = json.decode(helpers.read(clevel .. "level.json"))
  st.gm.resetlevel()
  st.gm.on = true
end


function st.leave()
  entities = {}
  if st.source ~= nil then
    st.source:stop()
    st.source = nil
  end
  st.sounddata = nil
end


function st.resume()

end


function st.update()
  maininput:update()
  lovebird.update()

  if maininput:pressed("back") then
    helpers.swap(states.songselect)
  end
  if maininput:pressed("a") then
    helpers.swap(states.rdconvert)
  end

  flux.update(1)
  em.update(dt)
end


function st.draw()
  shuv.start()

  love.graphics.rectangle("fill",0,0,400,240)
  love.graphics.setCanvas(st.canv)
  
    if not st.vfx.hom then
      love.graphics.clear()
    end
    
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)

    --if st.vfx.hom then
      --for i=0,st.vfx.homint do
        --love.graphics.points(math.random(0,400),math.random(0,240))
      --end 
      
    --end
    --ouch the lag
    if st.vfx.bgnoise.enable then
      love.graphics.draw(st.vfx.bgnoise.image,math.random(-2048+gameWidth,0),math.random(-2048+gameHeight,0))
    end
    love.graphics.draw(st.bg)

    helpers.color(1)
    em.draw()
    helpers.color(2)
    --love.graphics.print(st.hits.." / " .. (st.misses+st.hits),10,10)
    if st.combo >= 10 then
      love.graphics.print(st.combo.." combo!",10,220)
    end
    helpers.color(1)
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  if pq ~= "" then
    print(helpers.round(st.cbeat*8,true)/8 .. pq)
  end
  shuv.finish()

end


return st
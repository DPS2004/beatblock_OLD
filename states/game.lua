local st = {}
function st.init()

end


function st.enter(prev)
  st.p = em.init("player",screencenter.x,screencenter.y)
  st.gm = em.init("gamemanager",screencenter.x,screencenter.y)
  st.gm.init(st)

  st.canv = love.graphics.newCanvas(400,240)

  st.level = json.decode(helpers.read(clevel))
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

    if st.vfx.hom then
      for i=0,st.vfx.homint do
        love.graphics.points(math.random(0,400),math.random(0,240))
      end
    end
    love.graphics.draw(st.bg)
    em.draw()
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
  end
  shuv.finish()

end


return st
local st = {}
function st.init()

end


function st.enter(prev)
  st.p = em.init("player",screencenter.x,screencenter.y)
  st.gm = em.init("gamemanager",screencenter.x,screencenter.y)
  st.gm.init(st)

  st.canv = love.graphics.newCanvas(gameWidth,gameHeight)

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
  if not paused then
    if maininput:pressed("back") then
      helpers.swap(states.songselect)
    end
    --if maininput:pressed("a") then
      --helpers.swap(states.rdconvert)
    --end

    flux.update(1)
    em.update(dt)
  end
end


function st.draw()
  shuv.start()

  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)
  love.graphics.setCanvas(st.canv)
  
    helpers.drawgame()
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  if pq ~= "" then
    print(helpers.round(st.cbeat*8,true)/8 .. pq)
  end
  shuv.finish()

end


return st
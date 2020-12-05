local st = {}


function st.init()
end


function st.enter(prev)
  entities = {}
  st.goffset = 0
  st.pctgrade = ((states.game.maxhits - states.game.misses) / states.game.maxhits)*100
  if st.pctgrade == 100 then
    st.lgrade = "s"
  elseif st.pctgrade >= 90 then
    st.lgrade = "a"
    st.goffset = -6
  elseif st.pctgrade >= 80 then
    st.lgrade = "b"
  elseif st.pctgrade >= 70 then
    st.lgrade = "c"
    st.goffset = -4
  elseif st.pctgrade >= 60 then
    st.lgrade = "d"
  else
    st.lgrade = "f"
  end
  st.lgradepm = "none"
  if st.lgrade ~= "s" and st.lgrade ~= "f" then
    if st.pctgrade % 10 <= 3 then
      st.lgradepm = "minus"
    elseif st.pctgrade % 10 <= 7 then
      st.lgradepm = "none"
    else
      st.lgradepm = "plus"
    end
  end
end


function st.leave()

end


function st.resume()

end

function st.mousepressed(x,y,b,t,p)

end


function st.update()
  pq = ""
  maininput:update()
  lovebird.update()

  flux.update(1)
  em.update(dt)
end


function st.draw()
  --push:start()
  shuv.start()
  love.graphics.setColor(1,1,1)

  love.graphics.rectangle("fill",0,0,400,240)

  love.graphics.setColor(0,0,0)
  --metadata bar 
  love.graphics.printf(states.game.level.metadata.artist .. " - " .. states.game.level.metadata.songname,0,10,400,"center")
  love.graphics.rectangle("fill",0,33,400,2)
  
  --results circle
  love.graphics.circle("line",200,139,100)
  love.graphics.printf("Grade:",0,45,400,"center")
  love.graphics.setColor(1,1,1)
  love.graphics.draw(sprites.results.grades[st.lgrade],175+st.goffset,62)
  if st.lgradepm ~= "none" then
    love.graphics.draw(sprites.results.grades[st.lgradepm],202,61)
  end
  love.graphics.setColor(0,0,0)
  love.graphics.printf("Misses: " .. states.game.misses,0,135,400,"center")
  love.graphics.printf("Continue",0,201,400,"center")
  love.graphics.printf("Retry",0,219,400,"center")
  love.graphics.setColor(1,1,1)
  
  em.draw()

  shuv.finish()
end


return st
local st = {}


function st.init()
end


function st.enter(prev)
  entities = {}
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
  love.graphics.print("insert results screen here lol",100,100)
  love.graphics.setColor(1,1,1)

  em.draw()
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
    
  end

  shuv.finish()
end


return st
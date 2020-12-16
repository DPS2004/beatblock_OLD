local st = {}
function st.init()

end

function st.enter(prev)

end


function st.leave()

end


function st.resume()

end


function st.update()


  -- do things here
  flux.update(1)
  em.update(dt)
end


function st.draw()
  --push:start()
  shuv.start()
  love.graphics.setColor(1,1,1)

  love.graphics.rectangle("fill",0,0,400,240)


  em.draw()

  shuv.finish()
end


return st
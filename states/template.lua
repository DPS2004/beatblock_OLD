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
  if not paused then

    -- do things here
    flux.update(1)
    em.update(dt)\
  end
end


function st.draw()
  --push:start()
  shuv.start()
  love.graphics.setColor(1,1,1)

  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)


  em.draw()

  shuv.finish()
end


return st
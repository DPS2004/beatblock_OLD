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
  maininput:update()
  lovebird.update()
  
  
  
  flux.update(1)
  em.update(dt)
  

  
  
end
function st.draw()
  push:start()
  

  em.draw()
  

  push:finish()
end
return st
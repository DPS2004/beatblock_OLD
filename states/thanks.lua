local st = {}
function st.init()
  entities = {}

end

function st.enter(prev)
  entities = {}
  gob.sweep.reset()
  
  
end
function st.leave()
  
end

function st.resume()
  
end
function st.update(dt)


end
function st.draw()
  push:start()
  love.graphics.setColor(colors[3])
  love.graphics.print("THANK YOU FOR PLAYING",20,35)
  love.graphics.print("FIREKATANA",50,45)
  love.graphics.print("GAME BY DPS2004",40,70)



  

  push:finish()
end
return st
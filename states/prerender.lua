local st = {ease = nil}


function st.init()
end

function st.refresh()
  
  
end

function st.enter(prev)
  st.p = em.init("player",37,37)
  st.extend = 0
  st.rendercanv = love.graphics.newCanvas(74,74)
  st.rendered = false
end



function st.leave()
  st.p.delete = true
  st.p=nil
end


function st.resume()

end



function st.update()
  
  flux.update(1)
  --em.update(dt)
end


function st.draw()
  
  love.graphics.setFont(font1)
  --push:start()
  shuv.start()
  
  
  love.graphics.setColor(0.5,0.5,0.5,1)
  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)
  if not st.rendered then
    st.rendered = true
    
    
    
    
    for paddlesize = 0,6 do
      
      st.p.paddle_size = 30 + paddlesize * 20
      
      for angle = 0,359 do
        love.graphics.setCanvas(st.rendercanv)
        st.p.angle = angle
        love.graphics.clear()
        em.draw()
        love.graphics.setCanvas(shuv.canvas)
        local data = st.rendercanv:newImageData()
        local leadingstring = '_'
        if angle < 100 then
          leadingstring = leadingstring .. '0'
        end
        if angle < 10 then
          leadingstring = leadingstring .. '0'
        end
        data:encode('png',paddlesize .. leadingstring .. angle .. '.png')
      end
    end
  end
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(st.rendercanv,0,0)
  

  shuv.finish()
end


return st
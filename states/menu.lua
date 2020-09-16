local st = {}
function st.init()
  
end

function st.enter(prev)
  entities = {}
  st.transition = false
  st.logo={x=21,y=4}
  st.logo.anim = ez.newanim(ez.newtemplate("title/animlogo120x30.png",120,3,false))
  st.finished = false
  st.menu={eased = false, curease = nil,cmen=1,x=0,y=90,sprs={
    love.graphics.newImage("assets/title/menu1.png"),
    love.graphics.newImage("assets/title/menu2.png")
    }
  }
  st.cursor={easing=false,pos=1, firstease=false, curease = nil,x=80,y=160,anim=ez.newanim(ez.newtemplate("title/cursor.png",7,3))}
  
end
function st.leave()
  
end

function st.resume()
  
end


function st.update(d)

  helpers.updatemouse()
  if not ismobile then
  maininput:update()
  end
  lovebird.update()

  ez.animupdate(st.logo.anim)
  ez.animupdate(st.cursor.anim)
  if st.logo.anim.f == 15 then
    st.finished = true
    
  end
  if st.finished then
    if st.menu.eased == false then
      flux.to(st.menu, 60, {y = 0}):ease("outExpo")
      if not ismobile then
        st.cursor.curease = flux.to(st.cursor,100, {y = 70}):ease("outExpo"):oncomplete(function(f) st.cursor.firstease=true st.cursor.easing=false end)
      else
        st.cursor.curease = flux.to(st.cursor,10, {y = 70}):ease("outExpo"):oncomplete(function(f) st.cursor.firstease=true st.cursor.easing=false end)
      end
      st.menu.eased = true
    end
    if not ismobile then
      if st.cursor.firstease and not st.transition then
        
        if maininput:pressed("left") then
          if st.cursor.pos == 1 then
            lovebird.print("woo")
            st.cursor.curease:stop()
            st.cursor.easing = true
            st.cursor.pos = 0
            st.cursor.curease = flux.to(st.cursor,60, {x = 30}):ease("outExpo"):oncomplete(function(f) st.cursor.easing=false end)
          end
          if st.cursor.pos == 2 then
            lovebird.print("woo")
            st.cursor.curease:stop()
            st.cursor.easing = true
            st.cursor.pos = 1
            st.cursor.curease = flux.to(st.cursor,60, {x = 80}):ease("outExpo"):oncomplete(function(f) st.cursor.easing=false end)
          end
        end
        if maininput:pressed("right") then
          
          if st.cursor.pos == 1 then
            lovebird.print("woo")
            st.cursor.curease:stop()
            st.cursor.easing = true
            st.cursor.pos = 2
            st.cursor.curease = flux.to(st.cursor,60, {x = 130}):ease("outExpo"):oncomplete(function(f) st.cursor.easing=false end)
          end
          if st.cursor.pos == 0 then
            lovebird.print("woo")
            st.cursor.curease:stop()
            st.cursor.easing = true
            st.cursor.pos = 1
            st.cursor.curease = flux.to(st.cursor,60, {x = 80}):ease("outExpo"):oncomplete(function(f) st.cursor.easing=false end)
          end
          
        end
        
        if maininput:pressed("accept") then
          st.menu.y = 6
          st.menu.curease = flux.to(st.menu, 30, {y = 0}):ease("outExpo")
          --heck
          if st.menu.cmen == 1 then -- first menu screen
            if st.cursor.pos == 2 then -- quit
              love.event.quit()
            elseif st.cursor.pos == 1 then --play
              st.menu.cmen = 2
            end
            
          elseif st.menu.cmen == 2 then -- play menu
            if st.cursor.pos == 2 then -- back
              st.menu.cmen = 1
            elseif st.cursor.pos == 0 then --ambush
              st.transition = true
              st.menu.curease:stop()
              st.menu.curease = flux.to(st.menu,100, {y=-90}):ease("outExpo"):oncomplete(function(f) helpers.swap(states.assault) end)
              flux.to(st.logo,100,{y=100}):ease("outExpo")
              flux.to(st.cursor,100,{y=-70}):ease("outExpo")
              
            end
          end

        end
            
        
      end
    else
    if pressed > 0 and st.menu.curease == nil then
      st.menu.y = 6
    end
    if pressed == -1 and not st.transition then
      st.menu.y = 6
      st.menu.curease = flux.to(st.menu, 30, {y = 0}):ease("outExpo"):oncomplete(function(f) st.menu.curease = nil end)
      if my >= 36 and my <= 70 then
        if mx >= 0 and mx < 56 then
          if st.menu.cmen == 2 then -- play menu
            st.transition = true
            st.menu.curease:stop()
            st.menu.curease = flux.to(st.menu,100, {y=-90}):ease("outExpo"):oncomplete(function(f) helpers.swap(states.assault) end)
            flux.to(st.logo,100,{y=100}):ease("outExpo")
            flux.to(st.cursor,100,{y=-70}):ease("outExpo")
          end
        elseif mx >= 56 and mx < 102 then
          if st.menu.cmen == 1 then -- play
            st.menu.cmen = 2
          end
        else
          if st.menu.cmen == 1 then -- main menu
            love.event.quit()
          elseif st.menu.cmen == 2 then -- play menu
            st.menu.cmen = 1
          end
        end
        
        
      end
    end
    end
  end
  
  
  flux.update(dt)
  em.update(dt)
  


  
end
function st.draw()
  push:start()
  love.graphics.rectangle("fill",0,0,160,90)

  em.draw()
  ez.animdraw(st.logo.anim,st.logo.x,st.logo.y)
  love.graphics.draw(st.menu.sprs[st.menu.cmen],st.menu.x,st.menu.y)
  if not ismobile then
    ez.animdraw(st.cursor.anim, st.cursor.x-3,st.cursor.y)
  end
  push:finish()

  
end
return st
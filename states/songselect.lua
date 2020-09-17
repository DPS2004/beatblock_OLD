local st = {}
function st.init()
  st.fg = love.graphics.newImage("assets/game/selectfg.png")


end

function st.enter(prev)
  st.p = em.init("player",350,120)
  st.length = 42
  st.extend = 0
  st.levels = json.decode(helpers.read("songlist.json"))
  
  st.selection = 1
  st.move = false
  st.dispy = -60

  
end
function st.leave()
  st.p.delete = true
  st.p=nil
end

function st.resume()
  
end
function st.update()
  pq = ""
  maininput:update()
  lovebird.update()
  if maininput:pressed("up") then
    st.selection = st.selection - 1
    st.move = true
  end
  if maininput:pressed("down") then
    st.selection = st.selection + 1
    st.move = true
  end
  if maininput:pressed("accept") then
    clevel = st.levels[st.selection].filename
    helpers.swap(states.game)
  end
  if st.move then
    te.play("click.ogg","static")
    st.move = false
    flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
  end
  
  
  flux.update(1)
  em.update(dt)

  
  

  
  
end
function st.draw()
  --push:start()
  shuv.start()

  love.graphics.rectangle("fill",0,0,400,240)
  love.graphics.draw(st.fg,2,-2)
  helpers.color(2)
  for i,v in ipairs(st.levels) do
    love.graphics.print(v.songname,10,70+i*60+st.dispy,0,2,2)
    love.graphics.print(v.artist,10,100+i*60+st.dispy)
  end
  --love.graphics.print("Happy Birthday (8-Bit)",10,10,0,2,2)
  --love.graphics.print("Xeno Sound",10,40)
  --love.graphics.print("The Cannery",10,70,0,2,2)
  --love.graphics.print("Kevin MacLeod",10,100)
  --love.graphics.print("World 1-1",10,130,0,2,2)
  --love.graphics.print("Nintendo",10,160)
  --love.graphics.print("An Example For",10,190,0,2,2)
  --love.graphics.print("Captive Portal",10,220)
  em.draw()

  --push:finish()
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
  end
  shuv.finish()
end
return st
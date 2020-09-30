local st = {}


function st.init()
  st.fg = love.graphics.newImage("assets/game/selectfg.png")
end


function st.enter(prev)
  st.p = em.init("player",350,120)
  st.length = 42
  st.extend = 0
  st.list = json.decode(helpers.read("levels/songlist.json"))
  st.levels = {}
  for i,v in ipairs(st.list) do
    if v.show then
      local clevelj = json.decode(helpers.read("levels/".. v.name .. "/level.json"))
      table.insert(st.levels,{songname=clevelj.metadata.songname,artist=clevelj.metadata.artist,filename="levels/".. v.name.."/"})
    end
  end
  st.levelcount = #st.levels --Get the # of levels in the songlist

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

function st.mousepressed(x,y,b,t,p)
  if ismobile then
    local newselection = st.selection
    if (love.mouse.getY()/shuv.scale) < 240/3 then
      newselection = st.selection - 1
      st.move = true
    elseif (love.mouse.getY()/shuv.scale) > 240/3*2 then
      newselection = st.selection + 1
      st.move = true
    else
      clevel = st.levels[st.selection].filename
      helpers.swap(states.game)
    end
    if st.move then
      if newselection >= 1 and newselection <= st.levelcount then --Only move the cursor if it's within the bounds of the level list
        st.selection = newselection
        te.play("click2.ogg","static")
        flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
      end
      st.move = false
    end 
  end
end


function st.update()
  pq = ""
  maininput:update()
  lovebird.update()

  local newselection = st.selection
  if maininput:pressed("up") then
    newselection = st.selection - 1
    st.move = true
  end
  if maininput:pressed("down") then
    newselection = st.selection + 1
    st.move = true
  end
  if maininput:pressed("accept") then
    clevel = st.levels[st.selection].filename
    helpers.swap(states.game)
  end
  if maininput:pressed("e") then
    clevel = st.levels[st.selection].filename
    helpers.swap(states.editor)
  end
  if st.move then
    if newselection >= 1 and newselection <= st.levelcount then --Only move the cursor if it's within the bounds of the level list
      st.selection = newselection
      te.play("click2.ogg","static")
      flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
    end
    st.move = false
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
  em.draw()
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
    
  end

  shuv.finish()
end


return st
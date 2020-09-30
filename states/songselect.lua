local st = {ease = nil}


function st.init()
  st.fg = love.graphics.newImage("assets/game/selectfg.png")
end

function st.refresh()
  local clist = love.filesystem.getDirectoryItems(st.cdir)
  local levels = {}
  for i,v in ipairs(clist) do
    if love.filesystem.getInfo(st.cdir .. v .. "/level.json") then
      local clevelj = json.decode(helpers.read(st.cdir .. v .. "/level.json"))
      table.insert(levels,{islevel = true,songname=clevelj.metadata.songname,artist=clevelj.metadata.artist,filename=st.cdir .. v .. "/"})
    elseif love.filesystem.getInfo(st.cdir .. v .. "/").type == "directory" then
      
      table.insert(levels,{islevel = false,name = v,filename=st.cdir .. v .. "/"})
    end
  end
  if st.cdir ~= "levels/" then
    local fname = st.cdir
    local fname2 = ""
    local offset = 0
    if string.sub(st.cdir,-1) == "/" then
      fname = string.sub(fname,1,-2)
    end
    fname2 = fname:match(".*/(.*)")
    fname = string.sub(fname,1,-(string.len(fname2)+1))
    table.insert(levels,{islevel=false,name="back",filename=fname})
  end
  st.selection = 1
  return levels
end

function st.enter(prev)
  st.cdir = "levels/"
  st.p = em.init("player",350,120)
  st.length = 42
  st.extend = 0
  --st.list = json.decode(helpers.read("levels/songlist.json"))
  st.levels = st.refresh()

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
      if st.levels[st.selection].islevel then
        clevel = st.levels[st.selection].filename
        helpers.swap(states.game)
      else
        st.cdir = st.levels[st.selection].filename
        st.levels = st.refresh()

        st.levelcount = #st.levels --Get the # of levels in the songlist

        st.selection = 1
        st.move = true
        st.dispy = -60
      end
    end
    if st.move then
      if newselection >= 1 and newselection <= st.levelcount then --Only move the cursor if it's within the bounds of the level list
        st.selection = newselection
        te.play("click2.ogg","static")
        st.ease = flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
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
    if st.levels[st.selection].islevel then
      clevel = st.levels[st.selection].filename
      helpers.swap(states.game)
    else
      st.cdir = st.levels[st.selection].filename
      st.levels = st.refresh()
      
      st.levelcount = #st.levels --Get the # of levels in the songlist
      if st.ease then
        st.ease:stop()
      end
      st.selection = 1
      st.move = true
      te.play("click2.ogg","static")
      st.ease = flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
      --st.dispy = -60

      newselection = 1
    end
  end
  if maininput:pressed("e") then
    clevel = st.levels[st.selection].filename
    helpers.swap(states.editor)
  end
  if st.move then
    if newselection >= 1 and newselection <= st.levelcount then --Only move the cursor if it's within the bounds of the level list
      st.selection = newselection
      te.play("click2.ogg","static")
      
      st.ease = flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
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
    if v.islevel then
      love.graphics.print(v.songname,10,70+i*60+st.dispy,0,2,2)
      love.graphics.print(v.artist,10,100+i*60+st.dispy)
    else
      love.graphics.print(v.name,10,76+i*60+st.dispy,0,2,2)
      --love.graphics.print(v.artist,10,100+i*60+st.dispy)
    end
  end
  em.draw()
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
    
  end

  shuv.finish()
end


return st
local st = {}


function st.init()
end


function st.enter(prev)
  entities = {}
  st.selection = 1
  st.selectionbounds = {
    {x=167,y=201,w=64,h=14},
    {x=179,y=218,w=40,h=17}
  }
  st.cselectionbounds = {x=167,y=201,w=64,h=14}
  st.goffset = 0
  st.pctgrade = ((states.game.maxhits - states.game.misses) / states.game.maxhits)*100
  st.lgrade,st.lgradepm = helpers.gradecalc(st.pctgrade)
  st.pljson = dpf.loadjson("savedata/playedlevels.json",{})
  st.timesplayed = 0
  st.storepctgrade = st.pctgrade
  st.storemisses = states.game.misses
  if st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter] then
    st.timesplayed = st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter].timesplayed
    st.timesplayed = st.timesplayed + 1
    if st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter].misses < st.storemisses then
      st.storemisses = st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter].misses
    end
    if st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter].pctgrade > st.storepctgrade then
      st.storepctgrade = st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter].pctgrade
    end
  else
    st.timesplayed = 1
  end
  st.pljson[states.game.level.metadata.songname.."_"..states.game.level.metadata.charter]={pctgrade=st.storepctgrade,misses=st.storemisses,timesplayed=st.timesplayed}
  dpf.savejson("savedata/playedlevels.json", st.pljson)
end


function st.leave()

end


function st.resume()

end

function st.mousepressed(x,y,b,t,p)

end


function st.update()
  pq = ""
  if not paused then
    if maininput:pressed("up") then
      st.selection = 1
      st.ease = flux.to(st.cselectionbounds,30,{
        x=st.selectionbounds[1].x,
        y=st.selectionbounds[1].y,
        w=st.selectionbounds[1].w,
        h=st.selectionbounds[1].h,
        
      }):ease("outExpo")
    end
    if maininput:pressed("down") then
      st.selection = 2
      st.ease = flux.to(st.cselectionbounds,30,{
        x=st.selectionbounds[2].x,
        y=st.selectionbounds[2].y,
        w=st.selectionbounds[2].w,
        h=st.selectionbounds[2].h,
        
      }):ease("outExpo")
    end
    if maininput:pressed("accept") then
      if st.selection == 1 then
        helpers.swap(states.songselect)
      else
        helpers.swap(states.game)
      end
    end

      

    flux.update(1)
    em.update(dt)
  end
end


function st.draw()
  love.graphics.setFont(font1)
  --push:start()
  shuv.start()
  love.graphics.setColor(1,1,1)

  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)

  love.graphics.setColor(0,0,0)
  --metadata bar 
  love.graphics.printf(states.game.level.metadata.artist .. " - " .. states.game.level.metadata.songname,0,10,400,"center")
  love.graphics.rectangle("fill",0,33,400,2)
  
  --results circle
    love.graphics.setLineWidth(2)
  love.graphics.circle("line",200,139,100)
  love.graphics.printf(loc.get("grade"),0,45,400,"center")
  love.graphics.setColor(1,1,1)
  love.graphics.draw(sprites.results.grades[st.lgrade],175+st.goffset,62)
  if st.lgradepm ~= "none" then
    love.graphics.draw(sprites.results.grades[st.lgradepm],202,61)
  end
  love.graphics.setColor(0,0,0)
  love.graphics.printf(loc.get("misses") .. states.game.misses,0,135,400,"center")
  love.graphics.printf(loc.get("continue"),0,201,400,"center")
  love.graphics.printf(loc.get("retry"),0,218,400,"center")
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line",st.cselectionbounds.x,st.cselectionbounds.y,st.cselectionbounds.w,st.cselectionbounds.h)
  love.graphics.setColor(1,1,1)
  
  em.draw()

  shuv.finish()
end


return st
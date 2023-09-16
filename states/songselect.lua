local st = Gamestate:new('songselect')


st:setinit(function(self)
  self.fg = sprites.songselect.fg
	
  self.cdir = "levels/"
  self.p = em.init("player",{x=350,y=120})
  self.length = 42
  self.extend = 0
  self.levels = self:refresh()

  self.levelcount = #self.levels --Get the # of levels in the songlist
  self.crank = "none"
  self.selection = 1
  self.move = false
  self.dispy = -60
end)

function st:refresh()
  local clist = love.filesystem.getDirectoryItems(self.cdir)
  local levels = {}
  for i,v in ipairs(clist) do
    if love.filesystem.getInfo(self.cdir .. v .. "/level.json") then
      local clevelj = dpf.loadjson(self.cdir .. v .. "/level.json")
      table.insert(levels,{islevel = true,songname=clevelj.metadata.songname,artist=clevelj.metadata.artist,filename=self.cdir .. v .. "/"})
    elseif love.filesystem.getInfo(self.cdir .. v .. "/").type == "directory" then
      
      table.insert(levels,{islevel = false,name = v,filename=self.cdir .. v .. "/"})
    end
  end
  if self.cdir ~= "levels/" then
    local fname = self.cdir
    table.insert(levels,{islevel=false,name=loc.get("back"),filename=helpers.rliid(fname)})
  end
  self.selection = 1
  self.pljson = dpf.loadjson("savedata/playedlevels.json",{})
  return levels
  
end




function st:leave()
  self.p.delete = true
  self.p=nil
end


function st.resume()

end
--[[
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
        te.play(sounds.click,"static")
        st.ease = flux.to(st,30,{dispy=st.selection*-60}):ease("outExpo")
      end
      if st.levels[st.selection].islevel then
        local curjson = dpf.loadjson(st.levels[st.selection].filename .. "level.json")
        if st.pljson[curjson.metadata.songname.."_"..curjson.metadata.charter] then
          local cpct = st.pljson[curjson.metadata.songname.."_"..curjson.metadata.charter].pctgrade
          local sn,ch = helpers.gradecalc(cpct)
          st.crank = sn .. ch
        else
          st.crank = "none"
        end
      else
        st.crank = "none"
      end
      st.move = false
    end
  end
end
]]

st:setupdate(function(self,dt)
  pq = ""
  if not paused then
    local newselection = self.selection
    if maininput:pressed("up") then
      newselection = self.selection - 1
      self.move = true
    end
    if maininput:pressed("down") then
      newselection = self.selection + 1
      self.move = true
    end
    if maininput:pressed("accept") then
      if self.levels[self.selection].islevel then
        clevel = self.levels[self.selection].filename
				self:leave()
        cs = bs.load('game')
				cs:init()
      else
        self.cdir = self.levels[self.selection].filename
        self.levels = self:refresh()
        
        self.levelcount = #self.levels --Get the # of levels in the songlist
        if self.ease then
          self.ease:stop()
        end
        self.selection = 1
        self.move = true
        te.play(sounds.click,"static")
        self.ease = flux.to(self,30,{dispy=self.selection*-60}):ease("outExpo")
        --self.dispy = -60

        newselection = 1
      end
    end
    if maininput:pressed("e") then
      if self.levels[self.selection].islevel then
        clevel = self.levels[self.selection].filename
				self:leave()
        cs = bs.load('editor')
				cs:init()
      end
    end
    if self.move then
      if newselection >= 1 and newselection <= self.levelcount then --Only move the cursor if it's within the bounds of the level list
        self.selection = newselection
        te.play(sounds.click,"static")
        self.ease = flux.to(self,30,{dispy=self.selection*-60}):ease("outExpo")
      end
      if self.levels[self.selection].islevel then
        local curjson = dpf.loadjson(self.levels[self.selection].filename .. "level.json")
        if self.pljson[curjson.metadata.songname.."_"..curjson.metadata.charter] then
          local cpct = self.pljson[curjson.metadata.songname.."_"..curjson.metadata.charter].pctgrade
          local sn,ch = Gamemanager:gradecalc(cpct)
          self.crank = sn .. ch
        else
          self.crank = "none"
        end
      else
        self.crank = "none"
      end
      self.move = false
    end
  end
end)


st:setbgdraw(function(self)
  love.graphics.setFont(fonts.digitaldisco)
  --push:start()

  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
	
  love.graphics.draw(self.fg,2,-2)
  color('black')
	
  for i,v in ipairs(self.levels) do
    if v.islevel then
      love.graphics.print(v.songname,10,70+i*60+self.dispy,0,2,2)
      love.graphics.print(v.artist,10,100+i*60+self.dispy)
    else
      love.graphics.print(v.name,10,76+i*60+self.dispy,0,2,2)
      --love.graphics.print(v.artist,10,100+i*60+self.dispy)
    end
  end
end)


--em.draw()
st:setfgdraw(function(self)
	color()
  if self.crank ~= "none" then
    love.graphics.draw(sprites.songselect.grades[self.crank],320,20)
  end
  if pq ~= "" then
    --print(helpers.round(self.cbeat*6,true)/6 .. pq)
    
  end

  shuv.finish()
end)


return st
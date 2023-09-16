local st = Gamestate:new('results')

st:setinit(function(self)
  entities = {}
  self.selection = 1
  self.selectionbounds = {
    {x=167,y=201,w=64,h=14},
    {x=179,y=218,w=40,h=17}
  }
  self.cselectionbounds = {x=167,y=201,w=64,h=14}
  self.goffset = 0
  self.pctgrade = ((self.maxhits - self.misses) / self.maxhits)*100
  self.lgrade,self.lgradepm = Gamemanager:gradecalc(self.pctgrade)
  self.pljson = dpf.loadjson("savedata/playedlevels.json",{})
  self.timesplayed = 0
  self.storepctgrade = self.pctgrade
  self.storemisses = self.misses
  if self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter] then --hey what the FUCK is this
    self.timesplayed = self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter].timesplayed
    self.timesplayed = self.timesplayed + 1
    if self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter].misses < self.storemisses then
      self.storemisses = self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter].misses
    end
    if self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter].pctgrade > self.storepctgrade then
      self.storepctgrade = self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter].pctgrade
    end
  else
    self.timesplayed = 1
  end
  self.pljson[self.level.metadata.songname.."_"..self.level.metadata.charter]={pctgrade=self.storepctgrade,misses=self.storemisses,timesplayed=self.timesplayed}
  dpf.savejson("savedata/playedlevels.json", self.pljson)
end)

--[[
function st.mousepressed(x,y,b,t,p)
  if ismobile then
    if (love.mouse.getY()/shuv.scale) < 240/3 then -- up
      self.selection = 1
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[1].x,
        y=self.selectionbounds[1].y,
        w=self.selectionbounds[1].w,
        h=self.selectionbounds[1].h,
        
      }):ease("outExpo")
    elseif (love.mouse.getY()/shuv.scale) > 240/3*2 then -- down
      self.selection = 2
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[2].x,
        y=self.selectionbounds[2].y,
        w=self.selectionbounds[2].w,
        h=self.selectionbounds[2].h,
        
      }):ease("outExpo")
    else -- center
      if self.selection == 1 then
				cs = bs.load('songselect')
				cs:init()
      else
        cs = bs.load('game')
				cs:init()
      end
    
    end
  end
end
]]--


st:setupdate(function(self,dt)
  pq = ""
  if not paused then
    if maininput:pressed("up") then
      self.selection = 1
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[1].x,
        y=self.selectionbounds[1].y,
        w=self.selectionbounds[1].w,
        h=self.selectionbounds[1].h,
        
      }):ease("outExpo")
    end
    if maininput:pressed("down") then
      self.selection = 2
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[2].x,
        y=self.selectionbounds[2].y,
        w=self.selectionbounds[2].w,
        h=self.selectionbounds[2].h,
        
      }):ease("outExpo")
    end
    if maininput:pressed("accept") then
      if self.selection == 1 then
				cs = bs.load('songselect')
				cs:init()
      else
        cs = bs.load('game')
				cs:init()
      end
    end
  end
end)


st:setbgdraw(function(self)
  love.graphics.setFont(fonts.digitaldisco)

  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)

  love.graphics.setColor(0,0,0)
  --metadata bar 
  love.graphics.printf(self.level.metadata.artist .. " - " .. self.level.metadata.songname,0,10,400,"center")
  love.graphics.rectangle("fill",0,33,400,2)
  
  --results circle
    love.graphics.setLineWidth(2)
  love.graphics.circle("line",200,139,100)
  love.graphics.printf(loc.get("grade"),0,45,400,"center")
  love.graphics.setColor(1,1,1)
  love.graphics.draw(sprites.results.grades[self.lgrade],175+self.goffset,62)
  if self.lgradepm ~= "none" then
    love.graphics.draw(sprites.results.grades[self.lgradepm],202,61)
  end
  love.graphics.setColor(0,0,0)
  love.graphics.printf(loc.get("misses") .. self.misses,0,135,400,"center")
  love.graphics.printf(loc.get("continue"),0,201,400,"center")
  love.graphics.printf(loc.get("retry"),0,218,400,"center")
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line",self.cselectionbounds.x,self.cselectionbounds.y,self.cselectionbounds.w,self.cselectionbounds.h)
  love.graphics.setColor(1,1,1)
  
end)


return st
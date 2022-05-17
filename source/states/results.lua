ResultsScene = {}

class("ResultsScene").extends(NobleScene)

function ResultsScene:init()
  ResultsScene.super.init(self)
end

function ResultsScene:enter(prev)
  cs.gm.currst.source.source:stop()
  ResultsScene.super.enter(self)
  entities = {}
  self.selection = 1
  self.selectionbounds = {
    {x=165,y=200,w=68,h=16},
    {x=179,y=218,w=40,h=17}
  }
  self.cselectionbounds = self.selectionbounds[1]
  self.goffset = 0
  self.pctgrade = ((cs.gm.currst.maxhits - cs.gm.currst.misses) / cs.gm.currst.maxhits)*100
  self.lgrade, self.lgradepm = helpers.gradecalc(self.pctgrade)
  -- self.pljson = json.decodeFile("savedata/playedlevels.json",{})
  self.timesplayed = 0
  self.storepctgrade = self.pctgrade
  self.storemisses = cs.misses
  -- if self.pljson ~= nil then
  --   self.timesplayed = 1
  -- else
  --   if self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter] then
  --     self.timesplayed = self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].timesplayed
  --     self.timesplayed = self.timesplayed + 1
  --     if self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].misses < self.storemisses then
  --       self.storemisses = self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].misses
  --     end
  --     if self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].pctgrade > self.storepctgrade then
  --       self.storepctgrade = self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].pctgrade
  --     end
  --   end
  --   self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter]={pctgrade=self.storepctgrade,misses=self.storemisses,timesplayed=self.timesplayed}
  --   json.encodeToFile("savedata/playedlevels.json", self.pljson)
  -- end
end


function ResultsScene:exit()
  ResultsScene.super.exit(self)
end


function ResultsScene:resume()

end

function ResultsScene:update()
  updateDt()
  flux.update(dt)
  pq = ""
  if not paused then
    if maininput.pressed("up") then
      self.selection = 1
      self.cselectionbounds = self.selectionbounds[self.selection]
      --flux.to(self.cselectionbounds, 30, self.selectionbounds[self.selection]):ease("outExpo")
    end
    if maininput.pressed("down") then
      self.selection = 2
      self.cselectionbounds = self.selectionbounds[self.selection]
      --flux.to(self.cselectionbounds, 30, self.selectionbounds[self.selection]):ease("outExpo")
    end
    if maininput.pressed("accept") then
      if self.selection == 1 then
        Noble.transition(SongSelectScene)
      else
        Noble.transition(GameScene)
      end
    end

    em.update(dt)
  end
end

function ResultsScene:draw()

  flux.update(dt)
  
  -- clear the screen
  gfx.clear()
  
  -- draw metadata bar
  gfx.setColor(playdate.graphics.kColorBlack)
  gfx.setFont(DigitalDisco16)
  meta_text = (cs.level.metadata.artist .. " - " .. cs.level.metadata.songname)
  gfx.drawTextAligned(meta_text, 200, 10, kTextAlignment.center)
  gfx.fillRect(0, 33, 400, 2)

  -- draw results
  gfx.setLineWidth(2)
  gfx.drawCircleAtPoint(200, 139, 100)
  sprites.results.grades[self.lgrade]:draw (175+self.goffset,62)
  if self.lgradepm ~= "none" then
    sprites.results.grades[self.lgradepm]:draw(202,61)
  end
  gfx.drawTextAligned("hits: " .. cs.gm.currst.hits, 200, 135, kTextAlignment.center)
  gfx.drawTextAligned("misses: " .. cs.gm.currst.misses, 200, 158, kTextAlignment.center)
  
  -- draw buttons
  gfx.setFont(DigitalDisco12)
  if self.ease then 
    gfx.fillRoundRect(self.ease.x,self.ease.y,self.ease.w,self.ease.h,3)
  else 
    gfx.fillRoundRect(self.cselectionbounds.x,self.cselectionbounds.y,self.cselectionbounds.w,self.cselectionbounds.h,3)
  end
  gfx.setImageDrawMode(gfx.kDrawModeNXOR)
  if self.selection == 1 then 
    gfx.drawTextAligned("continue", 200, 201, kTextAlignment.center)
    gfx.drawTextAligned("retry", 200, 218, kTextAlignment.center)
  else
    gfx.drawTextAligned("continue", 200, 201, kTextAlignment.center)
    gfx.drawTextAligned("retry", 200, 218, kTextAlignment.center)
  end
  gfx.setImageDrawMode(gfx.kDrawModeCopy)
  
  em.draw()

end


return ResultsScene
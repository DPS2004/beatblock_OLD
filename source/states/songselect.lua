SongSelectScene = {}

class("SongSelectScene").extends(NobleScene)
SongSelectScene.backgroundColor = Graphics.kColorWhite

function SongSelectScene:init()
	SongSelectScene.super.init(self)
  SongSelectScene.fg = sprites.songselect.fg
  self.levels = {}
end

function SongSelectScene:refresh()
  local clist = playdate.file.listFiles(self.cdir)
  local levels = {}
  for i,v in ipairs(clist) do
    if playdate.file.exists(self.cdir .. v .. "level.json") then
      local clevelj = json.decodeFile(self.cdir .. v .. "level.json")
      table.insert(levels,{islevel = true,songname=clevelj.metadata.songname,artist=clevelj.metadata.artist,filename=self.cdir .. v .. ""})
    elseif playdate.file.isdir(self.cdir .. v .. "/") then
      table.insert(levels,{islevel = false,name = v,filename=self.cdir .. v })
    end
  end
  if self.cdir ~= "levels/" then
    local fname = self.cdir
    table.insert(levels,{islevel=false,name=gfx.getLocalizedText("back"),filename=helpers.rliid(fname)})
  end
  self.selection = 1
  self.pljson = json.decodeFile("savedata/playedlevels.json", {})
  return levels

end

function SongSelectScene:enter(prev)
	SongSelectScene.super.enter(self)
  self.cdir = "levels/"
  self.p = em.init("player",350,120)
  self.length = 42
  self.extend = 0
  self.levels = self:refresh()

  --self.levelcount = #self.levels --Get the # of levels in the songlist
  self.crank = "none"
  self.selection = 1
  self.move = false
  self.dispy = -60

  cs = Noble.currentScene()
end


function SongSelectScene:exit(prev)
	SongSelectScene.super.exit(self)
  self.p.delete = true
  self.p=nil
end

function SongSelectScene:update()
  updateDt()
  pq = ""
    local newselection = self.selection
    if maininput.pressed("up") then
      newselection = self.selection - 1
      self.move = true
    end
    if maininput.pressed("down") then
      newselection = self.selection + 1
      self.move = true
    end
    if maininput.pressed("accept") then
      if self.levels[self.selection].islevel then
        clevel = self.levels[self.selection].filename
	self.p.delete = true
        self.p=nil
        --helpers.swap(states.game)
        Noble.transition(GameScene)
      else
        self.cdir = self.levels[self.selection].filename
        self.levels = self:refresh()

        --self.levelcount = #self.levels --Get the # of levels in the songlist
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
    if maininput.pressed("e") then
      if self.levels[self.selection].islevel then
        clevel = self.levels[self.selection].filename
        helpers.swap(states.editor)
      end
    end
    if self.move then
      if newselection >= 1 and newselection <= #self.levels then --Only move the cursor if it's within the bounds of the level list
        self.selection = newselection
        te.play(sounds.click)--,"static")
        self.ease = flux.to(self,30,{dispy=self.selection*-60}):ease("outExpo")
      end
      if self.levels[self.selection].islevel then
        local curjson = json.decodeFile(self.levels[self.selection].filename .. "level.json")
        -- if self.pljson[curjson.metadata.songname.."_"..curjson.metadata.charter] then
        --   local cpct = self.pljson[curjson.metadata.songname.."_"..curjson.metadata.charter].pctgrade
        --   local sn,ch = helpers.gradecalc(cpct)
        --   self.crank = sn .. ch
        -- else
        --   self.crank = "none"
        -- end
      else
        self.crank = "none"
      end
      self.move = false
    end

  em.update(dt)
	flux.update(dt)
end


function SongSelectScene:draw()

  -- gfx.fillRect(0,0,gameWidth,gameHeight)
  self.fg:draw(2, -2)
  gfx.setColor(0)

  for i,v in ipairs(self.levels) do
    if v.islevel then
      gfx.setFont(DigitalDisco16)
      gfx.drawText(v.songname,10,69+i*60+self.dispy)
      gfx.setFont(DigitalDisco12)
      gfx.drawText(v.artist,10,96+i*60+self.dispy)
    else
      gfx.setFont(DigitalDisco16)
      gfx.drawText(v.name,10,76+i*60+self.dispy)
    end
  end
  em.draw()
  if cs.crank ~= "none" then
    --love.graphics.draw(sprites.songselect.grades[cs.crank],320,20)
  end
  if pq ~= "" then
    print(helpers.round(self.cbeat*6,true)/6 .. pq)

  end
end


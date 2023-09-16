local st = Gamestate:new('title')

st:setinit(function(self)
  self.i=0
  self.pstext = loc.get("pressspace")
end)


st:setupdate(function(self,dt)
  if not paused then
    self.i = self.i + 1

    if self.i %2 == 0 then
      local nc = em.init("titleparticle",{x=math.random(-8,408),y=-8,dx=(math.random() *2) -1,dy=2+ math.random()*2})
    end
		
    if maininput:pressed("accept") or maininput:pressed("mouse1") then
        cs = bs.load('songselect')
				cs:init()
    end
  end
end)

st:setbgdraw(function(self)
  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
end)


st:setfgdraw(function(self)
  love.graphics.setFont(fonts.digitaldisco)
  love.graphics.setColor(1,1,1)
  
  love.graphics.draw(sprites.title.logo,32,32+math.sin(self.i*0.03)*10) -- TODO: actually animate this
  for a=128,130 do
    for b=155,157 do
      love.graphics.print(self.pstext,a,b)
    end
  end
  love.graphics.setColor(0,0,0)
  love.graphics.print(self.pstext,129,156)
  love.graphics.setColor(1,1,1)
end)


return st
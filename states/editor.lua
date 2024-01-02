local st = Gamestate:new('editor')

st:setinit(function(self)
  --em.init('templateobj',{x=128,y=72})
	
  self.gm = em.init("gamemanager")

  self.canv = love.graphics.newCanvas(project.res.x,project.res.y)

  self.level = Levelmanager:loadlevel(clevel)
	self.editmode = true
  self.gm:resetlevel()
	
	self.holdentitydraw = true

	self.zoom = self.level.properties.speed or 40

	self.keybinds = {}
	
	--save
	self:addkeybind(function()
			if not maininput:down('alt') then
				local upgraded = Levelmanager:savelevel(self.level,clevel)
				if upgraded then
					print("NOTICE: upgraded format of level.")
				end
				self.p:hurtpulse()
			end
		end,
		'save',
		'ctrl','s'
	)
	
	--force both files save
	self:addkeybind(function()
			Levelmanager:savelevel(self.level,clevel,true)
			self.p:hurtpulse()
		end,
		'force both files save',
		'ctrl','alt','s'
	)
	
	
end)

function st:beattoradius(b)
	local currentbeat = 0
	return ((b - currentbeat)*self.zoom)+self.extend+self.length
	
end


function st:leave()
  entities = {}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end

function st:addkeybind(func,name,k1,k2,k3)
	table.insert(self.keybinds,{func = func, name = name, k1 = k1, k2 = k2, k3 = k3})
end

function st:checkkeybinds()
	for i,v in ipairs(self.keybinds) do
		if v.k1 and v.k2 and v.k3 then
			if maininput:down(v.k1) and maininput:down(v.k2) and maininput:pressed(v.k3) then
				print('pressed keybind ' .. v.name)
				v.func()
			end
		elseif v.k1 and v.k2 then
			if maininput:down(v.k1) and maininput:pressed(v.k2) then
				print('pressed keybind ' .. v.name)
				v.func()
			end
		else
			if maininput:pressed(v.k1) then
				print('pressed keybind ' .. v.name)
				v.func()
			end
		end
	end
end

st:setupdate(function(self,dt)
  if not paused then
		
		if self.editmode then
			self:checkkeybinds()
			
			if maininput:pressed("back") then
				self:leave()
				cs = bs.load('songselect')
				cs:init()
			end
			
		else
			self.gm:update(dt)
			
			--[[
			if maininput:pressed("back") then
				self:leave()
				cs = bs.load('songselect')
				cs:init()
			end
			]]--
		end
		
		
		
		
  end
end)



st:setfgdraw(function(self)

  color('white')
  love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
  love.graphics.setCanvas(self.canv)
  
	if self.editmode then
		self.gm:draw()
		
	else
	
	end
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canv)
  if pq ~= "" then
    print(helpers.round(self.cbeat*8,true)/8 .. pq)
  end

end)


return st
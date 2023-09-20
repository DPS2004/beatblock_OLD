local ricewine = {
  tweens = {},
  startbeat = 0,
  bpm = 100,
  functween = {x=0},
  queuedtweens = {}
}
ricewine.flux = dofile("lib/flux/flux.lua")
if not ricewine.flux then
  error('flux.lua not found!')
end

function ricewine:easenow(start,length,easefn,val,obj,param)
  if start < self.startbeat then
    obj[param] = val
  else
  
    start = (start - self.startbeat)
    length = length
    
    local kvtable = {}
    kvtable[param] = val
    table.insert(self.tweens,self.flux.to(obj, length, kvtable):ease(easefn):delay(start))
  end
end

function ricewine:funcnow(start,dofunc)
  if start < self.startbeat then
    dofunc()
  else
    start = (start - self.startbeat) 
    table.insert(self.tweens,self.flux.to(self.functween, 0, {x=0}):delay(start):onstart(dofunc))
  end
end

function ricewine:ease(start,length,easefn,val,obj,param)
  table.insert(self.queuedtweens,function() self:easenow(start,length,easefn,val,obj,param) end)
end

function ricewine:func(start,dofunc)
  table.insert(self.queuedtweens,function() self:funcnow(start,dofunc) end)
end

function ricewine:stopall()
  print('stopping')
  local deleted = 0
  for i=1, #self.tweens do
    v = self.tweens[i-deleted]
    if v._oncomplete then v._oncomplete = nil end
    if v._onstart then v._onstart = nil end
    v:stop()
    table.remove(self.tweens,i-deleted)
    deleted = deleted + 1
    print('removed a tween')
  end
end

function ricewine:update(beat)
  local deltabeat = beat - self.beat
  self.beat = beat
  self.flux.update(deltabeat)
  for i,v in ipairs(self.tweens) do
    if v.doremove then
      table.remove(self.tweens,i)
    end
  end
end

function ricewine:to(a,b,c)
  local newtween = self.flux.to(a,b,c)
  table.insert(self.tweens,newtween)
  return newtween
end

function ricewine:play(beat)
  
  self.startbeat = beat
  self.beat = beat


  for i,v in ipairs(self.queuedtweens) do
    v()
  end
  self.queuedtweens = {}
  self.startbeat = 0
end

return ricewine
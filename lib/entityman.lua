local em = {
  deep = deeper.init(),
  entities = {}
}


function em.new(fname,name)
  em.entities[name] = love.filesystem.load(fname)() -- this is a bad idea  
  print("made entity ".. name .." from " ..fname)
end

function em.init(en,kvtable)
  local succ, new = pcall(function() return em.entities[en]:new(kvtable) end)
  if not succ then
    print(new)
    error('tried to init entity named ' .. en ..', which did not exist')
  end

--  for k,v in pairs(kvtable) do
--    new[k] = v
--  end
--  new.name = en
  if (not new.skipupdate) or (not new.skiprender) then
    table.insert(entities,new)
    return entities[#entities]
  else
    return new
  end

 
end


function em.update(dt)
  
  
  for i,v in ipairs(entities) do
    if not v.skipupdate then
      if not paused then
        em.deep.queue(v.uplayer, em.update2, v, dt)
      elseif v.runonpause then
        em.deep.queue(v.uplayer, em.update2, v, dt)
      end
    end
  end
  em.deep.execute() -- OH MY FUCKING GOD IM SUCH A DINGUS
end


function em.draw()
  
  for i, v in ipairs(entities) do
    if not v.skiprender then

      em.deep.queue(v.layer, function() 
        if v.delete or v.skiprender then return end
        v:draw() 
      end)
      
    end
  end
  em.deep.execute()
	
	em.dodelete()
	
end

function em.dodelete()
	for i,v in ipairs(entities) do
    if v.delete then
      if v.onDelete then
        v:onDelete()
      end
      table.remove(entities, i)
    end
  end
end


function em.update2(v,dt)
  if v.skipupdate or v.delete then return end
  v:update(dt)
end


return em
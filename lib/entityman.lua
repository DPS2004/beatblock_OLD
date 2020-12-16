local em = {
  deep = deeper.init()
}

function em.init(en,x,y)
  local path = "obj/" .. en .. ".lua"
  local code = love.filesystem.load(path)
  local new = code()

  new.x = x
  new.y = y
  new.name = en
  table.insert(entities,new)

  return entities[#entities]
end


function em.update(dt)
  
  for i,v in ipairs(entities) do
    if not paused then
      em.deep.queue(v.uplayer, em.update2, v, dt)
    elseif v.runonpause then
      em.deep.queue(v.uplayer, em.update2, v, dt)
    end
  end
end


function em.draw()
  for i, v in ipairs(entities) do
    em.deep.queue(v.layer, v.draw)
  end
  em.deep.execute()
  for i,v in ipairs(entities) do
    if v.delete then
      table.remove(entities, i)
    end
  end
end


function em.update2(v,dt)
  v.update(dt)
end


return em
dpf = {}


function dpf.loadjson(f,w)
  print("dpf loading "..f)
  local cf = love.filesystem.read(f)
  if cf == nil then
    love.filesystem.createDirectory(helpers.rliid(f))
    print("trying to write a file cause it didnt exist")
    print(love.filesystem.write(f,json.encode(w)))
    cf = json.encode(w)
  end
  return json.decode(cf)
end

function dpf.savejson(f,w)
  love.filesystem.write(f,json.encode(w))
end


return dpf
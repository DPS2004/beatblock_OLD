local loc = {
  lang = "en",
  json=nil
}
function loc.load(j)
  loc.json = dpf.loadjson(j,{})
  print("localization file loaded")
end
function loc.setlang(l)
  loc.lang = l
  print("set language")
end
function loc.get(s)
  if loc.json[s][loc.lang] then
    return loc.json[s][loc.lang]
  else
    return(loc.lang .. "."..s)
  end
end
return loc
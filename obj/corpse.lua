local obj = {
  layer = -3,
  uplayer = 3,
  x=0,
  y=0,
  name = "corpse",
  width = 10,
  height = 10,
  hit=0,
  dead=false,
  delete=false,
  spr = ez.newanim(templates.corpse)
  
}


function obj.update(dt)
  ez.animupdate(obj.spr)
  if obj.spr.f == 12 then
    obj.delete = true
  end
  obj.layer = 0 - obj.y


  
end

function obj.draw()
  ez.animdraw(obj.spr,obj.x-5, obj.y-5)


end
return obj
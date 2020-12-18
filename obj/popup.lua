local obj = {
  layer = 100,
  uplayer = 9,
  x=screencenter.x,
  y=screencenter.y,
  w=100,
  h=100,
  text="Hello, world!",
  runonpause=true,
  buttons = {},
  samplebutton = {x=50,y=50,w=16,h=16,text="ok",onclick = function() end}
}


function obj.update(dt)
  if maininput:released("mouse1") then
    local mouseX = love.mouse.getX()/shuv.scale
    local mouseY = love.mouse.getY()/shuv.scale
    for i,v in ipairs(obj.buttons) do
      if helpers.collide({x=mouseX,y=mouseY,width=1,height=1},{x=v.x-v.w/2+(obj.x-obj.w/2),y=v.y-v.h/2+(obj.y-obj.h/2),width=v.w,height=v.h}) then
        v.onclick()
        
        --obj.delete=true
      end
    end
  end
end
function obj.newbutton(b)
  table.insert(obj.buttons,b)
end
function obj.draw()
  love.graphics.setColor(1,1,1,1)
  love.graphics.rectangle("fill",obj.x-obj.w/2,obj.y-obj.h/2,obj.w,obj.h)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("line",obj.x-obj.w/2,obj.y-obj.h/2,obj.w,obj.h)
  love.graphics.setFont(font2)
  love.graphics.printf(obj.text,obj.x-obj.w/2,obj.y-obj.h/2,obj.w,"center")
  love.graphics.setColor(1,1,1,1)
  --ok box
  for i, v in ipairs(obj.buttons) do
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill",v.x-v.w/2+(obj.x-obj.w/2),v.y-v.h/2+(obj.y-obj.h/2),v.w,v.h)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line",v.x-v.w/2+(obj.x-obj.w/2),v.y-v.h/2+(obj.y-obj.h/2),v.w,v.h)
    love.graphics.setFont(font2)
    love.graphics.printf(v.text,v.x-v.w/2+(obj.x-obj.w/2),v.y-v.h/2+(obj.y-obj.h/2),v.w,"center")
  end
end


return obj
local obj = {
  layer = 100,
  uplayer = 9,
  x=screencenter.x,
  y=screencenter.y,
  w=100,
  h=100,
  text="Hello, world!",
  runonpause=true,
  ok={x=50,y=50,w=16,h=16,show=true,onclick = function() end}
}


function obj.update(dt)
  if maininput:released("mouse1") then
    if obj.ok.show then
      local mouseX = love.mouse.getX()/shuv.scale
      local mouseY = love.mouse.getY()/shuv.scale
      if helpers.collide({x=mouseX,y=mouseY,width=1,height=1},{x=obj.ok.x-obj.ok.w/2+(obj.x-obj.w/2),y=obj.ok.y-obj.ok.h/2+(obj.y-obj.h/2),width=obj.ok.w,height=obj.ok.h}) then
        obj.ok.onclick()
        
        obj.delete=true
      end
    end
  end
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
  if obj.ok.show then
    love.graphics.rectangle("fill",obj.ok.x-obj.ok.w/2+(obj.x-obj.w/2),obj.ok.y-obj.ok.h/2+(obj.y-obj.h/2),obj.ok.w,obj.ok.h)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line",obj.ok.x-obj.ok.w/2+(obj.x-obj.w/2),obj.ok.y-obj.ok.h/2+(obj.y-obj.h/2),obj.ok.w,obj.ok.h)
    love.graphics.setFont(font2)
    love.graphics.printf("ok",obj.ok.x-obj.ok.w/2+(obj.x-obj.w/2),obj.ok.y-obj.ok.h/2+(obj.y-obj.h/2),obj.ok.w,"center")
  end
end


return obj
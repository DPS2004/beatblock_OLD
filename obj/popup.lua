local obj = {
  layer = 100,
  uplayer = 9,
  x=screencenter.x,
  y=screencenter.y,
  w=100,
  h=100,
  text="Hello, world!"
}


function obj.update(dt)

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

end


return obj
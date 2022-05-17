function popup()
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
    textinput = {text="",y=50,show=false,numberonly=true},
    samplebutton = {x=50,y=50,w=16,h=16,text="ok",onclick = function() end}
  }
  tinput = ""
  
  function obj.update(dt)
    if obj.textinput.show then
      --print(tinput)
      if obj.textinput.numberonly then
        if (tonumber(tinput) ~= nil or tinput == ".") or (obj.textinput.allowminus and tinput == "-") then
          obj.textinput.text = obj.textinput.text.. tinput
        end
      else
        obj.textinput.text = obj.textinput.text.. tinput
      end
      if maininput.pressed("backspace") then -- copied from https://love2d.org/wiki/utf8
        -- TODO
        -- local byteoffset = utf8.offset(obj.textinput.text, -1)
        -- if byteoffset then
        --   obj.textinput.text = string.sub(obj.textinput.text, 1, byteoffset - 1)
        -- end
      end
    end
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
    love.graphics.setFont(Axolotl12)
    love.graphics.printf(obj.text,obj.x-obj.w/2,obj.y-obj.h/2,obj.w,"center")
    if obj.textinput.show then
      love.graphics.printf(obj.textinput.text,obj.x-obj.w/2,(obj.y-obj.h/2)+obj.textinput.y,obj.w,"center")
      --print(obj.textinput.text)
    end
    love.graphics.setColor(1,1,1,1)
  
    --ok box
    for i, v in ipairs(obj.buttons) do
      love.graphics.setColor(1,1,1,1)
      love.graphics.rectangle("fill",v.x-v.w/2+(obj.x-obj.w/2),v.y-v.h/2+(obj.y-obj.h/2),v.w,v.h)
      love.graphics.setLineWidth(1)
      love.graphics.setColor(0,0,0,1)
      love.graphics.rectangle("line",v.x-v.w/2+(obj.x-obj.w/2),v.y-v.h/2+(obj.y-obj.h/2),v.w,v.h)
      love.graphics.setFont(Axolotl12)
      love.graphics.printf(v.text,v.x-v.w/2+(obj.x-obj.w/2),v.y-v.h/2+(obj.y-obj.h/2),v.w,"center")
    end
  end
  
  return obj
end

return popup
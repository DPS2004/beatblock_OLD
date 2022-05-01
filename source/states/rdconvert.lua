local st = {}
function st.init()

end


function st.enter(prev)
  st.canv = love.graphics.newCanvas(gameWidth,gameHeight)
  local rdstr = helpers.read("rd/level.rdlevel")
  rdstr = rdstr:sub(4) -- BEGONE, ∩╗┐
  st.rdin = json.decode(rdstr)
  st.level = {offset = 8,speed=40,events={}}
  for i,v in ipairs(st.rdin.events) do
    if v.type == "MoveRow" then
      local ty = nil
      if v.row == 0 then
        ty = "beat"
      elseif v.row == 1 then
        ty = "inverse"
      end
      table.insert(st.level.events,{type=ty,time=(v.beat-1)+(v.bar-1)*8,angle=v.angle,speedmult =v.scale[1]})

    end
    if v.type == "PlaySong" then
      table.insert(st.level.events,{type="play",time=(v.beat-1)+(v.bar-1)*8,file=v.filename})
      st.level.bpm = v.bpm
    end
    if v.type == "Comment" then
      print(v.text)
      local newevent = json.decode(v.text)
      newevent.time = (v.beat-1)+(v.bar-1)*8
      table.insert(st.level.events,newevent)
    end

  end
  helpers.write("output.json",json.encode(st.level))
  clevel = "output.json"
  helpers.swap(states.game)
end


function st.leave()

end


function st.resume()

end


function st.update()
  pq = ""
  if not paused then
    if maininput.pressed("back") then
      helpers.swap(states.songselect)
    end

    flux.update(1)
    em.update(dt)
  end
end


function st.draw()
  shuv.start()

  love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)
  love.graphics.setCanvas(st.canv)



    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)



    em.draw()
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
  end
  shuv.finish()

end


return st
local obj = {
  layer = 0,
  uplayer = 0,
  spr = {
    idle = love.graphics.newImage("assets/game/cranky/idle.png"),
    happy = love.graphics.newImage("assets/game/cranky/happy.png"),
    miss = love.graphics.newImage("assets/game/cranky/miss.png")
  },
  x=0,
  y=0,
  bobi=0,
  angle = 0,
  extend = 0,
  paddle_size = 70,
  handle_size = 15,
  paddle_width = 10,
  paddle_distance = 25,
  cmode = true,
  cemotion = "idle",
  emotimer = 0
}


function obj.update(dt)
  obj.emotimer = obj.emotimer - 1
  if obj.emotimer <= 0 then
    obj.cemotion = "idle"
  end
  if maininput:pressed("a") then
    obj.cmode = not obj.cmode
  end
  if not cs.autoplay then
    if obj.cmode then
      obj.angle = 0-math.deg(math.atan2(obj.y - love.mouse.getY()/shuv.scale, love.mouse.getX()/shuv.scale - obj.x)) +90
    else
      if maininput:down("left") then
        obj.angle = obj.angle - 7
      elseif maininput:down("right") then
        obj.angle = obj.angle + 7
      end
    end
  end
  obj.bobi = obj.bobi + 0.03
end

function obj.draw()
  love.graphics.setLineWidth(2)
  helpers.color(2)

  -- draw the paddle
  love.graphics.push()
    love.graphics.translate(obj.x, obj.y)
    love.graphics.rotate((obj.angle - 90) * math.pi / 180)

    -- draw the lines connecting the player to the paddle
    love.graphics.line(
      0, 0,
      (obj.paddle_distance + cs.extend) * math.cos(obj.handle_size * math.pi / 180),
      (obj.paddle_distance + cs.extend) * math.sin(obj.handle_size * math.pi / 180)
    )
    love.graphics.line(
      0, 0,
      (obj.paddle_distance + cs.extend) * math.cos(-obj.handle_size * math.pi / 180),
      (obj.paddle_distance + cs.extend) * math.sin(-obj.handle_size * math.pi / 180)
    )

    -- draw the paddle
    local paddle_angle = obj.paddle_size / 2 * math.pi / 180
    love.graphics.arc('line', 'open', 0, 0, (obj.paddle_distance + cs.extend), paddle_angle, -paddle_angle)
    love.graphics.arc('line', 'open', 0, 0, (obj.paddle_distance + cs.extend) + obj.paddle_width, paddle_angle, -paddle_angle)
    love.graphics.line(
      (obj.paddle_distance + cs.extend) * math.cos(paddle_angle),
      (obj.paddle_distance + cs.extend) * math.sin(paddle_angle),
      ((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.cos(paddle_angle),
      ((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.sin(paddle_angle)
    )
    love.graphics.line(
      (obj.paddle_distance + cs.extend) * math.cos(-paddle_angle),
      (obj.paddle_distance + cs.extend) * math.sin(-paddle_angle),
      ((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.cos(-paddle_angle),
      ((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.sin(-paddle_angle)
    )
  love.graphics.pop()

  helpers.color(1)
  love.graphics.circle("fill",obj.x,obj.y,16+cs.extend/2+(math.sin(obj.bobi))/2)
  helpers.color(2)
  love.graphics.circle("line",obj.x,obj.y,16+cs.extend/2+(math.sin(obj.bobi))/2)

  helpers.color(1)
  love.graphics.draw(obj.spr[obj.cemotion],obj.x,obj.y,0,1,1,16,16)
end


return obj
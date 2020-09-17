local obj = {
  layer = 0,
  uplayer = 0,
  spr1 = love.graphics.newImage("assets/game/circle.png"),
  spr2 = love.graphics.newImage("assets/game/paddle.png"),
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
}


function obj.update(dt)
  if maininput:pressed("a") then
    obj.cmode = not obj.cmode
  end
  if obj.cmode then
    obj.angle = 0-math.deg(math.atan2(obj.y - love.mouse.getY()/shuv.scale, love.mouse.getX()/shuv.scale - obj.x)) +90
  else
    if maininput:down("left") then
      obj.angle = obj.angle - 7
    elseif maininput:down("right") then
      obj.angle = obj.angle + 7
    end
  end

  obj.bobi = obj.bobi + 0.05
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
      obj.paddle_distance * math.cos(obj.handle_size * math.pi / 180),
      obj.paddle_distance * math.sin(obj.handle_size * math.pi / 180)
    )
    love.graphics.line(
      0, 0,
      obj.paddle_distance * math.cos(-obj.handle_size * math.pi / 180),
      obj.paddle_distance * math.sin(-obj.handle_size * math.pi / 180)
    )

    -- draw the paddle
    local paddle_angle = obj.paddle_size / 2 * math.pi / 180
    love.graphics.arc('line', 'open', 0, 0, obj.paddle_distance, paddle_angle, -paddle_angle)
    love.graphics.arc('line', 'open', 0, 0, obj.paddle_distance + obj.paddle_width, paddle_angle, -paddle_angle)
    love.graphics.line(
      obj.paddle_distance * math.cos(paddle_angle),
      obj.paddle_distance * math.sin(paddle_angle),
      (obj.paddle_distance + obj.paddle_width) * math.cos(paddle_angle),
      (obj.paddle_distance + obj.paddle_width) * math.sin(paddle_angle)
    )
    love.graphics.line(
      obj.paddle_distance * math.cos(-paddle_angle),
      obj.paddle_distance * math.sin(-paddle_angle),
      (obj.paddle_distance + obj.paddle_width) * math.cos(-paddle_angle),
      (obj.paddle_distance + obj.paddle_width) * math.sin(-paddle_angle)
    )
  love.graphics.pop()

  helpers.color(1)
  love.graphics.draw(obj.spr1,obj.x,obj.y+(math.sin(obj.bobi)*2),0,1,1,16,16)
end


return obj
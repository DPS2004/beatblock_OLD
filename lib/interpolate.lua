function helpers.interpolate(a, b, t, easeshape, easetype)
  easetype = easetype or "linear"
  easedir = easetyle or "in"
  q = nil

  if easetype == "in" then
    t = t

  elseif easetype == "out" then
    t = 1 - t

  elseif t ~= 0.5 then

    if easetype == "inout" then
      if t < 0.5 then
        t = 2 * t
      elseif t > 0.5 then
        t = 2 - (2 * t)
      end

    elseif easetype == "outin" then
      if t < 0.5 then
        t = 1 - (2 * t)
      elseif t > 0.5 then
        t = (2 * t) - 1
      end
    end
  end

  --the ease shapes, feel free to add more though these should be enough for most purposes
  if easeshape == "linear" then
    q = t
  end
  if easeshape == "quad" then
    q = t ^ 2
  end
  if easeshape == "cubic" then
    q = t ^ 3
  end
  if easeshape == "quart" then
    q = t ^ 4
  end
  if easeshape == "quint" then
    q = t ^ 5
  end
  if easeshape == "expo" then
    q = 2 ^ (10 * (t - 1))
  end
  if easeshape == "sine" then
    q = -math.cos(t * (math.pi * 0.5)) + 1
  end
  if easeshape == "circ" then
    q = -(math.sqrt(1 - (t ^ 2)) - 1)
  end
  if easeshape == "back" then
    q = (t ^ 2) * ((2.7 * t) - 1.7)
  end
  if easeshape == "elastic" then
    q = -(2 ^ (10 * (t - 1)) * math.sin((t - 1.075) * (math.pi * 2) / 0.3))
  end

  if easetype == "in" then
    return a + (b - a) * q

  elseif easetype == "out" then
    return a + (b - a) * (1 - q)

  elseif t == 0.5 then
    return 0.5

  --I don't really have an explanation for these two apart from "I messed around in desmos until it looked right"
  elseif easetype = "inout" then
    if q < 0.5 then
      return q
    elseif q > 0.5 then
      return 1 - q
    end

  elseif easetype = "outin" then
    if q < 0.5 then
      return 1 - q
    elseif q > 0.5 then
      return q
    end
  end
end
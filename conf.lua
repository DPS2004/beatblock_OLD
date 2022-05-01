function love.conf(t)
  release = true
  ismobile = false
  mobileoverride = false
  
  t.externalstorage = true
  is3ds = false
  gameWidth, gameHeight = 400,240 -- WARNING: SETTING THESE TO ANYTHING OTHER THAN 400,240 MAY CAUSE UNDESIRED EFFECTS!!!
  windowWidth, windowHeight = 400,240
  t.window.usedpiscale = false
  if not release then
    --t.console = true
  end
  t.window.width = 400
  t.window.height = 240 
end

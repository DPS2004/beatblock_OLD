function love.conf(t)
  release = true
  ismobile = false
  mobileoverride = false
  t.externalstorage = true
  gameWidth, gameHeight = 400,240 -- WARNING: SETTING THESE TO ANYTHING OTHER THAN 400,240 MAY CAUSE UNDESIRED EFFECTS!!!
  windowWidth, windowHeight = 800, 480
  t.window.usedpiscale = false
  if not release then
    t.console = true
  end
  t.window.width = 800
  t.window.height = 480 
end

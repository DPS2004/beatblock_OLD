function love.conf(t)
  release = true
  ismobile = false
  mobileoverride = false
  t.window.usedpiscale = false
  if not release then
    t.console = true
  end
  t.window.width = 800
  t.window.height = 480 
end
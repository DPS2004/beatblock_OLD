local shaders = {}

shaders.videoshader = love.graphics.newShader('assets/shaders/videoshader.glsl')
shaders.palshader = love.graphics.newShader('assets/shaders/palshader.glsl')
shaders.outline = love.graphics.newShader('assets/shaders/outline.glsl')

return shaders
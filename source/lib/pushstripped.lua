-- push.lua v0.3

-- Copyright (c) 2018 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



local push = {

}


function push:applySettings(settings)

end

function push:resetSettings()

end

function push:setupScreen(WWIDTH, WHEIGHT, RWIDTH, RHEIGHT, settings)

end

function push:setupCanvas(canvases)

end

function push:apply(operation, shader)

end

function push:start()

end

function push:applyShaders(canvas, shaders)

end


function push:setBorderColor(color, g, b)

end

function push:toGame(x, y)

end

--doesn't work - TODO
function push:toReal(x, y)
end



function push:switchFullscreen(winw, winh)

end

function push:resize(w, h)

end

function push:getWidth()  end
function push:getHeight()   end
function push:getDimensions()  end

return push
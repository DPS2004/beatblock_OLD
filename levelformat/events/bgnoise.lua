local info = {
	event = 'bgnoise',
	name = 'BG noise',
	storeinchart = false,
	description = [[Parameters:
time: Beat to activate on
enable: Turn on/off noise. if false, all following arguments are optional
filename: Noise image to load
r:
g:
b:
a: RGBA values, from 0 to 1
]]
}


--onload, onoffset, onbeat
local function onload(event)
	if event.enable then
		cs.noisecache = cs.bgcache or {}
		cs.noisecache[event.filename] = love.graphics.newImage("assets/game/noise/" .. event.filename)
		pq = pq.. '     loaded noise '  .. event.filename
	end
end

local function onbeat(event)
	cs.vfx.bgnoise.enable = event.enable
	if event.enable then
		cs.vfx.bgnoise.image = cs.noisecache[event.filename]
		cs.vfx.bgnoise.r = event.r or cs.vfx.bgnoise.r
		cs.vfx.bgnoise.g = event.g or cs.vfx.bgnoise.g
		cs.vfx.bgnoise.b = event.b or cs.vfx.bgnoise.b
		cs.vfx.bgnoise.a = event.a or cs.vfx.bgnoise.a
		
		pq = pq .. "    ".. "BG Noise enabled with filename of " .. event.filename
	else
		pq = pq .. "    ".. "BG Noise disabled"
	end
end


return info, onload, onoffset, onbeat
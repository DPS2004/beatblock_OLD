local info = {
	event = 'setbg',
	name = 'Set BG',
	storeinchart = false,
	description = [[Parameters:
time: Beat to show on
file: BG image to load
]]
}


--onload, onoffset, onbeat
local function onload(event)
	cs.bgcache = cs.bgcache or {}
	cs.bgcache[event.file] = love.graphics.newImage("assets/bgs/".. event.file)
	pq = pq.. '     loaded bg '  .. event.file
end

local function onbeat(event)
	cs.bg = cs.bgcache[event.file]
	pq = pq.. "     set bg to " .. event.file
end


return info, onload, onoffset, onbeat
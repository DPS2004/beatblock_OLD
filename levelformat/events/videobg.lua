local info = {
	event = 'videobg',
	name = 'Play Videobg',
	description = [[Parameters:
time: Beat to start playing video
file: Filename of video, MUST BE OGV
]]
}

--onload, onoffset, onbeat
local function onload(event)
	cs.videobg = love.graphics.newVideo(clevel..event.file)
	pq = pq .. "      loaded videobg"
end

local function onbeat(event)
	pq = pq .. "    ".. "playing videobg"
	cs.drawvideobg = true
	cs.videobg:play()
	
end


return info, onload, onoffset, onbeat
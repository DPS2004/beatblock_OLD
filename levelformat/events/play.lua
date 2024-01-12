local info = {
	event = 'play',
	name = 'Play song',
	storeinchart = false,
	description = [[Parameters:
time: Beat to start playing song
file: Filename of song 
bpm: BPM of song
]]
}

--onload, onoffset, onbeat
local function onload(event)
	cs.level.bpm = event.bpm
	cs.sounddata = love.sound.newSoundData(clevel..event.file)
	pq = pq .. "      loaded sounddata"
end

local function onbeat(event)
	cs.source = lovebpm.newTrack()
		:load(cs.sounddata)
		:setBPM(event.bpm)
		:setLooping(false)
		:play()
		:on("end", function(f) print("song finished!!!!!!!!!!") cs.gm.songfinished = true end)
	cs.songoffset = event.time
	cs.source:setBeat(cs.cbeat - event.time)
	pq = pq .. "    ".. "now playing ".. event.file
	
end

local function editordraw(event)
	local pos = cs:getposition(event.angle,event.time)
	
	love.graphics.draw(sprites.editor.events.play,pos[1],pos[2],0,1,1,8,8)
end

local function editorproperties(event)
	Event.property(event,'string', 'file', 'Filename of song')
	Event.property(event,'decimal', 'bpm', 'BPM of song', {step = 1})
end

return info, onload, onoffset, onbeat, editordraw, editorproperties
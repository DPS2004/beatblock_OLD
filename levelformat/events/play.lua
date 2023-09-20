local info = {
	event = 'play',
	name = 'Play song',
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
		:on("end", function(f) print("song finished!!!!!!!!!!") self.songfinished = true end)
	cs.songoffset = event.time
	cs.source:setBeat(cs.cbeat - event.time)
	pq = pq .. "    ".. "now playing ".. event.file
	
end


return info, onload, onoffset, onbeat
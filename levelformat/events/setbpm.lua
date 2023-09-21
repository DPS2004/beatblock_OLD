local info = {
	event = 'setbpm',
	name = 'Set BPM',
	description = [[Parameters:
time: Beat to change BPM on
bpm: The BPM to change to
]]
}

--onload, onoffset, onbeat
local function onbeat(event) --...unsure if this works with scrubbing at all?
	cs.level.bpm = event.bpm
	cs.source:setBPM(event.bpm, event.time)
	pq = pq .. "    set bpm to "..event.bpm .. " !!"
end


return info, onload, onoffset, onbeat
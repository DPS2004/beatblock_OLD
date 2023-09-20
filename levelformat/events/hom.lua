local info = {
	event = 'hom',
	name = 'Hall of Mirrors',
	description = [[Parameters:
time: Beat to toggle HOM on
enable: Turns on/off HOM
]]
}

--onload, onoffset, onbeat
local function onbeat(event)
	cs.vfx.hom = event.enable

	if event.enable then
		pq = pq .. "    ".. "Hall Of Mirrors enabled"
	else
		pq = pq .. "    ".. "Hall Of Mirrors disabled"
	end
end


return info, onload, onoffset, onbeat
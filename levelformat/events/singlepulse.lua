local info = {
	event = 'singlepulse',
	name = 'Pulse',
	storeinchart = false,
	description = [[Parameters:
time: Beat to pulse on
intensity: (Optional) How far out to pulse, defaults to 10.
]]
}

--onload, onoffset, onbeat
local function onbeat(event)
	pq = pq.. "    pulsing"
	cs.extend = event.intensity or 10
	flux.to(cs,10,{extend=0}):ease("linear")
end


return info, onload, onoffset, onbeat
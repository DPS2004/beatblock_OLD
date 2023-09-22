local info = {
	event = 'multipulse',
	name = 'Multipulse',
	storeinchart = false,
	description = [[Parameters:
time: Beat to start pulsing
reps: How many extra pulses
delay: Time between pulses
intensity: (Optional) How far out to pulse, defaults to 10.
]]
}

--onload, onoffset, onbeat
local function onbeat(event)
	pq = pq.. "    pulsing, generating other pulses"
	cs.extend = event.intensity or 10
	flux.to(cs,10,{extend=0}):ease("linear")
	for i=1,event.reps do
		table.insert(cs.playevents,{type="singlepulse",time=event.time+event.delay*i,intensity=event.intensity})
	end
end


return info, onload, onoffset, onbeat
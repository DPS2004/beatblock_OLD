local info = {
	event = 'width',
	name = 'Set Width',
	description = [[Parameters:
time: Beat to start width change
newwidth: New width to ease to
duration: Length of ease (in 1/60th of seconds, will get changed to beats at some point)
ease: (Optional) Ease function to use
]]
}

--onload, onoffset, onbeat
local function onbeat(event)
	local e = event.ease or 'linear'
	flux.to(cs.p,event.duration,{paddle_size=event.newwidth}):ease(e)
	pq = pq.. "    width set to " .. event.newwidth
end


return info, onload, onoffset, onbeat
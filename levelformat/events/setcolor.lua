local info = {
	event = 'setcolor',
	name = 'Set color',
	storeinchart = false,
	description = [[Parameters:
time: Beat to show on
color: color index
r (Optional): red value 
g (Optional): green value
b (Optional): blue value
duration (Optional): length of ease
ease (Optional): ease to use
]]
}


--onload, onoffset, onbeat

local function onload(event)
	local duration = event.duration or 0
	local ease = event.ease or 'linear'
	rw:ease(event.time,duration,ease,{r = event.r, g = event.g, b = event.b},shuv.pal[event.color])
end


return info, onload, onoffset, onbeat
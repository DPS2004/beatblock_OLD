local info = {
	event = 'setbgcolor',
	name = 'Set BG color',
	storeinchart = false,
	description = [[Parameters:
time: Beat to show on
color: Color name or index
]]
}


--onload, onoffset, onbeat

local function onbeat(event)
	cs.bgcolor = tonumber(event.color) or event.color
	pq = pq.. "     set bgcolor to " .. event.color
end


return info, onload, onoffset, onbeat
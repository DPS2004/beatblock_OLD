local info = {
	event = 'template',
	name = '_TEMPLATE',
	storeinchart = false,
	description = [[Parameters:
time: Beat
]]
}

--onload, onoffset, onbeat
local function onload(event)
	print('template event called')
end


return info, onload, onoffset, onbeat
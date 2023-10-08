local info = {
	event = 'outline',
	name = 'Outline',
	storeinchart = false,
	description = [[Parameters:
time: Beat to show on
enable (Optional): Show outline
color: Color index
]]
}


local function onbeat(event)
	if event.enable == false then
		cs.outline = -1
		pq = pq.. "     disabled outline "
	else
		cs.outline = event.color
		pq = pq.. "     set outline to "..cs.outline
	end
end


return info, onload, onoffset, onbeat
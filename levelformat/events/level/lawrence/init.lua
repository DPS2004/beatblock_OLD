local info = {
	event = 'lawrence_init',
	name = 'Lawrence Init',
	storeinchart = false,
	description = [[Parameters:
time: Beat to show on
]]
}


--onload, onoffset, onbeat
local function onload(event)
	cs.lawrencebg = em.init('lawrencebg',{x=project.res.cx,y=project.res.cy})
end



return info, onload, onoffset, onbeat
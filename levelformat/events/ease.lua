local info = {
	event = 'ease',
	name = 'Ease',
	storeinchart = false,
	description = [[Parameters:
time: Beat to start
var: Variable to ease (must be a child of cs)
start (Optional): Starting value
value: End value
duration (Optional): length of ease
ease (Optional): ease to use
]]
}


--onload, onoffset, onbeat

local function onload(event)
	local duration = event.duration or 0
	local ease = event.ease or 'linear'
	
	local var = cs
	local varsplit = {}
	
	for v in string.gmatch(event.var,"([^.]+)") do
		table.insert(varsplit,v)
	end
	
	for i,v in ipairs(varsplit) do
		if var[v] then
			if i ~= #varsplit then
				var = var[v]
			end
		else
			error("Couldnt find key '" .. v .. "' in cs."..event.var)
		end
	end
	
	param = varsplit[#varsplit]
	
	if duration == 0 then
		rw:func(event.time,function() var[param] = event.value end)
		return
	end
	

	
	
	rw:ease(event.time,duration,ease,event.value,var,param,event.start)
end


return info, onload, onoffset, onbeat
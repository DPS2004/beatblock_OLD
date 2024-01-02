local info = {
	event = 'beat',
	name = 'Spawn Block (LEGACY)',
	storeinchart = true,
	hits = 1,
	description = [[Parameters:
time: Beat to spawn on
angle: Angle to spawn at
endangle: (Optional) Angle to end up at
spinease: (Optional) Ease to use while rotating
speedmult: (Optional) Speed multiplier for approach
]]
}

--onload, onoffset, onbeat
local function onoffset(event)
	Event.onoffset['block'](event)
	
end


return info, onload, onoffset, onbeat
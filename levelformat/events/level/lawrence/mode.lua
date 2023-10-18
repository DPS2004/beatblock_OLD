local info = {
	event = 'lawrence_mode',
	name = 'Lawrence Mode',
	storeinchart = false,
	description = [[Parameters:
time: Beat to set mode on
followplayer: Whether the player is followed or not
]]
}


--onload, onoffset, onbeat
local function onload(event)
	--cs.lawrencebg
	local startval = 1
	local endval = 0
	if event.followplayer then
		startval = 0
		endval = 1
		rw:func(event.time, function() cs.lawrencebg:resetplayerrot() end)
	end
	Event.onload.ease({
		time = event.time,
		var = 'lawrencebg.rotatemix',
		start = startval,
		value = endval,
		duration = 4,
		ease = 'outExpo'
	})
	
end



return info, onload, onoffset, onbeat
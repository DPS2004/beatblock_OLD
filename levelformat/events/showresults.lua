local info = {
	event = 'showresults',
	name = 'Show Results',
	storeinchart = false,
	description = [[Parameters:
time: Beat to show results on
]]
}

--onload, onoffset, onbeat
local function onbeat(event)
	flux.to(cs.p,60,{ouchpulse=300,lookradius=0}):ease("inExpo"):oncomplete(function(f) 
		cs:gotoresults()
	end)
end


return info, onload, onoffset, onbeat
local info = {
	event = 'minehold',
	name = 'Spawn Minehold',
	storeinchart = true,
	description = [[Parameters:
time: Beat to spawn on
angle1: First Angle to spawn at
angle2: Second Angle to spawn at
duration: How many beats the Minehold will last
segments: (Optional) Force a certain number of line segments
holdease: (Optional) Change ease from angle1 to angle2
endangle: (Optional) First Angle to end up at
spinease: (Optional) Ease to use while rotating
speedmult: (Optional) Speed multiplier for approach
]]
}

--onload, onoffset, onbeat
local function onoffset(event)
	
	local newbeat = em.init("minehold",{
		x = project.res.cx,
		y = project.res.cy,
		segments = event.segments,
		duration = event.duration,
		holdease = event.holdease,
		angle = event.angle1,
		angle2 = event.angle2,
		endangle = event.endangle,
		spinease = event.spinease,
		hb = event.time,
		smult = event.speedmult
	})
	pq = pq .. "    ".. "minehold spawn here!"
	newbeat:update(dt)
	
end


return info, onload, onoffset, onbeat
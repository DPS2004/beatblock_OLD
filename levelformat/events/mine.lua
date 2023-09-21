local info = {
	event = 'mine',
	name = 'Spawn Mine',
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
	
	local newbeat = em.init("mine",{
		x=project.res.cx,
		y=project.res.cy,
		angle = event.angle,
		endangle = event.endangle,
		spinease = event.spinease,
		hb = event.time,
		smult = event.speedmult
	})
	pq = pq .. "    ".. "mine here!"
	newbeat:update(dt)
	
end


return info, onload, onoffset, onbeat
local info = {
	event = 'minehold',
	name = 'Minehold',
	storeinchart = true,
	hits = 1,
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

local function editordraw(event)
	--todo: actual hold drawing logic
	local pos = cs:getposition(event.angle,event.time)
	
	love.graphics.draw(sprites.note.minehold,pos[1],pos[2],0,1,1,8,8)
end


return info, onload, onoffset, onbeat, editordraw, editorproperties
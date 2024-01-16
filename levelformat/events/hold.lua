local info = {
	event = 'hold',
	name = 'Hold',
	storeinchart = true,
	hits = 1,
	description = [[Parameters:
time: Beat to spawn on
angle: First Angle to spawn at
angle2: Second Angle to spawn at
duration: How many beats the Hold will last
segments: (Optional) Force a certain number of line segments
holdease: (Optional) Change ease from angle1 to angle2
endangle: (Optional) First Angle to end up at
spinease: (Optional) Ease to use while rotating
speedmult: (Optional) Speed multiplier for approach
]]
}

--onload, onoffset, onbeat
local function onoffset(event)
	
	local newbeat = em.init("hold",{
		x = project.res.cx,
		y = project.res.cy,
		segments = event.segments,
		duration = event.duration,
		holdease = event.holdease,
		angle = event.angle,
		angle2 = event.angle2,
		endangle = event.endangle,
		spinease = event.spinease,
		hb = event.time,
		smult = event.speedmult
	})
	pq = pq .. "    ".. "hold spawn here!"
	newbeat:update(dt)
	
end

local function editordraw(event)
	--todo: actual hold drawing logic
	local pos = cs:getposition(event.angle,event.time)
	
	love.graphics.draw(sprites.note.hold,pos[1],pos[2],0,1,1,8,8)
	if not event.iscursor then
		pos = cs:getposition(event.angle2,event.time+event.duration)
		
		love.graphics.draw(sprites.note.hold,pos[1],pos[2],0,1,1,8,8)
	end
end

local function editorproperties(event)
	
	Event.property(event,'decimal', 'angle2', 'Angle for end of the hold', {step = cs:getanglestep(), default = event.angle})
	Event.property(event,'decimal', 'duration', 'How many beats the hold lasts', {step = cs:getbeatstep(), default = 1})

	
	
	Event.property(event,'int', 'segments', 'Force a certain number of line segments', {optional = true, default = 1})
	Event.property(event,'ease', 'holdease', 'Change ease from angle1 to angle2', {optional = true, default = 'linear'})
	Event.property(event,'decimal', 'endangle', 'Angle to end up at', {step = cs:getanglestep(), optional = true, default = 0})
	Event.property(event,'ease', 'spinease', 'Ease to use while rotating', {optional = true, default = 'linear'})
	Event.property(event,'decimal', 'speedmult', 'Speed multiplier for approach', {step = 0.01, optional = true, default = 1})
end


return info, onload, onoffset, onbeat, editordraw, editorproperties
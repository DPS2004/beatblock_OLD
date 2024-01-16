local info = {
	event = 'inverse',
	name = 'Inverse Block',
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
	
	local newbeat = em.init("block",{
		x=project.res.cx,
		y=project.res.cy,
		angle = event.angle,
		endangle = event.endangle,
		spinease = event.spinease,
		hb = event.time,
		smult = event.speedmult,
		inverse = true
	})
	pq = pq .. "    ".. "spawn here!"
	newbeat:update(dt)
	
end


local function editordraw(event)
	local pos = cs:getposition(event.angle,event.time)
	
	love.graphics.draw(sprites.note.inverse,pos[1],pos[2],0,1,1,8,8)
end

local function editorproperties(event)
	Event.property(event,'decimal', 'endangle', 'Angle to end up at', {step = cs:getanglestep(), optional = true, default = 0})
	Event.property(event,'ease', 'spinease', 'Ease to use while rotating', {optional = true, default = 'linear'})
	Event.property(event,'decimal', 'speedmult', 'Speed multiplier for approach', {step = 0.01, optional = true, default = 1})
end


return info, onload, onoffset, onbeat, editordraw, editorproperties
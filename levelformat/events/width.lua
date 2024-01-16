local info = {
	event = 'width',
	name = 'Set Width',
	storeinchart = false,
	description = [[Parameters:
time: Beat to start width change
newwidth: New width to ease to
duration: Length of ease (in 1/60th of seconds, will get changed to beats at some point)
ease: (Optional) Ease function to use
]]
}

--onload, onoffset, onbeat
local function onbeat(event)
	local e = event.ease or 'linear'
	flux.to(cs.p,event.duration,{paddle_size=event.newwidth}):ease(e)
	pq = pq.. "    width set to " .. event.newwidth
end


local function editordraw(event)
	local pos = cs:getposition(event.angle,event.time)
	
	love.graphics.draw(sprites.editor.events.width,pos[1],pos[2],0,1,1,8,8)
end

local function editorproperties(event)
	Event.property(event,'int', 'newwidth', 'New width to ease to', {default = 70})
	Event.property(event,'decimal', 'duration', 'Length of ease (in 1/60th of seconds, will get changed to beats at some point)', {default = 60})
	Event.property(event,'ease', 'ease', 'Ease function to use', {optional = true, default = 'linear'})
end


return info, onload, onoffset, onbeat, editordraw, editorproperties
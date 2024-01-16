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
	flux.to(cs.p,60,{bodypulse=300,lookradius=0}):ease("inExpo"):oncomplete(function(f) 
		cs:gotoresults()
	end)
end


local function editordraw(event)
	local pos = cs:getposition(event.angle,event.time)
	
	love.graphics.draw(sprites.editor.events.showresults,pos[1],pos[2],0,1,1,8,8)
end

return info, onload, onoffset, onbeat, editordraw, editorproperties
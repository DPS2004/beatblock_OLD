Levelmanager = class('Levelmanager',Entity)

local currentversion = 1

function Levelmanager:initialize(params)
	
	self.skiprender = true
	self.skipupdate = true
  self.layer = 1
  self.uplayer = -9999
  self.x=0
  self.y=0
	
  Entity.initialize(self,params)
	
end

function Levelmanager:loadlevel(filename)
	filename = filename or clevel
	
	local level = dpf.loadjson(filename .. "level.json")
	local chart = nil
	if level.properties.formatversion then
		if level.properties.formatversion >= 1 then
			chart = dpf.loadjson(clevel .. "chart.json")
		end
	end
	
	if chart then
		for i,v in ipairs(chart) do
			table.insert(level.events,v)
		end
	end
	
	return level
	
end

function Levelmanager:upgradelevel(level)
	
	local upgraded = (level.properties.formatversion ~= currentversion)
	if level.properties.formatversion == nil then
		level.properties.formatversion = 1
	end
	--[[
	if level.properties.formatversion == 1 then
		--format 2 goes here, etc, etc
	end
	]]--
	return level, upgraded -- return if it got upgraded to force savebothfiles
	
	
	
end

function Levelmanager:savelevel(level,filename,savebothfiles)
	filename = filename or clevel
	
	local upgraded = nil
	level, upgraded = self:upgradelevel(level)
	
	savebothfiles = savebothfiles or upgraded
	
	local level_export = {}
	level_export.properties = level.properties
	level_export.metadata = level.metadata
	level_export.events = {}
	
	local chart_export = {}
	
	for i,v in ipairs(level.events) do
		--just in case
    v.play_onload = nil
		v.play_onoffset = nil
		v.play_onbeat = nil
		
		if Event.info[v.type].storeinchart then
			table.insert(chart_export, v)
		else
			table.insert(level_export.events, v)
		end
		
  end
	
	if savebothfiles then
		dpf.savejson(filename .. "level.json",level_export)
	end
	dpf.savejson(filename .. "chart.json",chart_export)
	
	
end


return Levelmanager
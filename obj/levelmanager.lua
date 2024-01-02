Levelmanager = class('Levelmanager',Entity)

local currentversion = 2
--[[
FORMAT CHANGELOG:
- Version 0: initial version
- Version 1: Split chart and vfx+metadata into two separate files, chart.json and level.json
- Version 2: Replace "beat" event type with "block". "beat" still exists as a legacy event type.
]]--
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
	local saveboth = false
	--format 1
	if level.properties.formatversion == nil then
		level.properties.formatversion = 1
		saveboth = true -- this changes format significantly, so it requires a resave. for minor revisions, this is not needed.
	end
	--format 2
	if level.properties.formatversion == 1 then
		for i,v in ipairs(level.events) do
			if v.type == 'beat' then
				v.type = 'block'
			end
		end
	end
	return level, saveboth -- return if it got upgraded to force savebothfiles
	
	
	
end

function Levelmanager:savelevel(level,filename,savebothfiles)
	filename = filename or clevel
	
	local upgraded = false
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
		--may appear in legacy levels
		v.autoplayed = nil
		v.played = nil
		
		if Event.info[v.type] and Event.info[v.type].storeinchart then
			table.insert(chart_export, v)
		else
			table.insert(level_export.events, v)
		end
		
  end
	
	if savebothfiles then
		dpf.savejson(filename .. "level.json",level_export)
	end
	dpf.savejson(filename .. "chart.json",chart_export)
	
	return upgraded
	
end


return Levelmanager
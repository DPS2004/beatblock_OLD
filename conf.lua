function love.conf(t)
	if love.filesystem.getInfo('project.lua') then
		project = require('project')
	else
		project = require('projects/debug')
	end
	project.res.cx = project.res.x / 2
	project.res.cy = project.res.y / 2
	t.externalstorage = true

	if project.name == 'roomedit' then
		t.identity = 'roomedit'
		project.saveloc = 'savedata/main.sav'
		project.defaultsaveloc = 'data/defaultsave.json'
	else
		t.identity = 'lovetemplate'
		project.saveloc = 'savedata/main.sav'
		project.defaultsaveloc = 'data/defaultsave.json'
	end
	t.window.usedpiscale = false
	if not project.release then
		t.console = true
	end

	t.window.width = project.res.x
	t.window.height = project.res.y

  
end

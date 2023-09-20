local project = {}

project.release = false

project.name = 'BeatBlock'

project.initstate = 'title'
--clevel = 'levels/Finished Levels/lawrence/'
--project.startbeat = 340
--project.frameadvance = true

project.res = {}

project.res.useshuv = true

project.res.x = 400
project.res.y = 240
project.res.s = 2


project.fullscreen = false

project.intscale = 1


project.ctrls = {
	left = {"key:left",  "axis:rightx-", "button:dpleft"},
	right = {"key:right",  "axis:rightx+", "button:dpright"},
	up = {"key:up", "key:w", "axis:righty-", "button:dpup"},
	down = {"key:down", "key:s", "axis:righty+", "button:dpdown"},
	accept = {"key:space", "key:return", "button:a"},
	back = {"key:escape", "button:b"},
	ctrl = {},
	shift = {"key:lshift", "key:rshift"},
	backspace = {"key:backspace"},
	plus = {"key:+", "key:="},
	minus = {"key:-"},
	leftbracket = {"key:["},
	rightbracket = {"key:]"},
	comma = {"key:,"},
	period = {"key:."},
	slash = {"key:/"},
	s = {"key:s"},
	x = {"key:x"},
	a = {"key:a"},
	c = {"key:c"},
	e = {"key:e"},
	p = {"key:p"},
	r = {"key:r"},
	pause = {"key:tab"},
	k1 = {"key:1"},
	k2 = {"key:2"},
	k3 = {"key:3"},
	k4 = {"key:4"},
	k5 = {"key:5"},
	k6 = {"key:6"},
	k7 = {"key:7"},
	k8 = {"key:8"},
	f4 = {"key:f4"},
	f5 = {"key:f5"},
	mouse1 = {"mouse:1"},
	mouse2 = {"mouse:2"},
	mouse3 = {"mouse:3"}
}


project.acdelt = true

return project
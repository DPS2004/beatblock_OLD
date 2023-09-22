local sprites = {}


sprites.beat= {
	square = love.graphics.newImage("assets/game/square.png"),
	inverse = love.graphics.newImage("assets/game/inverse.png"),
	hold = love.graphics.newImage("assets/game/hold.png"),
	mine = love.graphics.newImage("assets/game/mine.png"),
	side = love.graphics.newImage("assets/game/side.png"),
	minehold = love.graphics.newImage("assets/game/minehold.png"),
	ringcw = love.graphics.newImage("assets/game/ringcw.png"),
	ringccw = love.graphics.newImage("assets/game/ringccw.png")
}
sprites.player = {
	idle = love.graphics.newImage("assets/game/cranky/idle.png"),
	happy = love.graphics.newImage("assets/game/cranky/happy.png"),
	miss = love.graphics.newImage("assets/game/cranky/miss.png")
}
sprites.songselect = {
	fg = love.graphics.newImage("assets/game/selectfg.png"),
	grades = {
		fnone = love.graphics.newImage("assets/results/small/fnone.png"),
		snone = love.graphics.newImage("assets/results/small/snone.png"),
		anone = love.graphics.newImage("assets/results/small/anone.png"),
		bnone = love.graphics.newImage("assets/results/small/bnone.png"),
		cnone = love.graphics.newImage("assets/results/small/cnone.png"),
		dnone = love.graphics.newImage("assets/results/small/dnone.png"),

		aplus = love.graphics.newImage("assets/results/small/aplus.png"),
		bplus = love.graphics.newImage("assets/results/small/bplus.png"),
		cplus = love.graphics.newImage("assets/results/small/cplus.png"),
		dplus = love.graphics.newImage("assets/results/small/dplus.png"),

		aminus = love.graphics.newImage("assets/results/small/aminus.png"),
		bminus = love.graphics.newImage("assets/results/small/bminus.png"),
		cminus = love.graphics.newImage("assets/results/small/cminus.png"),
		dminus = love.graphics.newImage("assets/results/small/dminus.png")

	}
}
sprites.results = {
	grades = {
		a = love.graphics.newImage("assets/results/big/a.png"),
		b = love.graphics.newImage("assets/results/big/b.png"),
		c = love.graphics.newImage("assets/results/big/c.png"),
		d = love.graphics.newImage("assets/results/big/d.png"),
		f = love.graphics.newImage("assets/results/big/f.png"),
		plus = love.graphics.newImage("assets/results/big/plus.png"),
		minus = love.graphics.newImage("assets/results/big/minus.png"),
		none = love.graphics.newImage("assets/results/big/none.png"),
		s = love.graphics.newImage("assets/results/big/s.png")
	}
}
sprites.title = {
	logo = love.graphics.newImage("assets/title/logo.png")
}

sprites.editor = {
	Square = love.graphics.newImage("assets/editor/editorSquare.png"),
  Palette = love.graphics.newImage("assets/editor/editorPalette.png"),
  Rect51x26 = love.graphics.newImage("assets/editor/editorRect51x26.png"),
  Rect41x33 = love.graphics.newImage("assets/editor/editorRect41x33.png"),
  Selected = love.graphics.newImage("assets/editor/editorSelected.png"),
  PlaySymbol = love.graphics.newImage("assets/editor/editorPlaySymbol.png"),
  TextBox = love.graphics.newImage("assets/editor/editorTextBox.png")
}

return sprites
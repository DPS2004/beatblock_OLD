--load in entities

em.new('obj/template.lua','templateobj')

em.new('obj/gamemanager.lua','gamemanager')

em.new('obj/levelmanager.lua','levelmanager')

em.new('obj/player.lua','player')

em.new('obj/notes/block.lua','block')
	em.new('obj/notes/mine.lua','mine')
	em.new('obj/notes/hold.lua','hold')
		em.new('obj/notes/minehold.lua','minehold')
	em.new('obj/notes/side.lua','side')


em.new('obj/hitpart.lua','hitpart')
em.new('obj/misspart.lua','misspart')

em.new('obj/titleparticle.lua','titleparticle')

--level specific
em.new('obj/level/lawrence/lawrencebg.lua','lawrencebg')


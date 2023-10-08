--load in entities

em.new('obj/template.lua','templateobj')

em.new('obj/gamemanager.lua','gamemanager')
em.new('obj/player.lua','player')
em.new('obj/beats/beat.lua','beat')
	em.new('obj/beats/mine.lua','mine')
	em.new('obj/beats/hold.lua','hold')
		em.new('obj/beats/minehold.lua','minehold')
	em.new('obj/beats/side.lua','side')


em.new('obj/hitpart.lua','hitpart')
em.new('obj/misspart.lua','misspart')

em.new('obj/titleparticle.lua','titleparticle')

--level specific
em.new('obj/level/lawrence/lawrencebg.lua','lawrencebg')


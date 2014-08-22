neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[The Independent are those with no strong affiliation for any of the other factions.

Despite being seen as a faction, they are not truely one. Most traders consider themselves independent, but certain voices have started to speak up about creating a merchant faction.]])

human = FactionInfo():setName("Human Navy")
human:setGMColor(255, 255, 255)
human:setDescription([[The remenants of the human navy.

While all other races where driven to the stars out of greed or intressed in science

The humans where the only race to start with galaxic exploration because their home world could no longer sustain their population]])

spaceCow = FactionInfo():setName("SpaceCow")
spaceCow:setGMColor(255, 0, 0)
spaceCow:setEnemy(human)
spaceCow:setDescription([[Moo mooo momooo mooooh boooh mooh booo bo bo mohmboo]])

sheeple = FactionInfo():setName("Sheeple")
sheeple:setGMColor(255, 128, 0)
sheeple:setEnemy(human)
sheeple:setEnemy(spaceCow)
sheeple:setDescription([[BAAAAAAH! BAAH BAAAAAAH!]])

pirateScorpions = FactionInfo():setName("PirateScorpions")
pirateScorpions:setGMColor(255, 0, 128)
pirateScorpions:setEnemy(neutral)
pirateScorpions:setEnemy(human)
pirateScorpions:setEnemy(spaceCow)
pirateScorpions:setEnemy(sheeple)
pirateScorpions:setDescription([[Yarrr]])

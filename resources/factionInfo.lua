neutral = FactionInfo():setName("Neutral")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[The neutral faction consists out of
creatures from all races.

They are not affiated with anyone,
but do not feel the need for war.
They rather trade peacefully.]])

human = FactionInfo():setName("Human")
human:setGMColor(255, 255, 255)
human:setDescription([[Humans.
No race in the gallaxy is looked at as
strange as the humans.
While all other races where driven to the
stars out of greed or intressed in science

The humans where the only race to start
with galaxic exploration because they
blew up their home planet by mistake.]])

spaceCow = FactionInfo():setName("SpaceCow")
spaceCow:setGMColor(255, 0, 0)
spaceCow:setEnemy(human)

sheeple = FactionInfo():setName("Sheeple")
sheeple:setGMColor(255, 128, 0)
sheeple:setEnemy(human)
sheeple:setEnemy(spaceCow)

pirateScorpions = FactionInfo():setName("PirateScorpions")
pirateScorpions:setGMColor(255, 0, 128)

pirateScorpions:setEnemy(neutral)
pirateScorpions:setEnemy(human)
pirateScorpions:setEnemy(spaceCow)
pirateScorpions:setEnemy(sheeple)

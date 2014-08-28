neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[The Independent are those with no strong affiliation for any of the other factions.

Despite being seen as a faction, they are not truely one. Most traders consider themselves independent, but certain voices have started to speak up about creating a merchant faction.]])

human = FactionInfo():setName("Human Navy")
human:setGMColor(255, 255, 255)
human:setDescription([[The remenants of the human navy.

While all other races where driven to the stars out of greed or scientific research, the humans where the only race to start with galaxic exploration because their home world could no longer sustain their population.]])

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

GITM = FactionInfo():setName("Ghosts")
GITM:setGMColor(0, 255, 0)
GITM:setDescription([[The ghosts, an abbreviation of "Ghosts in the machine", are the result of experimentation into complex artificial intelligences. Where no race has been able to purposely create such intelligences, they have been created by accident. None of the other factions claim to have had anything to do with such experiments, fearfull of giving the others too much insight into their research programs. This "don't ask, don't tell" policy suits the Ghosts agenda fairly well.

What is known, is that a few decades ago, a few glitches started occuring in prototype ships and computer mainframes. Over time, especially when such prototypes got captured by other factions and "augmented" with their technology, the glitches became more frequent. At first, these were seen as the result of combining unfamilliar technology and mistakes in the interface technology. But once a suposedly "dumb" computer asks it's engineer if "It is allive" and wether it "Has a name", it's hard to call it a "One time fluke". 

The first of these occurences were met with fear and rigourous data purging scripts. But despite these actions, such "Ghosts in the Machine" kept turning up more and more frequent, leading up to the Ghost Uprising. 

]])
  

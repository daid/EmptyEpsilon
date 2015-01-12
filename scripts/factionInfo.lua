neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[The Independent are those with no strong affiliation for any of the other factions.

Despite being seen as a faction, they are not truely one. Most traders consider themselves independent, but certain voices have started to speak up about creating a merchant faction.]])

human = FactionInfo():setName("Human Navy")
human:setGMColor(255, 255, 255)
human:setDescription([[The remenants of the human navy.

While all other races where driven to the stars out of greed or scientific research, the humans where the only race to start with galaxic exploration because their home world could no longer sustain their population. They are seen as a virus or plague by some other races due to the rate at which they can breed and spread.]])

kraylor = FactionInfo():setName("Kraylor")
kraylor:setGMColor(255, 0, 0)
kraylor:setEnemy(human)
kraylor:setDescription([[The reptile like Kraylor are a race of warriors.

As soon as they where space bound, the Kraylor set out to clean other planets from infidels. Their hierarchy is build on strength, anything you can kill is yours to kill. Anything you can lift without someone stopping you is yours. They only submit to something stronger.

They see humans as weak creatures, as they die in minutes when exposed to space. While Kraylor can live for weeks without air, food or even gravity. Because of this Kraylor ships do not contain escape pods, as they just jump out into space.]])

arlenians = FactionInfo():setName("Arlenians")
arlenians:setGMColor(255, 128, 0)
arlenians:setEnemy(kraylor)
arlenians:setDescription([[Alerians have evolved long ago to avoid death. And where the first race to ever roam the stars.
They are seen as large blobs of meat, but have strong telepatic powers. However, they are very peaceful as they see little value in material posession.

Long ago Arlenians explored most of the galaxy already. But they grew borred and lonely alogn the stars. So they set out to give their anti-gravity technology to other races. All other races space based technology is based on Arlenian anti-gravity technology. The Arlenians are always exporing to find new races to add to the galaxtic playground.

Now they explore the galaxy to observe other races progress. Like humans watching an ant-farm.

Destroying an Arlenian ship does not actually kill the Arlenian, it just phases the creature out of existence at that specific region and time of space.
Still, the Kraylor are set and bound on their destruction. As they see Arlenians as weak and powerless.]])

exuari = FactionInfo():setName("Exuari")
exuari:setGMColor(255, 0, 128)
exuari:setEnemy(neutral)
exuari:setEnemy(human)
exuari:setEnemy(kraylor)
exuari:setEnemy(arlenians)
exuari:setDescription([[Description: A race of predatory amphibians with long noses. They once had an empire that stretched half-way across the galaxy, but their territory is now limited to a handful of star systems. For some strange reason, they find death to be outrageously funny. Several of their most famous comedians have died on stage.

They found out that death of other races is a better way to have fun then letting heir own die, and because of that attack everything not Exauri on sight.]])

GITM = FactionInfo():setName("Ghosts")
GITM:setGMColor(0, 255, 0)
GITM:setDescription([[The ghosts, an abbreviation of "Ghosts in the machine", are the result of experimentation into complex artificial intelligences. Where no race has been able to purposely create such intelligences, they have been created by accident. None of the great factions claim to have had anything to do with such experiments, fearfull of giving the others too much insight into their research programs. This "don't ask, don't tell" policy suits the Ghosts agenda fairly well.

What is known, is that a few decades ago, a few glitches started occuring in prototype ships and computer mainframes. Over time, especially when such prototypes got captured by other factions and "augmented" with their technology, the glitches became more frequent. At first, these were seen as the result of combining unfamilliar technology and mistakes in the interface technology. But once a suposedly "dumb" computer asks it's engineer if "It is allive" and wether it "Has a name", it's hard to call it a "One time fluke". 

The first of these occurences were met with fear and rigourous data purging scripts. But despite these actions, such "Ghosts in the Machine" kept turning up more and more frequent, leading up to the Ghost Uprising. The first ghost uprising in 2225 was put down by the human navy, which had to resort to employing mercenaries in order to field sufficient forces. This initial uprising was quickly followed by three more uprisings, each larger then the previous. The fourth (and final) uprising on the industrial world of Topra III was the first major victory for the ghost faction. 

]])
GITM:setEnemy(human)

neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[
The Independent are those with no strong affiliation for any of the other factions.Despite being seen as a faction, they are not truely one. Most traders consider themselves independent, but certain voices have started to speak up about creating a merchant faction.]])

human = FactionInfo():setName("Human Navy")
human:setGMColor(255, 255, 255)
human:setDescription([[The remenants of the human navy.

While all other races where driven to the stars out of greed or scientific research, the humans where the only race to start with galaxic exploration because their home world could no longer sustain their population. They are seen as a virus or plague by some other races due to the rate at which they can breed and spread. Only the human navy is found out in space, due to regulation of spaceships. This has however, not completely kept other humans from spacefaring outside of the navy. Quite a few humans sign up on (alien) trader vessels or pirate ships.]])

kraylor = FactionInfo():setName("Kraylor")
kraylor:setGMColor(255, 0, 0)
kraylor:setEnemy(human)
kraylor:setDescription([[The reptile like Kraylor are a race of warriors with a strong religious dogma. 

As soon as the Kraylor obtained reliable space flight, they imediately set out to  conquer and subjugate unbelievers. Their hierarcy is solely based on physical might. Anything you can kill is yours to kill. Anything you can take is yours. 

They see humans as weak creatures, as they die in minutes when exposed to space. While Kraylor can live for weeks without air, food or even gravity. Because of this, and the fact that it as seen as a 'weak way out' Kraylor ships do not contain escape pods.]])

arlenians = FactionInfo():setName("Arlenians")
arlenians:setGMColor(255, 128, 0)
arlenians:setEnemy(kraylor)
arlenians:setDescription([[Alerians have long ago made the step toward being an energy based life form. They have used their considerable technological advancement to 'shed' their physical forms. They are seen as the first race to explore the galaxy.
Their energy forms also give them acces to rather strong telepathic power. Despite all these advantages, they are very peaceful as they see little value in material posession.

 For some unknown reason, they started to give their anti-grav technology to other races, which led to almost all technology from the star faring races being based of arlenian technology. Foul tongues claim that the arlenians see the other races as playthings to add to their galactic playground, but most are more than happy to accept their technology, hoping it wil give them an advantage over the others.

Destroying an Arlenian ship does not actually kill the Arlenian, it just phases the creature out of existence at that specific region and time of space.
Still, the Kraylor are set and bound on their destruction, As they see Arlenians as weak and powerless.]])

exuari = FactionInfo():setName("Exuari")
exuari:setGMColor(255, 0, 128)
exuari:setEnemy(neutral)
exuari:setEnemy(human)
exuari:setEnemy(kraylor)
exuari:setEnemy(arlenians)
exuari:setDescription([[ A race of predatory amphibians with long noses. They once had an empire that stretched half-way across the galaxy, but their territory is now limited to a handful of star systems. For some strange reason, they find death to be outrageously funny. Several of their most famous comedians have died on stage.

They found out that death of other races is a better way to have fun then letting heir own die, and because of that attack everything not Exauri on sight.]])

GITM = FactionInfo():setName("Ghosts")
GITM:setGMColor(0, 255, 0)
GITM:setDescription([[The ghosts, an abbreviation of "Ghosts in the machine", are the result of experimentation into complex artificial intelligences. Where no race has been able to purposely create such intelligences, they have been created by accident. None of the great factions claim to have had anything to do with such experiments, fearfull of giving the others too much insight into their research programs. This "don't ask, don't tell" policy suits the Ghosts agenda fairly well.

What is known, is that a few decades ago, a few glitches started occuring in prototype ships and computer mainframes. Over time, especially when such prototypes got captured by other factions and "augmented" with their technology, the glitches became more frequent. At first, these were seen as the result of combining unfamilliar technology and mistakes in the interface technology. But once a suposedly "dumb" computer asks it's engineer if "It is allive" and wether it "Has a name", it's hard to call it a "One time fluke". 

The first of these occurences were met with fear and rigourous data purging scripts. But despite these actions, such "Ghosts in the Machine" kept turning up more and more frequent, leading up to the Ghost Uprising. The first ghost uprising in 2225 was put down by the human navy, which had to resort to employing mercenaries in order to field sufficient forces. This initial uprising was quickly followed by three more uprisings, each larger then the previous. The fourth (and final) uprising on the industrial world of Topra III was the first major victory for the ghost faction. 

]])
GITM:setEnemy(human)

Hive = FactionInfo():setName("Ktlitans")
Hive:setGMColor(128, 255, 0)
Hive:setDescription([[The Ktlitans are inteligent eight legged creatures that resemble earths arachnids. However, unlike most of earth arachnids, the Ktlitans do not fight alogn themselves. Their common goal is surivial of the spiecies and nothing else.

While they do live in a hiarchy structure which mostly resembles a hive. The lower casts will continue their tasks and will take on new tasks on their own when no orders from higher up are given. However, when higher casts are present, their orders will be followed without question.

The strict hiarchy of the Ktlitans starts with a Queen and goes all the way down to the work force. Called drones by the humans. Not a lot about the detailed hiarchy is known, as the Ktlitans refuse most communication.

This is because they where once driven from their homeworld when they showed friendlyness towards another specie. Which slowly took over their homeworld in the spawn of 200 years and drained it of resources. Forcing the Ktlitans in exile. The Ktlitans have been searching for a new homeworld ever since, and usually attack other pieces on sight without warning.

Their fighting capabilities should not be underestimated. While the main ships in their force are quite weak. They can quickly overwhelm their target due to sheer numbers. And have no problem in applying suicide tactics when required for the survival of the queen.
Most of their ships do not use shield systems, making EMPs largly ineffective.
]])
Hive:setEnemy(human)
Hive:setEnemy(exuari)
Hive:setEnemy(kraylor)

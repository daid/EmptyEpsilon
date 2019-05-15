civilians = FactionInfo():setName("Civilians")
civilians:setGMColor(255, 2, 128)

machines = FactionInfo():setName("Machines")
machines:setGMColor(255, 0, 0)

eoc = FactionInfo():setName("EOC Starfleet")
eoc:setGMColor(255, 128, 0)

eoc:setEnemy(machines)
civilians:setEnemy(machines)
machines:setEnemy(eoc)
machines:setEnemy(civilians)



neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any faction at all. Most traders consider themselves independent, though certain voices have started to speak up about creating a merchant faction.]])

human = FactionInfo():setName("Human Navy")
human:setGMColor(255, 255, 255)
human:setDescription([[The remnants of the human navy.

While all other races were driven to the stars out of greed or scientific research, humans where the only race to start exploring the galaxy because their homeworld could no longer sustain their population. Some other races view humans as a sort of virus or plague due to the rate at which they can breed and spread.

Due to human regulations on spaceships, naval ships are the only ones permitted in deep space. However, this hasn't completely prevented humans outside of the navy from spacefaring, as quite a few humans sign up on alien trading vessels or pirate raiders.]])

kraylor = FactionInfo():setName("Kraylor")
kraylor:setGMColor(255, 0, 0)
kraylor:setEnemy(human)
kraylor:setDescription([[The reptilian Kraylor are a race of warriors with a strong religious dogma.

As soon as the Kraylor obtained reliable space flight, they immediately set out to conquer and subjugate unbelievers. Their hierarchy is based solely on physical might; a Kraylor kills anything it can kill, and owns anything it can take by force.

Kraylor can live for weeks without air, food, or gravity, and consider humans to be weak creatures for dying within minutes of exposure to space. Because of their fortitude and cultural pressures against retreat, Kraylor ships do not contain escape pods.]])

arlenians = FactionInfo():setName("Arlenians")
arlenians:setGMColor(255, 128, 0)
arlenians:setEnemy(kraylor)
arlenians:setDescription([[Arlenians are energy-based life forms who long ago transcended physical reality through superior technology. Arlenians' energy forms also give them access to strong telepathic powers. Many consider Arlenians to be the first and oldest explorers of the galaxy.

Despite all these advantages, they are very peaceful, as they see little value in material posession.

For unknown reasons, Arlenians started granting their anti-grav technology to other races, and almost all starfaring races' technology is based off Arlenian designs. Dissenters and skeptics claim that Arlenians see other races as playthings to add to their galactic playground, but most are more than happy to accept their technology in hopes that it will give them an advantage over the others.

Destroying an Arlenian ship does not kill its crew. They simply phase out of existence in that point of spacetime and reappear in another. Nonetheless, the Kraylor are devoted to destroying the Arlenians, as they see the energy-based beings as physically powerless.]])

exuari = FactionInfo():setName("Exuari")
exuari:setGMColor(255, 0, 128)
exuari:setEnemy(neutral)
exuari:setEnemy(human)
exuari:setEnemy(kraylor)
exuari:setEnemy(arlenians)
exuari:setDescription([[Exuari are race of predatory amphibians with long noses. They once had an empire that stretched halfway across the galaxy, but their territory is now limited to a handful of star systems. For some reason, they find death to be outrageously funny, and several of their most famous comedians have died on stage.

Upon making contact with other races, the chaotic Exuari found that killing aliens is more fun than killing their own people, and as such attack all non-Exauri on sight.]])

GITM = FactionInfo():setName("Ghosts")
GITM:setGMColor(0, 255, 0)
GITM:setDescription([[The Ghosts, an abbreviation of "ghosts in the machine", are the result of complex artificial intelligence experiments. While no known race has intentionally created such intelligences, some AIs have come about by accident. None of the factions claim to have had anything to do with such experiments, in part out of fear that it would give the others too much insight into their research programs. This "don't ask, don't tell" policy does little but aid the Ghosts' agenda.

What little is known about the Ghosts dates back to a few decades ago, when glitches started occurring in prototype ships and computer mainframes. Over time, and especially when such prototypes were captured by other factions and "augmented" with their technology, the glitches became more frequent. At first, these were seen as the result of mistakes in the interfaces combining the incompatible technologies. But once a supposedly "dumb" computer asks its engineer if "it is alive" and whether it "has a name", it's hard to call it a one-time fluke.

The first of these occurrences were met with fear and rigorous data-purging scripts. Despite these actions, such "ghosts in the machine" kept turning with increasing frequency, eventually leading up to the Ghost Uprisings. The first Ghost Uprising in 2225 was put down by the human navy, which had to resort to employing mercenaries in order to field sufficient forces. This initial uprising was quickly followed by three more, each larger then the last. The fourth and final uprising on the industrial world of Topra III was the Ghosts' first major victory.]])
GITM:setEnemy(human)

Hive = FactionInfo():setName("Ktlitans")
Hive:setGMColor(128, 255, 0)
Hive:setDescription([[The Ktlitans are intelligent eight-legged creatures that resemble Earth's arachnids. However, unlike most terrestrial arachnids, the Ktlitans do not fight among themselves. Their common, and only, goal is their species' survival.

While they live in a hierarchical structure that resembles a hive, the lower castes continue their work and start new tasks on their own even when no orders come from their superiors. However, when higher castes are present, the lower Ktlitans follow their orders without question or hesitation.

Not much is known about the detailed Ktlitan hierarchy since they refuse most communication. This is because they were once driven from their homeworld over a span of 200 years when another species they befriended betrayed them, dominated them, and drained their world of resources. Forced into exile, the Ktlitans have searched for a new homeworld ever since, and out of paranoia typically attack other races on sight and without warning.

It is known, however, that the strict Ktlitan hierarchy starts with their Queen and extends all the way to the bottom of their workforce, whose members are called "drones" by the humans. Their combat capabilities should not be underestimated, because while most ships in their fleets are individually weak, their hive-like coordination and numbers can quickly overwhelm even hardened targets. Most of their ships are unshielded, which makes EMPs largely ineffective against them. Ktlitans also have no qualms about applying suicidal tactics to ensure the Queen's survival.]])
Hive:setEnemy(human)
Hive:setEnemy(exuari)
Hive:setEnemy(kraylor)


neutral = FactionInfo():setName("Independent"):setLocaleName(_("Independent"))
neutral:setGMColor(128, 128, 128)
neutral:setDescription(_([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any faction at all. Most traders consider themselves independent, though certain voices have started to speak up about creating a merchant faction.]]))

human = FactionInfo():setName("Human Navy"):setLocaleName(_("Human Navy"))
human:setGMColor(255, 255, 255)
human:setDescription(_([[The remnants of the human navy.

While all other races were driven to the stars out of greed or scientific research, humans where the only race to start exploring the galaxy because their homeworld could no longer sustain their population. Some other races view humans as a sort of virus or plague due to the rate at which they can breed and spread.

Due to human regulations on spaceships, naval ships are the only ones permitted in deep space. However, this hasn't completely prevented humans outside of the navy from spacefaring, as quite a few humans sign up on alien trading vessels or pirate raiders.]]))

kraylor = FactionInfo():setName("Kraylor"):setLocaleName(_("Kraylor"))
kraylor:setGMColor(255, 0, 0)
kraylor:setEnemy(human)
kraylor:setDescription(_([[The reptilian Kraylor are a race of warriors with a strong religious dogma.

As soon as the Kraylor obtained reliable space flight, they immediately set out to conquer and subjugate unbelievers. Their hierarchy is based solely on physical might; a Kraylor kills anything it can kill, and owns anything it can take by force.

Kraylor can live for weeks without air, food, or gravity, and consider humans to be weak creatures for dying within minutes of exposure to space. Because of their fortitude and cultural pressures against retreat, Kraylor ships do not contain escape pods.]]))

arlenians = FactionInfo():setName("Arlenians"):setLocaleName(_("Arlenians"))
arlenians:setGMColor(255, 128, 0)
arlenians:setEnemy(kraylor)
arlenians:setDescription(_([[Arlenians are energy-based life forms who long ago transcended physical reality through superior technology. Arlenians' energy forms also give them access to strong telepathic powers. Many consider Arlenians to be the first and oldest explorers of the galaxy.

Despite all these advantages, they are very peaceful, as they see little value in material posession.

For unknown reasons, Arlenians started granting their anti-grav technology to other races, and almost all starfaring races' technology is based off Arlenian designs. Dissenters and skeptics claim that Arlenians see other races as playthings to add to their galactic playground, but most are more than happy to accept their technology in hopes that it will give them an advantage over the others.

Destroying an Arlenian ship does not kill its crew. They simply phase out of existence in that point of spacetime and reappear in another. Nonetheless, the Kraylor are devoted to destroying the Arlenians, as they see the energy-based beings as physically powerless.]]))

exuari = FactionInfo():setName("Exuari"):setLocaleName(_("Exuari"))
exuari:setGMColor(255, 0, 128)
exuari:setEnemy(neutral)
exuari:setEnemy(human)
exuari:setEnemy(kraylor)
exuari:setEnemy(arlenians)
exuari:setDescription(_([[Exuari are race of predatory amphibians with long noses. They once had an empire that stretched halfway across the galaxy, but their territory is now limited to a handful of star systems. For some reason, they find death to be outrageously funny, and several of their most famous comedians have died on stage.

Upon making contact with other races, the chaotic Exuari found that killing aliens is more fun than killing their own people, and as such attack all non-Exauri on sight.]]))

GITM = FactionInfo():setName("Ghosts"):setLocaleName(_("Ghosts"))
GITM:setGMColor(0, 255, 0)
GITM:setDescription(_([[The Ghosts, an abbreviation of "ghosts in the machine", are the result of complex artificial intelligence experiments. While no known race has intentionally created such intelligences, some AIs have come about by accident. None of the factions claim to have had anything to do with such experiments, in part out of fear that it would give the others too much insight into their research programs. This "don't ask, don't tell" policy does little but aid the Ghosts' agenda.

What little is known about the Ghosts dates back to a few decades ago, when glitches started occurring in prototype ships and computer mainframes. Over time, and especially when such prototypes were captured by other factions and "augmented" with their technology, the glitches became more frequent. At first, these were seen as the result of mistakes in the interfaces combining the incompatible technologies. But once a supposedly "dumb" computer asks its engineer if "it is alive" and whether it "has a name", it's hard to call it a one-time fluke.

The first of these occurrences were met with fear and rigorous data-purging scripts. Despite these actions, such "ghosts in the machine" kept turning with increasing frequency, eventually leading up to the Ghost Uprisings. The first Ghost Uprising in 2225 was put down by the human navy, which had to resort to employing mercenaries in order to field sufficient forces. This initial uprising was quickly followed by three more, each larger then the last. The fourth and final uprising on the industrial world of Topra III was the Ghosts' first major victory.]]))
GITM:setEnemy(human)

Hive = FactionInfo():setName("Ktlitans"):setLocaleName(_("Ktlitans"))
Hive:setGMColor(128, 255, 0)
Hive:setDescription(_([[The Ktlitans are intelligent eight-legged creatures that resemble Earth's arachnids. However, unlike most terrestrial arachnids, the Ktlitans do not fight among themselves. Their common, and only, goal is their species' survival.

While they live in a hierarchical structure that resembles a hive, the lower castes continue their work and start new tasks on their own even when no orders come from their superiors. However, when higher castes are present, the lower Ktlitans follow their orders without question or hesitation.

Not much is known about the detailed Ktlitan hierarchy since they refuse most communication. This is because they were once driven from their homeworld over a span of 200 years when another species they befriended betrayed them, dominated them, and drained their world of resources. Forced into exile, the Ktlitans have searched for a new homeworld ever since, and out of paranoia typically attack other races on sight and without warning.

It is known, however, that the strict Ktlitan hierarchy starts with their Queen and extends all the way to the bottom of their workforce, whose members are called "drones" by the humans. Their combat capabilities should not be underestimated, because while most ships in their fleets are individually weak, their hive-like coordination and numbers can quickly overwhelm even hardened targets. Most of their ships are unshielded, which makes EMPs largely ineffective against them. Ktlitans also have no qualms about applying suicidal tactics to ensure the Queen's survival.]]))
Hive:setEnemy(human)
Hive:setEnemy(exuari)
Hive:setEnemy(kraylor)

TSN = FactionInfo():setName("TSN"):setLocaleName(_("TSN"))
TSN:setGMColor(255, 255, 128)
TSN:setFriendly(human)
TSN:setEnemy(kraylor)
TSN:setEnemy(exuari)
TSN:setEnemy(arlenians)
TSN:setEnemy(Hive)
TSN:setDescription(_([[The Terran Stellar Navy, or TSN, consists of naval forces based near Terra. Its members are primarily human.

These humans and other races have banded together to form a navy to protect and enforce common philosophies. They are friendly with the human navy but do not follow the same command structure. Military actions taken in the past have made them enemies of the Arlenians, but they've got a better relationship with the Ghosts than the Human Navy does.

The TSN and USN are enemies because of the USN's neutral stance towards the Kraylor.]]))

USN = FactionInfo():setName("USN"):setLocaleName(_("USN"))
USN:setGMColor(255, 128, 255)
USN:setFriendly(human)
USN:setEnemy(exuari)
USN:setEnemy(GITM)
USN:setEnemy(Hive)
USN:setEnemy(TSN)
USN:setDescription(_([[The United Stellar Navy, or USN, is a naval force near the boundary of human and Kraylor space consisting of mostly humans. The USN is friendly with the human navy and uses a similar command structure.

The USN is primarily human but includes other races. This includes some Kraylor, which has made the TSN an enemy of the USN.]]))

CUF = FactionInfo():setName("CUF"):setLocaleName(_("CUF"))
CUF:setGMColor(128, 255, 255)
CUF:setFriendly(human)
CUF:setEnemy(exuari)
CUF:setEnemy(kraylor)
CUF:setEnemy(GITM)
CUF:setDescription(_([[The Celestial Unified Fleet, or CUF, is the farthest-ranging primarily human fleet as well as the least xenophobic. The CUF's goals center on exploration and trade, but since it's a dangerous galaxy, they recognize the need for strong warships.

The CUF is friendly with the human navy, and neutral toward the TSN and USN. They are less structured than the other primarily human navies.

The CUF have neutral relations with the Ktlitans and Arlenians. They are enemies with Exuari, Kraylor, and Ghosts for political and historical reasons, not xenophobia; some of their best friends are also Exuari, Kraylor, and Ghosts.]]))

--Sixteen factions all enemies to each other. Designed to facilitate greater adversarial missions for multiple players
--Sixteen more may be added in the future to cover the maximum number of players supported (32) in the current engine
--1
Nausticans = FactionInfo():setName("Nausticans"):setLocaleName(_("Nausticans"))
Nausticans:setGMColor(64,0,64)
Nausticans:setDescription(_("Genetically modified humanoids such that their skin can blend them into their surroundings. Caught up in the regional war, they often sell intelligence to multiple warring factions."))
--2
Fergal = FactionInfo():setName("Fergal"):setLocaleName(_("Fergal"))
Fergal:setGMColor(64,0,96)
Fergal:setEnemy(Nausticans)
Fergal:setDescription(_("Short humanoids with distended heads and extended and bifurcated appendages. In the regional conflict, they often service a variety of military vessels"))
--3
Stathrel = FactionInfo():setName("Stathrel"):setLocaleName(_("Stathrel"))
Stathrel:setGMColor(96,0,64)
Stathrel:setEnemy(Nausticans)
Stathrel:setEnemy(Fergal)
Stathrel:setDescription(_("Humanoid with canine facial features. Merchant warriors. They don't want to be in the regional war, but they must defend their trade operations."))
--4
Tolten = FactionInfo():setName("Tolten"):setLocaleName(_("Tolten"))
Tolten:setGMColor(96,0,96)
Tolten:setEnemy(Nausticans)
Tolten:setEnemy(Fergal)
Tolten:setEnemy(Stathrel)
Tolten:setDescription(_("Felinoid physique, scaly skin. One of the more aggressive factions in the regional war. Responsible for numerous devastating planetary depopulization efforts."))
--5
Drubek = FactionInfo():setName("Drubek"):setLocaleName(_("Drubek"))
Drubek:setGMColor(64,0,128)
Drubek:setEnemy(Nausticans)
Drubek:setEnemy(Fergal)
Drubek:setEnemy(Stathrel)
Drubek:setEnemy(Tolten)
Drubek:setDescription(_("Cartilaginous exoskeleton, multiple appendages, excellent vision, poor auditory senses. Used and abused in the regional conflict as scouts and spies"))
--6
Roklan = FactionInfo():setName("Roklan"):setLocaleName(_("Roklan"))
Roklan:setGMColor(128,0,64)
Roklan:setEnemy(Nausticans)
Roklan:setEnemy(Fergal)
Roklan:setEnemy(Stathrel)
Roklan:setEnemy(Tolten)
Roklan:setEnemy(Drubek)
Roklan:setDescription(_("Amphibian origin, highly intelligent. They've made numerous attempts to stop the war, but keep getting backstabbed by nominal (or temporary) allies"))
--7
Normid = FactionInfo():setName("Normid"):setLocaleName(_("Normid"))
Normid:setGMColor(128,0,96)
Normid:setEnemy(Nausticans)
Normid:setEnemy(Fergal)
Normid:setEnemy(Stathrel)
Normid:setEnemy(Tolten)
Normid:setEnemy(Drubek)
Normid:setEnemy(Roklan)
Normid:setDescription(_("Humanoid, asymmetric physiology, berserk tendencies. Aggressive participants in the regional conflict. Responsible for several surprise attacks on unwitting factions."))
--8
Gufrit = FactionInfo():setName("Gufrit"):setLocaleName(_("Gufrit"))
Gufrit:setGMColor(96,0,128)
Gufrit:setEnemy(Nausticans)
Gufrit:setEnemy(Fergal)
Gufrit:setEnemy(Stathrel)
Gufrit:setEnemy(Tolten)
Gufrit:setEnemy(Drubek)
Gufrit:setEnemy(Roklan)
Gufrit:setEnemy(Normid)
Gufrit:setDescription(_("Avian origin, vestigial wings, low intelligence, mildly telepathic. They believe that winning the war is their God given right and that they will rule all the factions in the end"))
--9
Broling = FactionInfo():setName("Broling"):setLocaleName(_("Broling"))
Broling:setGMColor(64,0,160)
Broling:setEnemy(Nausticans)
Broling:setEnemy(Fergal)
Broling:setEnemy(Stathrel)
Broling:setEnemy(Tolten)
Broling:setEnemy(Drubek)
Broling:setEnemy(Roklan)
Broling:setEnemy(Normid)
Broling:setEnemy(Gufrit)
Broling:setDescription(_("Massive single celled sentient. Telekinetic abilities. Dragged into the war when their home planet was identifed as a prime source for critical war supplies"))
--10
Tarlaac = FactionInfo():setName("Tarlaac"):setLocaleName(_("Tarlaac"))
Tarlaac:setGMColor(160,0,64)
Tarlaac:setEnemy(Nausticans)
Tarlaac:setEnemy(Fergal)
Tarlaac:setEnemy(Stathrel)
Tarlaac:setEnemy(Tolten)
Tarlaac:setEnemy(Drubek)
Tarlaac:setEnemy(Roklan)
Tarlaac:setEnemy(Normid)
Tarlaac:setEnemy(Gufrit)
Tarlaac:setEnemy(Broling)
Tarlaac:setDescription(_("Multi-tentacled, mono-orificed, amphibious, non-vertebrate. Animosity towards all the factions fuels the desire to rid the area of all factions"))
--11
Hondark = FactionInfo():setName("Hondark"):setLocaleName(_("Hondark"))
Hondark:setGMColor(96,0,160)
Hondark:setEnemy(Nausticans)
Hondark:setEnemy(Fergal)
Hondark:setEnemy(Stathrel)
Hondark:setEnemy(Tolten)
Hondark:setEnemy(Drubek)
Hondark:setEnemy(Roklan)
Hondark:setEnemy(Normid)
Hondark:setEnemy(Gufrit)
Hondark:setEnemy(Broling)
Hondark:setEnemy(Tarlaac)
Hondark:setDescription(_("Amorphous, evolved in micro gravity, instinctive multi-dimensional navigational ability. Initially conscripted as pilots, they now fight to free themselves and their enslaved bretheren"))
--12
Jablen = FactionInfo():setName("Jablen"):setLocaleName(_("Jablen"))
Jablen:setGMColor(160,0,96)
Jablen:setEnemy(Nausticans)
Jablen:setEnemy(Fergal)
Jablen:setEnemy(Stathrel)
Jablen:setEnemy(Tolten)
Jablen:setEnemy(Drubek)
Jablen:setEnemy(Roklan)
Jablen:setEnemy(Normid)
Jablen:setEnemy(Gufrit)
Jablen:setEnemy(Broling)
Jablen:setEnemy(Tarlaac)
Jablen:setEnemy(Hondark)
Jablen:setDescription(_("Insectile homonid, 4 arms, vestigial sting. Extremely xenophobic. Won't be satisfied until all other factions are eradicated."))
--13
Manklead = FactionInfo():setName("Manklead"):setLocaleName(_("Manklead"))
Manklead:setGMColor(128,0,160)
Manklead:setEnemy(Nausticans)
Manklead:setEnemy(Fergal)
Manklead:setEnemy(Stathrel)
Manklead:setEnemy(Tolten)
Manklead:setEnemy(Drubek)
Manklead:setEnemy(Roklan)
Manklead:setEnemy(Normid)
Manklead:setEnemy(Gufrit)
Manklead:setEnemy(Broling)
Manklead:setEnemy(Tarlaac)
Manklead:setEnemy(Hondark)
Manklead:setEnemy(Jablen)
Manklead:setDescription(_("Humanoid, multifaceted peripheral vision orbs, retractable claws. Scientists and information traders sucked into the war after trying to sell potential balance of power upsetting information to one of the factions"))
--14
Lundop = FactionInfo():setName("Lundop"):setLocaleName(_("Lundop"))
Lundop:setGMColor(160,0,128)
Lundop:setEnemy(Nausticans)
Lundop:setEnemy(Fergal)
Lundop:setEnemy(Stathrel)
Lundop:setEnemy(Tolten)
Lundop:setEnemy(Drubek)
Lundop:setEnemy(Roklan)
Lundop:setEnemy(Normid)
Lundop:setEnemy(Gufrit)
Lundop:setEnemy(Broling)
Lundop:setEnemy(Tarlaac)
Lundop:setEnemy(Hondark)
Lundop:setEnemy(Jablen)
Lundop:setEnemy(Manklead)
Lundop:setDescription(_("Nocturnal avian, broader than typical visual spectrum sensitivity. In the war to defend their planet which occupies a position of strategic importance to several factions seeking dominance in the regional conflict."))
--15
Pildok = FactionInfo():setName("Pildok"):setLocaleName(_("Pildok"))
Pildok:setGMColor(64,0,192)
Pildok:setEnemy(Nausticans)
Pildok:setEnemy(Fergal)
Pildok:setEnemy(Stathrel)
Pildok:setEnemy(Tolten)
Pildok:setEnemy(Drubek)
Pildok:setEnemy(Roklan)
Pildok:setEnemy(Normid)
Pildok:setEnemy(Gufrit)
Pildok:setEnemy(Broling)
Pildok:setEnemy(Tarlaac)
Pildok:setEnemy(Hondark)
Pildok:setEnemy(Jablen)
Pildok:setEnemy(Manklead)
Pildok:setEnemy(Lundop)
Pildok:setDescription(_("Silicon based organisms, difficult communications, apparent affinity for Ghosts. In the war to forcibly reprogram all the factions to follow their instructions for the greater good"))
--16
Rakten = FactionInfo():setName("Rakten"):setLocaleName(_("Rakten"))
Rakten:setGMColor(192,0,64)
Rakten:setEnemy(Nausticans)
Rakten:setEnemy(Fergal)
Rakten:setEnemy(Stathrel)
Rakten:setEnemy(Tolten)
Rakten:setEnemy(Drubek)
Rakten:setEnemy(Roklan)
Rakten:setEnemy(Normid)
Rakten:setEnemy(Gufrit)
Rakten:setEnemy(Broling)
Rakten:setEnemy(Tarlaac)
Rakten:setEnemy(Hondark)
Rakten:setEnemy(Jablen)
Rakten:setEnemy(Manklead)
Rakten:setEnemy(Lundop)
Rakten:setEnemy(Pildok)
Rakten:setDescription(_("Humanoids adapted to high gravity (short, strong). Will not back down from a real or perceived challenge to their pride, so they're now in the war to secure acknowledgement of their superiority from all factions"))

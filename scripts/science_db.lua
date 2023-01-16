--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not affect the game in any other way and just contributes to the lore.
	For details on ScienceDatabase scripting functions, see the scripting reference.
--]]

-- "Natural" describes space terrain objects
space_objects = ScienceDatabase():setName(_('Natural'))
space_objects:setLongDescription(_([[This database covers naturally occurring phenomena that spaceborne crews might encounter.

While ship captains are encouraged to avoid unnecessary interactions with these phenomena, knowing their properties can offer an advantage in conflicts near them.]]))

item = space_objects:addEntry(_('Asteroid'))
item:setLongDescription(_([[An asteroid is a minor planet, usually smaller than a few kilometers. Larger variants are sometimes refered to as planetoids.]]))

item = space_objects:addEntry(_('Black hole'))
item:setLongDescription(_([[A black hole is a point of supercondensed mass with a gravitational pull so powerful that not even light can escape it. It has no locally detectable features, and can only be seen indirectly by blocking the view and distorting its surroundings, creating a strange circular mirror image of the galaxy. The black disc in the middle marks the event horizon, the boundary where even light can't escape it anymore. 
	
On the sensors, a black hole appears as a disc indicating the zone where the gravitational pull is getting dangerous, and soon will be stronger then the ship's impulse engines. An object that crosses a black hole is drawn toward its center and quickly ripped apart by the gravitational forces.]]))

item = space_objects:addEntry(_('Nebula'))
item:setLongDescription(_([[Nebulae are the birthing places of new stars. These gas fields, usually created by the death of an old star, slowly form new stars due to the gravitational pull of its gas molecules.

Because of the ever-changing nature of gas nebulae, most radar and scanning technologies are unable to penetrate them. Science officers are therefore advised to rely on probes and visual observations.]]))

item = space_objects:addEntry(_('Planet'))
item:setLongDescription(_([[A planetary-mass object is large, dense, near-spherical astronomical body comprised of various forms of matter. Most planets are either terrestrial, like Earth, or giants, like the gas giant Jupiter or ice giant Neptune.

Planets often have gaseous atmospheres, and some are orbited by one or more large planetoids typically called moons.]]))

item = space_objects:addEntry(_('Wormhole'))
item:setLongDescription(_([[A wormhole, also known as an Einstein-Rosen bridge, is a phenomena that connects two points of spacetime. Jump drives operate in a similar fashion, but instead of being created at will, a wormhole occupies a specific location in space. Objects that enter a wormhole instantaneously emerge from the other end, which might be anywhere from a few feet to thousands of light years away. 

Wormholes are rare, and most can move objects in only one direction. Traversable wormholes, which are stable and allow for movement in both directions, are even rarer. All wormholes generate tremendous sensor activity, which an astute science officer can detect even through disruptions such as nebulae.]]))

-- "Technologies" describes non-ship, non-weapon ship features
technologies = ScienceDatabase():setName(_('Technologies'))
technologies:setLongDescription(_([[This database covers ship systems and technologically created phenomena that spacefaring crews might encounter in densely populated regions of space.

This reference is intended only as a primer. Refer to your ship's technical manuals and training materials for details on maintaining and operating your craft.]]))

item = technologies:addEntry(_('Beam/shield frequencies'))
item:addKeyValue(_('Unit'), _('Terahertz'))
item:setLongDescription(_([[Ships with shield and beam systems can often configure their terahertz-frequency radiation. By manipulating these frequencies, savvy ship crews can maximize their beam weapon efficiency while reducing their enemies'.

A beam frequency that's resonant with a target's shield frequency can do considerably more damage, and beam frequencies can be quickly modulated. On the opposite effect, a fully dissonant shield frequency can negate considerably more beam energy per unit of energy, but requires several seconds of shield downtime to recalibrate.

If your Science officer fully scans a target, your ship's computer presents them with a detailed analysis of beam and shield frequencies and suggests optimal values for each.]]))

item = technologies:addEntry(_('Hacking measure'))
item:addKeyValue(_('Interaction'), _('Long-range transmission'))
item:setLongDescription(_([[Thanks to our covert operations teams, we've acquired enough information about our enemies' computer systems to repurpose our long-range communications systems into intrusion and exploitation tools.

While we've managed to create algorithmic attack vectors that you can deploy at range to target and degrade specific ship systems, these exploits still require active human intervention to fully function.

To facilitate successful operations in the field, our software engineers have abstracted the required inputs into common puzzles that even a Relay crew member can successfully complete.]]))

item = technologies:addEntry(_('Radar signature'))
item:addKeyValue(_('Signature'), _('Related color bands'))
item:addKeyValue(_('Biological'), _('Red, green'))
item:addKeyValue(_('Electrical'), _('Red, blue'))
item:addKeyValue(_('Gravitational'), _('Green, blue'))
item:setLongDescription(_([[The outer ring of long-range Science radar screens contain three colored bands that represent raw sensor inputs monitored on that heading. Ships and space phenomena emit energies or exhibit characteristics that your sensor suite translates into icons on your radar, but these raw rings can provide more information to a well-trained eye.

For tactical purposes, heat generated by ship systems is registered in raw thermal sensor data in a similar manner as biological (red, green) sources. If a ship's systems are under- or over-powered, its electrical (red, blue) readings change accordingly.

A ship warping or preparing to jump exponentially increases its gravitational (green, blue) output. After completing a jump a ship performs a massive power transfer that raw sensor data reads as an electrical spike.]]))

item = technologies:addEntry(_('Scan probe'))
item:addKeyValue(_('Radar range'), '5u')
item:addKeyValue(_('Typical lifetime'), _('10 minutes'))
item:addKeyValue(_('Interaction'), _('Systems link'))
item:setImage('radar/probe.png')
item:setModelDataName('SensorBuoyMkI')
item:setLongDescription(_([[Whether your mission involves scientific investigation, deep-space exploration, or military operations, remember to take advantage of any scan probes distributed for your ship.

Your Relay officer can launch a probe to any coordinates in their sector map, which fires its payload at high velocity directly toward the target coordinates. Upon arrival, Relay can then link the probe to the Science officer, who can switch their long-range radar to the probe's short-range radar.

This allows the Science officer to scan objects well outside of your ship's long-range radar range, including regions obfuscated by phenomena like nebulae that occlude your sensors.

Scan probes have a limited energy supply and expire within minutes, and your ship carries a limited number of them that only some stations can or will replenish.]]))

item = technologies:addEntry(_('Supply drop'))
item:addKeyValue(_('Contents'), _('Weapons, energy'))
item:addKeyValue(_('Interaction'), _('Close-range retrieval'))
item:setImage('radar/blip.png')
item:setModelDataName("ammo_box")
item:setLongDescription(_([[To expedite resupply actions, our engineers have standardized containers for weapons and energy that can be automatically and quickly integrated into your ship's systems.

Commonly known as a supply drop, your ship needs only to enter near-contact range with one of these containers to automatically engage your ship's acquisition and integration systems. Supply drops are cryptographically keyed to respond only to ships of the same faction, so theft isn't possible.]]))

item = technologies:addEntry(_('Warp jammer'))
item:addKeyValue(_('Interaction'), _('Short-range encounter'))
item:setImage('radar/blip.png')
item:setModelDataName('shield_generator')
item:setLongDescription(_([[Warp and jump technologies rely on technological manipulation of gravitational forces to achieve long-range travel. However, these manipulative forces can be nullified or interdicted by devices that generate electromagnetically simulated gravitational wells. Such devices are colloquially known as warp jammers, even though they can also prevent jumps.

A warping ship that enters a jammer's radius is interdicted and slowed to impulse speeds. A jumping ship is unable to engage its jump drive while within a jammer's radius.

Ship captains who value the option of retreat are advised to either give warp jammers a wide berth or prioritize their destruction.]]))

-- "Weapons" describes ship weapon types
weapons = ScienceDatabase():setName(_('Weapons'))
weapons:setLongDescription(_([[This database covers only the basic versions of missile weapons used throughout the galaxy.

It has been reported that some battleships started using larger variations of those missiles. Small fighters and even frigates should not have too much trouble dodging them, but space captains of bigger ships should be wary of their doubled damage potential.

Smaller variations of these missiles have become common in the galaxy, too. Fighter pilots praise their speed and maneuverability, because it gives them an edge against small and fast-moving targets. They only deal half the damage of their basic counterparts, but what good is a missile if it does not hit its target.]]))

item = weapons:addEntry(_('Homing missile'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Damage'), '35')
item:setLongDescription(_([[This target-seeking missile is the workhorse of many space combat arsenals. It's compact enough to be fitted on frigates, and packs enough punch to be used on larger ships, though usually in more than a single missile tube.]]))

item = weapons:addEntry(_('Nuke'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Blast radius'), '1u')
item:addKeyValue(_('Damage at center'), '160')
item:addKeyValue(_('Damage at edge'), '30')
item:setLongDescription(_([[A nuclear missile is similar to a homing missile in that it can seek a target, but it moves and turns more slowly and explodes a greatly increased payload. Its nuclear explosion spans 1U of space and can take out multiple ships in a single shot.

Some captains oppose the use of nuclear weapons because their large explosions can lead to 'fragging', or unintentional friendly fire. Shields should protect crews from harmful radiation, but because these weapons are often used in the thick of battle, there's no way of knowing if hull plating or shields can provide enough protection.]]))

item = weapons:addEntry(_('Mine'))
item:addKeyValue(_('Drop distance'), '1u')
item:addKeyValue(_('Trigger distance'), '0.6u')
item:addKeyValue(_('Blast radius'), '1u')
item:addKeyValue(_('Damage at center'), '160')
item:addKeyValue(_('Damage at edge'), '30')
item:setLongDescription(_([[Mines are often placed in defensive perimeters around stations. There are also old minefields scattered around the galaxy from older wars.

Some fearless captains use mines as offensive weapons, but their delayed detonation and blast radius make this use risky at best.]]))

item = weapons:addEntry(_('EMP'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Blast radius'), '1u')
item:addKeyValue(_('Damage at center'), '160')
item:addKeyValue(_('Damage at edge'), '30')
item:setLongDescription(_([[The electromagnetic pulse missile (EMP) reproduces the disruptive effects of a nuclear explosion, but without the destructive properties. This causes it to only affect shields within its blast radius, leaving their hulls intact. The EMP missile is also smaller and easier to store than heavy nukes. Many captains (and pirates) prefer EMPs over nukes for these reasons, and use them to knock out targets' shields before closing to disable them with focused beam fire.]]))

item = weapons:addEntry(_('HVLI'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Damage'), '10 each, 50 total')
item:addKeyValue(_('Burst'), '5')
item:setLongDescription(_([[A high-velocity lead impactor (HVLI) fires a simple slug of lead at a high velocity. This weapon is usually found in simpler ships since it does not require guidance computers. This also means its projectiles fly in a straight line from its tube and can't pursue a target.

Each shot from an HVLI fires a burst of 5 projectiles, which increases the chance to hit but requires precision aiming to be effective. It reaches its full damage potential at a range of 2u.]]))

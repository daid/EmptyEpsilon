--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not effect the game in any other way and just contributes to the lore.
--]]
space_objects = ScienceDatabase():setName('Natural')
item = space_objects:addEntry('Asteroid')
item:setLongDescription([[Asteroids are minor planets, usually smaller than a few kilometers. The larger variants are sometimes refered to as planetoids. ]])

item = space_objects:addEntry('Neblua')
item:setLongDescription([[Neblua are the birthing place of new stars. These gas fields, usually created by the death of an old star, slowly from new stars due to the gravitational pull of the gas molecules. Due to the ever changing nature of gas nebulaes, most radar and scanning technolgy is unable to detect objects that lie within. Science officers are therefore advised to rely on visual observations.]])

weapons = ScienceDatabase():setName('Weapons')
item = weapons:addEntry('Homing missile')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Damage', '35')
item:setLongDescription([[This target seeking missile is the work horse of many ships. It's compact enought to be fitted on frigates and packs enough punch to be used on larger ships, albeit with more than a single missile tube.]])

item = weapons:addEntry('Nuke')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[The nuclear missile is the same as the homing missile, but with a greatly increased (nuklear) payload. It is capable of taking out multiple ships in a single shot.
Some captains question the use of these weapons as they have lead to 'fragging' or un-intentional friendly fire. 
The shielding of ships should protect the crew from any harmfull radiation, but seeing that these weapons are often used in the thick of battle, there is no way of knowing if the hull plating or shield will provide enough protection.]])

item = weapons:addEntry('Mine')
item:addKeyValue('Drop distance', '1.2u')
item:addKeyValue('Trigger distance', '0.6u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[Mines are often placed in a defensive perimeter around stations.
There are also old mine fields scattered around the universe from older wars.
Some fearless captains have used mines as offensive weapons. But this is with great risk]])

item = weapons:addEntry('EMP')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[The EMP is a shield-only damaging weapon It matches the heavy nuke in damage but does no hull damage.
The EMP missile is smaller and easier to storage then the heavy nuke.
And thus many captains preferer it's use over nukes.]])

item = weapons:addEntry('HVLI')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Damage', '7 each, 35 total')
item:addKeyValue('Burst', '5')
item:setLongDescription([[HVLI: High Velocity Lead Impactor.
A simple large piece of lead fired at a high velocity. This weapon is usually found in simpler ships, as this weapon does not require any guidance computers.
This also means it only flies straight ahead and does not home in towards your target. After all, it is just a chunk of lead.
This weapon is fired in bursts of 5 shots. To increase the hit chance.]])

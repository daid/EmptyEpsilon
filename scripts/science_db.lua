--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not effect the game in any other way and just contributes to the lore.
--]]
weapons = ScienceDatabase():setName('Weapons')
item = weapons:addEntry('Homing missile')
item:addKeyValue('Range', '6km')
item:addKeyValue('Damage', '30')
item:setLongDescription([[This target seeking missile is the work horse of many ships. It's compact enought to be fitted on frigates and packs enough punch to be used on larger ships, albeit with more than a single missile tube.]])

item = weapons:addEntry('Nuke')
item:addKeyValue('Range', '4.8km')
item:addKeyValue('Blast radius', '1km')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[The nuclear missile is the same as the homing missile, but with a greatly increased (nuklear) payload. It is capable of taking out multiple ships in a single shot.
Some captains question the use of these weapons as they have lead to 'fragging' or un-intentional friendly fire. 
The shielding of ships should protect the crew from any harmfull radiation, but seeing that these weapons are often used in the thick of battle, there is no way of knowing if the hull plating or shield will provide enough protection.]])

item = weapons:addEntry('Mine')
item:addKeyValue('Drop distance', '1.2km')
item:addKeyValue('Trigger distance', '600m')
item:addKeyValue('Blast radius', '1km')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[Mines are often placed in a defensive perimeter around stations.
There are also old mine fields scattered around the universe from older wars.
Some fearless captains have used mines as offensive weapons. But this is with great risk]])

item = weapons:addEntry('EMP')
item:addKeyValue('Range', '4.8km')
item:addKeyValue('Blast radius', '1km')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[The EMP is a shield-only damaging weapon It matches the heavy nuke in damage but does no hull damage.
The EMP missile is smaller and easier to storage then the heavy nuke.
And thus many captains preferer it's use over nukes.]])

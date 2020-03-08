require("options.lua")
require(lang .. "/science_db.lua")

--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not affect the game in any other way and just contributes to the lore.
--]]

space_objects = ScienceDatabase():setName(spaceObjectsName)
item = space_objects:addEntry(asteroidName)
item:setLongDescription(asteroidDescription)

item = space_objects:addEntry(nebulaName)
item:setLongDescription(nebulaDescription)

item = space_objects:addEntry(blackHoleName)
item:setLongDescription(blackHoleDescription)

item = space_objects:addEntry(wormHoleName)
item:setLongDescription(wormHoleDescription)

weapons = ScienceDatabase():setName(weaponsName)
item = weapons:addEntry(homingMissileName)
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Damage', '35')
item:setLongDescription(homingMissileDescription)

item = weapons:addEntry(nukeName)
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription(nukeDescription)

item = weapons:addEntry(mineName)
item:addKeyValue('Drop distance', '1.2u')
item:addKeyValue('Trigger distance', '0.6u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription(mineDescription)

item = weapons:addEntry(empName)
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription(empDescription)

item = weapons:addEntry(hvliName)
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Damage', '7 each, 35 total')
item:addKeyValue('Burst', '5')
item:setLongDescription(hvliDescription)
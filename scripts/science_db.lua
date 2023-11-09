--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not affect the game in any other way and just contributes to the lore.
--]]

-- "Weapons" describes ship weapon types
weapons = ScienceDatabase():setName(_('Weapons'))
weapons:setLongDescription(_([[This database covers only the basic versions of missile weapons.]]))

item = weapons:addEntry(_('Homing missile'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Damage'), '35')
item:setLongDescription(_([[This target-seeking missile is the workhorse of many space combat arsenals. It's compact enough to be fitted on frigates, and packs enough punch to be used on larger ships, though usually in more than a single missile tube.]]))

item = weapons:addEntry('EMP')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[The electromagnetic pulse missile (EMP) reproduces the disruptive effects of a nuclear explosion, but without the destructive properties. This causes it to only affect shields within its blast radius, leaving their hulls intact. Many captains use EMP's to knock out targets' shields before closing to disable them with focused beam fire.]])

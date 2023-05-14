----------     CPU Ship Diversification Utility     ----------
--	Created from a desire to have a more diverse set up ships flying around out there.
--	Some of these are simple tweaks to existing ships. Some are more radically changed.
--	The intent for the armed ships is for them to be mixed in with the stock armed ships.
--	I usually end up creating a list of CPU ship templates:
--	ship_template = {	--ordered by relative strength
--		["Gnat"] =				{strength = 2,		create = gnat},
--		["Lite Drone"] =		{strength = 3,		create = droneLite},
--		["Jacket Drone"] =		{strength = 4,		create = droneJacket},
--		["Ktlitan Drone"] =		{strength = 4,		create = stockTemplate},
--	}
--	I order them by relative strength. This is an arbitrary value I give each ship to
--	help create groups of ships that are a consistent degree of difficulty compared to
--	the player ship or ships in the game. It's the create portion that is more
--	interesting in this context. With the templates set up in a list like this with the
--	create function in the list, a ship can be spawned like this:
--		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
--	...where you specify selected_template and enemyFaction using whatever criteria your
--	scenario requires.
--
--	No global variables per se, just the function names themselves.
function stockTemplate(enemyFaction,template)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate(template)
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	return ship
end
--------------------------------------------------------------------------------------------
--	Additional enemy ships with some modifications from the original template parameters  --
--------------------------------------------------------------------------------------------
function farco3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 3")
	ship:setShieldsMax(60, 40)									--stronger shields (vs 50, 40)
	ship:setShields(60, 40)					
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 3")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_3_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_3_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_3_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_3_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 3, the beams are longer and faster and the shields are slightly stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,		--jump range
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
function farco5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 5")
	ship:setShieldsMax(60, 40)				--stronger shields (vs 50, 40)
	ship:setShields(60, 40)	
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 5")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_5_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_5_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_5_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","30 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_5_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 5, the tubes load faster and the shields are slightly stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,		--jump range
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
function farco8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 8")
	ship:setShieldsMax(80, 50)				--stronger shields (vs 50, 40)
	ship:setShields(80, 50)	
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 8")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_8_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_8_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_8_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","30 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_8_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 8, the beams are longer and faster, the tubes load faster and the shields are stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,		--jump range
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
function farco11(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 11")
	ship:setShieldsMax(80, 50)				--stronger shields (vs 50, 40)
	ship:setShields(80, 50)	
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 10)
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setBeamWeapon(2,	20,	  0,	 1800,	5.0,	4.0)	--additional sniping beam
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 11")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_11_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_11_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_11_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_11_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 11, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam and the shields are stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,		--jump range
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
function farco13(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 13")
	ship:setShieldsMax(90, 70)				--stronger shields (vs 50, 40)
	ship:setShields(90, 70)	
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 10)
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setBeamWeapon(2,	20,	  0,	 1800,	5.0,	4.0)	--additional sniping beam
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	ship:setWeaponStorageMax("Homing",16)						--more (vs 6)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",30)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 30)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 13")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_13_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_13_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_13_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","30 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_13_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 13, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam, the tubes load faster, there are more missiles and the shields are stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,		--jump range
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
function whirlwind(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Storm")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Whirlwind")
	ship:setWeaponTubeCount(9)					--more (vs 5)
	ship:setWeaponTubeDirection(0,-90)			--3 left, 3 right, 3 front (vs 5 front)	
	ship:setWeaponTubeDirection(1,-92)				
	ship:setWeaponTubeDirection(2,-88)				
	ship:setWeaponTubeDirection(3, 90)				
	ship:setWeaponTubeDirection(4, 92)				
	ship:setWeaponTubeDirection(5, 88)				
	ship:setWeaponTubeDirection(6,  0)				
	ship:setWeaponTubeDirection(7,  2)				
	ship:setWeaponTubeDirection(8, -2)				
	ship:setWeaponStorageMax("Homing",36)						--more (vs 15)
	ship:setWeaponStorage("Homing", 36)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 15)
	ship:setWeaponStorage("HVLI", 36)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local whirlwind_key = _("scienceDB","Whirlwind")
	local storm_key = _("scienceDB","Storm")
	local whirlwind_db = queryScienceDatabase(ships_key,frigate_key,whirlwind_key)
	if whirlwind_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(whirlwind_key)
			whirlwind_db = queryScienceDatabase(ships_key,frigate_key,whirlwind_key)
			local tube_key = _("scienceDB","Tube -90")
			local tube2_key = _("scienceDB","Tube -92")
			local tube3_key = _("scienceDB","Tube -88")
			local tube4_key = _("scienceDB","Tube  90")
			local tube5_key = _("scienceDB","Tube  92")
			local tube6_key = _("scienceDB","Tube  88")
			local tube7_key = _("scienceDB","Tube   0")
			local tube8_key = _("scienceDB","Tube   2")
			local tube9_key = _("scienceDB","Tube  -2")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,storm_key),	--base ship database entry
				whirlwind_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Whirlwind, another heavy artillery cruiser, takes the Storm and adds tubes and missiles. It's as if the Storm swallowed a Pirahna and grew gills. Expect to see missiles, lots of missiles"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube9_key, value = load_val},	--torpedo tube direction and load speed
				},
				nil,		--jump range
				"HeavyCorvetteYellow"
			)
		end
	end
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local phobos_r2_key = _("scienceDB","Phobos R2")
	local phobos_key = _("scienceDB","Phobos T3")
	local phobos_r2_db = queryScienceDatabase(ships_key,frigate_key,phobos_r2_key)
	if phobos_r2_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(phobos_r2_key)
			phobos_r2_db = queryScienceDatabase(ships_key,frigate_key,phobos_r2_key)
			local tube_key = _("scienceDB","Tube 0")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				phobos_r2_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
				},
				nil,	--jump
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("MV52 Hornet")
	ship:setBeamWeapon(0, 30, 0, 1000.0, 4.0, 3.0)	--longer and stronger beam (vs 700 & 2)
	ship:setRotationMaxSpeed(31)					--faster maneuver (vs 30)
	ship:setImpulseMaxSpeed(130)					--faster impulse (vs 120)
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local mv52_hornet_key = _("scienceDB","MV52 Hornet")
	local hornet_key = _("scienceDB","MT52 Hornet")
	local hornet_mv52_db = queryScienceDatabase(ships_key,starfighter_key,mv52_hornet_key)
	if hornet_mv52_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(mv52_hornet_key)
			hornet_mv52_db = queryScienceDatabase(ships_key,starfighter_key,mv52_hornet_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,hornet_key),	--base ship database entry
				hornet_mv52_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The MV52 Hornet is very similar to the MT52 and MU52 models. The beam does more damage than both of the other Hornet models, it's max impulse speed is faster than both of the other Hornet models, it turns faster than the MT52, but slower than the MU52"),
				nil,	--misc key value pairs
				nil,	--jump
				"WespeScoutYellow"
			)
		end
	end
	return ship
end
function k2fighter(enemyFaction)
	local k2_key = _("scienceDB","K2 Fighter")
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName(k2_key)
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local ktlitan_key = _("scienceDB","Ktlitan Fighter")
	local k2_fighter_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
	if k2_fighter_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(k2_key)
			k2_fighter_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				k2_fighter_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is a bit weaker."),
				nil,	--misc key value pairs
				nil,	--jump range
				"sci_fi_alien_ship_1"
			)
		end
	end
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local k3_key = _("scienceDB","K3 Fighter")
	local ktlitan_key = _("scienceDB","Ktlitan Fighter")
	local k3_fighter_db = queryScienceDatabase(ships_key,no_class_key,k3_key)
	if k3_fighter_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(k3_key)
			k3_fighter_db = queryScienceDatabase(ships_key,no_class_key,k3_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				k3_fighter_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that are stronger and that cycle faster, but the hull is weaker."),
				nil,	--misc key value pairs
				nil,		--jump range
				"sci_fi_alien_ship_1"
			)
		end
	end
	return ship
end	
function waddle5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Waddle 5")
	ship:setWarpDrive(true)
--				   Index,  Arc,	  Dir, Range, Cycle,	Damage
	ship:setBeamWeapon(2,	70,	  -30,	 600,	5.0,	2.0)	--adjust beam direction to match starboard side (vs -35)
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local waddle5_key = _("scienceDB","Waddle 5")
	local adder_key = _("scienceDB","Adder MK5")
	local waddle_5_db = queryScienceDatabase(ships_key,starfighter_key,waddle5_key)
	if waddle_5_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(waddle5_key)
			waddle_5_db = queryScienceDatabase(ships_key,starfighter_key,waddle5_key)
			local tube_key = _("scienceDB","Small tube 0")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,adder_key),	--base ship database entry
				waddle_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
				},
				nil,	--jump range
				"AdlerLongRangeScoutYellow"
			)
		end
	end
	return ship
end
function jade5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Jade 5")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)
--				   Index,  Arc,	  Dir, Range, Cycle,	Damage
	ship:setBeamWeapon(2,	70,	  -30,	 600,	5.0,	2.0)	--adjust beam direction to match starboard side (vs -35)
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local jade5_key = _("scienceDB","Jade 5")
	local adder_key = _("scienceDB","Adder MK5")
	local jade_5_db = queryScienceDatabase(ships_key,starfighter_key,jade5_key)
	if jade_5_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(jade5_key)
			jade_5_db = queryScienceDatabase(ships_key,starfighter_key,jade5_key)
			local tube_key = _("scienceDB","Small tube 0")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,adder_key),	--base ship database entry
				jade_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
				},
				"5 - 35 U"	,	--jump range
				"AdlerLongRangeScoutYellow"
			)
		end
	end
	return ship
end
function droneLite(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Lite Drone")
	ship:setHullMax(20)					--weaker hull (vs 30)
	ship:setHull(20)
	ship:setImpulseMaxSpeed(130)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(20)		--faster maneuver (vs 10)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local lite_drone_key = _("scienceDB","Lite Drone")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local drone_lite_db = queryScienceDatabase(ships_key,no_class_key,lite_drone_key)
	if drone_lite_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(lite_drone_key)
			drone_lite_db = queryScienceDatabase(ships_key,no_class_key,lite_drone_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				drone_lite_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The light drone was pieced together from scavenged parts of various damaged Ktlitan drones. Compared to the Ktlitan drone, the lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed"),
				nil,	--misc key value pairs
				nil,	--jump
				"sci_fi_alien_ship_4"
			)
		end
	end
	return ship
end
function droneHeavy(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Heavy Drone")
	ship:setHullMax(40)					--stronger hull (vs 30)
	ship:setHull(40)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,8)	--stronger (vs 6) beam
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local heavy_drone_key = _("scienceDB","Heavy Drone")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local drone_heavy_db = queryScienceDatabase(ships_key,no_class_key,heavy_drone_key)
	if drone_heavy_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(heavy_drone_key)
			drone_heavy_db = queryScienceDatabase(ships_key,no_class_key,heavy_drone_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				drone_heavy_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower"),
				nil,	--misc key value pairs
				nil,	--jump
				"sci_fi_alien_ship_4"
			)
		end
	end
	return ship
end
function droneJacket(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Jacket Drone")
	ship:setShieldsMax(20)				--stronger shields (vs none)
	ship:setShields(20)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local jacket_drone_key = _("scienceDB","Jacket Drone")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local drone_jacket_db = queryScienceDatabase(ships_key,no_class_key,jacket_drone_key)
	if drone_jacket_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(jacket_drone_key)
			drone_jacket_db = queryScienceDatabase(ships_key,no_class_key,jacket_drone_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				drone_jacket_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield"),
				nil,	--misc key value pairs
				nil,	--jump
				"sci_fi_alien_ship_4"
			)
		end
	end
	return ship
end
function wzLindworm(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("WX-Lindworm")
	ship:setTypeName("WZ-Lindworm")
	ship:setWeaponStorageMax("Nuke",2)		--more nukes (vs 0)
	ship:setWeaponStorage("Nuke",2)
	ship:setWeaponStorageMax("Homing",4)	--more homing (vs 1)
	ship:setWeaponStorage("Homing",4)
	ship:setWeaponStorageMax("HVLI",12)		--more HVLI (vs 6)
	ship:setWeaponStorage("HVLI",12)
	ship:setRotationMaxSpeed(12)			--slower maneuver (vs 15)
	ship:setHullMax(45)						--weaker hull (vs 50)
	ship:setHull(45)
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local wzlindworm_key = _("scienceDB","WZ-Lindworm")
	local worm_key = _("scienceDB","WX-Lindworm")
	local wz_lindworm_db = queryScienceDatabase(ships_key,starfighter_key,wzlindworm_key)
	if wz_lindworm_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(wzlindworm_key)
			wz_lindworm_db = queryScienceDatabase(ships_key,starfighter_key,wzlindworm_key)
			local tube_key = _("scienceDB","Small tube 0")
			local tube2_key = _("scienceDB","Small tube 1")
			local tube3_key = _("scienceDB","Small tube -1")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,worm_key),	--base ship database entry
				wz_lindworm_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
				},
				nil,	--jump
				"LindwurmFighterYellow"
			)
		end
	end
	return ship
end
function tempest(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F12")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Tempest")
	ship:setWeaponTubeCount(10)						--four more tubes (vs 6)
	ship:setWeaponTubeDirection(0, -88)				--5 per side
	ship:setWeaponTubeDirection(1, -89)				--slight angle spread
	ship:setWeaponTubeDirection(3,  88)				--3 for HVLI each side
	ship:setWeaponTubeDirection(4,  89)				--2 for homing and nuke each side
	ship:setWeaponTubeDirection(6, -91)				
	ship:setWeaponTubeDirection(7, -92)				
	ship:setWeaponTubeDirection(8,  91)				
	ship:setWeaponTubeDirection(9,  92)				
	ship:setWeaponTubeExclusiveFor(7,"HVLI")
	ship:setWeaponTubeExclusiveFor(9,"HVLI")
	ship:setWeaponStorageMax("Homing",16)			--more (vs 6)
	ship:setWeaponStorage("Homing", 16)				
	ship:setWeaponStorageMax("Nuke",8)				--more (vs 0)
	ship:setWeaponStorage("Nuke", 8)				
	ship:setWeaponStorageMax("HVLI",34)				--more (vs 20)
	ship:setWeaponStorage("HVLI", 34)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local tempest_key = _("scienceDB","Tempest")
	local pirahna_key = _("scienceDB","Piranha F12")
	local tempest_db = queryScienceDatabase(ships_key,frigate_key,tempest_key)
	if tempest_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(tempest_key)
			tempest_db = queryScienceDatabase(ships_key,frigate_key,tempest_key)
			local tube_key = _("scienceDB","Large tube -88")
			local tube2_key = _("scienceDB","Tube -89")
			local tube3_key = _("scienceDB","Large tube -90")
			local tube4_key = _("scienceDB","Large tube 88")
			local tube5_key = _("scienceDB","Tube 89")
			local tube6_key = _("scienceDB","Large tube 90")
			local tube7_key = _("scienceDB","Tube -91")
			local tube8_key = _("scienceDB","Tube -92")
			local tube9_key = _("scienceDB","Tube 91")
			local tube10_key = _("scienceDB","Tube 92")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,pirahna_key),	--base ship database entry
				tempest_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube9_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube10_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,	--jump
				"HeavyCorvetteRed"
			)
		end
	end
	return ship
end
function enforcer(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Blockade Runner")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Enforcer")
	ship:setRadarTrace("ktlitan_destroyer.png")			--different radar trace
	ship:setWarpDrive(true)										--warp (vs none)
	ship:setWarpSpeed(600)
	ship:setImpulseMaxSpeed(100)								--faster impulse (vs 60)
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 15)
	ship:setShieldsMax(200,100,100)								--stronger shields (vs 100,150)
	ship:setShields(200,100,100)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	30,	    5,	1500,		6,		10)	--narrower (vs 60), longer (vs 1000), stronger (vs 8)
	ship:setBeamWeapon(1,	30,	   -5,	1500,		6,		10)
	ship:setBeamWeapon(2,	 0,	    0,	   0,		0,		 0)	--fewer (vs 4)
	ship:setBeamWeapon(3,	 0,	    0,	   0,		0,		 0)
	ship:setWeaponTubeCount(3)									--more (vs 0)
	ship:setTubeSize(0,"large")									--large (vs normal)
	ship:setWeaponTubeDirection(1,-15)				
	ship:setWeaponTubeDirection(2, 15)				
	ship:setTubeLoadTime(0,18)
	ship:setTubeLoadTime(1,12)
	ship:setTubeLoadTime(2,12)			
	ship:setWeaponStorageMax("Homing",18)						--more (vs 0)
	ship:setWeaponStorage("Homing", 18)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local enforcer_key = _("scienceDB","Enforcer")
	local blockade_runner_key = _("scienceDB","Blockade Runner")
	local enforcer_db = queryScienceDatabase(ships_key,frigate_key,enforcer_key)
	if enforcer_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(enforcer_key)
			enforcer_db = queryScienceDatabase(ships_key,frigate_key,enforcer_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube -15")
			local tube3_key = _("scienceDB","Tube 15")
			local load_val = _("scienceDB","18 sec")
			local load2_val = _("scienceDB","12 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,blockade_runner_key),	--base ship database entry
				enforcer_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and strengthened front beams."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load2_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load2_val},		--torpedo tube direction and load speed
				},
				nil,	--jump
				"battleship_destroyer_3_upgraded"
			)
			enforcer_db:setImage("radar/ktlitan_destroyer.png")		--override default radar image
		end
	end
	return ship		
end
function predator(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Predator")
	ship:setShieldsMax(100,100)									--stronger shields (vs 30,30)
	ship:setShields(100,100)					
	ship:setHullMax(80)											--stronger hull (vs 70)
	ship:setHull(80)
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 40)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	    0,	1000,		6,		 4)	--more (vs 0)
	ship:setBeamWeapon(1,	90,	  180,	1000,		6,		 4)	
	ship:setWeaponTubeCount(8)									--more (vs 3)
	ship:setWeaponTubeDirection(0,-60)				
	ship:setWeaponTubeDirection(1,-90)				
	ship:setWeaponTubeDirection(2,-90)				
	ship:setWeaponTubeDirection(3, 60)				
	ship:setWeaponTubeDirection(4, 90)				
	ship:setWeaponTubeDirection(5, 90)				
	ship:setWeaponTubeDirection(6,-120)				
	ship:setWeaponTubeDirection(7, 120)				
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Homing")
	ship:setWeaponTubeExclusiveFor(2,"Homing")
	ship:setWeaponTubeExclusiveFor(3,"Homing")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeExclusiveFor(5,"Homing")
	ship:setWeaponTubeExclusiveFor(6,"Homing")
	ship:setWeaponTubeExclusiveFor(7,"Homing")
	ship:setWeaponStorageMax("Homing",32)						--more (vs 5)
	ship:setWeaponStorage("Homing", 32)		
	ship:setWeaponStorageMax("HVLI",0)							--less (vs 10)
	ship:setWeaponStorage("HVLI", 0)
	ship:setRadarTrace("missile_cruiser.png")				--different radar trace
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local predator_key = _("scienceDB","Predator")
	local pirahna_key = _("scienceDB","Piranha F8")
	local predator_db = queryScienceDatabase(ships_key,frigate_key,predator_key)
	if predator_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(predator_key)
			predator_db = queryScienceDatabase(ships_key,frigate_key,predator_key)
			local tube_key = _("scienceDB","Large tube -60")
			local tube2_key = _("scienceDB","Tube -90")
			local tube3_key = _("scienceDB","Large tube -90")
			local tube4_key = _("scienceDB","Large tube 60")
			local tube5_key = _("scienceDB","Tube 90")
			local tube6_key = _("scienceDB","Large tube 90")
			local tube7_key = _("scienceDB","Tube -120")
			local tube8_key = _("scienceDB","Tube 120")
			local load_val = _("scienceDB","12 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,pirahna_key),	--base ship database entry
				predator_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},		--torpedo tube direction and load speed
				},
				"5 - 35 U"		--jump range
			)
			predator_db:setImage("radar/missile_cruiser.png")		--override default radar image
			predator_db:setModelDataName("HeavyCorvetteRed")
		end
	end
	return ship		
end
function atlantisY42(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Atlantis X23")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Atlantis Y42")
	ship:setShieldsMax(300,200,300,200)							--stronger shields (vs 200,200,200,200)
	ship:setShields(300,200,300,200)					
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 3.5)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(2,	80,	  190,	1500,		6,		 8)	--narrower (vs 100)
	ship:setBeamWeapon(3,	80,	  170,	1500,		6,		 8)	--extra (vs 3 beams)
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)
	local ships_key = _("scienceDB","Ships")
	local corvette_key = _("scienceDB","Corvette")
	local y42_key = _("scienceDB","Atlantis Y42")
	local atlantis_key = _("scienceDB","Atlantis X23")
	local atlantis_y42_db = queryScienceDatabase(ships_key,corvette_key,y42_key)
	if atlantis_y42_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,corvette_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(y42_key)
			atlantis_y42_db = queryScienceDatabase(ships_key,corvette_key,y42_key)
			local tube_key = _("scienceDB","Tube -90")
			local tube2_key = _("scienceDB"," Tube -90")
			local tube3_key = _("scienceDB","Tube 90")
			local tube4_key = _("scienceDB"," Tube 90")
			local load_val = _("scienceDB","10 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,corvette_key,atlantis_key),	--base ship database entry
				atlantis_y42_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
				},
				"5 - 50 U",		--jump range
				"battleship_destroyer_1_upgraded"
			)
		end
	end
	return ship		
end
function starhammerV(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Starhammer V")
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 35)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setShieldsMax(450, 350, 250, 250, 350)					--stronger shields (vs 450, 350, 150, 150, 350)
	ship:setShields(450, 350, 250, 250, 350)					
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(4,	60,	  180,	1500,		8,		11)	--extra rear facing beam
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 36)
	local ships_key = _("scienceDB","Ships")
	local corvette_key = _("scienceDB","Corvette")
	local starhammerV_key = _("scienceDB","Starhammer V")
	local starhammer2_key = _("scienceDB","Starhammer II")
	local starhammer_v_db = queryScienceDatabase(ships_key,corvette_key,starhammerV_key)
	if starhammer_v_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,corvette_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(starhammerV_key)
			starhammer_v_db = queryScienceDatabase(ships_key,corvette_key,starhammerV_key)
			local tube_key = _("scienceDB","Tube 0")
			local tube2_key = _("scienceDB"," Tube 0")
			local load_val = _("scienceDB","10 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,corvette_key,starhammer2_key),	--base ship database entry
				starhammer_v_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
				},
				"5 - 50 U",		--jump range
				"battleship_destroyer_4_upgraded"
			)
		end
	end
	return ship		
end
function tyr(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Battlestation")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Tyr")
	ship:setImpulseMaxSpeed(50)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(10)								--faster maneuver (vs 1.5)
	ship:setShieldsMax(400, 300, 300, 400, 300, 300)			--stronger shields (vs 300, 300, 300, 300, 300)
	ship:setShields(400, 300, 300, 400, 300, 300)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	  -60,	2500,		6,		 8)	--stronger beams, broader coverage
	ship:setBeamWeapon(1,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(2,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(3,	90,	  120,	2500,		6,		 8)
	ship:setBeamWeapon(4,	90,	  -60,	2500,		6,		 8)
	ship:setBeamWeapon(5,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(6,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(7,	90,	  120,	2500,		6,		 8)
	ship:setBeamWeapon(8,	90,	  -60,	2500,		6,		 8)
	ship:setBeamWeapon(9,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(10,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(11,	90,	  120,	2500,		6,		 8)
	local ships_key = _("scienceDB","Ships")
	local dreadnought_key = _("scienceDB","Dreadnought")
	local tyr_key = _("scienceDB","Tyr")
	local battlestation_key = _("scienceDB","Battlestation")
	local tyr_db = queryScienceDatabase(ships_key,dreadnought_key,tyr_key)
	if tyr_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,dreadnought_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(tyr_key)
			tyr_db = queryScienceDatabase(ships_key,dreadnought_key,tyr_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,dreadnought_key,battlestation_key),	--base ship database entry
				tyr_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Tyr is the shipyard's answer to admiral Konstatz' casual statement that the Battlestation model was too slow to be effective. The shipyards improved on the Battlestation by fitting the Tyr with more than twice the impulse speed and more than six times the turn speed. They threw in stronger shields and hull and wider beam coverage just to show that they could"),
				nil,
				"5 - 50 U",		--jump range
				"Ender Battlecruiser"
			)
		end
	end
	return ship
end
function gnat(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Gnat")
	ship:setHullMax(15)					--weaker hull (vs 30)
	ship:setHull(15)
	ship:setImpulseMaxSpeed(140)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(25)		--faster maneuver (vs 10)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,   40,		0,	 600,		4,		 3)	--weaker (vs 6) beam
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local gnat_key = _("scienceDB","Gnat")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local gnat_db = queryScienceDatabase(ships_key,no_class_key,gnat_key)
	if gnat_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(gnat_key)
			gnat_db = queryScienceDatabase(ships_key,no_class_key,gnat_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				gnat_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Gnat is a nimbler version of the Ktlitan Drone. It's got half the hull, but it moves and turns faster"),
				nil,	--misc key value pairs
				nil,	--jump range
				"sci_fi_alien_ship_4"
			)
		end
	end
	return ship
end
function cucaracha(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Tug")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Cucaracha")
	ship:setShieldsMax(200, 50, 50, 50, 50, 50)		--stronger shields (vs 20)
	ship:setShields(200, 50, 50, 50, 50, 50)					
	ship:setHullMax(100)							--stronger hull (vs 50)
	ship:setHull(100)
	ship:setRotationMaxSpeed(20)					--faster maneuver (vs 10)
	ship:setAcceleration(30)						--faster acceleration (vs 15)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	60,	    0,	1500,		6,		10)	--extra rear facing beam
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local cucaracha_key = _("scienceDB","Cucaracha")
	local tug_key = _("scienceDB","Tug")
	local cucaracha_db = queryScienceDatabase(ships_key,no_class_key,cucaracha_key)
	if cucaracha_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(cucaracha_key)
			cucaracha_db = queryScienceDatabase(ships_key,no_class_key,cucaracha_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,tug_key),	--base ship database entry
				cucaracha_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Cucaracha is a quick ship built around the Tug model with heavy shields and a heavy beam designed to be difficult to squash"),
				nil,
				nil,		--jump range
				"space_tug"
			)
		end
	end
	return ship
end
function maniapak(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Maniapak")
	ship:setRadarTrace("exuari_fighter.png")			--different radar trace
	ship:setImpulseMaxSpeed(70)					--slower impulse (vs 80)
	ship:setWeaponTubeCount(9)					--more (vs 1)
	ship:setWeaponTubeDirection(0,  0)				
	ship:setWeaponTubeDirection(1,-10)				
	ship:setWeaponTubeDirection(2, 10)				
	ship:setWeaponTubeDirection(3,  0)				
	ship:setWeaponTubeDirection(4,-12)				
	ship:setWeaponTubeDirection(5, 12)				
	ship:setWeaponTubeDirection(6,  0)				
	ship:setWeaponTubeDirection(7,-15)				
	ship:setWeaponTubeDirection(8, 15)				
	ship:setTubeSize(0,"small")
	ship:setTubeSize(1,"small")
	ship:setTubeSize(2,"small")
	ship:setTubeSize(6,"large")
	ship:setTubeSize(7,"large")
	ship:setTubeSize(8,"large")
	ship:setTubeLoadTime(0,15)
	ship:setTubeLoadTime(1,16)
	ship:setTubeLoadTime(2,17)
	ship:setTubeLoadTime(3,18)
	ship:setTubeLoadTime(4,19)
	ship:setTubeLoadTime(5,20)
	ship:setTubeLoadTime(6,21)
	ship:setTubeLoadTime(7,22)
	ship:setTubeLoadTime(8,23)
	ship:setWeaponStorageMax("Homing", 27)		--more (vs 0)
	ship:setWeaponStorage("Homing",    27)
	ship:setWeaponStorageMax("EMP",    18)		--more (vs 0)
	ship:setWeaponStorage("EMP",       18)
	ship:setWeaponStorageMax("Nuke",   27)		--more (vs 0)
	ship:setWeaponStorage("Nuke",      27)
	ship:setWeaponStorageMax("HVLI",   36)		--more (vs 4)
	ship:setWeaponStorage("HVLI",      36)
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local maniapak_key = _("scienceDB","Maniapak")
	local adder_key = _("scienceDB","Adder MK5")
	local maniapak_db = queryScienceDatabase(ships_key,starfighter_key,maniapak_key)
	if maniapak_db == nil then
		local fighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if fighter_db ~= nil then
			fighter_db:addEntry(maniapak_key)
			maniapak_db = queryScienceDatabase(ships_key,starfighter_key,maniapak_key)
			local tube_key = _("scienceDB","Small tube 0")
			local tube2_key = _("scienceDB","Small tube -10")
			local tube3_key = _("scienceDB","Small tube 10")
			local tube4_key = _("scienceDB","Tube 0")
			local tube5_key = _("scienceDB","Tube -12")
			local tube6_key = _("scienceDB","Tube 12")
			local tube7_key = _("scienceDB","Large tube 0")
			local tube8_key = _("scienceDB","Large tube -15")
			local tube9_key = _("scienceDB","Large tube 15")
			local load_val = _("scienceDB","15 sec")
			local load2_val = _("scienceDB","16 sec")
			local load3_val = _("scienceDB","17 sec")
			local load4_val = _("scienceDB","18 sec")
			local load5_val = _("scienceDB","19 sec")
			local load6_val = _("scienceDB","20 sec")
			local load7_val = _("scienceDB","21 sec")
			local load8_val = _("scienceDB","22 sec")
			local load9_val = _("scienceDB","23 sec")
			local storage_key = _("scienceDB","Missile Storage")
			local storage_val = _("scienceDB","H:27 E:18 N:27 L:36")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,adder_key),	--base ship database entry
				maniapak_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Maniapak is an extreme modification of an Adder MK5 and a Blade. A maniacal designer was tasked with packing as many missiles as possible in this tiny starfighter frame. This record has yet to be beaten. Unfortunately, this ship is often a danger to friends as well as foes."),
				{
					{key = tube_key, value = load_val},		--torpedo tube size, direction and load speed
					{key = tube2_key, value = load2_val},		--torpedo tube size, direction and load speed
					{key = tube3_key, value = load3_val},		--torpedo tube size, direction and load speed
					{key = tube4_key, value = load4_val},
					{key = tube5_key, value = load5_val},
					{key = tube6_key, value = load6_val},
					{key = tube7_key, value = load7_val},
					{key = tube8_key, value = load8_val},
					{key = tube9_key, value = load9_val},
					{key = storage_key, value = storage_val},
				},
				nil,
				"AdlerLongRangeScoutYellow"
			)
			maniapak_db:setImage("radar/exuari_fighter.png")		--override default radar image
		end
	end
	return ship		
end
function starhammerIII(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Starhammer III")
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(4,	60,	  180,	1500,		8,		11)	--extra rear facing beam
	ship:setTubeSize(0,"large")
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 36)
	local ships_key = _("scienceDB","Ships")
	local corvette_key = _("scienceDB","Corvette")
	local starhammer3_key = _("scienceDB","Starhammer III")
	local starhammer2_key = _("scienceDB","Starhammer II")
	local starhammer_iii_db = queryScienceDatabase(ships_key,corvette_key,starhammer3_key)
	if starhammer_iii_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,corvette_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(starhammer3_key)
			starhammer_iii_db = queryScienceDatabase(ships_key,corvette_key,starhammer3_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube 0")
			local load_val = _("scienceDB","10 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,corvette_key,starhammer2_key),	--base ship database entry
				starhammer_iii_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The designers of the Starhammer III took the Starhammer II and added a rear facing beam, enlarged one of the missile tubes and added more missiles to fire"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},			--torpedo tube direction and load speed
				},
				"5 - 50 U",		--jump range
				"battleship_destroyer_4_upgraded"
			)
		end
	end
	return ship
end
function k2breaker(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Breaker")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("K2 Breaker")
	ship:setHullMax(200)							--stronger hull (vs 120)
	ship:setHull(200)
	ship:setWeaponTubeCount(3)						--more (vs 1)
	ship:setTubeSize(0,"large")						--large (vs normal)
	ship:setWeaponTubeDirection(1,-30)				
	ship:setWeaponTubeDirection(2, 30)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")		--only HVLI (vs any)
	ship:setWeaponStorageMax("Homing",16)			--more (vs 0)
	ship:setWeaponStorage("Homing", 16)
	ship:setWeaponStorageMax("HVLI",8)				--more (vs 5)
	ship:setWeaponStorage("HVLI", 8)
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local k2_key = _("scienceDB","K2 Breaker")
	local ktlitan_key = _("scienceDB","Ktlitan Breaker")
	local k2_breaker_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
	if k2_breaker_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(k2_key)
			k2_breaker_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube -30")
			local tube3_key = _("scienceDB","Tube 30")
			local load_val = _("scienceDB","13 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				k2_breaker_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The K2 Breaker designers took the Ktlitan Breaker and beefed up the hull, added two bracketing tubes, enlarged the center tube and added more missiles to shoot. Should be good for a couple of enemy ships"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,	--jump
				"sci_fi_alien_ship_2"
			)
		end
	end
	return ship
end
function hurricane(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Hurricane")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,40000)			
	ship:setWeaponTubeCount(8)						--more (vs 3)
	ship:setWeaponTubeExclusiveFor(1,"HVLI")		--only HVLI (vs any)
	ship:setWeaponTubeDirection(1,  0)				--forward (vs -90)
	ship:setTubeSize(3,"large")						
	ship:setWeaponTubeDirection(3,-90)
	ship:setTubeSize(4,"small")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeDirection(4,-15)
	ship:setTubeSize(5,"small")
	ship:setWeaponTubeExclusiveFor(5,"Homing")
	ship:setWeaponTubeDirection(5, 15)
	ship:setWeaponTubeExclusiveFor(6,"Homing")
	ship:setWeaponTubeDirection(6,-30)
	ship:setWeaponTubeExclusiveFor(7,"Homing")
	ship:setWeaponTubeDirection(7, 30)
	ship:setWeaponStorageMax("Homing",24)			--more (vs 5)
	ship:setWeaponStorage("Homing", 24)
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local hurricane_key = _("scienceDB","Hurricane")
	local pirahna_key = _("scienceDB","Piranha F8")
	local hurricane_db = queryScienceDatabase(ships_key,frigate_key,hurricane_key)
	if hurricane_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(hurricane_key)
			hurricane_db = queryScienceDatabase(ships_key,frigate_key,hurricane_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube 0")
			local tube3_key = _("scienceDB","Large tube 90")
			local tube4_key = _("scienceDB","Large tube -90")
			local tube5_key = _("scienceDB","Small tube -15")
			local tube6_key = _("scienceDB","Small tube 15")
			local tube7_key = _("scienceDB","Tube -30")
			local tube8_key = _("scienceDB","Tube 30")
			local load_val = _("scienceDB","12 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,pirahna_key),	--base ship database entry
				hurricane_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Hurricane is designed to jump in and shower the target with missiles. It is based on the Piranha F8, but with a jump drive, five more tubes in various directions and sizes and lots more missiles to shoot"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},			--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},		--torpedo tube direction and load speed
				},
				"5 - 40 U",		--jump range
				"HeavyCorvetteRed"
			)
		end
	end
	return ship
end
function phobosT4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Phobos T4")
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 10)
	ship:setShieldsMax(80,30)									--stronger shields (vs 50,40)
	ship:setShields(80,30)					
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	  -15,	1500,		6,		6)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	   15,	1500,		6,		6)	
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local t4_key = _("scienceDB","Phobos T4")
	local phobos_key = _("scienceDB","Phobos T3")
	local phobos_t4_db = queryScienceDatabase(ships_key,frigate_key,t4_key)
	if phobos_t4_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(t4_key)
			phobos_t4_db = queryScienceDatabase(ships_key,frigate_key,t4_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				phobos_t4_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Phobos T4 makes some simple improvements on the Phobos T3: faster maneuver, stronger front shields, though weaker rear shields and longer and faster beam weapons"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
				},
				nil,		--jump range
				"AtlasHeavyFighterYellow"
			)
		end
	end
	return ship
end
--	unarmed ships
function spaceSedan(enemyFaction)
	local ship = CpuShip():setTemplate("Personnel Jump Freighter 3")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local sedan_key = _("scienceDB","Space Sedan")
	ship:setTypeName(sedan_key):setCommsScript(""):setCommsFunction(commsShip)
	addFreighter(sedan_key,ship)	--update science database if applicable
	return ship
end
function courier(enemyFaction)
	local ship = CpuShip():setTemplate("Personnel Freighter 1")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local courier_key = _("scienceDB","Courier")
	ship:setTypeName(courier_key):setCommsScript(""):setCommsFunction(commsShip)
	ship:setWarpDrive(true)
	ship:setWarpSpeed(1500)
	ship:setRotationMaxSpeed(20)
	addFreighter(courier_key,ship)	--update science database if applicable
	return ship
end
function workWagon(enemyFaction)
	local ship = CpuShip():setTemplate("Equipment Freighter 2")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local wagon_key = _("scienceDB","Work Wagon")
	ship:setTypeName(wagon_key):setCommsScript(""):setCommsFunction(commsShip)
	ship:setWarpDrive(true)
	ship:setWarpSpeed(200)
	addFreighter(wagon_key,ship)	--update science database if applicable
	return ship
end
function omnibus(enemyFaction)
	local ship = CpuShip():setTemplate("Personnel Jump Freighter 5")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local omnibus_key = _("scienceDB","Omnibus")
	ship:setTypeName(omnibus_key):setCommsScript(""):setCommsFunction(commsShip)
	addFreighter(omnibus_key,ship)	--update science database if applicable
	return ship
end
function ladenLorry(enemyFaction)
	local ship = CpuShip():setTemplate("Goods Freighter 3")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local lorry_key = _("scienceDB","Laden Lorry")
	ship:setTypeName(lorry_key):setCommsScript(""):setCommsFunction(commsShip)
	ship:setWarpDrive(true)
	ship:setWarpSpeed(150)
	addFreighter(lorry_key,ship)	--update science database if applicable
	return ship
end
function physicsResearch(enemyFaction)
	local ship = CpuShip():setTemplate("Garbage Freighter 3")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local physics_key = _("scienceDB","Physics Research")
	ship:setTypeName(physics_key):setCommsScript(""):setCommsFunction(commsShip)
	ship:setImpulseMaxSpeed(65)				--faster impulse (vs 45)
	ship:setRotationMaxSpeed(10)			--faster maneuver (vs 6)
	ship:setShieldsMax(80, 80)				--stronger shields (vs 50, 50)
	ship:setShields(80, 80)					
	addFreighter(physics_key,ship)	--update science database if applicable
	return ship
end
function serviceJonque(enemyFaction)
	local ship = CpuShip():setTemplate("Garbage Jump Freighter 4")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	local jonque_key = _("scienceDB","Service Jonque")
	ship:setTypeName(jonque_key):setCommsScript(""):setCommsFunction(commsServiceJonque)
	addFreighter(jonque_key,ship)	--update science database if applicable
	return ship
end
--	science database update functions
function genericFreighterScienceInfo(specific_freighter_db,base_db,ship)
	local freighter_key = _("scienceDB","Freighter")
	local subclass_key = _("scienceDB","Sub-class")
	local size_key = _("scienceDB","Size")
	specific_freighter_db:setImage("radar/transport.png")
	specific_freighter_db:setKeyValue(subclass_key,freighter_key)
	specific_freighter_db:setKeyValue(size_key,base_db:getKeyValue(size_key))
	local shields = ship:getShieldCount()
	if shields > 0 then
		local shield_string = ""
		for i=1,shields do
			if shield_string == "" then
				shield_string = string.format("%i",math.floor(ship:getShieldMax(i-1)))
			else
				shield_string = string.format("%s/%i",shield_string,math.floor(ship:getShieldMax(i-1)))
			end
		end
		specific_freighter_db:setKeyValue("Shield",shield_string)
	end
	specific_freighter_db:setKeyValue("Hull",string.format("%i",math.floor(ship:getHullMax())))
	specific_freighter_db:setKeyValue("Move speed",string.format("%.1f u/min",ship:getImpulseMaxSpeed()*60/1000))
	specific_freighter_db:setKeyValue("Turn speed",string.format("%.1f deg/sec",ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		local base_jump_range = base_db:getKeyValue("Jump range")
		if base_jump_range ~= nil and base_jump_range ~= "" then
			specific_freighter_db:setKeyValue("Jump range",base_jump_range)
		else
			specific_freighter_db:setKeyValue("Jump range","5 - 50 u")
		end
	end
	if ship:hasWarpDrive() then
		specific_freighter_db:setKeyValue("Warp Speed",string.format("%.1f u/min",ship:getWarpSpeed()*60/1000))
	end
end
function addFreighters()
	local ships_key = _("scienceDB","Ships")
	local freighter_key = _("scienceDB","Freighter")
	local freighter_db = queryScienceDatabase(ships_key,freighter_key)
	if freighter_db == nil then
		local ship_db = queryScienceDatabase(ships_key)
		ship_db:addEntry(freighter_key)
		freighter_db = queryScienceDatabase(ships_key,freighter_key)
		freighter_db:setImage("radar/transport.png")
		freighter_db:setLongDescription(_("scienceDB","Small, medium and large scale transport ships. These are the working ships that keep commerce going in any sector. They may carry personnel, goods, cargo, equipment, garbage, fuel, research material, etc."))
	end
	return freighter_db
end
function addFreighter(freighter_type,ship)
	local ships_key = _("scienceDB","Ships")
	local freighter_key = _("scienceDB","Freighter")
	local corvette_key = _("scienceDB","Corvette")
	local sedan_key = _("scienceDB","Space Sedan")
	local omnibus_key = _("scienceDB","Omnibus")
	local jonque_key = _("scienceDB","Service Jonque")
	local courier_key = _("scienceDB","Courier")
	local wagon_key = _("scienceDB","Work Wagon")
	local lorry_key = _("scienceDB","Laden Lorry")
	local physics_key = _("scienceDB","Physics Research")
	local freighter_db = addFreighters()
	if freighter_type ~= nil then
		if freighter_type == sedan_key then
			local space_sedan_db = queryScienceDatabase(ships_key,freighter_key,sedan_key)
			if space_sedan_db == nil then
				local pjf3_key = _("scienceDB","Personnel Jump Freighter 3")
				freighter_db:addEntry(sedan_key)
				space_sedan_db = queryScienceDatabase(ships_key,freighter_key,sedan_key)
				genericFreighterScienceInfo(space_sedan_db,queryScienceDatabase(ships_key,corvette_key,pjf3_key),ship)
				space_sedan_db:setModelDataName("transport_1_3")
				space_sedan_db:setLongDescription(_("scienceDB","The Space Sedan was built around a surplus Personnel Jump Freighter 3. It's designed to provide relatively low cost transportation primarily for people, but there is also a limited amount of cargo space available"))
			end
		elseif freighter_type == omnibus_key then
			local omnibus_db = queryScienceDatabase(ships_key,freighter_key,omnibus_key)
			if omnibus_db == nil then
				local pjf5_key = _("scienceDB","Personnel Jump Freighter 5")
				freighter_db:addEntry(omnibus_key)
				omnibus_db = queryScienceDatabase(ships_key,freighter_key,omnibus_key)
				genericFreighterScienceInfo(omnibus_db,queryScienceDatabase(ships_key,corvette_key,pjf5_key),ship)
				omnibus_db:setModelDataName("transport_1_5")
				omnibus_db:setLongDescription(_("scienceDB","The Omnibus was designed from the Personnel Jump Freighter 5. It's made to transport large numbers of passengers of various types along with their luggage and any associated cargo"))
			end
		elseif freighter_type == jonque_key then
			local service_jonque_db = queryScienceDatabase(ships_key,freighter_key,jonque_key)
			if service_jonque_db == nil then
				local ejf4_key = _("scienceDB","Equipment Jump Freighter 4")
				freighter_db:addEntry(jonque_key)
				service_jonque_db = queryScienceDatabase(ships_key,freighter_key,jonque_key)
				genericFreighterScienceInfo(service_jonque_db,queryScienceDatabase(ships_key,corvette_key,"Equipment Jump Freighter 4"),ship)
				service_jonque_db:setModelDataName("transport_4_4")
				service_jonque_db:setLongDescription(_("scienceDB","The Service Jonque is a modified Equipment Jump Freighter 4. It's designed to carry spare parts and equipment as well as the necessary repair personnel to where it's needed to repair stations and ships"))
			end
		elseif freighter_type == courier_key then
			local courier_db = queryScienceDatabase(ships_key,freighter_key,courier_key)
			if courier_db == nil then
				local pf1_key = _("scienceDB","Personnel Freighter 1")
				freighter_db:addEntry(courier_key)
				courier_db = queryScienceDatabase(ships_key,freighter_key,courier_key)
				genericFreighterScienceInfo(courier_db,queryScienceDatabase(ships_key,corvette_key,pf1_key),ship)
				courier_db:setModelDataName("transport_1_1")
				courier_db:setLongDescription(_("scienceDB","The Courier is a souped up Personnel Freighter 1. It's made to deliver people and messages fast. Very fast"))
			end
		elseif freighter_type == wagon_key then
			local work_wagon_db = queryScienceDatabase(ships_key,freighter_key,wagon_key)
			if work_wagon_db == nil then
				local ef2_key = _("scienceDB","Equipment Freighter 2")
				freighter_db:addEntry(wagon_key)
				work_wagon_db = queryScienceDatabase(ships_key,freighter_key,wagon_key)
				genericFreighterScienceInfo(work_wagon_db,queryScienceDatabase(ships_key,corvette_key,ef2_key),ship)
				work_wagon_db:setModelDataName("transport_4_2")
				work_wagon_db:setLongDescription(_("scienceDB","The Work Wagon is a conversion of an Equipment Freighter 2 designed to carry equipment and parts where they are needed for repair or construction."))
			end
		elseif freighter_type == lorry_key then
			local laden_lorry_db = queryScienceDatabase(ships_key,freighter_key,lorry_key)
			if laden_lorry_db == nil then
				local gf3_key = _("scienceDB","Goods Freighter 3")
				freighter_db:addEntry(lorry_key)
				laden_lorry_db = queryScienceDatabase(ships_key,freighter_key,lorry_key)
				genericFreighterScienceInfo(laden_lorry_db,queryScienceDatabase(ships_key,corvette_key,gf3_key),ship)
				laden_lorry_db:setModelDataName("transport_2_3")
				laden_lorry_db:setLongDescription(_("scienceDB","As a side contract, Conversion R Us put together the Laden Lorry from some recently acquired Goods Freighter 3 hulls. The added warp drive makes for a more versatile goods carrying vessel."))
			end
		elseif freighter_type == physics_key then
			local physics_research_db = queryScienceDatabase(ships_key,freighter_key,physics_key)
			if physics_research_db == nil then
				local garf3_key = _("scienceDB","Garbage Freighter 3")
				freighter_db:addEntry(physics_key)
				physics_research_db = queryScienceDatabase(ships_key,freighter_key,physics_key)
				genericFreighterScienceInfo(physics_research_db,queryScienceDatabase(ships_key,corvette_key,garf3_key),ship)
				physics_research_db:setModelDataName("transport_3_3")
				physics_research_db:setLongDescription(_("scienceDB","Conversion R Us cleaned up and converted excess freighter hulls into Physics Research vessels. The reduced weight improved the impulse speed and maneuverability."))
			end
		end
	end
end
function addShipToDatabase(base_db,modified_db,ship,description,tube_directions,jump_range,model_name)
	modified_db:setLongDescription(description)
	if base_db ~= nil then
		modified_db:setImage(base_db:getImage())
		local class_key = _("scienceDB","Class")
		local subclass_key = _("scienceDB","Sub-class")
		local size_key = _("scienceDB","Size")
		modified_db:setKeyValue(class_key,base_db:getKeyValue(class_key))
		modified_db:setKeyValue(subclass_key,base_db:getKeyValue(subclass_key))
		modified_db:setKeyValue(size_key,base_db:getKeyValue(size_key))
	end
	local shields = ship:getShieldCount()
	if shields > 0 then
		local shield_string = ""
		for i=1,shields do
			if shield_string == "" then
				shield_string = string.format("%i",math.floor(ship:getShieldMax(i-1)))
			else
				shield_string = string.format("%s/%i",shield_string,math.floor(ship:getShieldMax(i-1)))
			end
		end
		local shield_key = _("scienceDB","Shield")
		modified_db:setKeyValue(shield_key,shield_string)
	end
	local hull_key = _("scienceDB","Hull")
	local move_speed_key = _("scienceDB","Move speed")
	local reverse_move_speed_key = _("scienceDB","Reverse move speed")
	local turn_speed_key = _("scienceDB","Turn speed")
	local impulse_forward, impulse_reverse = ship:getImpulseMaxSpeed()
	modified_db:setKeyValue(hull_key,string.format("%i",math.floor(ship:getHullMax())))
	modified_db:setKeyValue(move_speed_key,string.format(_("scienceDB","%.1f u/min"),impulse_forward*60/1000))
	modified_db:setKeyValue(reverse_move_speed_key,string.format(_("scienceDB","%.1f u/min"),impulse_reverse*60/1000))
	modified_db:setKeyValue(turn_speed_key,string.format(_("scienceDB","%.1f deg/sec"),ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		local jump_range_key = _("scienceDB","Jump range")
		if jump_range == nil then
			local base_jump_range = nil
			if base_db ~= nil then
				base_jump_range = base_db:getKeyValue(jump_range_key)
			end
			if base_jump_range ~= nil and base_jump_range ~= "" then
				modified_db:setKeyValue(jump_range_key,base_jump_range)
			else
				modified_db:setKeyValue(jump_range_key,"5 - 50 u")
			end
		else
			modified_db:setKeyValue(jump_range_key,jump_range)
		end
	end
	if ship:hasWarpDrive() then
		local ward_speed_key = _("scienceDB","Warp Speed")
		modified_db:setKeyValue(ward_speed_key,string.format(_("scienceDB","%.1f u/min"),ship:getWarpSpeed()*60/1000))
	end
	local key = ""
	if ship:getBeamWeaponRange(0) > 0 then
		local bi = 0
		local count_repeat_loop = 0
		repeat
			local beam_direction = ship:getBeamWeaponDirection(bi)
			if beam_direction > 315 and beam_direction < 360 then
				beam_direction = beam_direction - 360
			end
			key = string.format(_("scienceDB","Beam weapon %.1f:%.1f"),ship:getBeamWeaponDirection(bi),ship:getBeamWeaponArc(bi))
			while(modified_db:getKeyValue(key) ~= "") do
				key = " " .. key
			end
			modified_db:setKeyValue(key,string.format(_("scienceDB","%.1f Dmg / %.1f sec"),ship:getBeamWeaponDamage(bi),ship:getBeamWeaponCycleTime(bi)))
			bi = bi + 1
			count_repeat_loop = count_repeat_loop + 1
		until(ship:getBeamWeaponRange(bi) < 1 or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when going through beams")
		end
	end
	local tubes = ship:getWeaponTubeCount()
	if tubes > 0 then
		if tube_directions ~= nil then
			for i=1,#tube_directions do
				modified_db:setKeyValue(tube_directions[i].key,tube_directions[i].value)
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for index, missile_type in ipairs(missile_types) do
			local max_storage = ship:getWeaponStorageMax(missile_type)
			if max_storage > 0 then
				modified_db:setKeyValue(string.format(_("scienceDB","Storage %s"),missile_type),string.format("%i",max_storage))
			end
		end
	end
	if model_name ~= nil then
		modified_db:setModelDataName(model_name)
	end
end

--[[                  Frigates
Frigates are 1 size up from starfighters. They require a crew from 3 to 20 people.
Think, Firefly, millennium falcon.
They generally have 2 or more shield sections. But more then 4 would be extremely rare.
This class of ships is normally not fitted with jump or warp drives. But in some cases ships are modified to include these, or for certain roles it is build in.

They are divided in 3 different sub-classes:
* Cruiser: Weaponized frigates, focused on combat. These come in various roles.
* Light transport: Small transports, like transporting up to 50 soldiers. Or a few diplomats. Depending on the role can have some weaponry.
* Support: Support types come in many variaties. They are simply a frigate hull fitted with whatever was needed. Anything from mine-layers to science vessels.
----------------------------------------------------------]]
template = ShipTemplate():setName("Phobos T3"):setClass("Frigate", "Cruiser"):setModel("AtlasHeavyFighterYellow")
template:setDescription([[Generic cruiser, not specialized in anything.]])
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(60, 10, 10)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)

variation = template:copy("Phobos M3"):setModel("AtlasHeavyFighterRed")
variation:setDescription([[Upgraded Phobos T3 to include a mine subsystem]])
variation:setTubes(3, 10.0)
variation:setWeaponStorage("Mine", 6)
variation:weaponTubeDisallowMissle(0, "Mine"):weaponTubeDisallowMissle(1, "Mine")
variation:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, "Mine")

template = ShipTemplate():setName("Nirvana R5"):setClass("Frigate", "Cruiser: Anti Starfighter"):setModel("small_frigate_5") -- TODO: Better 3D model selection
template:setDescription([[Anti fighter cruiser. Has a large amount of fast firing, low damage lasers to quickly take out starfighter class ships.]])
template:setBeamWeapon(0, 90, -15, 1200, 3, 1)
template:setBeamWeapon(1, 90,  15, 1200, 3, 1)
template:setBeamWeapon(2, 90,  50, 1200, 3, 1)
template:setBeamWeapon(3, 90, -50, 1200, 3, 1)
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(70, 12, 10)

variation = template:copy("Nirvana R5A")
variation:setDescription([[Advanced version of the Nirvana R5. Faster turning speed and slightly more fire power]])
variation:setBeamWeapon(0, 90, -15, 1200, 2.9, 1)
variation:setBeamWeapon(1, 90,  15, 1200, 2.9, 1)
variation:setBeamWeapon(2, 90,  50, 1200, 2.9, 1)
variation:setBeamWeapon(3, 90, -50, 1200, 2.9, 1)
variation:setSpeed(70, 15, 10)

template = ShipTemplate():setName("Piranha F12"):setClass("Frigate", "Cruiser: Light Artillery"):setModel("small_frigate_5") -- TODO: Better 3D model selection
template:setDescription([[Light artillery cruiser, smallest ship that is an exclusive broadside.]])
template:setHull(70)
template:setShields(30, 30)
template:setSpeed(40, 6, 8)
template:setTubes(6, 12.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -90):setWeaponTubeExclusiveFor(0, "HVLI")
template:setTubeDirection(1, -90)
template:setTubeDirection(2, -90):setWeaponTubeExclusiveFor(2, "HVLI")
template:setTubeDirection(3,  90):setWeaponTubeExclusiveFor(3, "HVLI")
template:setTubeDirection(4,  90)
template:setTubeDirection(5,  90):setWeaponTubeExclusiveFor(5, "HVLI")

variation = template:copy("Piranha F12.M")
variation:setDescription([[Modified F12 Piranha. In all aspects the same, except that it has made special modifications to fire Nukes next to the normal loadout. This does lower the overal missile storage.]])
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 4)
variation:setWeaponStorage("Nuke", 2)

variation = template:copy("Piranha F8")
variation:setDescription([[First version of the Piranha that was sold. Not popular due to the low amount of firepower, and the odd tube configuration. A huge financial failure.]])
variation:setTubes(3, 12.0)
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 5)
variation:setTubeDirection(0,   0)
variation:setTubeDirection(1, -90)
variation:setTubeDirection(2,  90)

template = ShipTemplate():setName("Ranus U"):setClass("Frigate", "Cruiser: Sniper"):setModel("dark_fighter_6") -- TODO: Better 3D model selection
template:setDescription([[The sniper is intended to fly in, deal a quick large amount of damage from a distance, and head off again. It's the only basic frigate that carries nukes. Of all frigates, this is the smalles one.]])
template:setHull(30)
template:setShields(30, 5, 5)
template:setSpeed(50, 6, 20)
template:setTubes(3, 25.0)
template:weaponTubeDisallowMissle(1, "Nuke"):weaponTubeDisallowMissle(2, "Nuke")
template:setWeaponStorage("Homing", 6)
template:setWeaponStorage("Nuke", 2)

--Cruiser: stike craft (fast in/out)
--Cruiser: tackler
--Cruiser: sniper
--Light transport: troop transport
--Light transport: 
--Support: mine layer
--Support: mine sweeper
--Support: science vessel
--Support: deep space recon
--Support: light repair
--Support: resupply

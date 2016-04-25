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

template = ShipTemplate():setName("Nirvana R5"):setClass("Frigate", "Cruiser: Anti Starfighter"):setModel("?")
template:setDescription([[Anti fighter cruiser. Has a large amount of fast firing, low damage lasers to quickly take out starfighter class ships.]])
template:setBeamWeapon(0, 90, -15, 1200, 3, 1)
template:setBeamWeapon(1, 90,  15, 1200, 3, 1)
template:setBeamWeapon(2, 90,  50, 1200, 3, 1)
template:setBeamWeapon(3, 90, -50, 1200, 3, 1)
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(70, 12, 10)

template = ShipTemplate():setName("Piranha F12"):setClass("Frigate", "Cruiser: Light Artillery"):setModel("?")
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

template = ShipTemplate():setName("Piranha F12.M"):setClass("Frigate", "Cruiser: Light Artillery"):setModel("?")
template:setDescription([[Modified F12 Piranha. In all aspects the same, except that it has made special modifications to fire Nukes next to the normal loadout. This does lower the overal missile storage.]])
template:setHull(70)
template:setShields(30, 30)
template:setSpeed(40, 6, 8)
template:setTubes(6, 12.0)
template:setWeaponStorage("HVLI", 14)
template:setWeaponStorage("Homing", 4)
template:setWeaponStorage("Nuke", 2)
template:setTubeDirection(0, -90):setWeaponTubeExclusiveFor(0, "HVLI")
template:setTubeDirection(1, -90)
template:setTubeDirection(2, -90):setWeaponTubeExclusiveFor(2, "HVLI")
template:setTubeDirection(3,  90):setWeaponTubeExclusiveFor(3, "HVLI")
template:setTubeDirection(4,  90)
template:setTubeDirection(5,  90):setWeaponTubeExclusiveFor(5, "HVLI")

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

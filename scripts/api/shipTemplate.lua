-- Global to store all the templates.
__ship_templates = {}
__player_ship_templates = {}
__allow_new_player_ships = true

-- Called by the engine to populate the list of player ships that can be spawned.
-- Returns a list of {key, label, description}.
function getSpawnablePlayerShips()
    local result = {}
    if __allow_new_player_ships then
        for i, v in ipairs(__player_ship_templates) do
            if not v.__hidden then
                result[#result+1] = {v.typename.type_name, v.typename.localized, v.__description}
            end
        end
    end
    return result
end
-- Called by the engine when on the server the user wants to spawn a player ship.
-- Called with the [key] from the list returned in getSpawnablePlayerShips
function spawnPlayerShipFromUI(key)
    if not __allow_new_player_ships then return end
    for i, v in ipairs(__player_ship_templates) do
        if not v.__hidden and v.typename.type_name == key then
            local ship = PlayerSpaceship()
            ship:setTemplate(key)
            return ship
        end
    end
end

function allowNewPlayerShips(enabled)
    if enabled ~= nil then
        __allow_new_player_ships = enabled
    end
    return __allow_new_player_ships
end

--- A ShipTemplate defines the base functionality, stats, models, and other details for the ShipTemplateBasedObjects created from it.
--- ShipTemplateBasedObjects belong to either the SpaceStation or SpaceShip subclasses. SpaceShips in turn belong to the CpuShip or PlayerSpaceship classes.
--- ShipTemplates appear in ship and space station creation lists, such as the ship selection screen on scenarios that allow player ship creation, or the GM console's object creation tool.
--- They also appear as default entries in the science database.
--- EmptyEpsilon loads scripts/shipTemplates.lua at launch, which requires files containing ShipTemplates located in scripts/shiptemplates/.
--- New ShipTemplates can't be defined while a scenario is running.
--- Use Lua variables to apply several ShipTemplate functions to the same template.
--- Example:
--- -- Create a ShipTemplate for a Cruiser Frigate-class CpuShip designated Phobos T3
--- template = ShipTemplate():setName("Phobos T3"):setLocaleName(_("ship","Phobos T3")):setClass(_("class","Frigate"),_("subclass","Cruiser"))
--- -- Set the Phobos T3's appearance to the ModelData named "AtlasHeavyFighterYellow"
--- template:setModel("AtlasHeavyFighterYellow")
ShipTemplate = createClass()
function ShipTemplate:__init__()
    self.radar_trace = {
        icon="radar/arrow.png",
        radius=300.0*0.8,
        max_size=1024,
        color_by_faction=true,
    }
    self.__repair_crew_count = 3
    self.share_short_range_radar = {}
    self.comms_receiver = {script="comms_ship.lua"}
end

--- Sets this ShipTemplate's unique reference name.
--- Use this value for referencing this ShipTemplate in scripts.
--- If this value begins with "Player ", including the trailing space, EmptyEpsilon uses only what follows as the name.
--- If this ShipTemplate lacks a localized name (ShipTemplate:setLocaleName()), it defaults to this reference name.
--- Example: template:setName("Phobos T3")
function ShipTemplate:setName(name)
    __ship_templates[name] = self
    self.typename = {type_name=name, localized=name}
    return self
end
--- Sets the displayed vessel model designation for ShipTemplateBasedObjects created from this ShipTemplate.
--- Use with the _ function to expose the localized name to translation.
--- Examples:
--- template:setLocaleName("Phobos T3")
--- template:setLocaleName(_("ship","Phobos T3")) -- with a translation-exposed name
function ShipTemplate:setLocaleName(name)
    self.typename.localized = name
    return self
end
--- Sets the vessel class and subclass for ShipTemplateBasedObjects created from this ShipTemplate.
--- Vessel classes are used to define certain traits across similar ships, such as dockability.
--- See also ShipTemplate:setExternalDockClasses() and ShipTemplate:setInternalDockClasses().
--- For consistent class usage across translations, wrap class name strings in the _ function.
--- Defaults to the equivalent value of (_("No class"),_("No sub-class")).
--- Examples:
--- template:setClass(_("class","Frigate"),_("subclass","Cruiser"))
function ShipTemplate:setClass(class, subclass)
    if self.docking_port == nil then self.docking_port = {} end
    self.docking_port.dock_class = class
    self.docking_port.dock_subclass = subclass
    return self
end
--- Sets the description shown in the science database for ShipTemplateBasedObjects created from this ShipTemplate.
--- Example: template:setDescription(_("The Phobos T3 is most any navy's workhorse frigate."))
function ShipTemplate:setDescription(description)
    self.__description = description
    return self
end
--- Sets the object-oriented subclass of ShipTemplateBasedObject to create from this ShipTemplate.
--- Defaults to "ship" (CpuShip).
--- Valid values are "ship", "playership" (PlayerSpaceship), and "station" (SpaceStation).
--- Using setType("station") is equivalent to also using ShipTemplate:setRepairDocked(true) and ShipTemplate:setRadarTrace("blip.png").
--- Example: template:setType("playership")
function ShipTemplate:setType(template_type)
    self.__type = template_type
    if template_type == "playership" then
        __player_ship_templates[#__player_ship_templates + 1] = self
        --Add some default player ship components.
        self.reactor = {}
        self.coolant = {}
        self.self_destruct = {}
        self.science_scanner = {}
        self.scan_probe_launcher = {}
        self.hacking_device = {}
        self.long_range_radar = {}
        self.comms_transmitter = {}
        self.comms_receiver = nil
    end
    if template_type == "station" then
        if self.docking_bay == nil then self.docking_bay = {} end
        self.docking_bay.repair = true
        if self.radar_trace.icon == "radar/arrow.png" then
            self.radar_trace.icon = "radar/blip.png"
        end
        self.comms_receiver = {script="comms_station.lua"}
    end
    return self
end
--- If declared, this function hides this ShipTemplate from creation features and the science database.
--- Hidden templates provide backward compatibility to older scenario scripts.
--- Example: template:hidden() -- hides this template
function ShipTemplate:hidden(hidden)
    self.__hidden = hidden
    return self
end
--- Sets the default combat AI state for CpuShips created from this ShipTemplate.
--- Combat AI states determine the AI's combat tactics and responses.
--- They're distinct from orders, which determine the ship's active objectives and are defined by CpuShip:order...() functions.
--- Valid combat AI states are:
--- - "default" directly pursues enemies at beam range while making opportunistic missile attacks
--- - "evasion" maintains distance from enemy weapons and evades attacks
--- - "fighter" prefers strafing maneuvers and attacks briefly at close range while passing
--- - "missilevolley" prefers lining up missile attacks from long range
--- Example: template:setAI("fighter") -- default to the "fighter" combat AI state
function ShipTemplate:setDefaultAI(default_ai)
    self.ai_controller = {new_name=default_ai}
    return self
end
--- Sets the 3D appearance, by ModelData name, of ShipTemplateBasedObjects created from this ShipTemplate.
--- ModelData objects define a 3D mesh, textures, adjustments, and collision box, and are loaded from scripts/model_data.lua when EmptyEpsilon is launched.
--- Example: template:setModel("AtlasHeavyFighterYellow") -- uses the ModelData named "AtlasHeavyFighterYellow"
function ShipTemplate:setModel(model_data_name)
    self.__model_data_name = model_data_name
    for k, v in pairs(__model_data[model_data_name]) do
        if string.sub(1, 2) ~= "__" then
            self[k] = table.deepcopy(v)
        end
    end
    if self.physics and self.radar_trace then
        if type(self.physics.size) == "table" then
            self.radar_trace.radius = self.physics.size[1] * 0.8
        else
            self.radar_trace.radius = self.physics.size * 0.8
        end
    end
    return self
end
--- As ShipTemplate:setExternalDockClasses().
function ShipTemplate:setDockClasses(...)
    return self:setExternalDockClasses(...)
end
--- Defines a list of vessel classes that can be externally docked to ShipTemplateBasedObjects created from this ShipTemplate.
--- External docking keeps the docked ship attached to the outside of the carrier.
--- By default, SpaceStations allow all classes of SpaceShips to dock externally.
--- For consistent class usage across translations, wrap class name strings in the _ function.
--- Example: template:setExternalDockClasses(_("class","Frigate"),_("class","Corvette")) -- all Frigate and Corvette ships can dock to the outside of this ShipTemplateBasedObject
function ShipTemplate:setExternalDockClasses(...)
    if self.docking_bay == nil then self.docking_bay = {} end
    self.docking_bay.external_dock_classes = {...}
    return self
end
--- Defines a list of ship classes that can be docked inside of ShipTemplateBasedObjects created from this ShipTemplate.
--- Internal docking stores the docked ship inside of this derived ShipTemplateBasedObject.
--- For consistent class usage across translations, wrap class name strings in the _ function.
--- Example: template:setInternalDockClasses(_("class","Starfighter")) -- all Starfighter ships can dock inside of this ShipTemplateBasedObject
function ShipTemplate:setInternalDockClasses(...)
    if self.docking_bay == nil then self.docking_bay = {} end
    self.docking_bay.internal_dock_classes = {...}
    return self
end
--- Sets the amount of energy available for PlayerSpaceships created from this ShipTemplate.
--- Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
--- Defaults to 1000.
--- Example: template:setEnergyStorage(500)
function ShipTemplate:setEnergyStorage(amount)
    self.reactor = {max_energy=amount, energy=amount}
    return self
end
--- Sets the default number of repair crew for PlayerSpaceships created from this ShipTemplate.
--- Defaults to 3.
--- Only PlayerSpaceships use repair crews. Setting this for other ShipTemplateBasedObject types has no effect.
--- Example: template:setRepairCrewCount(5)
function ShipTemplate:setRepairCrewCount(amount)
    self.__repair_crew_count = amount
    return self
end
--- As ShipTemplate:setBeamWeapon().
function ShipTemplate:setBeam(index, arc, direction, range, cycle_time, damage)
    return self:setBeamWeapon(index, arc, direction, range, cycle_time, damage)
end
--- Defines the traits of a BeamWeapon for ShipTemplateBasedObjects created from this ShipTemplate.
--- - index: Each beam weapon in this ShipTemplate must have a unique index.
--- - arc: Sets the arc of its firing capability, in degrees.
--- - direction: Sets the default center angle of the arc, in degrees relative to the ship's forward bearing. Value can be negative.
--- - range: Sets how far away the beam can fire.
--- - cycle_time: Sets the base firing delay, in seconds. System effectiveness modifies the cycle time.
--- - damage: Sets the base damage done by the beam to the target. System effectiveness modifies the damage.
--- To add multiple beam weapons to a ship, invoke this function multiple times, assigning each weapon a unique index value.
--- To create a turreted beam, also add ShipTemplate:setBeamWeaponTurret(), and set the beam weapon's arc to be smaller than the turret's arc.
--- Example: setBeamWeapon(0,90,-15,1200,3,1) -- index 0, 90-degree arc centered -15 degrees from forward, extending 1.2U, firing every 3 seconds and dealing 1 damage
function ShipTemplate:setBeamWeapon(index, arc, direction, range, cycle_time, damage)
    if self.beam_weapons == nil then self.beam_weapons = {} end
    while #self.beam_weapons < index + 1 do
        self.beam_weapons[#self.beam_weapons + 1] = {}
    end
    self.beam_weapons[index + 1] = {arc=arc, direction=direction, range=range, cycle_time=cycle_time, damage=damage}
    return self
end
--- Converts a BeamWeapon into a turret and defines its traits for SpaceShips created from this ShipTemplate.
--- A turreted beam weapon rotates within its turret arc toward the weapons target at the given rotation rate.
--- - index: Must match the index of an existing beam weapon.
--- - arc: Sets the turret's maximum targeting angles, in degrees. The turret arc must be larger than the associated beam weapon's arc.
--- - direction: Sets the default center angle of the turret arc, in degrees relative to the ship's forward bearing. Value can be negative.
--- - rotation_rate: Sets how many degrees per tick that the associated beam weapon's direction can rotate toward the target within the turret arc. System effectiveness modifies the rotation rate.
--- To create a turreted beam, also add ShipTemplate:setBeamWeapon(), and set the beam weapon's arc to be smaller than the turret's arc.
--- Example:
--- -- Makes beam weapon 0 a turret with a 200-degree turret arc centered on 90 degrees from forward, rotating at 5 degrees per tick (unit?)
--- template:setBeamWeaponTurret(0,200,90,5)
function ShipTemplate:setBeamWeaponTurret(index, arc, direction, rotation_rate)
    self.beam_weapons[index + 1].turret_arc = arc
    self.beam_weapons[index + 1].turret_direction = arc
    self.beam_weapons[index + 1].turret_rotation_rate = rotation_rate
    return self
end
--- Sets the BeamEffect texture, by filename, for the BeamWeapon with the given index on SpaceShips created from this ShipTemplate.
--- See BeamEffect:setTexture().
--- Example: template:setBeamWeaponTexture("texture/beam_blue.png")
function ShipTemplate:setBeamTexture(index, texture)
    self.beam_weapons[index + 1].texture = texture
    return self
end
--- Sets how much energy is drained each time the BeamWeapon with the given index is fired.
--- Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
--- Defaults to 3.0, as defined in src/spaceObjects/spaceshipParts/beamWeapon.cpp.
--- Example: template:setBeamWeaponEnergyPerFire(0,1) -- sets beam 0 to use 1 energy per firing
function ShipTemplate:setBeamWeaponEnergyPerFire(index, amount)
    self.beam_weapons[index + 1].energy_per_beam_fire = amount
    return self
end
--- Sets how much "beamweapon" system heat is generated, in percentage of total system heat capacity, each time the BeamWeapon with the given index is fired.
--- Only PlayerSpaceships generate and manage heat. Setting this for other ShipTemplateBasedObject types has no effect.
--- Defaults to 0.02, as defined in src/spaceObjects/spaceshipParts/beamWeapon.cpp.
--- Example: template:setBeamWeaponHeatPerFire(0,0.5) -- sets beam 0 to generate 0.5 (50%) system heat per firing
function ShipTemplate:setBeamWeaponHeatPerFire(index, amount)
    self.beam_weapons[index + 1].heat_per_beam_fire = amount
    return self
end
--- Sets the number of WeaponTubes for ShipTemplateBasedObjects created from this ShipTemplate, and the default delay for loading and unloading each tube, in seconds.
--- Weapon tubes are 0-indexed. For example, 3 tubes would be indexed 0, 1, and 2.
--- Ships are limited to a maximum of 16 weapon tubes.
--- The default ShipTemplate adds 0 tubes and an 8-second loading time.
--- Example: template:setTubes(6,15.0) -- creates 6 weapon tubes with 15-second loading times
function ShipTemplate:setTubes(amount, loading_time)
    if self.missile_tubes == nil then self.missile_tubes = {} end
    for n=1,amount do
        self.missile_tubes[n] = {load_time=loading_time}
    end
    return self
end
--- Sets the delay, in seconds, for loading and unloading the WeaponTube with the given index.
--- Defaults to 8.0.
--- Example: template:setTubeLoadTime(0,12) -- sets the loading time for tube 0 to 12 seconds
function ShipTemplate:setTubeLoadTime(index, time)
    self.missile_tubes[index+1].load_time = time
    return self
end
--- Sets which weapon types the WeaponTube with the given index can load.
--- Note the spelling of "missle".
--- Example: template:weaponTubeAllowMissle(0,"Homing") -- allows Homing missiles to be loaded in tube 0
function ShipTemplate:weaponTubeAllowMissle(index, type)
    local type = string.lower(type)
    self.missile_tubes[index+1]["allow_"..type] = true
    return self
end
--- Sets which weapon types the WeaponTube with the given index can't load.
--- Note the spelling of "missle".
--- Example: template:weaponTubeDisallowMissle(0,"Homing") -- prevents Homing missiles from being loaded in tube 0
function ShipTemplate:weaponTubeDisallowMissle(index, type)
    local type = string.lower(type)
    self.missile_tubes[index+1]["allow_"..type] = false
    return self
end
--- Sets a WeaponTube with the given index to allow loading only the given weapon type.
--- Example: template:setWeaponTubeExclusiveFor(0,"Homing") -- allows only Homing missiles to be loaded in tube 0
function ShipTemplate:setWeaponTubeExclusiveFor(index, type)
    local type = string.lower(type)
    self.missile_tubes[index+1]["allow_homing"] = false
    self.missile_tubes[index+1]["allow_nuke"] = false
    self.missile_tubes[index+1]["allow_mine"] = false
    self.missile_tubes[index+1]["allow_emp"] = false
    self.missile_tubes[index+1]["allow_hvli"] = false
    self.missile_tubes[index+1]["allow_"..type] = true
    return self
end
--- Sets the angle, relative to the ShipTemplateBasedObject's forward bearing, toward which the WeaponTube with the given index points.
--- Defaults to 0. Accepts negative and positive values.
--- Example:
--- -- Sets tube 0 to point 90 degrees right of forward, and tube 1 to point 90 degrees left of forward
--- template:setTubeDirection(0,90):setTubeDirection(1,-90)
function ShipTemplate:setTubeDirection(index, direction)
    self.missile_tubes[index+1].direction = direction
    return self
end
--- Sets the weapon size launched from the WeaponTube with the given index.
--- Defaults to "medium".
--- Example: template:setTubeSize(0,"large") -- sets tube 0 to fire large weapons
function ShipTemplate:setTubeSize(index, size)
    self.missile_tubes[index+1].size = size
    return self
end
--- Sets the number of default hull points for ShipTemplateBasedObjects created from this ShipTemplate.
--- Defaults to 70.
--- Example: template:setHull(100)
function ShipTemplate:setHull(amount)
    self.hull = {current=amount, max=amount}
    return self
end
--- Sets the maximum points per shield segment for ShipTemplateBasedObjects created from this ShipTemplate.
--- Each argument segments the shield clockwise by dividing the arc equally for each segment, up to a maximum of 8 segments.
--- The center of the first segment's arc always faces forward.
--- A ShipTemplateBasedObject with one shield segment has only a front shield generator system, and one with two or more segments has only front and rear generator systems.
--- If not defined, the ShipTemplateBasedObject defaults to having no shield capabilities.
--- Examples:
--- template:setShields(400) -- one shield segment; hits from all angles damage the same shield
--- template:setShields(100,80) -- two shield segments; the front 180-degree shield has 100 points, the rear 80
--- template:setShields(100,50,40,30) -- four shield segments; the front 90-degree shield has 100, right 50, rear 40, and left 30
function ShipTemplate:setShields(...)
    if self.shields == nil then self.shields = {} end
    for n, level in ipairs({...}) do
        self.shields[n] = {level=level, max=level}
    end
    for n=#{...} + 1, #self.shields do
        self.shields[n] = nil
    end
    return self
end
--- Sets the impulse speed, rotational speed, and impulse acceleration for SpaceShips created from this ShipTemplate.
--- (unit?)
--- The optional fourth and fifth arguments set the reverse speed and reverse acceleration.
--- If the reverse speed and acceleration aren't explicitly set, the defaults are equal to the forward speed and acceleration.
--- See also SpaceShip:setImpulseMaxSpeed(), SpaceShip:setRotationMaxSpeed(), SpaceShip:setAcceleration().
--- Defaults to the equivalent value of (500,10,20).
--- Example:
--- -- Sets the forward impulse speed to 80, rotational speed to 15, forward acceleration to 25, reverse speed to 20, and reverse acceleration to the same as the forward acceleration
--- template:setSpeed(80,15,25,20)
function ShipTemplate:setSpeed(forward_speed, turn_rate, forward_acceleration, reverse_speed, reverse_acceleration)
    if reverse_speed == nil then reverse_speed = forward_speed end
    if reverse_acceleration == nil then reverse_acceleration = forward_acceleration end
    if self.maneuvering_thrusters == nil then self.maneuvering_thrusters = {} end
    if self.impulse_engine == nil then self.impulse_engine = {} end
    self.maneuvering_thrusters.speed = turn_rate
    self.impulse_engine.max_speed_forward = forward_speed
    self.impulse_engine.max_speed_reverse = reverse_speed
    self.impulse_engine.acceleration_forward = forward_acceleration
    self.impulse_engine.acceleration_reverse = reverse_acceleration
    return self
end
--- Sets the combat maneuver capacity for SpaceShips created from this ShipTemplate.
--- The boost value sets the forward maneuver capacity, and the strafe value sets the lateral maneuver capacity.
--- Defaults to (0,0).
--- Example: template:setCombatManeuver(400,250)
function ShipTemplate:setCombatManeuver(boost, strafe)
    if self.combat_maneuvering_thrusters == nil then self.combat_maneuvering_thrusters = {} end
    self.combat_maneuvering_thrusters.boost_speed = boost
    self.combat_maneuvering_thrusters.strafe_speed = strafe
    return self
end
--- Sets the warp speed factor for SpaceShips created from this ShipTemplate.
--- Defaults to 0. The typical warp speed value for a warp-capable ship is 1000, which is equivalent to 60U/minute at warp 1.
--- Setting any value also enables the "warp" system and controls.
--- Example: template:setWarpSpeed(1000)
function ShipTemplate:setWarpSpeed(speed)
    if self.warp_drive == nil then self.warp_drive = {} end
    self.warp_drive.speed_per_level = speed
    return self
end
--- Defines whether ShipTemplateBasedObjects created from this ShipTemplate supply energy to docked PlayerSpaceships.
--- Defaults to true.
--- Example: template:setSharesEnergyWithDocked(false)
function ShipTemplate:setSharesEnergyWithDocked(enabled)
    if self.docking_bay then self.docking_bay.share_energy = enabled end
    return self
end
--- Defines whether ShipTemplateBasedObjects created from this template repair docked SpaceShips.
--- Defaults to false. ShipTemplate:setType("station") sets this to true.
--- Example: template:setRepairDocked(true)
function ShipTemplate:setRepairDocked(enabled)
    if self.docking_bay then self.docking_bay.repair = enabled end
    return self
end
--- Defines whether ShipTemplateBasedObjects created from this ShipTemplate restock scan probes on docked PlayerSpaceships.
--- Defaults to false.
--- Example: template:setRestocksScanProbes(true)
function ShipTemplate:setRestocksScanProbes(enabled)
    if self.docking_bay then self.docking_bay.restock_probes = enabled end
    return self
end
--- Defines whether ShipTemplateBasedObjects created from this ShipTemplate restock missiles on docked CpuShips.
--- To restock docked PlayerSpaceships' weapons, use a comms script. See ShipTemplateBasedObject:setCommsScript() and :setCommsFunction().
--- Defaults to false.
--- Example template:setRestocksMissilesDocked(true)
function ShipTemplate:setRestocksMissilesDocked(enabled)
    if self.docking_bay then self.docking_bay.restock_missiles = enabled end
    return self
end
--- Defines whether SpaceShips created from this ShipTemplate have a jump drive.
--- Defaults to false.
--- Example: template:setJumpDrive(true)
function ShipTemplate:setJumpDrive(enabled)
    if enabled then
        self.jump_drive = {}
    else
        self.jump_drive = nil
    end
    return self
end
--- Sets the minimum and maximum jump distances for SpaceShips created from this ShipTemplate.
--- Defaults to (5000,50000).
--- Example: template:setJumpDriveRange(2500,25000) -- sets the minimum jump distance to 2.5U and maximum to 25U
function ShipTemplate:setJumpDriveRange(min, max)
    if self.jump_drive == nil then self.jump_drive = {} end
    self.jump_drive.min_distance = min
    self.jump_drive.max_distance = max
    return self
end

--- Not implemented.
--- Defaults to false.
function ShipTemplate:setCloaking(enabled)
    return self
end

--- Sets the storage capacity of the given weapon type for ShipTemplateBasedObjects created from this ShipTemplate.
--- Example: template:setWeaponStorage("HVLI", 6):setWeaponStorage("Homing",4) -- sets HVLI capacity to 6 and Homing capacity to 4
function ShipTemplate:setWeaponStorage(type, amount)
    if self.missile_tubes == nil then self.missile_tubes = {} end
    local type = string.lower(type)
    self.missile_tubes["storage_" .. type] = amount
    self.missile_tubes["max_" .. type] = amount
    return self
end

--- Adds an empty room to a ShipTemplate.
--- Rooms are displayed on the engineering and damcon screens.
--- If a system room isn't accessible via other rooms connected by doors, repair crews on PlayerSpaceships might not be able to repair that system.
--- Rooms are placed on a 0-indexed integer x/y grid, with the given values representing the room's upper-left corner, and are sized by damage crew capacity (minimum 1x1).
--- To place multiple rooms, declare addRoom() multiple times.
--- Example: template::addRoom(0,0,3,2) -- adds a 3x2 room with its upper-left coordinate at position 0,0
function ShipTemplate:addRoom(x, y, w, h)
    if self.internal_rooms == nil then self.internal_rooms = {} end
    self.internal_rooms[#self.internal_rooms+1] = {position={x, y}, size={w, h}}
    return self
end

--- Adds a room containing a ship system to a ShipTemplate.
--- Rooms are displayed on the engineering and damcon screens.
--- If a system room doesn't exist or isn't accessible via other rooms connected by doors, repair crews on PlayerSpaceships won't be able to repair that system.
--- Rooms are placed on a 0-indexed integer x/y grid, with the given values representing the room's upper-left corner, and are sized by damage crew capacity (minimum 1x1).
--- To place multiple rooms, declare addRoomSystem() multiple times.
--- Example: template:addRoomSystem(1,2,3,4,"reactor")  -- adds a 3x4 room with its upper-left coordinate at position 1,2 that contains the Reactor system
function ShipTemplate:addRoomSystem(x, y, w, h, system)
    if self.internal_rooms == nil then self.internal_rooms = {} end
    self.internal_rooms[#self.internal_rooms+1] = {position={x, y}, size={w, h}, system=system}
    return self
end
--- Adds a door between rooms in a ShipTemplate.
--- Doors connect rooms as displayed on the engineering and damcon screens. All doors are 1 damage crew wide.
--- If a system room isn't accessible via other rooms connected by doors, repair crews on PlayerSpaceships might not be able to repair that system.
--- The horizontal value defines whether the door is oriented horizontally (true) or vertically (false).
--- Doors are placed on a 0-indexed integer x/y grid, with the given values representing the door's left-most point (horizontal) or top-most point (vertical) point.
--- To place multiple doors, declare addDoor() multiple times.
--- Example: template:addDoor(2,1,true) -- places a horizontal door with its left-most point at 2,1
function ShipTemplate:addDoor(x, y, horizontal)
    if self.internal_rooms == nil then self.internal_rooms = {} end
    if self.internal_rooms.doors == nil then self.internal_rooms.doors = {} end
    self.internal_rooms.doors[#self.internal_rooms.doors+1] = {x, y, horizontal}
    return self
end
--- Sets the default radar trace image for ShipTemplateBasedObjects created from this ShipTemplate.
--- Valid values are filenames of PNG images relative to the resources/radar/ directory.
--- Radar trace images should be white with a transparent background.
--- Defaults to arrow.png. ShipTemplate:setType("station") sets this to blip.png.
--- Example: template:setRadarTrace("cruiser.png")
function ShipTemplate:setRadarTrace(trace)
    self.radar_trace.icon = "radar/" .. trace
    return self
end
--- Sets the long-range radar range of SpaceShips created from this ShipTemplate.
--- PlayerSpaceships use this range on the science and operations screens' radar.
--- AI orders of CpuShips use this range to detect potential targets.
--- Defaults to 30000.0 (30U).
--- Example: template:setLongRangeRadarRange(20000) -- sets the long-range radar range to 20U
function ShipTemplate:setLongRangeRadarRange(range)
    if self.long_range_radar then self.long_range_radar.long_range = range end
    return self
end
--- Sets the short-range radar range of SpaceShips created from this ShipTemplate.
--- PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
--- AI orders of CpuShips use this range to decide when to disengage pursuit of fleeing targets.
--- This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
--- Defaults to 5000.0 (5U).
--- Example: template:setShortRangeRadarRange(4000) -- sets the short-range radar range to 4U
function ShipTemplate:setShortRangeRadarRange(range)
    if self.long_range_radar then self.long_range_radar.short_range = range end
    return self
end
--- Sets the sound file used for the impulse drive sounds on SpaceShips created from this ShipTemplate.
--- Valid values are filenames to WAV files relative to the resources directory.
--- Use a looping sound file that tolerates being pitched up and down as the ship's impulse speed changes.
--- Defaults to sfx/engine.wav.
--- Example: template:setImpulseSoundFile("sfx/engine_fighter.wav")
function ShipTemplate:setImpulseSoundFile(sfx)
    if self.impulse_engine then self.impulse_engine.sound = sfx end
    return self
end
--- Defines whether scanning features appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
--- Defaults to true.
--- Example: template:setCanScan(false)
function ShipTemplate:setCanScan(enabled)
    if enabled then self.science_scanner = {} else self.science_scanner = nil end
    return self
end
--- Defines whether hacking features appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
--- Defaults to true.
--- Example: template:setCanHack(false)
function ShipTemplate:setCanHack(enabled)
    if enabled then self.hacking_device = {} else self.hacking_device = nil end
    return self
end
--- Defines whether the "Request Docking" button appears on related crew screens in PlayerSpaceships created from this ShipTemplate.
--- Defaults to true.
--- Example: template:setCanDock(false)
function ShipTemplate:setCanDock(enabled)
    if enabled then self.docking_port = {} else self.docking_port = nil end
    return self
end
--- Defines whether combat maneuver controls appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
--- Defaults to true.
--- Example: template:setCanCombatManeuver(false)
function ShipTemplate:setCanCombatManeuver(enabled)
    if enabled then self.combat_maneuvering_thrusters = {} else self.combat_maneuvering_thrusters = nil end
    return self
end
--- Defines whether self-destruct controls appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
--- Defaults to true.
--- Example: template:setCanSelfDestruct(false)
function ShipTemplate:setCanSelfDestruct(enabled)
    if enabled then self.self_destruct = {} else self.self_destruct = nil end
    return self
end
--- Defines whether ScanProbe-launching controls appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
--- Defaults to true.
--- Example: template:setCanLaunchProbe(false)
function ShipTemplate:setCanLaunchProbe(enabled)
    if enabled then
        self.scan_probe_launcher = {}
    else
        self.scan_probe_launcher = nil
    end
    return self
end
--- Returns an exact copy of this ShipTemplate and sets the new copy's reference name to the given name, as ShipTemplate:setName().
--- The copy retains all other traits of the copied ShipTemplate.
--- Use this function to create variations of an existing ShipTemplate.
--- Example:
--- -- Create two ShipTemplates: one with 50 hull points and one 50-point shield segment,
--- -- and a second with 50 hull points and two 25-point shield segments.
--- template = ShipTemplate():setName("Stalker Q7"):setHull(50):setShields(50)
--- variation = template:copy("Stalker Q5"):setShields(25,25)
function ShipTemplate:copy(new_name)
    local copy = ShipTemplate()
    for orig_key, orig_value in next, self, nil do
        copy[orig_key] = table.deepcopy(orig_value)
    end
    copy:setName(new_name)
    return copy
end

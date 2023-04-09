#include <i18n.h>
#include <optional>
#include "shipTemplate.h"
#include "spaceObjects/spaceObject.h"
#include "mesh.h"
#include "multiplayer_server.h"

#include "scriptInterface.h"

/// A ShipTemplate defines the base functionality, stats, models, and other details for the ShipTemplateBasedObjects created from it.
/// ShipTemplateBasedObjects belong to either the SpaceStation or SpaceShip subclasses. SpaceShips in turn belong to the CpuShip or PlayerSpaceship classes.
/// ShipTemplates appear in ship and space station creation lists, such as the ship selection screen on scenarios that allow player ship creation, or the GM console's object creation tool.
/// They also appear as default entries in the science database.
/// EmptyEpsilon loads shipTemplates.lua at launch, which requires files containing ShipTemplates located in the shiptemplates/ subdirectory of a resource path.
/// New ShipTemplates can't be defined while a scenario is running.
/// Use Lua variables to apply several ShipTemplate functions to the same template.
/// Example:
/// -- Create a ShipTemplate for a Cruiser Frigate-class CpuShip designated Phobos T3
/// template = ShipTemplate():setName("Phobos T3"):setLocaleName(_("ship","Phobos T3")):setClass(_("class","Frigate"),_("subclass","Cruiser"))
/// -- Set the Phobos T3's appearance to the ModelData named "AtlasHeavyFighterYellow"
/// template:setModel("AtlasHeavyFighterYellow")
REGISTER_SCRIPT_CLASS(ShipTemplate)
{
    /// Sets this ShipTemplate's unique reference name.
    /// Use this value for referencing this ShipTemplate in scripts.
    /// If this value begins with "Player ", including the trailing space, EmptyEpsilon uses only what follows as the name.
    /// If this ShipTemplate lacks a localized name (ShipTemplate:setLocaleName()), it defaults to this reference name.
    /// Example: template:setName("Phobos T3")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setName);
    /// Sets the displayed vessel model designation for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Use with the _ function to expose the localized name to translation.
    /// Examples:
    /// template:setLocaleName("Phobos T3")
    /// template:setLocaleName(_("ship","Phobos T3")) -- with a translation-exposed name
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setLocaleName);
    /// Sets the vessel class and subclass for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Vessel classes are used to define certain traits across similar ships, such as dockability.
    /// See also ShipTemplate:setExternalDockClasses() and ShipTemplate:setInternalDockClasses().
    /// For consistent class usage across translations, wrap class name strings in the _ function.
    /// Defaults to the equivalent value of (_("No class"),_("No sub-class")).
    /// Examples:
    /// template:setClass(_("class","Frigate"),_("subclass","Cruiser"))
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setClass);
    /// Sets the description shown in the science database for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Example: template:setDescription(_("The Phobos T3 is most any navy's workhorse frigate."))
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDescription);
    /// Sets the object-oriented subclass of ShipTemplateBasedObject to create from this ShipTemplate.
    /// Defaults to "ship" (CpuShip).
    /// Valid values are "ship", "playership" (PlayerSpaceship), and "station" (SpaceStation).
    /// Using setType("station") is equivalent to also using ShipTemplate:setRepairDocked(true) and ShipTemplate:setRadarTrace("blip.png").
    /// Example: template:setType("playership")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setType);
    /// If declared, this function hides this ShipTemplate from creation features and the science database.
    /// Hidden templates provide backward compatibility to older scenario scripts.
    /// Example: template:hidden() -- hides this template
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, hidden);
    /// Sets the default combat AI state for CpuShips created from this ShipTemplate.
    /// Combat AI states determine the AI's combat tactics and responses.
    /// They're distinct from orders, which determine the ship's active objectives and are defined by CpuShip:order...() functions.
    /// Valid combat AI states are:
    /// - "default" directly pursues enemies at beam range while making opportunistic missile attacks
    /// - "evasion" maintains distance from enemy weapons and evades attacks
    /// - "fighter" prefers strafing maneuvers and attacks briefly at close range while passing
    /// - "missilevolley" prefers lining up missile attacks from long range
    /// Example: template:setAI("fighter") -- default to the "fighter" combat AI state
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDefaultAI);
    /// Sets the 3D appearance, by ModelData name, of ShipTemplateBasedObjects created from this ShipTemplate.
    /// ModelData objects define a 3D mesh, textures, adjustments, and collision box, and are loaded from model_data.lua when EmptyEpsilon is launched.
    /// Example: template:setModel("AtlasHeavyFighterYellow") -- uses the ModelData named "AtlasHeavyFighterYellow"
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setModel);
    /// As ShipTemplate:setExternalDockClasses().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setDockClasses);
    /// Defines a list of vessel classes that can be externally docked to ShipTemplateBasedObjects created from this ShipTemplate.
    /// External docking keeps the docked ship attached to the outside of the carrier.
    /// By default, SpaceStations allow all classes of SpaceShips to dock externally.
    /// For consistent class usage across translations, wrap class name strings in the _ function.
    /// Example: template:setExternalDockClasses(_("class","Frigate"),_("class","Corvette")) -- all Frigate and Corvette ships can dock to the outside of this ShipTemplateBasedObject
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setExternalDockClasses);
    /// Defines a list of ship classes that can be docked inside of ShipTemplateBasedObjects created from this ShipTemplate.
    /// Internal docking stores the docked ship inside of this derived ShipTemplateBasedObject.
    /// For consistent class usage across translations, wrap class name strings in the _ function.
    /// Example: template:setInternalDockClasses(_("class","Starfighter")) -- all Starfighter ships can dock inside of this ShipTemplateBasedObject
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setInternalDockClasses);
    /// Sets the amount of energy available for PlayerSpaceships created from this ShipTemplate.
    /// Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
    /// Defaults to 1000.
    /// Example: template:setEnergyStorage(500)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setEnergyStorage);
    /// Sets the default number of repair crew for PlayerSpaceships created from this ShipTemplate.
    /// Defaults to 3.
    /// Only PlayerSpaceships use repair crews. Setting this for other ShipTemplateBasedObject types has no effect.
    /// Example: template:setRepairCrewCount(5)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRepairCrewCount);
    /// As ShipTemplate:setBeamWeapon().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeam);
    /// Defines the traits of a BeamWeapon for ShipTemplateBasedObjects created from this ShipTemplate.
    /// - index: Each beam weapon in this ShipTemplate must have a unique index.
    /// - arc: Sets the arc of its firing capability, in degrees.
    /// - direction: Sets the default center angle of the arc, in degrees relative to the ship's forward bearing. Value can be negative.
    /// - range: Sets how far away the beam can fire.
    /// - cycle_time: Sets the base firing delay, in seconds. System effectiveness modifies the cycle time.
    /// - damage: Sets the base damage done by the beam to the target. System effectiveness modifies the damage.
    /// To add multiple beam weapons to a ship, invoke this function multiple times, assigning each weapon a unique index value.
    /// To create a turreted beam, also add ShipTemplate:setBeamWeaponTurret(), and set the beam weapon's arc to be smaller than the turret's arc.
    /// Example: setBeamWeapon(0,90,-15,1200,3,1) -- index 0, 90-degree arc centered -15 degrees from forward, extending 1.2U, firing every 3 seconds and dealing 1 damage
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeapon);
    /// Converts a BeamWeapon into a turret and defines its traits for SpaceShips created from this ShipTemplate.
    /// A turreted beam weapon rotates within its turret arc toward the weapons target at the given rotation rate.
    /// - index: Must match the index of an existing beam weapon.
    /// - arc: Sets the turret's maximum targeting angles, in degrees. The turret arc must be larger than the associated beam weapon's arc.
    /// - direction: Sets the default center angle of the turret arc, in degrees relative to the ship's forward bearing. Value can be negative.
    /// - rotation_rate: Sets how many degrees per tick that the associated beam weapon's direction can rotate toward the target within the turret arc. System effectiveness modifies the rotation rate.
    /// To create a turreted beam, also add ShipTemplate:setBeamWeapon(), and set the beam weapon's arc to be smaller than the turret's arc.
    /// Example:
    /// -- Makes beam weapon 0 a turret with a 200-degree turret arc centered on 90 degrees from forward, rotating at 5 degrees per tick (unit?)
    /// template:setBeamWeaponTurret(0,200,90,5)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeaponTurret);
    /// Sets the BeamEffect texture, by filename, for the BeamWeapon with the given index on SpaceShips created from this ShipTemplate.
    /// See BeamEffect:setTexture().
    /// Example: template:setBeamWeaponTexture("texture/beam_blue.png")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamTexture);
    /// Sets how much energy is drained each time the BeamWeapon with the given index is fired.
    /// Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
    /// Defaults to 3.0, as defined in src/spaceObjects/spaceshipParts/beamWeapon.cpp.
    /// Example: template:setBeamWeaponEnergyPerFire(0,1) -- sets beam 0 to use 1 energy per firing
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeaponEnergyPerFire);
    /// Sets how much "beamweapon" system heat is generated, in percentage of total system heat capacity, each time the BeamWeapon with the given index is fired.
    /// Only PlayerSpaceships generate and manage heat. Setting this for other ShipTemplateBasedObject types has no effect.
    /// Defaults to 0.02, as defined in src/spaceObjects/spaceshipParts/beamWeapon.cpp.
    /// Example: template:setBeamWeaponHeatPerFire(0,0.5) -- sets beam 0 to generate 0.5 (50%) system heat per firing
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setBeamWeaponHeatPerFire);
    /// Sets the number of WeaponTubes for ShipTemplateBasedObjects created from this ShipTemplate, and the default delay for loading and unloading each tube, in seconds.
    /// Weapon tubes are 0-indexed. For example, 3 tubes would be indexed 0, 1, and 2.
    /// Ships are limited to a maximum of 16 weapon tubes.
    /// The default ShipTemplate adds 0 tubes and an 8-second loading time.
    /// Example: template:setTubes(6,15.0) -- creates 6 weapon tubes with 15-second loading times
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubes);
    /// Sets the delay, in seconds, for loading and unloading the WeaponTube with the given index.
    /// Defaults to 8.0.
    /// Example: template:setTubeLoadTime(0,12) -- sets the loading time for tube 0 to 12 seconds
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubeLoadTime);
    /// Sets which weapon types the WeaponTube with the given index can load.
    /// Note the spelling of "missle".
    /// Example: template:weaponTubeAllowMissle(0,"Homing") -- allows Homing missiles to be loaded in tube 0
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, weaponTubeAllowMissle);
    /// Sets which weapon types the WeaponTube with the given index can't load.
    /// Note the spelling of "missle".
    /// Example: template:weaponTubeDisallowMissle(0,"Homing") -- prevents Homing missiles from being loaded in tube 0
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, weaponTubeDisallowMissle);
    /// Sets a WeaponTube with the given index to allow loading only the given weapon type.
    /// Example: template:setWeaponTubeExclusiveFor(0,"Homing") -- allows only Homing missiles to be loaded in tube 0
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWeaponTubeExclusiveFor);
    /// Sets the angle, relative to the ShipTemplateBasedObject's forward bearing, toward which the WeaponTube with the given index points.
    /// Defaults to 0. Accepts negative and positive values.
    /// Example:
    /// -- Sets tube 0 to point 90 degrees right of forward, and tube 1 to point 90 degrees left of forward
    /// template:setTubeDirection(0,90):setTubeDirection(1,-90)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubeDirection);
    /// Sets the weapon size launched from the WeaponTube with the given index.
    /// Defaults to "medium".
    /// Example: template:setTubeSize(0,"large") -- sets tube 0 to fire large weapons
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setTubeSize);
    /// Sets the number of default hull points for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Defaults to 70.
    /// Example: template:setHull(100)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setHull);
    /// Sets the maximum points per shield segment for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Each argument segments the shield clockwise by dividing the arc equally for each segment, up to a maximum of 8 segments.
    /// The center of the first segment's arc always faces forward.
    /// A ShipTemplateBasedObject with one shield segment has only a front shield generator system, and one with two or more segments has only front and rear generator systems.
    /// If not defined, the ShipTemplateBasedObject defaults to having no shield capabilities.
    /// Examples:
    /// template:setShields(400) -- one shield segment; hits from all angles damage the same shield
    /// template:setShields(100,80) -- two shield segments; the front 180-degree shield has 100 points, the rear 80
    /// template:setShields(100,50,40,30) -- four shield segments; the front 90-degree shield has 100, right 50, rear 40, and left 30
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setShields);
    /// Sets the impulse speed, rotational speed, and impulse acceleration for SpaceShips created from this ShipTemplate.
    /// (unit?)
    /// The optional fourth and fifth arguments set the reverse speed and reverse acceleration.
    /// If the reverse speed and acceleration aren't explicitly set, the defaults are equal to the forward speed and acceleration.
    /// See also SpaceShip:setImpulseMaxSpeed(), SpaceShip:setRotationMaxSpeed(), SpaceShip:setAcceleration().
    /// Defaults to the equivalent value of (500,10,20).
    /// Example:
    /// -- Sets the forward impulse speed to 80, rotational speed to 15, forward acceleration to 25, reverse speed to 20, and reverse acceleration to the same as the forward acceleration
    /// template:setSpeed(80,15,25,20)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setSpeed);
    /// Sets the combat maneuver capacity for SpaceShips created from this ShipTemplate.
    /// The boost value sets the forward maneuver capacity, and the strafe value sets the lateral maneuver capacity.
    /// Defaults to (0,0).
    /// Example: template:setCombatManeuver(400,250)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCombatManeuver);
    /// Sets the warp speed factor for SpaceShips created from this ShipTemplate.
    /// Defaults to 0. The typical warp speed value for a warp-capable ship is 1000, which is equivalent to 60U/minute at warp 1.
    /// Setting any value also enables the "warp" system and controls.
    /// Example: template:setWarpSpeed(1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWarpSpeed);
    /// Defines whether ShipTemplateBasedObjects created from this ShipTemplate supply energy to docked PlayerSpaceships.
    /// Defaults to true.
    /// Example: template:setSharesEnergyWithDocked(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setSharesEnergyWithDocked);
    /// Defines whether ShipTemplateBasedObjects created from this template repair docked SpaceShips.
    /// Defaults to false. ShipTemplate:setType("station") sets this to true.
    /// Example: template:setRepairDocked(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRepairDocked);
    /// Defines whether ShipTemplateBasedObjects created from this ShipTemplate restock scan probes on docked PlayerSpaceships.
    /// Defaults to false.
    /// Example: template:setRestocksScanProbes(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRestocksScanProbes);
    /// Defines whether ShipTemplateBasedObjects created from this ShipTemplate restock missiles on docked CpuShips.
    /// To restock docked PlayerSpaceships' weapons, use a comms script. See ShipTemplateBasedObject:setCommsScript() and :setCommsFunction().
    /// Defaults to false.
    /// Example template:setRestocksMissilesDocked(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRestocksMissilesDocked);
    /// Defines whether SpaceShips created from this ShipTemplate have a jump drive.
    /// Defaults to false.
    /// Example: template:setJumpDrive(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setJumpDrive);
    /// Sets the minimum and maximum jump distances for SpaceShips created from this ShipTemplate.
    /// Defaults to (5000,50000).
    /// Example: template:setJumpDriveRange(2500,25000) -- sets the minimum jump distance to 2.5U and maximum to 25U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setJumpDriveRange);
    /// Not implemented.
    /// Defaults to false.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCloaking);
    /// Sets the storage capacity of the given weapon type for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Example: template:setWeaponStorage("HVLI", 6):setWeaponStorage("Homing",4) -- sets HVLI capacity to 6 and Homing capacity to 4
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setWeaponStorage);
    /// Adds an empty room to a ShipTemplate.
    /// Rooms are displayed on the engineering and damcon screens.
    /// If a system room isn't accessible via other rooms connected by doors, repair crews on PlayerSpaceships might not be able to repair that system.
    /// Rooms are placed on a 0-indexed integer x/y grid, with the given values representing the room's upper-left corner, and are sized by damage crew capacity (minimum 1x1).
    /// To place multiple rooms, declare addRoom() multiple times.
    /// Example: template::addRoom(0,0,3,2) -- adds a 3x2 room with its upper-left coordinate at position 0,0
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addRoom);
    /// Adds a room containing a ship system to a ShipTemplate.
    /// Rooms are displayed on the engineering and damcon screens.
    /// If a system room doesn't exist or isn't accessible via other rooms connected by doors, repair crews on PlayerSpaceships won't be able to repair that system.
    /// Rooms are placed on a 0-indexed integer x/y grid, with the given values representing the room's upper-left corner, and are sized by damage crew capacity (minimum 1x1).
    /// To place multiple rooms, declare addRoomSystem() multiple times.
    /// Example: template:addRoomSystem(1,2,3,4,"reactor")  -- adds a 3x4 room with its upper-left coordinate at position 1,2 that contains the Reactor system
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addRoomSystem);
    /// Adds a door between rooms in a ShipTemplate.
    /// Doors connect rooms as displayed on the engineering and damcon screens. All doors are 1 damage crew wide.
    /// If a system room isn't accessible via other rooms connected by doors, repair crews on PlayerSpaceships might not be able to repair that system.
    /// The horizontal value defines whether the door is oriented horizontally (true) or vertically (false).
    /// Doors are placed on a 0-indexed integer x/y grid, with the given values representing the door's left-most point (horizontal) or top-most point (vertical) point.
    /// To place multiple doors, declare addDoor() multiple times.
    /// Example: template:addDoor(2,1,true) -- places a horizontal door with its left-most point at 2,1
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, addDoor);
    /// Sets the default radar trace image for ShipTemplateBasedObjects created from this ShipTemplate.
    /// Optional. Defaults to "arrow.png". Setting ShipTemplate:setType("station") sets this to "blip.png".
    /// Valid values are filenames of images relative to the radar/ subdirectory of a resource path.
    /// You can also reference radar traces from resource packs if they're located in a radar/ subpath inside the pack.
    /// Radar trace images should be white with a transparent background.
    /// Example: template:setRadarTrace("cruiser.png") -- sets the ship's radar trace image relative to a resource directory
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setRadarTrace);
    /// Sets the long-range radar range of SpaceShips created from this ShipTemplate.
    /// PlayerSpaceships use this range on the science and operations screens' radar.
    /// AI orders of CpuShips use this range to detect potential targets.
    /// Defaults to 30000.0 (30U).
    /// Example: template:setLongRangeRadarRange(20000) -- sets the long-range radar range to 20U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setLongRangeRadarRange);
    /// Sets the short-range radar range of SpaceShips created from this ShipTemplate.
    /// PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
    /// AI orders of CpuShips use this range to decide when to disengage pursuit of fleeing targets.
    /// This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
    /// Defaults to 5000.0 (5U).
    /// Example: template:setShortRangeRadarRange(4000) -- sets the short-range radar range to 4U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setShortRangeRadarRange);
    /// Sets the sound file used for the impulse drive sounds on SpaceShips created from this ShipTemplate.
    /// Valid values are filenames to WAV files relative to the resources directory.
    /// Use a looping sound file that tolerates being pitched up and down as the ship's impulse speed changes.
    /// Defaults to sfx/engine.wav.
    /// Example: template:setImpulseSoundFile("sfx/engine_fighter.wav")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setImpulseSoundFile);
    /// Defines whether scanning features appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
    /// Defaults to true.
    /// Example: template:setCanScan(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCanScan);
    /// Defines whether hacking features appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
    /// Defaults to true.
    /// Example: template:setCanHack(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCanHack);
    /// Defines whether the "Request Docking" button appears on related crew screens in PlayerSpaceships created from this ShipTemplate.
    /// Defaults to true.
    /// Example: template:setCanDock(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCanDock);
    /// Defines whether combat maneuver controls appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
    /// Defaults to true.
    /// Example: template:setCanCombatManeuver(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCanCombatManeuver);
    /// Defines whether self-destruct controls appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
    /// Defaults to true.
    /// Example: template:setCanSelfDestruct(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCanSelfDestruct);
    /// Defines whether ScanProbe-launching controls appear on related crew screens in PlayerSpaceships created from this ShipTemplate.
    /// Defaults to true.
    /// Example: template:setCanLaunchProbe(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, setCanLaunchProbe);
    /// Returns an exact copy of this ShipTemplate and sets the new copy's reference name to the given name, as ShipTemplate:setName().
    /// The copy retains all other traits of the copied ShipTemplate.
    /// Use this function to create variations of an existing ShipTemplate.
    /// Example:
    /// -- Create two ShipTemplates: one with 50 hull points and one 50-point shield segment,
    /// -- and a second with 50 hull points and two 25-point shield segments.
    /// template = ShipTemplate():setName("Stalker Q7"):setHull(50):setShields(50)
    /// variation = template:copy("Stalker Q5"):setShields(25,25)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplate, copy);
}

std::unordered_map<string, P<ShipTemplate> > ShipTemplate::templateMap;

ShipTemplate::ShipTemplate()
{
    if (game_server) { LOG(ERROR) << "ShipTemplate objects can not be created during a scenario."; destroy(); return; }

    type = Ship;
    class_name = tr("No class");
    sub_class_name = tr("No sub-class");
    shares_energy_with_docked = true;
    repair_docked = false;
    restocks_scan_probes = false;
    restocks_missiles_docked = false;
    energy_storage_amount = 1000;
    repair_crew_count = 3;
    weapon_tube_count = 0;
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].load_time = 8.0;
        weapon_tube[n].type_allowed_mask = (1 << MW_Count) - 1;
        weapon_tube[n].direction = 0;
        weapon_tube[n].size = MS_Medium;
    }
    hull = 70;
    shield_count = 0;
    for(int n=0; n<max_shield_count; n++)
        shield_level[n] = 0.0;
    impulse_speed = 500.0;
    impulse_reverse_speed = 500.0;
    impulse_acceleration = 20.0;
    impulse_reverse_acceleration = 20.0;
    turn_speed = 10.0;
    combat_maneuver_boost_speed = 0.0f;
    combat_maneuver_strafe_speed = 0.0f;
    warp_speed = 0.0;
    has_jump_drive = false;
    jump_drive_min_distance = 5000.0;
    jump_drive_max_distance = 50000.0;
    has_cloaking = false;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = 0;
    long_range_radar_range = 30000.0f;
    short_range_radar_range = 5000.0f;
    radar_trace = "radar/arrow.png";
    impulse_sound_file = "sfx/engine.wav";
    default_ai_name = "default";
}

void ShipTemplate::setBeamTexture(int index, string texture)

{
    if (index >= 0 && index < max_beam_weapons)
    {
        beams[index].setBeamTexture(texture);
    }
}

void ShipTemplate::setTubes(int amount, float load_time)
{
    weapon_tube_count = std::min(max_weapon_tubes, amount);
    for(int n=0; n<max_weapon_tubes; n++)
        weapon_tube[n].load_time = load_time;
}

void ShipTemplate::setTubeLoadTime(int index, float load_time)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].load_time = load_time;
}

void ShipTemplate::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].type_allowed_mask |= (1 << type);
}

void ShipTemplate::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].type_allowed_mask &=~(1 << type);
}

void ShipTemplate::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].type_allowed_mask = (1 << type);
}

void ShipTemplate::setTubeDirection(int index, float direction)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].direction = direction;
}

void ShipTemplate::setTubeSize(int index, EMissileSizes size)
{
    if (index < 0 || index >= max_weapon_tubes)
        return;
    weapon_tube[index].size = size;
}

void ShipTemplate::setType(TemplateType type)
{
    if (radar_trace == "radar/arrow.png" && type == Station)
    {
        radar_trace = "radar/blip.png";
    }
    if (type == Station)
        repair_docked = true;
    this->type = type;
}

void ShipTemplate::setName(string name)
{
    if (templateMap.find(name) != templateMap.end())
    {
        LOG(ERROR) << "Duplicate ship template definition: " << name;
    }

    templateMap[name] = this;
    if (name.startswith("Player "))
        name = name.substr(7);
    this->name = name;
    if (this->locale_name == "")
        this->locale_name = name;
}

void ShipTemplate::setLocaleName(string name)
{
    this->locale_name = name;
}

void ShipTemplate::setClass(string class_name, string sub_class_name)
{
    this->class_name = class_name;
    this->sub_class_name = sub_class_name;
}

void ShipTemplate::setBeam(int index, float arc, float direction, float range, float cycle_time, float damage)
{
    setBeamWeapon(index, arc, direction, range, cycle_time, damage);
}

void ShipTemplate::setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage)
{
    if (index < 0 || index > max_beam_weapons)
        return;
    beams[index].setDirection(direction);
    beams[index].setArc(arc);
    beams[index].setRange(range);
    beams[index].setCycleTime(cycle_time);
    beams[index].setDamage(damage);
}

void ShipTemplate::setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate)
{
    if (index < 0 || index > max_beam_weapons)
        return;
    beams[index].setTurretArc(arc);
    beams[index].setTurretDirection(direction);
    beams[index].setTurretRotationRate(rotation_rate);
}

glm::ivec2 ShipTemplate::interiorSize()
{
    glm::ivec2 min_pos(1000, 1000);
    glm::ivec2 max_pos(0, 0);
    for(unsigned int n=0; n<rooms.size(); n++)
    {
        min_pos.x = std::min(min_pos.x, rooms[n].position.x);
        min_pos.y = std::min(min_pos.y, rooms[n].position.y);
        max_pos.x = std::max(max_pos.x, rooms[n].position.x + rooms[n].size.x);
        max_pos.y = std::max(max_pos.y, rooms[n].position.y + rooms[n].size.y);
    }
    if (min_pos != glm::ivec2(1, 1))
    {
        glm::ivec2 offset = glm::ivec2(1, 1) - min_pos;
        for(unsigned int n=0; n<rooms.size(); n++)
            rooms[n].position += offset;
        for(unsigned int n=0; n<doors.size(); n++)
            doors[n].position += offset;
        max_pos += offset;
    }
    max_pos += glm::ivec2(1, 1);
    return max_pos;
}

ESystem ShipTemplate::getSystemAtRoom(glm::ivec2 position)
{
    for(unsigned int n=0; n<rooms.size(); n++)
    {
        if (rooms[n].position.x <= position.x && rooms[n].position.x + rooms[n].size.x > position.x && rooms[n].position.y <= position.y && rooms[n].position.y + rooms[n].size.y > position.y)
            return rooms[n].system;
    }
    return SYS_None;
}

void ShipTemplate::setCollisionData(P<SpaceObject> object)
{
    model_data->setCollisionData(object);
}

void ShipTemplate::setShields(const std::vector<float>& values)
{
    shield_count = std::min(max_shield_count, int(values.size()));
    for(int n=0; n<shield_count; n++)
    {
        shield_level[n] = values[n];
    }
}


P<ShipTemplate> ShipTemplate::getTemplate(string name)
{
    if (templateMap.find(name) == templateMap.end())
    {
        LOG(ERROR) << "Failed to find ship template: " << name;
        return nullptr;
    }
    return templateMap[name];
}

std::vector<string> ShipTemplate::getAllTemplateNames()
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        ret.push_back(i->first);
    return ret;
}

std::vector<string> ShipTemplate::getTemplateNameList(TemplateType type)
{
    std::vector<string> ret;
    for(std::unordered_map<string, P<ShipTemplate> >::iterator i = templateMap.begin(); i != templateMap.end(); i++)
        if (i->second->getType() == type)
            ret.push_back(i->first);
    return ret;
}

string getSystemName(ESystem system)
{
    switch(system)
    {
    case SYS_Reactor: return "Reactor";
    case SYS_BeamWeapons: return "Beam Weapons";
    case SYS_MissileSystem: return "Missile System";
    case SYS_Maneuver: return "Maneuvering";
    case SYS_Impulse: return "Impulse Engines";
    case SYS_Warp: return "Warp Drive";
    case SYS_JumpDrive: return "Jump Drive";
    case SYS_FrontShield: return "Front Shield Generator";
    case SYS_RearShield: return "Rear Shield Generator";
    default:
        return "UNKNOWN";
    }
}

string getLocaleSystemName(ESystem system)
{
    switch(system)
    {
    case SYS_Reactor: return tr("system", "Reactor");
    case SYS_BeamWeapons: return tr("system", "Beam Weapons");
    case SYS_MissileSystem: return tr("system", "Missile System");
    case SYS_Maneuver: return tr("system", "Maneuvering");
    case SYS_Impulse: return tr("system", "Impulse Engines");
    case SYS_Warp: return tr("system", "Warp Drive");
    case SYS_JumpDrive: return tr("system", "Jump Drive");
    case SYS_FrontShield: return tr("system", "Front Shield Generator");
    case SYS_RearShield: return tr("system", "Rear Shield Generator");
    default:
        return "UNKNOWN";
    }
}

void ShipTemplate::setDescription(string description)
{
    this->description = description;
}

void ShipTemplate::setModel(string model_name)
{
    this->model_data = ModelData::getModel(model_name);
}

void ShipTemplate::setDefaultAI(string default_ai_name)
{
    this->default_ai_name = default_ai_name;
}

void ShipTemplate::setDockClasses(const std::vector<string>& classes)
{
    external_dock_classes = std::unordered_set<string>(classes.begin(), classes.end());
}

void ShipTemplate::setExternalDockClasses(const std::vector<string>& classes)
{
    external_dock_classes = std::unordered_set<string>(classes.begin(), classes.end());
}

void ShipTemplate::setInternalDockClasses(const std::vector<string>& classes)
{
    internal_dock_classes = std::unordered_set<string>(classes.begin(), classes.end());
}

void ShipTemplate::setSpeed(float impulse, float turn, float acceleration, std::optional<float> reverse_speed, std::optional<float> reverse_acceleration)
{
    impulse_speed = impulse;
    turn_speed = turn;
    impulse_acceleration = acceleration;

    impulse_reverse_speed = reverse_speed.value_or(impulse);
    impulse_reverse_acceleration = reverse_acceleration.value_or(acceleration);
}

void ShipTemplate::setCombatManeuver(float boost, float strafe)
{
    combat_maneuver_boost_speed = boost;
    combat_maneuver_strafe_speed = strafe;
}

void ShipTemplate::setWarpSpeed(float warp)
{
    warp_speed = warp;
}

void ShipTemplate::setSharesEnergyWithDocked(bool enabled)
{
    shares_energy_with_docked = enabled;
}

void ShipTemplate::setRepairDocked(bool enabled)
{
    repair_docked = enabled;
}

void ShipTemplate::setRestocksScanProbes(bool enabled)
{
    restocks_scan_probes = enabled;
}

void ShipTemplate::setRestocksMissilesDocked(bool enabled)
{
    restocks_missiles_docked = enabled;
}

void ShipTemplate::setJumpDrive(bool enabled)
{
    has_jump_drive = enabled;
}

void ShipTemplate::setCloaking(bool enabled)
{
    has_cloaking = enabled;
}

void ShipTemplate::setWeaponStorage(EMissileWeapons weapon, int amount)
{
    if (weapon != MW_None)
    {
        weapon_storage[weapon] = amount;
    }
}

void ShipTemplate::addRoom(glm::ivec2 position, glm::ivec2 size)
{
    rooms.push_back(ShipRoomTemplate(position, size, SYS_None));
}

void ShipTemplate::addRoomSystem(glm::ivec2 position, glm::ivec2 size, ESystem system)
{
    rooms.push_back(ShipRoomTemplate(position, size, system));
}

void ShipTemplate::addDoor(glm::ivec2 position, bool horizontal)
{
    doors.push_back(ShipDoorTemplate(position, horizontal));
}

void ShipTemplate::setRadarTrace(string trace)
{
    radar_trace = "radar/" + trace;
}

void ShipTemplate::setLongRangeRadarRange(float range)
{
    range = std::max(range, 100.0f);
    long_range_radar_range = range;
    short_range_radar_range = std::min(short_range_radar_range, range);
}

void ShipTemplate::setShortRangeRadarRange(float range)
{
    range = std::max(range, 100.0f);
    short_range_radar_range = range;
    long_range_radar_range = std::max(long_range_radar_range, range);
}

void ShipTemplate::setImpulseSoundFile(string sound)
{
    impulse_sound_file = sound;
}

P<ShipTemplate> ShipTemplate::copy(string new_name)
{
    P<ShipTemplate> result = new ShipTemplate();
    result->setName(new_name);

    result->description = description;
    result->class_name = class_name;
    result->sub_class_name = sub_class_name;
    result->type = type;
    result->model_data = model_data;

    result->external_dock_classes = external_dock_classes;
    result->internal_dock_classes = internal_dock_classes;
    result->energy_storage_amount = energy_storage_amount;
    result->repair_crew_count = repair_crew_count;

    result->can_scan = can_scan;
    result->can_hack = can_hack;
    result->can_dock = can_dock;
    result->can_combat_maneuver = can_combat_maneuver;
    result->can_self_destruct = can_self_destruct;
    result->can_launch_probe = can_launch_probe;

    result->default_ai_name = default_ai_name;
    for(int n=0; n<max_beam_weapons; n++)
        result->beams[n] = beams[n];
    result->weapon_tube_count = weapon_tube_count;
    for(int n=0; n<max_weapon_tubes; n++)
        result->weapon_tube[n] = weapon_tube[n];
    result->hull = hull;
    result->shield_count = shield_count;
    for(int n=0; n<max_shield_count; n++)
        result->shield_level[n] = shield_level[n];
    result->impulse_speed = impulse_speed;
    result->impulse_reverse_speed = impulse_reverse_speed;
    result->turn_speed = turn_speed;
    result->warp_speed = warp_speed;
    result->impulse_acceleration = impulse_acceleration;
    result->impulse_reverse_acceleration = impulse_reverse_acceleration;
    result->combat_maneuver_boost_speed = combat_maneuver_boost_speed;
    result->combat_maneuver_strafe_speed = combat_maneuver_strafe_speed;
    result->shares_energy_with_docked = shares_energy_with_docked;
    result->repair_docked = repair_docked;
    result->restocks_scan_probes = restocks_scan_probes;
    result->restocks_missiles_docked = restocks_missiles_docked;
    result->has_jump_drive = has_jump_drive;
    result->has_cloaking = has_cloaking;
    for(int n=0; n<MW_Count; n++)
        result->weapon_storage[n] = weapon_storage[n];
    result->radar_trace = radar_trace;

    result->rooms = rooms;
    result->doors = doors;

    return result;
}

void ShipTemplate::setEnergyStorage(float energy_amount)
{
    this->energy_storage_amount = energy_amount;
}

void ShipTemplate::setRepairCrewCount(int amount)
{
    this->repair_crew_count = amount;
}

string ShipTemplate::getName()
{
    return this->name;
}

string ShipTemplate::getLocaleName()
{
    return this->locale_name;
}

string ShipTemplate::getDescription()
{
    return this->description;
}

string ShipTemplate::getClass()
{
    return this->class_name;
}

string ShipTemplate::getSubClass()
{
    return this->sub_class_name;
}

ShipTemplate::TemplateType ShipTemplate::getType()
{
    return type;
}

#include "shipTemplate.hpp"

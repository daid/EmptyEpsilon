#include "spaceship.h"

#include <array>

#include <i18n.h>

#include "mesh.h"
#include "random.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/beamEffect.h"
#include "factionInfo.h"
#include "spaceObjects/explosionEffect.h"
#include "particleEffect.h"
#include "spaceObjects/warpJammer.h"
#include "textureManager.h"
#include "multiplayer_client.h"
#include "gameGlobalInfo.h"

#include "scriptInterface.h"

#include <SDL_assert.h>

/// A SpaceShip is a ShipTemplateBasedObject controlled by either the AI (CpuShip) or players (PlayerSpaceship).
/// It can carry and deploy weapons, dock with or carry docked ships, and move using impulse, jump, or warp drives.
/// It's also subject to collision physics, unlike SpaceStations.
/// This is the parent class of CpuShip and PlayerSpaceship objects, which inherit all STBO and SpaceShip functions.
/// Objects of this class can't be created by scripts, but its child classes can.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(SpaceShip, ShipTemplateBasedObject)
{
    /// [DEPRECATED]
    /// Use SpaceShip:isFriendOrFoeIdentifiedBy() or SpaceShip:isFriendOrFoeIdentifiedByFaction().
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentified);
    /// [DEPRECATED]
    /// Use SpaceShip:isFullyScannedBy() or SpaceShip:isFullyScannedByFaction().
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScanned);
    /// Returns whether this SpaceShip has been identified by the given ship as either hostile or friendly.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedBy);
    /// Returns whether this SpaceShip has been fully scanned by the given ship.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedBy);
    /// Returns whether this SpaceShip has been identified by the given faction as either hostile or friendly.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    /// Returns whether this SpaceShip has been fully scanned by the given faction.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
    /// Returns whether this SpaceShip is docked with a station or another ship.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isDocked);
    /// Returns the object with which this SpaceShip is docked.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDockedWith);
    /// Returns whether this SpaceShip has been identified by the given SpaceObject as either hostile or friendly.
    /// Example: ship:isFriendOrFoeIdentifiedBy(enemy)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedBy);
    /// Returns whether this SpaceShip has been fully scanned by the given SpaceObject.
    /// See also SpaceObject:isScannedBy().
    /// Example: ship:isFullyScannedBy(enemy)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedBy);
    /// Returns whether this SpaceShip has been identified by the given faction as either hostile or friendly.
    /// Example: ship:isFriendOrFoeIdentifiedByFaction("Kraylor")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    /// Returns whether this SpaceShip has been fully scanned by the given faction.
    /// See also SpaceObject:isScannedByFaction().
    /// Example: ship:isFullyScannedByFaction("Kraylor")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
    /// Returns whether this SpaceShip is docked with the given SpaceObject.
    /// Example: ship:isDocked(base) -- returns true if `ship` is fully docked with `base`
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isDocked);
    /// Returns the SoaceObject with which this SpaceShip is docked.
    /// Example: base = ship:getDockedWith()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDockedWith);
    /// Returns the EDockingState value of this SpaceShip.
    /// 0 = Not docked
    /// 1 = Docking in progress
    /// 2 = Docked
    /// Example: ds = ship:getDockingState()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDockingState);
    /// Returns this SpaceShip's weapons target.
    /// For a CpuShip, this can differ from its orders target.
    /// Example: target = ship:getTarget()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTarget);
    /// Returns the number of the given weapon type stocked by this SpaceShip.
    /// Example: homing = ship:getWeaponStorage("Homing")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorage);
    /// Returns this SpaceShip's capacity for the given weapon type.
    /// Example: homing_max = ship:getWeaponStorageMax("Homing")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorageMax);
    /// Sets the number of the given weapon type stocked by this SpaceShip.
    /// Example: ship:setWeaponStorage("Homing", 2) -- this ship has 2 Homing missiles
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorage);
    /// Sets this SpaceShip's capacity for the given weapon type.
    /// If this ship has more stock of that weapon type than the new capacity, its stock is reduced.
    /// However, if this ship's capacity for a weapon type is increased, its stocks are not.
    /// Use SpaceShip:setWeaponStorage() to update the stocks.
    /// Example: ship:setWeaponStorageMax("Homing", 4) -- this ship can carry 4 Homing missiles
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorageMax);
    /// Returns this SpaceShip's shield frequency index.
    /// To convert the index to the value used by players, multiply it by 20, then add 400.
    /// Example:
    /// frequency = ship:getShieldsFrequency() -- frequency index is 10
    /// -- Outputs "Ship's shield frequency is 600THz"
    /// print("Ship's shield frequency is " .. (frequency * 20) + 400 .. "THz")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getShieldsFrequency);
    /// Sets this SpaceShip's shield frequency index.
    /// To convert the index to the value used by players, multiply it by 20, then add 400.
    /// Valid values are 0 (400THz) to 20 (800THz). Defaults to a random value.
    /// Unlike PlayerSpaceship:commandSetShieldFrequency(), this instantly changes the frequency with no calibration delay.
    /// Example: frequency = ship:setShieldsFrequency(10) -- frequency is 600THz
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShieldsFrequency);
    /// Returns this SpaceShip's beam weapon frequency.
    /// To convert the index to the value used by players, multiply it by 20, then add 400.
    /// Example:
    /// frequency = ship:getBeamFrequency() -- frequency index is 10
    /// -- Outputs "Ship's beam frequency is 600THz"
    /// print("Ship's beam frequency is " .. (frequency * 20) + 400 .. "THz")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamFrequency);
    /// Returns this SpaceShip's energy capacity.
    /// Example: ship:getMaxEnergy()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getMaxEnergy);
    /// Sets this SpaceShip's energy capacity.
    /// CpuShips and SpaceStations don't consume energy. Setting this has no effect on them.
    /// Example: ship:setMaxEnergy(800)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setMaxEnergy);
    /// Returns this SpaceShip's energy level.
    /// Example: ship:getEnergy()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getEnergy);
    /// Sets this SpaceShip's energy level.
    /// Valid values are any greater than 0 and less than the energy capacity (getMaxEnergy()).
    /// Invalid values are ignored.
    /// Example: ship:setEnergy(1000) -- sets the ship's energy to 1000 if its capacity is 1000 or more
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setEnergy);
    /// Returns whether this SpaceShip has the given system.
    /// Example: ship:hasSystem("impulse") -- returns true if the ship has impulse drive
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasSystem);
    /// Returns the hacked level for the given system on this SpaceShip.
    /// Returns a value between 0.0 (unhacked) and 1.0 (fully hacked).
    /// Example: ship:getSystemHackedLevel("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHackedLevel);
    /// Sets the hacked level for the given system on this SpaceShip.
    /// Valid range is 0.0 (unhacked) to 1.0 (fully hacked).
    /// Example: ship:setSystemHackedLevel("impulse",0.5) -- sets the ship's impulse drive to half hacked
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHackedLevel);
    /// Returns the given system's health on this SpaceShip.
    /// System health is related to damage, and is separate from its hacked level.
    /// Returns a value between 0.0 (fully disabled) and 1.0 (undamaged).
    /// Example: ship:getSystemHealth("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHealth);
    /// Sets the given system's health on this SpaceShip.
    /// System health is related to damage, and is separate from its hacked level.
    /// Valid range is 0.0 (fully disabled) and 1.0 (undamaged).
    /// Example: ship:setSystemHealth("impulse",0.5) -- sets the ship's impulse drive to half damaged
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHealth);
    /// Returns the given system's maximum health on this SpaceShip.
    /// Returns a value between 0.0 (fully disabled) and 1.0 (undamaged).
    /// Example: ship:getSystemHealthMax("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHealthMax);
    /// Sets the given system's maximum health on this SpaceShip.
    /// Valid range is 0.0 (fully disabled) and 1.0 (undamaged).
    /// Example: ship:setSystemHealthMax("impulse", 0.5) -- limits the ship's impulse drive health to half
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHealthMax);
    /// Returns the given system's heat level on this SpaceShip.
    /// Returns a value between 0.0 (no heat) and 1.0 (overheating).
    /// Example: ship:getSystemHeat("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeat);
    /// Sets the given system's heat level on this SpaceShip.
    /// CpuShips and SpaceStations don't generate or manage heat. Setting this has no effect on them.
    /// Valid range is 0.0 (fully disabled) to 1.0 (undamaged).
    /// Example: ship:setSystemHeat("impulse", 0.5) -- sets the ship's impulse drive heat to half of capacity
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeat);
    /// Returns the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
    /// Example: ship:getSystemHeatRate("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeatRate);
    /// Sets the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
    /// CpuShips and SpaceStations don't generate or manage heat. Setting this has no effect on them.
    /// Example: ship:setSystemHeatRate("impulse", 0.05)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeatRate);
    /// Returns the given system's power level on this SpaceShip.
    /// Returns a value between 0.0 (unpowered) and 1.0 (fully powered).
    /// Example: ship:getSystemPower("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPower);
    /// Sets the given system's power level.
    /// Valid range is 0.0 (unpowered) to 1.0 (fully powered).
    /// Example: ship:setSystemPower("impulse", 0.5) -- sets the ship's impulse drive to half power
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPower);
    /// Returns the given system's rate of consuming power, in points per second?, in this SpaceShip.
    /// Example: ship:getSystemPowerRate("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPowerRate);
    /// Sets the given system's rate of consuming power, in points per second?, in this SpaceShip.
    /// CpuShips and SpaceStations don't consume energy. Setting this has no effect.
    /// Example: ship:setSystemPowerRate("impulse", 0.4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPowerRate);
    /// Returns the relative power drain factor for the given system.
    /// Example: ship:getSystemPowerFactor("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPowerFactor);
    /// Sets the relative power drain factor? for the given system in this SpaceShip.
    /// "reactor" has a negative value because it generates power rather than draining it.
    /// CpuShips and SpaceStations don't consume energy. Setting this has no effect.
    /// Example: ship:setSystemPowerFactor("impulse", 4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPowerFactor);
    /// Returns the coolant distribution for the given system in this SpaceShip.
    /// Returns a value between 0.0 (none) and 1.0 (capacity).
    /// Example: ship:getSystemCoolant("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolant);
    /// Sets the coolant quantity for the given system in this SpaceShip.
    /// CpuShips and SpaceStations don't generate or manage heat. Setting this has no effect on them.
    /// Valid range is 0.0 (none) to 1.0 (capacity).
    /// Example: ship:setSystemPowerFactor("impulse", 4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemCoolant);
    /// Returns the rate at which the given system in this SpaceShip takes coolant, in points per second?
    /// Example: ship:getSystemCoolantRate("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolantRate);
    /// Sets the rate at which the given system in this SpaceShip takes coolant, in points per second?
    /// CpuShips and SpaceStations don't generate or manage heat. Setting this has no effect on them.
    /// Example: ship:setSystemCoolantRate("impulse", 1.2)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemCoolantRate);
    /// Returns this SpaceShip's forward and reverse impulse speed limits.
    /// Examples:
    /// forward,reverse = getImpulseMaxSpeed()
    /// forward = getImpulseMaxSpeed() -- forward speed only
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getImpulseMaxSpeed);
    /// Sets this SpaceShip's maximum forward and reverse impulse speeds.
    /// The reverse maximum speed value is optional.
    /// Calling this with a single argument sets both forward and reverse maximum speeds to the same value.
    /// Examples:
    /// ship:setImpulseMaxSpeed(30,20) -- sets the max forward speed to 30 and reverse to 20
    /// ship:setImpulseMaxSpeed(30) -- sets the max forward and reverse speed to 30
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setImpulseMaxSpeed);
    /// Returns this SpaceShip's maximum rotational speed, in degrees per second?
    /// Example: ship:getRotationMaxSpeed()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getRotationMaxSpeed);
    /// Sets this SpaceShip's maximum rotational speed, in degrees per second?
    /// Example: ship:setRotationMaxSpeed(10)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRotationMaxSpeed);
    /// Returns the SpaceShip's forward and reverse impulse acceleration values, in (unit?)
    /// Examples:
    /// forward,reverse = getAcceleration()
    /// forward = getAcceleration() -- forward acceleration only
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getAcceleration);
    /// Sets the SpaceShip's forward and reverse impulse acceleration values, in (unit?)
    /// The reverse acceleration value is optional.
    /// Calling with a single argument sets both forward and reverse acceleration to the same value.
    /// Examples:
    /// ship:setAcceleration(5,3.5) -- sets the max forward acceleration to 5 and reverse to 3.5
    /// ship:setAcceleration(5) -- sets the max forward and reverse acceleration to 5
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setAcceleration);
    /// Sets the SpaceShip's combat maneuvering capacities.
    /// The boost value sets the forward maneuver capacity, and the strafe value sets the lateral maneuver capacity.
    /// Example: ship:setCombatManeuver(400,250) -- sets boost capacity to 400 and lateral to 250
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setCombatManeuver);
    /// Returns whether the SpaceShip has a jump drive.
    /// Example: ship:hasJumpDrive()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasJumpDrive);
    /// Defines whether the SpaceShip has a jump drive.
    /// If true, this ship gains jump drive controls and a "jumpdrive" ship system.
    /// Example: ship:setJumpDrive(true) -- gives this ship a jump drive
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDrive);
    /// Sets the minimum and maximum jump distances for this SpaceShip.
    /// Defaults to (5000,50000) if not set by the ShipTemplate.
    /// Example: ship:setJumpDriveRange(2500,25000) -- sets the minimum jump distance to 2.5U and maximum to 25U
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDriveRange);
    /// Sets this SpaceShip's current jump drive charge.
    /// Jumping depletes the ship's jump drive charge by a value equal to the distance jumped.
    /// For example, a 5U jump depletes the charge by 5000.
    /// A SpaceShip with a jump drive can jump only when this value is equal to or greater than the ship's maximum jump range.
    /// Any numeric value is valid, including negative values (longer to recharge) and values larger than the ship's maximum jump range (can jump again with a shorter, or no, recharge required).
    /// Jump drive charge regenerates at a rate modified by the "jumpdrive" system's effectiveness.
    /// Example: ship:setJumpDriveCharge(50000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDriveCharge);
    /// Returns this SpaceShip's current jump drive charge.
    /// Example: jump_charge = ship:getJumpDriveCharge()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getJumpDriveCharge);
    /// Returns the time required by this SpaceShip to complete a jump once initiated.
    /// A ship can't perform certain actions, such as docking, while its jump delay is not 0.
    /// Returns a value between 0.0 (no delay, ready to jump) to 10.0.
    /// With normal "jumpdrive" system effectiveness, this delay is 10 seconds.
    /// System effectiveness can modify this delay.
    /// Example: ship:getJumpDelay()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getJumpDelay);
    /// Returns whether this SpaceShip has a warp drive.
    /// Example: ship:hasWarpDrive()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasWarpDrive);
    /// Defines whether this SpaceShip has a warp drive.
    /// If true, this ship gains warp drive controls and a "warp" ship system.
    /// Example: ship:setWarpDrive(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWarpDrive);
    /// Sets this SpaceShip's warp speed factor.
    /// Valid values are any greater than 0. Ships don't tend to go faster than 24000 (1400U/min) due to engine limitations.
    /// Unlike ShipTemplate:setWarpSpeed(), setting this value does NOT also grant this ship a warp drive.
    /// Example: ship:setWarpSpeed(1000);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWarpSpeed);
    /// Returns this SpaceShip's warp speed factor.
    /// Actual warp speed can be modified by "warp" system effectiveness.
    /// Example: ship:getWarpSpeed();
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWarpSpeed);
    /// Returns the arc, in degrees, for the BeamWeapon with the given index on this SpaceShip.
    /// Example: ship:getBeamWeaponArc(0); -- returns beam weapon 0's arc
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponArc);
    /// Returns the direction, in degrees relative to the ship's forward bearing, for the arc's center of the BeamWeapon with the given index on this SpaceShip.
    /// Example: ship:getBeamWeaponDirection(0); -- returns beam weapon 0's direction
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDirection);
    /// Returns the range for the BeamWeapon with the given index on this SpaceShip.
    /// Example: ship:getBeamWeaponRange(0); -- returns beam weapon 0's range
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponRange);
    /// Returns the turret arc, in degrees, for the BeamWeapon with the given index on this SpaceShip.
    /// Example: ship:getBeamWeaponTurretArc(0); -- returns beam weapon 0's turret arc
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponTurretArc);
    /// Returns the direction, in degrees relative to the ship's forward bearing, for the turret arc's center for the BeamWeapon with the given index on this SpaceShip.
    /// Example: ship:getBeamWeaponTurretDirection(0); -- returns beam weapon 0's turret direction
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponTurretDirection);
    /// Returns the base firing delay, in seconds, for the BeamWeapon with the given index on this SpaceShip.
    /// Actual cycle time can be modified by "beamweapon" system effectiveness.
    /// Example: ship:getBeamWeaponCycleTime(0); -- returns beam weapon 0's cycle time
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponCycleTime);
    /// Returns the base damage dealt by the BeamWeapon with the given index on this SpaceShip.
    /// Actual damage can be modified by "beamweapon" system effectiveness.
    /// Example: ship:getBeamWeaponDamage(0); -- returns beam weapon 0's damage
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDamage);
    /// Returns how much of this SpaceShip's energy is drained each time the BeamWeapon with the given index is fired.
    /// Actual drain can be modified by "beamweapon" system effectiveness.
    /// Example: ship:getBeamWeaponEnergyPerFire(0); -- returns beam weapon 0's energy use per firing
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponEnergyPerFire);
    /// Returns the heat generated by each firing of the BeamWeapon with the given index on this SpaceShip.
    /// Actual heat generation can be modified by "beamweapon" system effectiveness.
    /// Example: ship:getBeamWeaponHeatPerFire(0); -- returns beam weapon 0's heat generation per firing
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponHeatPerFire);
    /// Defines the traits of a BeamWeapon with the given index on this SpaceShip.
    /// - index: Each beam weapon on this SpaceShip must have a unique index.
    /// - arc: Sets the arc of its firing capability, in degrees.
    /// - direction: Sets the default center angle of the arc, in degrees relative to the ship's forward bearing. Accepts 0, negative, and positive values.
    /// - range: Sets how far away the beam can fire.
    /// - cycle_time: Sets the base firing delay, in seconds. System effectiveness modifies the cycle time.
    /// - damage: Sets the base damage done by the beam to the target. System effectiveness modifies the damage.
    /// To create a turreted beam, also add SpaceShip:setBeamWeaponTurret(), and set the beam weapon's arc to be smaller than the turret's arc.
    /// Example:
    /// -- Creates a beam weapon with index 0, arc of 90 degrees, direction pointing backward, range of 1U, base cycle time of 1 second, and base damage of 1 point
    /// ship:setBeamWeapon(0,90,180,1000,1,1)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeapon);
    /// Converts a BeamWeapon with the given index on this SpaceShip into a turret and defines its traits.
    /// A turreted beam weapon rotates within its turret arc toward the weapons target at the given rotation rate.
    /// - index: Must match the index of an existing beam weapon on this SpaceShip.
    /// - arc: Sets the turret's maximum targeting angles, in degrees. The turret arc must be larger than the associated beam weapon's arc.
    /// - direction: Sets the default center angle of the turret arc, in degrees relative to the ship's forward bearing. Accepts 0, negative, and positive values.
    /// - rotation_rate: Sets how many degrees per tick (unit?) that the associated beam weapon's direction can rotate toward the target within the turret arc. System effectiveness modifies the turret's rotation rate.
    /// To create a turreted beam, also add SpaceShip:setBeamWeapon(), and set the beam weapon's arc to be smaller than the turret's arc.
    /// Example:
    /// -- Makes beam weapon 0 a turret with a 200-degree turret arc centered on 90 degrees from forward, rotating at 5 degrees per tick (unit?)
    /// ship:setBeamWeaponTurret(0,200,90,5)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTurret);
    /// Sets the BeamEffect texture, by filename, for the BeamWeapon with the given index on this SpaceShip.
    /// See BeamEffect:setTexture().
    /// Example: ship:setBeamWeaponTexture(0,"texture/beam_blue.png")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTexture);
    /// Sets how much energy is drained each time the BeamWeapon with the given index is fired on this SpaceShip.
    /// Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
    /// Example: ship:setBeamWeaponEnergyPerFire(0,1) -- sets beam 0 to use 1 energy per firing
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponEnergyPerFire);
    /// Sets how much "beamweapon" system heat is generated, in percentage of total system heat capacity, each time the BeamWeapon with the given index is fired on this SpaceShip.
    /// Only PlayerSpaceships generate and manage heat. Setting this for other ShipTemplateBasedObject types has no effect.
    /// Example: ship:setBeamWeaponHeatPerFire(0,0.02) -- sets beam 0 to generate 0.02 (2%) system heat per firing
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponHeatPerFire);
    /// Sets the colors used to draw the radar arc for the BeamWeapon with the given index on this SpaceShip.
    /// The first three-number value sets the RGB color for the arc when idle, and the second sets the color when firing.
    /// Example: ship:setBeamWeaponArcColor(0,0,128,0,0,255,0) -- makes beam 0's arc green
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponArcColor);
    /// Sets the damage type dealt by the BeamWeapon with the given index on this SpaceShip.
    /// Example: ship:setBeamWeaponDamageType(0,"emp") -- makes beam 0 deal EMP damage
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponDamageType);
    /// Sets the number of WeaponTubes for this SpaceShip.
    /// Weapon tubes are 0-indexed. For example, 3 tubes would be indexed 0, 1, and 2.
    /// Ships are limited to a maximum of 16 weapon tubes.
    /// Example: ship:setWeaponTubeCount(4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeCount);
    /// Returns the number of WeaponTube on this SpaceShip.
    /// Example: ship:getWeaponTubeCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeCount);
    /// Returns the weapon type loaded into the WeaponTube with the given index on this SpaceShip.
    /// Returns no value if no weapon is loaded, which includes the tube being in a loading or unloading state.
    /// Example: ship:getWeaponTubeLoadType(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeLoadType);
    /// Sets which weapon types the WeaponTube with the given index on this SpaceShip can load.
    /// Note the spelling of "missle".
    /// Example: ship:weaponTubeAllowMissle(0,"Homing") -- allows Homing missiles to be loaded in WeaponTube 0
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeAllowMissle);
    /// Sets which weapon types the WeaponTube with the given index can't load on this SpaceShip.
    /// Note the spelling of "missle".
    /// Example: ship:weaponTubeDisallowMissle(0,"Homing") -- prevents Homing missiles from being loaded in tube 0
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeDisallowMissle);
    /// Sets a weapon tube with the given index on this SpaceShip to allow loading only the given weapon type.
    /// Example: ship:setWeaponTubeExclusiveFor(0,"Homing") -- allows only Homing missiles to be loaded in tube 0
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeExclusiveFor);
    /// Sets the angle, relative to this SpaceShip's forward bearing, toward which the WeaponTube with the given index on this SpaceShip points.
    /// Accepts 0, negative, and positive values.
    /// Example:
    /// -- Sets tube 0 to point 90 degrees right of forward, and tube 1 to point 90 degrees left of forward
    /// ship:setWeaponTubeDirection(0,90):setWeaponTubeDirection(1,-90)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeDirection);
    /// Sets the weapon size launched from the WeaponTube with the given index on this SpaceShip.
    /// Example: ship:setTubeSize(0,"large") -- sets tube 0 to fire large weapons
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setTubeSize);
    /// Returns the size of the weapon tube with the given index on this SpaceShip.
    /// Example: ship:getTubeSize(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTubeSize);
    /// Returns the delay, in seconds, for loading and unloading the WeaponTube with the given index on this SpaceShip.
    /// Example: ship:getTubeLoadTime(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTubeLoadTime);
    /// Sets the time, in seconds, required to load the weapon tube with the given index on this SpaceShip.
    /// Example: ship:setTubeLoadTime(0,12) -- sets the loading time for tube 0 to 12 seconds
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setTubeLoadTime);
    /// Sets the radar trace image for this SpaceShip.
    /// Valid values are filenames to PNG images relative to the resources/radar/ directory.
    /// Radar trace images should be white with a transparent background.
    /// Only scanned SpaceShips use a specific radar trace image. Unscanned SpaceShips always display as an arrow.
    /// Example: ship:setRadarTrace("blip.png") -- displays a dot for this ship on radar when scanned
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRadarTrace);
    /// Returns the dynamic gravitational radar signature value emitted by this SpaceShip.
    /// Ship functions can dynamically modify this SpaceShip's radar signature values.
    /// Example: ship:getDynamicRadarSignatureGravity()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDynamicRadarSignatureGravity);
    /// Returns the dynamic electrical radar signature value emitted by this SpaceShip.
    /// Ship functions can dynamically modify this SpaceShip's radar signature values.
    /// Example: ship:getDynamicRadarSignatureElectrical()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDynamicRadarSignatureElectrical);
    /// Returns the dynamic biological radar signature value emitted by this SpaceShip.
    /// Ship functions can dynamically modify this SpaceShip's radar signature values.
    /// Example: ship:getDynamicRadarSignatureBiological()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDynamicRadarSignatureBiological);
    /// Broadcasts a message from this SpaceShip to the comms of all other SpaceShips matching the threshold.
    /// The threshold value can be an integer equivalent of EFactionVsFactionState:
    /// 0: Broadcast to all friendly SpaceShips
    /// 1: Broadcast to all friendly and neutral SpaceShips
    /// 2: Broadcast to all SpaceShips, including enemies
    /// Providing an invalid threshold value defaults to broadcasting only to friendly SpaceShips.
    /// Examples:
    /// ship:addBroadcast(1, "Help!")
    /// ship:addBroadcast(2, "We're taking over!")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, addBroadcast);
    /// Sets the scan state of this SpaceShip for every faction.
    /// Example: ship:setScanState("fullscan") -- every faction treats this ship as fully scanned
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setScanState);
    /// Sets the scan state of this SpaceShip for a given faction.
    /// Example: ship:setScanStateByFaction("Kraylor","fullscan") -- Kraylor faction treats this ship as fully scanned
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setScanStateByFaction);
}

std::array<float, SYS_COUNT> SpaceShip::default_system_power_factors{
    /*SYS_Reactor*/     -25.f,
    /*SYS_BeamWeapons*/   3.f,
    /*SYS_MissileSystem*/ 1.f,
    /*SYS_Maneuver*/      2.f,
    /*SYS_Impulse*/       4.f,
    /*SYS_Warp*/          5.f,
    /*SYS_JumpDrive*/     5.f,
    /*SYS_FrontShield*/   5.f,
    /*SYS_RearShield*/    5.f,
};

SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
    setCollisionPhysics(true, false);

    target_rotation = getRotation();
    impulse_request = 0;
    current_impulse = 0;
    has_warp_drive = true;
    warp_request = 0;
    current_warp = 0;
    warp_speed_per_warp_level = 1000.f;
    has_jump_drive = true;
    jump_drive_min_distance = 5000.f;
    jump_drive_max_distance = 50000.f;
    jump_drive_charge = jump_drive_max_distance;
    jump_distance = 0.f;
    jump_delay = 0.f;
    wormhole_alpha = 0.f;
    weapon_tube_count = 0;
    turn_speed = 10.f;
    impulse_max_speed = 600.f;
    impulse_max_reverse_speed = 600.f;
    combat_maneuver_charge = 1.f;
    combat_maneuver_boost_request = 0.f;
    combat_maneuver_boost_active = 0.f;
    combat_maneuver_strafe_request = 0.f;
    combat_maneuver_strafe_active = 0.f;
    combat_maneuver_boost_speed = 0.0f;
    combat_maneuver_strafe_speed = 0.0f;
    target_id = -1;
    beam_frequency = irandom(0, max_frequency);
    beam_system_target = SYS_None;
    shield_frequency = irandom(0, max_frequency);
    docking_state = DS_NotDocking;
    impulse_acceleration = 20.f;
    impulse_reverse_acceleration = 20.f;
    energy_level = 1000;
    max_energy_level = 1000;
    turnSpeed = 0.0f;

    registerMemberReplication(&target_rotation, 1.5f);
    registerMemberReplication(&turnSpeed, 0.1f);
    registerMemberReplication(&impulse_request, 0.1f);
    registerMemberReplication(&current_impulse, 0.5f);
    registerMemberReplication(&has_warp_drive);
    registerMemberReplication(&warp_request, 0.1f);
    registerMemberReplication(&current_warp, 0.1f);
    registerMemberReplication(&has_jump_drive);
    registerMemberReplication(&jump_drive_charge, 0.5f);
    registerMemberReplication(&jump_delay, 0.5f);
    registerMemberReplication(&jump_drive_min_distance);
    registerMemberReplication(&jump_drive_max_distance);
    registerMemberReplication(&wormhole_alpha, 0.5f);
    registerMemberReplication(&weapon_tube_count);
    registerMemberReplication(&target_id);
    registerMemberReplication(&turn_speed);
    registerMemberReplication(&impulse_max_speed);
    registerMemberReplication(&impulse_max_reverse_speed);
    registerMemberReplication(&impulse_acceleration);
    registerMemberReplication(&impulse_reverse_acceleration);
    registerMemberReplication(&warp_speed_per_warp_level);
    registerMemberReplication(&shield_frequency);
    registerMemberReplication(&docking_state);
    registerMemberReplication(&docked_style);
    registerMemberReplication(&beam_frequency);
    registerMemberReplication(&combat_maneuver_charge, 0.5f);
    registerMemberReplication(&combat_maneuver_boost_request);
    registerMemberReplication(&combat_maneuver_boost_active, 0.2f);
    registerMemberReplication(&combat_maneuver_strafe_request);
    registerMemberReplication(&combat_maneuver_strafe_active, 0.2f);
    registerMemberReplication(&combat_maneuver_boost_speed);
    registerMemberReplication(&combat_maneuver_strafe_speed);
    registerMemberReplication(&radar_trace);

    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        SDL_assert(n < default_system_power_factors.size());
        systems[n].health = 1.0f;
        systems[n].health_max = 1.0f;
        systems[n].power_level = 1.0f;
        systems[n].power_rate_per_second = ShipSystem::default_power_rate_per_second;
        systems[n].power_request = 1.0f;
        systems[n].coolant_level = 0.0f;
        systems[n].coolant_rate_per_second = ShipSystem::default_coolant_rate_per_second;
        systems[n].coolant_request = 0.0f;
        systems[n].heat_level = 0.0f;
        systems[n].heat_rate_per_second = ShipSystem::default_heat_rate_per_second;
        systems[n].hacked_level = 0.0f;
        systems[n].power_factor = default_system_power_factors[n];

        registerMemberReplication(&systems[n].health, 0.1f);
        registerMemberReplication(&systems[n].health_max, 0.1f);
        registerMemberReplication(&systems[n].hacked_level, 0.1f);
    }

    for(int n = 0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].setParent(this);
    }

    for(int n = 0; n < max_weapon_tubes; n++)
    {
        weapon_tube[n].setParent(this);
        weapon_tube[n].setIndex(n);
    }

    for(int n = 0; n < MW_Count; n++)
    {
        weapon_storage[n] = 0;
        weapon_storage_max[n] = 0;
        registerMemberReplication(&weapon_storage[n]);
        registerMemberReplication(&weapon_storage_max[n]);
    }

    scanning_complexity_value = -1;
    scanning_depth_value = -1;

    // Ships can have dynamic signatures. Initialize a default baseline value
    // from which clients derive the dynamic signature on update.
    setRadarSignatureInfo(0.05f, 0.2f, 0.2f);

    if (game_server)
        setCallSign(gameGlobalInfo->getNextShipCallsign());
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
SpaceShip::~SpaceShip()
{
}

void SpaceShip::applyTemplateValues()
{
    for(int n=0; n<max_beam_weapons; n++)
    {
        beam_weapons[n].setPosition(ship_template->model_data->getBeamPosition(n));
        beam_weapons[n].setArc(ship_template->beams[n].getArc());
        beam_weapons[n].setDirection(ship_template->beams[n].getDirection());
        beam_weapons[n].setRange(ship_template->beams[n].getRange());
        beam_weapons[n].setTurretArc(ship_template->beams[n].getTurretArc());
        beam_weapons[n].setTurretDirection(ship_template->beams[n].getTurretDirection());
        beam_weapons[n].setTurretRotationRate(ship_template->beams[n].getTurretRotationRate());
        beam_weapons[n].setCycleTime(ship_template->beams[n].getCycleTime());
        beam_weapons[n].setDamage(ship_template->beams[n].getDamage());
        beam_weapons[n].setBeamTexture(ship_template->beams[n].getBeamTexture());
        beam_weapons[n].setEnergyPerFire(ship_template->beams[n].getEnergyPerFire());
        beam_weapons[n].setHeatPerFire(ship_template->beams[n].getHeatPerFire());
    }
    weapon_tube_count = ship_template->weapon_tube_count;
    energy_level = max_energy_level = ship_template->energy_storage_amount;

    impulse_max_speed = ship_template->impulse_speed;
    impulse_max_reverse_speed = ship_template->impulse_reverse_speed;
    impulse_acceleration = ship_template->impulse_acceleration;
    impulse_reverse_acceleration = ship_template->impulse_reverse_acceleration;
    
    turn_speed = ship_template->turn_speed;
    combat_maneuver_boost_speed = ship_template->combat_maneuver_boost_speed;
    combat_maneuver_strafe_speed = ship_template->combat_maneuver_strafe_speed;
    has_warp_drive = ship_template->warp_speed > 0.0f;
    warp_speed_per_warp_level = ship_template->warp_speed;
    has_jump_drive = ship_template->has_jump_drive;
    jump_drive_min_distance = ship_template->jump_drive_min_distance;
    jump_drive_max_distance = ship_template->jump_drive_max_distance;
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].setLoadTimeConfig(ship_template->weapon_tube[n].load_time);
        weapon_tube[n].setDirection(ship_template->weapon_tube[n].direction);
        weapon_tube[n].setSize(ship_template->weapon_tube[n].size);
        for(int m=0; m<MW_Count; m++)
        {
            if (ship_template->weapon_tube[n].type_allowed_mask & (1 << m))
                weapon_tube[n].allowLoadOf(EMissileWeapons(m));
            else
                weapon_tube[n].disallowLoadOf(EMissileWeapons(m));
        }
    }
    //shipTemplate->has_cloaking;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = weapon_storage_max[n] = ship_template->weapon_storage[n];

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);
}

void SpaceShip::draw3D()
{
    if (docked_style == DockStyle::Internal) return;
    ShipTemplateBasedObject::draw3D();
}

void SpaceShip::draw3DTransparent()
{
    if (!ship_template) return;
    if (docked_style == DockStyle::Internal) return;
    ShipTemplateBasedObject::draw3DTransparent();

    if ((has_jump_drive && jump_delay > 0.0f) ||
        (wormhole_alpha > 0.0f))
    {
        float delay = jump_delay;
        if (wormhole_alpha > 0.0f)
            delay = wormhole_alpha;
        float alpha = 1.0f - (delay / 10.0f);
        model_info.renderOverlay(getModelMatrix(), textureManager.getTexture("texture/electric_sphere_texture.png"), alpha);
    }
}

RawRadarSignatureInfo SpaceShip::getDynamicRadarSignatureInfo()
{
    // Adjust radar_signature dynamically based on current state and activity.
    // radar_signature becomes the ship's baseline radar signature.
    RawRadarSignatureInfo signature_delta;

    // For each ship system ...
    for(int n = 0; n < SYS_COUNT; n++)
    {
        ESystem ship_system = static_cast<ESystem>(n);

        // ... increase the biological band based on system heat, offset by
        // coolant.
        signature_delta.biological += std::max(
            0.0f,
            std::min(
                1.0f,
                getSystemHeat(ship_system) - (getSystemCoolant(ship_system) / 10.0f)
            )
        );

        // ... adjust the electrical band if system power allocation is not
        // 100%.
        if (ship_system == SYS_JumpDrive && jump_drive_charge < jump_drive_max_distance)
        {
            // ... elevate electrical after a jump, since recharging jump
            // consumes energy.
            signature_delta.electrical += std::max(
                0.0f,
                std::min(
                    1.0f,
                    getSystemPower(ship_system) * (jump_drive_charge + 0.01f / jump_drive_max_distance)
                )
            );
        } else if (getSystemPower(ship_system) != 1.0f)
        {
            // For non-Jump systems, allow underpowered systems to reduce the
            // total electrical signal output.
            signature_delta.electrical += std::max(
                -1.0f,
                std::min(
                    1.0f,
                    getSystemPower(ship_system) - 1.0f
                )
            );
        }
    }

    // Increase the gravitational band if the ship is about to jump, or is
    // actively warping.
    if (jump_delay > 0.0f)
    {
        signature_delta.gravity += std::max(
            0.0f,
            std::min(
                (1.0f / jump_delay + 0.01f) + 0.25f,
                10.0f
            )
        );
    } else if (current_warp > 0.0f)
    {
        signature_delta.gravity += current_warp;
    }

    // Update the signature by adding the delta to its baseline.
    RawRadarSignatureInfo info = getRadarSignatureInfo();
    info += signature_delta;
    return info;
}

void SpaceShip::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (docked_style == DockStyle::Internal) return;

    // Draw beam arcs on short-range radar only, and only for fully scanned
    // ships.
    if (!long_range && (!my_spaceship || (getScannedStateFor(my_spaceship) == SS_FullScan)))
    {
        auto draw_arc = [&renderer](auto arc_center, auto angle0, auto arc_angle, auto arc_radius, auto color)
        {
            // Initialize variables from the beam's data.
            float beam_arc = arc_angle;
            float beam_range = arc_radius;

            // Set the beam's origin on radar to its relative position on the mesh.
            float outline_thickness = std::min(20.0f, beam_range * 0.2f);
            float beam_arc_curve_length = beam_range * beam_arc / 180.0f * glm::pi<float>();
            outline_thickness = std::min(outline_thickness, beam_arc_curve_length * 0.25f);

            size_t curve_point_count = 0;
            if (outline_thickness > 0.f)
                curve_point_count = static_cast<size_t>(beam_arc_curve_length / (outline_thickness * 0.9f));

            struct ArcPoint {
                glm::vec2 point;
                glm::vec2 normal; // Direction towards the center.
            };

            //Arc points
            std::vector<ArcPoint> arc_points;
            arc_points.reserve(curve_point_count + 1);
            
            for (size_t i = 0; i < curve_point_count; i++)
            {
                auto angle = vec2FromAngle(angle0 + i * beam_arc / curve_point_count) * beam_range;
                arc_points.emplace_back(ArcPoint{ arc_center + angle, glm::normalize(angle) });
            }
            {
                auto angle = vec2FromAngle(angle0 + beam_arc) * beam_range;
                arc_points.emplace_back(ArcPoint{ arc_center + angle, glm::normalize(angle) });
            }

            for (size_t n = 0; n < arc_points.size() - 1; n++)
            {
                const auto& p0 = arc_points[n].point;
                const auto& p1 = arc_points[n + 1].point;
                const auto& n0 = arc_points[n].normal;
                const auto& n1 = arc_points[n + 1].normal;
                renderer.drawTexturedQuad("gradient.png",
                    p0, p0 - n0 * outline_thickness,
                    p1 - n1 * outline_thickness, p1,
                    { 0.f, 0.5f }, { 1.f, 0.5f }, { 1.f, 0.5f }, { 0.f, 0.5f },
                    color);
            }

            if (beam_arc < 360.f)
            {
                // Arc bounds.
                // We use the left- and right-most edges as lines, going inwards, parallel to the center.
                const auto left_edge = vec2FromAngle(angle0) * beam_range;
                const auto right_edge = vec2FromAngle(angle0 + beam_arc) * beam_range;
            
                // Compute the half point, always going clockwise from the left edge.
                // This makes sure the algorithm never takes the short road.
                auto halfway_angle = vec2FromAngle(angle0 + beam_arc / 2.f) * beam_range;
                auto middle = glm::normalize(halfway_angle);

                // Edge vectors.
                const auto left_edge_vector = glm::normalize(left_edge);
                const auto right_edge_vector = glm::normalize(right_edge);

                // Edge normals, inwards.
                auto left_edge_normal = glm::vec2{ left_edge_vector.y, -left_edge_vector.x };
                const auto right_edge_normal = glm::vec2{ -right_edge_vector.y, right_edge_vector.x };

                // Initial offset, follow along the edges' normals, inwards.
                auto left_inner_offset = -left_edge_normal * outline_thickness;
                auto right_inner_offset = -right_edge_normal * outline_thickness;

                if (beam_arc < 180.f)
                {
                    // The thickness being perpendicular from the edges,
                    // the inner lines just crosses path on the height,
                    // so just use that point.
                    left_inner_offset = middle * outline_thickness / sinf(glm::radians(beam_arc / 2.f));
                    right_inner_offset = left_inner_offset;
                }
                else
                {
                    // Make it shrink nicely as it grows up to 360 deg.
                    // For that, we use the edge's normal against the height which will change from 0 to 90deg.
                    // Also flip the direction so our points stay inside the beam.
                    auto thickness_scale = -glm::dot(middle, right_edge_normal);
                    left_inner_offset *= thickness_scale;
                    right_inner_offset *= thickness_scale;
                }

                renderer.drawTexturedQuad("gradient.png",
                    arc_center, arc_center + left_inner_offset,
                    arc_center + left_edge - left_edge_normal * outline_thickness, arc_center + left_edge,
                    { 0.f, 0.5f }, { 1.f, 0.5f }, { 1.f, 0.5f }, { 0.f, 0.5f },
                    color);

                renderer.drawTexturedQuad("gradient.png",
                    arc_center, arc_center + right_inner_offset,
                    arc_center + right_edge - right_edge_normal * outline_thickness, arc_center + right_edge,
                    { 0.f, 0.5f }, { 1.f, 0.5f }, { 1.f, 0.5f }, { 0.f, 0.5f },
                    color);
            }
        };

        // For each beam ...
        for(int n = 0; n < max_beam_weapons; n++)
        {
            // Draw beam arcs only if the beam has a range. A beam with range 0
            // effectively doesn't exist; exit if that's the case.
            if (beam_weapons[n].getRange() == 0.0f) continue;

            // If the beam is cooling down, flash and fade the arc color.
            glm::u8vec4 color = Tween<glm::u8vec4>::linear(std::max(0.0f, beam_weapons[n].getCooldown()), 0, beam_weapons[n].getCycleTime(), beam_weapons[n].getArcColor(), beam_weapons[n].getArcFireColor());

            
            // Initialize variables from the beam's data.
            float beam_direction = beam_weapons[n].getDirection();
            float beam_arc = beam_weapons[n].getArc();
            float beam_range = beam_weapons[n].getRange();

            // Set the beam's origin on radar to its relative position on the mesh.
            auto beam_offset = rotateVec2(ship_template->model_data->getBeamPosition2D(n) * scale, getRotation()-rotation);
            auto arc_center = beam_offset + position;

            draw_arc(arc_center, getRotation() - rotation + (beam_direction - beam_arc / 2.0f), beam_arc, beam_range * scale, color);
           

            // If the beam is turreted, draw the turret's arc. Otherwise, exit.
            if (beam_weapons[n].getTurretArc() == 0.0f)
                continue;

            // Initialize variables from the turret data.
            float turret_arc = beam_weapons[n].getTurretArc();
            float turret_direction = beam_weapons[n].getTurretDirection();

            // Draw the turret's bounds, at half the transparency of the beam's.
            // TODO: Make this color configurable.
            color.a /= 4;

            draw_arc(arc_center, getRotation() - rotation + (turret_direction - turret_arc / 2.0f), turret_arc, beam_range * scale, color);
        }
    }
    // If not on long-range radar ...
    if (!long_range)
    {
        // ... and the ship being drawn is either not our ship or has been
        // scanned ...
        if (!my_spaceship || getScannedStateFor(my_spaceship) >= SS_SimpleScan)
        {
            // ... draw and show shield indicators on our radar.
            drawShieldsOnRadar(renderer, position, scale, rotation, 1.f, true);
        } else {
            // Otherwise, draw the indicators, but don't show them.
            drawShieldsOnRadar(renderer, position, scale, rotation, 1.f, false);
        }
    }

    // Set up the radar sprite for objects.
    string object_sprite = radar_trace;
    // If the object is a ship that hasn't been scanned, draw the default icon.
    // Otherwise, draw the ship-specific icon.
    if (my_spaceship && (getScannedStateFor(my_spaceship) == SS_NotScanned || getScannedStateFor(my_spaceship) == SS_FriendOrFoeIdentified))
    {
        object_sprite = "radar/arrow.png";
    }

    glm::u8vec4 color;
    if (my_spaceship == this)
    {
        color = glm::u8vec4(192, 192, 255, 255);
    }else if (my_spaceship)
    {
        if (getScannedStateFor(my_spaceship) != SS_NotScanned)
        {
            if (isEnemy(my_spaceship))
                color = glm::u8vec4(255, 0, 0, 255);
            else if (isFriendly(my_spaceship))
                color = glm::u8vec4(128, 255, 128, 255);
            else
                color = glm::u8vec4(128, 128, 255, 255);
        }else{
            color = glm::u8vec4(192, 192, 192, 255);
        }
    }else{
        if (factionInfo[getFactionId()])
            color = factionInfo[getFactionId()]->getGMColor();
    }
    renderer.drawRotatedSprite(object_sprite, position, long_range ? 22.f : 32.f, getRotation() - rotation, color);
}

void SpaceShip::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (docked_style == DockStyle::Internal) return;

    if (!long_range)
    {
        renderer.fillRect(sp::Rect(position.x - 30, position.y - 30, 60 * hull_strength / hull_max, 5), glm::u8vec4(128, 255, 128, 128));
    }
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    if (hasCollisionShape() != (docked_style != DockStyle::Internal))
    {
        if (docked_style == DockStyle::Internal)
            setCollisionRadius(0);
        else if (ship_template)
            ship_template->setCollisionData(this);
    }

    if (game_server)
    {
        if (docking_state == DS_Docking)
        {
            if (!docking_target)
                docking_state = DS_NotDocking;
            else
                target_rotation = vec2ToAngle(getPosition() - docking_target->getPosition());
            if (fabs(angleDifference(target_rotation, getRotation())) < 10.0f)
                impulse_request = -1.f;
            else
                impulse_request = 0.f;
        }
        if (docking_state == DS_Docked)
        {
            if (!docking_target)
            {
                docking_state = DS_NotDocking;
                docked_style = DockStyle::None;
            }else{
                setPosition(docking_target->getPosition() + rotateVec2(docking_offset, docking_target->getRotation()));
                target_rotation = vec2ToAngle(getPosition() - docking_target->getPosition());

                P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
                if (docked_with_template_based && docked_with_template_based->repair_docked)  //Check if what we are docked to allows hull repairs, and if so, do it.
                {
                    if (hull_strength < hull_max)
                    {
                        hull_strength += delta;
                        if (hull_strength > hull_max)
                            hull_strength = hull_max;
                    }
                }
            }
            impulse_request = 0.f;
        }
        if ((docking_state == DS_Docked) || (docking_state == DS_Docking))
            warp_request = 0;
    }

    float rotationDiff;
    if (fabs(turnSpeed) < 0.0005f) {
        rotationDiff = angleDifference(getRotation(), target_rotation);
    } else {
        rotationDiff = turnSpeed;
    }

    if (rotationDiff > 1.0f)
        setAngularVelocity(turn_speed * getSystemEffectiveness(SYS_Maneuver));
    else if (rotationDiff < -1.0f)
        setAngularVelocity(-turn_speed * getSystemEffectiveness(SYS_Maneuver));
    else
        setAngularVelocity(rotationDiff * turn_speed * getSystemEffectiveness(SYS_Maneuver));

    //Here we want to have max speed at 100% impulse, and max reverse speed at -100% impulse
    float cap_speed = impulse_max_speed;
    
    if(current_impulse < 0 && impulse_max_reverse_speed <= 0.01f)
    {
        current_impulse = 0; //we could get stuck with a ship with no reverse speed, not being able to accelerate
    }
    if(current_impulse < 0) 
    {
        cap_speed = impulse_max_reverse_speed;
    }
    if ((has_jump_drive && jump_delay > 0) || (has_warp_drive && warp_request > 0))
    {
        if (WarpJammer::isWarpJammed(getPosition()))
        {
            jump_delay = 0;
            warp_request = 0;
        }
    }
    if (has_jump_drive && jump_delay > 0)
    {
        if (current_impulse > 0.0f)
        {
            if (cap_speed > 0)
                current_impulse -= delta * (impulse_reverse_acceleration / cap_speed);
            if (current_impulse < 0.0f)
                current_impulse = 0.f;
        }
        if (current_impulse < 0.0f)
        {
            if (cap_speed > 0)
                current_impulse += delta * (impulse_acceleration / cap_speed);
            if (current_impulse > 0.0f)
                current_impulse = 0.f;
        }
        if (current_warp > 0.0f)
        {
            current_warp -= delta;
            if (current_warp < 0.0f)
                current_warp = 0.f;
        }
        jump_delay -= delta * getSystemEffectiveness(SYS_JumpDrive);
        if (jump_delay <= 0.0f)
        {
            executeJump(jump_distance);
            jump_delay = 0.f;
        }
    }else if (has_warp_drive && (warp_request > 0 || current_warp > 0))
    {
        if (current_impulse > 0.0f)
        {
            if (cap_speed > 0)
                current_impulse -= delta * (impulse_reverse_acceleration / cap_speed);
            if (current_impulse < 0.0f)
                current_impulse = 0.0f;
        }else if (current_impulse < 0.0f)
        {
            if (cap_speed > 0)
                current_impulse += delta * (impulse_acceleration / cap_speed);
            if (current_impulse > 0.0f)
                current_impulse = 0.0f;
        }else{
            if (current_warp < warp_request)
            {
                current_warp += delta / warp_charge_time;
                if (current_warp > warp_request)
                    current_warp = warp_request;
            }else if (current_warp > warp_request)
            {
                current_warp -= delta / warp_decharge_time;
                if (current_warp < warp_request)
                    current_warp = warp_request;
            }
        }
    }else{
        if (has_jump_drive)
        {
            float f = getJumpDriveRechargeRate();
            if (f > 0)
            {
                if (jump_drive_charge < jump_drive_max_distance)
                {
                    float extra_charge = (delta / jump_drive_charge_time * jump_drive_max_distance) * f;
                    if (useEnergy(extra_charge * jump_drive_energy_per_km_charge / 1000.0f))
                    {
                        jump_drive_charge += extra_charge;
                        if (jump_drive_charge >= jump_drive_max_distance)
                            jump_drive_charge = jump_drive_max_distance;
                    }
                }
            }else{
                jump_drive_charge += (delta / jump_drive_charge_time * jump_drive_max_distance) * f;
                if (jump_drive_charge < 0.0f)
                    jump_drive_charge = 0.0f;
            }
        }
        current_warp = 0.f;
        if (impulse_request > 1.0f)
            impulse_request = 1.0f;
        if (impulse_request < -1.0f)
            impulse_request = -1.0f;
        if (current_impulse < impulse_request)
        {
            if (cap_speed > 0)
                current_impulse += delta * (impulse_acceleration / cap_speed);
            if (current_impulse > impulse_request)
                current_impulse = impulse_request;
        }else if (current_impulse > impulse_request)
        {
            if (cap_speed > 0)
                current_impulse -= delta * (impulse_reverse_acceleration / cap_speed);
            if (current_impulse < impulse_request)
                current_impulse = impulse_request;
        }
    }

    // Add heat based on warp factor.
    addHeat(SYS_Warp, current_warp * delta * heat_per_warp * getSystemEffectiveness(SYS_Warp));

    // Determine forward direction and velocity.
    auto forward = vec2FromAngle(getRotation());
    setVelocity(forward * (current_impulse * cap_speed * getSystemEffectiveness(SYS_Impulse) + current_warp * warp_speed_per_warp_level * getSystemEffectiveness(SYS_Warp)));

    if (combat_maneuver_boost_active > combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active -= delta;
        if (combat_maneuver_boost_active < combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_boost_active < combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active += delta;
        if (combat_maneuver_boost_active > combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active -= delta;
        if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }
    if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active += delta;
        if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }

    // If the ship is making a combat maneuver ...
    if (combat_maneuver_boost_active != 0.0f || combat_maneuver_strafe_active != 0.0f)
    {
        // ... consume its combat maneuver boost.
        combat_maneuver_charge -= fabs(combat_maneuver_boost_active) * delta / combat_maneuver_boost_max_time;
        combat_maneuver_charge -= fabs(combat_maneuver_strafe_active) * delta / combat_maneuver_strafe_max_time;

        // Use boost only if we have boost available.
        if (combat_maneuver_charge <= 0.0f)
        {
            combat_maneuver_charge = 0.0f;
            combat_maneuver_boost_request = 0.0f;
            combat_maneuver_strafe_request = 0.0f;
        }else
        {
            setVelocity(getVelocity() + forward * combat_maneuver_boost_speed * combat_maneuver_boost_active);
            setVelocity(getVelocity() + vec2FromAngle(getRotation() + 90) * combat_maneuver_strafe_speed * combat_maneuver_strafe_active);
        }
    // If the ship isn't making a combat maneuver, recharge its boost.
    }else if (combat_maneuver_charge < 1.0f)
    {
        combat_maneuver_charge += (delta / combat_maneuver_charge_time) * (getSystemEffectiveness(SYS_Maneuver) + getSystemEffectiveness(SYS_Impulse)) / 2.0f;
        if (combat_maneuver_charge > 1.0f)
            combat_maneuver_charge = 1.0f;
    }

    // Add heat to systems consuming combat maneuver boost.
    addHeat(SYS_Impulse, fabs(combat_maneuver_boost_active) * delta * heat_per_combat_maneuver_boost);
    addHeat(SYS_Maneuver, fabs(combat_maneuver_strafe_active) * delta * heat_per_combat_maneuver_strafe);

    for(int n = 0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].update(delta);
    }

    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].update(delta);
    }

    for(int n=0; n<SYS_COUNT; n++)
    {
        systems[n].hacked_level = std::max(0.0f, systems[n].hacked_level - delta / unhack_time);
        systems[n].health = std::min(systems[n].health,systems[n].health_max);
    }

    model_info.engine_scale = std::min(1.0f, (float) std::max(fabs(getAngularVelocity() / turn_speed), fabs(current_impulse)));
    if (has_jump_drive && jump_delay > 0.0f)
        model_info.warp_scale = (10.0f - jump_delay) / 10.0f;
    else
        model_info.warp_scale = 0.f;
}

float SpaceShip::getShieldRechargeRate(int shield_index)
{
    float rate = 0.3f;
    rate *= getSystemEffectiveness(getShieldSystemForShieldIndex(shield_index));
    if (docking_state == DS_Docked)
    {
        P<SpaceShip> docked_with_ship = docking_target;
        if (!docked_with_ship)
            rate *= 4.0f;
    }
    return rate;
}

P<SpaceObject> SpaceShip::getTarget()
{
    if (game_server)
        return game_server->getObjectById(target_id);
    return game_client->getObjectById(target_id);
}

void SpaceShip::executeJump(float distance)
{
    float f = systems[SYS_JumpDrive].health;
    if (f <= 0.0f)
        return;

    distance = (distance * f) + (distance * (1.0f - f) * random(0.5, 1.5));
    auto target_position = getPosition() + vec2FromAngle(getRotation()) * distance;
    target_position = WarpJammer::getFirstNoneJammedPosition(getPosition(), target_position);
    setPosition(target_position);
    addHeat(SYS_JumpDrive, jump_drive_heat_per_jump);
}

DockStyle SpaceShip::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj) || !ship_template)
        return DockStyle::None;
    P<SpaceShip> ship = obj;
    if (!ship || !ship->ship_template)
        return DockStyle::None;
    if (ship_template->external_dock_classes.count(ship->ship_template->getClass()) > 0)
        return DockStyle::External;
    if (ship_template->external_dock_classes.count(ship->ship_template->getSubClass()) > 0)
        return DockStyle::External;
    if (ship_template->internal_dock_classes.count(ship->ship_template->getClass()) > 0)
        return DockStyle::Internal;
    if (ship_template->internal_dock_classes.count(ship->ship_template->getSubClass()) > 0)
        return DockStyle::Internal;
    return DockStyle::None;
}

void SpaceShip::collide(Collisionable* other, float force)
{
    if (docking_state == DS_Docking && fabs(angleDifference(target_rotation, getRotation())) < 10.0f)
    {
        P<SpaceObject> dock_object = P<Collisionable>(other);
        if (dock_object == docking_target)
        {
            docking_state = DS_Docked;
            docked_style = docking_target->canBeDockedBy(this);
            docking_offset = rotateVec2(getPosition() - other->getPosition(), -other->getRotation());
            float length = glm::length(docking_offset);
            docking_offset = docking_offset / length * (length + 2.0f);
        }
    }
}

void SpaceShip::initializeJump(float distance)
{
    if (docking_state != DS_NotDocking)
        return;
    if (jump_drive_charge < jump_drive_max_distance) // You can only jump when the drive is fully charged
        return;
    if (jump_delay <= 0.0f)
    {
        jump_distance = distance;
        jump_delay = 10.f;
        jump_drive_charge -= distance;
    }
}

void SpaceShip::requestDock(P<SpaceObject> target)
{
    if (!target || docking_state != DS_NotDocking || target->canBeDockedBy(this) == DockStyle::None)
        return;
    if (glm::length(getPosition() - target->getPosition()) > 1000 + target->getRadius())
        return;
    if (!canStartDocking())
        return;

    docking_state = DS_Docking;
    docking_target = target;
    warp_request = 0;
}

void SpaceShip::requestUndock()
{
    if (docking_state == DS_Docked && getSystemEffectiveness(SYS_Impulse) > 0.1f)
    {
        docked_style = DockStyle::None;
        docking_state = DS_NotDocking;
        impulse_request = 0.5;
    }
}

void SpaceShip::abortDock()
{
    if (docking_state == DS_Docking)
    {
        docking_state = DS_NotDocking;
        impulse_request = 0.f;
        warp_request = 0;
        target_rotation = getRotation();
    }
}

int SpaceShip::scanningComplexity(P<SpaceObject> other)
{
    if (scanning_complexity_value > -1)
        return scanning_complexity_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 2;
        return 1;
    case SC_Advanced:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 3;
        return 2;
    }
    return 0;
}

int SpaceShip::scanningChannelDepth(P<SpaceObject> other)
{
    if (scanning_depth_value > -1)
        return scanning_depth_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        return 2;
    case SC_Advanced:
        return 2;
    }
    return 0;
}

void SpaceShip::scannedBy(P<SpaceObject> other)
{
    switch(getScannedStateFor(other))
    {
    case SS_NotScanned:
    case SS_FriendOrFoeIdentified:
        setScannedStateFor(other, SS_SimpleScan);
        break;
    case SS_SimpleScan:
        setScannedStateFor(other, SS_FullScan);
        break;
    case SS_FullScan:
        break;
    }
}

void SpaceShip::setScanState(EScannedState state)
{
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        setScannedStateForFaction(faction_id, state);
    }
}

void SpaceShip::setScanStateByFaction(string faction_name, EScannedState state)
{
    setScannedStateForFaction(FactionInfo::findFactionId(faction_name), state);
}

bool SpaceShip::isFriendOrFoeIdentified()
{
    LOG(WARNING) << "Deprecated \"isFriendOrFoeIdentified\" function called, use isFriendOrFoeIdentifiedBy or isFriendOrFoeIdentifiedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) > SS_NotScanned)
            return true;
    }
    return false;
}

bool SpaceShip::isFullyScanned()
{
    LOG(WARNING) << "Deprecated \"isFullyScanned\" function called, use isFullyScannedBy or isFullyScannedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) >= SS_FullScan)
            return true;
    }
    return false;
}

bool SpaceShip::isFriendOrFoeIdentifiedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FullScan;
}

bool SpaceShip::isFriendOrFoeIdentifiedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FullScan;
}

bool SpaceShip::canBeHackedBy(P<SpaceObject> other)
{
    return (!(this->isFriendly(other)) && this->isFriendOrFoeIdentifiedBy(other)) ;
}

std::vector<std::pair<ESystem, float>> SpaceShip::getHackingTargets()
{
    std::vector<std::pair<ESystem, float>> results;
    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        if (n != SYS_Reactor && hasSystem(ESystem(n)))
        {
            results.emplace_back(ESystem(n), systems[n].hacked_level);
        }
    }
    return results;
}

void SpaceShip::hackFinished(P<SpaceObject> source, string target)
{
    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        if (hasSystem(ESystem(n)))
        {
            if (target == getSystemName(ESystem(n)))
            {
                systems[n].hacked_level = std::min(1.0f, systems[n].hacked_level + 0.5f);
                return;
            }
        }
    }
    LOG(WARNING) << "Unknown hacked target: " << target;
}

float SpaceShip::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    float frequency_damage_factor = 1.f;
    if (info.type == DT_Energy && gameGlobalInfo->use_beam_shield_frequencies)
    {
        frequency_damage_factor = frequencyVsFrequencyDamageFactor(info.frequency, shield_frequency);
    }
    ESystem system = getShieldSystemForShieldIndex(shield_index);

    //Shield damage reduction curve. Damage reduction gets slightly exponetial effective with power.
    // This also greatly reduces the ineffectiveness at low power situations.
    float shield_damage_exponent = 1.6f;
    float shield_damage_divider = 7.0f;
    float shield_damage_factor = 1.0f + powf(1.0f, shield_damage_exponent) / shield_damage_divider-powf(getSystemEffectiveness(system), shield_damage_exponent) / shield_damage_divider;

    return shield_damage_factor * frequency_damage_factor;
}

void SpaceShip::didAnOffensiveAction()
{
    //We did an offensive action towards our target.
    // Check for each faction. If this faction knows if the target is an enemy or a friendly, it now knows if this object is an enemy or a friendly.
    for(unsigned int faction_id=0; faction_id<factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) == SS_NotScanned)
        {
            if (getTarget() && getTarget()->getScannedStateForFaction(faction_id) != SS_NotScanned)
                setScannedStateForFaction(faction_id, SS_FriendOrFoeIdentified);
        }
    }
}

void SpaceShip::takeHullDamage(float damage_amount, DamageInfo& info)
{
    if (gameGlobalInfo->use_system_damage)
    {
        if (info.system_target != SYS_None)
        {
            //Target specific system
            float system_damage = (damage_amount / hull_max) * 2.0f;
            if (info.type == DT_Energy)
                system_damage *= 3.0f;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[info.system_target].health -= system_damage;
            if (systems[info.system_target].health < -1.0f)
                systems[info.system_target].health = -1.0f;

            for(int n=0; n<2; n++)
            {
                ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (damage_amount / hull_max) * 1.0f;
                systems[random_system].health -= system_damage;
                if (systems[random_system].health < -1.0f)
                    systems[random_system].health = -1.0f;
            }

            if (info.type == DT_Energy)
                damage_amount *= 0.02f;
            else
                damage_amount *= 0.5f;
        }else{
            ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
            //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
            float system_damage = (damage_amount / hull_max) * 3.0f;
            if (info.type == DT_Energy)
                system_damage *= 2.5f;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[random_system].health -= system_damage;
            if (systems[random_system].health < -1.0f)
                systems[random_system].health = -1.0f;
        }
    }

    ShipTemplateBasedObject::takeHullDamage(damage_amount, info);
}

void SpaceShip::destroyedByDamage(DamageInfo& info)
{
    ExplosionEffect* e = new ExplosionEffect();
    e->setSize(getRadius() * 1.5f);
    e->setPosition(getPosition());
    e->setRadarSignatureInfo(0.f, 0.2f, 0.2f);

    if (info.instigator)
    {
        float points = hull_max * 0.1f;
        for(int n=0; n<shield_count; n++)
            points += shield_max[n] * 0.1f;
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

bool SpaceShip::hasSystem(ESystem system)
{
    switch(system)
    {
    case SYS_None:
    case SYS_COUNT:
        return false;
    case SYS_Warp:
        return has_warp_drive;
    case SYS_JumpDrive:
        return has_jump_drive;
    case SYS_MissileSystem:
        return weapon_tube_count > 0;
    case SYS_FrontShield:
        return shield_count > 0;
    case SYS_RearShield:
        return shield_count > 1;
    case SYS_Reactor:
        return true;
    case SYS_BeamWeapons:
        return true;
    case SYS_Maneuver:
        return turn_speed > 0.0f;
    case SYS_Impulse:
        return impulse_max_speed > 0.0f;
    }
    return true;
}

float SpaceShip::getSystemEffectiveness(ESystem system)
{
    float power = systems[system].power_level;

    // Substract the hacking from the power, making double hacked systems run at 25% efficiency.
    power = std::max(0.0f, power - systems[system].hacked_level * 0.75f);

    // Degrade all systems except the reactor once energy level drops below 10.
    if (system != SYS_Reactor)
    {
        if (energy_level < 10.0f && energy_level > 0.0f && power > 0.0f)
            power = std::min(power * energy_level / 10.0f, power);
        else if (energy_level <= 0.0f || power <= 0.0f)
            power = 0.0f;
    }

    // Degrade damaged systems.
    if (gameGlobalInfo && gameGlobalInfo->use_system_damage)
        return std::max(0.0f, power * systems[system].health);

    // If a system cannot be damaged, excessive heat degrades it.
    return std::max(0.0f, power * (1.0f - systems[system].heat_level));
}

void SpaceShip::setWeaponTubeCount(int amount)
{
    weapon_tube_count = std::max(0, std::min(amount, max_weapon_tubes));
    for(int n=weapon_tube_count; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].forceUnload();
    }
}

int SpaceShip::getWeaponTubeCount()
{
    return weapon_tube_count;
}

EMissileWeapons SpaceShip::getWeaponTubeLoadType(int index)
{
    if (index < 0 || index >= weapon_tube_count)
        return MW_None;
    if (!weapon_tube[index].isLoaded())
        return MW_None;
    return weapon_tube[index].getLoadType();
}

void SpaceShip::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].disallowLoadOf(type);
}

void SpaceShip::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    for(int n=0; n<MW_Count; n++)
        weapon_tube[index].disallowLoadOf(EMissileWeapons(n));
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::setWeaponTubeDirection(int index, float direction)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].setDirection(direction);
}

void SpaceShip::setTubeSize(int index, EMissileSizes size)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].setSize(size);
}

EMissileSizes SpaceShip::getTubeSize(int index)
{
    if (index < 0 || index >= weapon_tube_count)
        return MS_Medium;
    return weapon_tube[index].getSize();
}

float SpaceShip::getTubeLoadTime(int index)
{
    if (index < 0 || index >= weapon_tube_count) {
        return 0;
    }
    return weapon_tube[index].getLoadTimeConfig();
}

void SpaceShip::setTubeLoadTime(int index, float time)
{
    if (index < 0 || index >= weapon_tube_count) {
        return;
    }
    weapon_tube[index].setLoadTimeConfig(time);
}

void SpaceShip::addBroadcast(int threshold, string message)
{
    if ((threshold < 0) || (threshold > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(ERROR) << "Invalid threshold: " << threshold;
        threshold = 0;
    }

    message = this->getCallSign() + " : " + message; //append the callsign at the start of broadcast

    glm::u8vec4 color = glm::u8vec4(255, 204, 51, 255); //default : yellow, should never be seen

    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        bool addtolog = 0;
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (this->isFriendly(ship))
            {
                color = glm::u8vec4(154, 255, 154, 255); //ally = light green
                addtolog = 1;
            }
            else if ((FactionInfo::getState(this->getFactionId(), ship->getFactionId()) == FVF_Neutral) && ((threshold >= FVF_Neutral)))
            {
                color = glm::u8vec4(128,128,128, 255); //neutral = grey
                addtolog = 1;
            }
            else if ((this->isEnemy(ship)) && (threshold == FVF_Enemy))
            {
                color = glm::u8vec4(255,102,102, 255); //enemy = light red
                addtolog = 1;
            }

            if (addtolog)
            {
                ship->addToShipLog(message, color);
            }
        }
    }
}

std::unordered_map<string, string> SpaceShip::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret = ShipTemplateBasedObject::getGMInfo();
    return ret;
}

string SpaceShip::getScriptExportModificationsOnTemplate()
{
    // Exports attributes common to ships as Lua script function calls.
    // Initialize the exported string.
    string ret = "";

    // If traits don't differ from the ship template, don't bother exporting
    // them.
    if (getTypeName() != ship_template->getName())
        ret += ":setTypeName(\"" + getTypeName() + "\")";
    if (hull_max != ship_template->hull)
        ret += ":setHullMax(" + string(hull_max, 0) + ")";
    if (hull_strength != ship_template->hull)
        ret += ":setHull(" + string(hull_strength, 0) + ")";
    if (impulse_max_speed != ship_template->impulse_speed)
        ret += ":setImpulseMaxSpeed(" + string(impulse_max_speed, 1) + ")";
    if (impulse_max_reverse_speed != ship_template->impulse_reverse_speed)
        ret += ":setImpulseMaxReverseSpeed(" + string(impulse_max_reverse_speed, 1) + ")";
    if (turn_speed != ship_template->turn_speed)
        ret += ":setRotationMaxSpeed(" + string(turn_speed, 1) + ")";
    if (has_jump_drive != ship_template->has_jump_drive)
        ret += ":setJumpDrive(" + string(has_jump_drive ? "true" : "false") + ")";
    if (jump_drive_min_distance != ship_template->jump_drive_min_distance
        || jump_drive_max_distance != ship_template->jump_drive_max_distance)
        ret += ":setJumpDriveRange(" + string(jump_drive_min_distance) + ", " + string(jump_drive_max_distance) + ")";
    if (has_warp_drive != (ship_template->warp_speed > 0))
        ret += ":setWarpDrive(" + string(has_warp_drive ? "true" : "false") + ")";
    if (warp_speed_per_warp_level != ship_template->warp_speed)
        ret += ":setWarpSpeed(" + string(warp_speed_per_warp_level) + ")";

    // Shield data
    // Determine whether to export shield data.
    bool add_shields_max_line = getShieldCount() != ship_template->shield_count;
    bool add_shields_line = getShieldCount() != ship_template->shield_count;

    // If shield max and level don't differ from the template, don't bother
    // exporting them.
    for(int n = 0; n < getShieldCount(); n++)
    {
        if (getShieldMax(n) != ship_template->shield_level[n])
            add_shields_max_line = true;
        if (getShieldLevel(n) != ship_template->shield_level[n])
            add_shields_line = true;
    }

    // If we're exporting shield max ...
    if (add_shields_max_line)
    {
        ret += ":setShieldsMax(";

        // ... for each shield, export the shield max.
        for(int n = 0; n < getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";

            ret += string(getShieldMax(n));
        }

        ret += ")";
    }

    // If we're exporting shield level ...
    if (add_shields_line)
    {
        ret += ":setShields(";

        // ... for each shield, export the shield level.
        for(int n = 0; n < getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";

            ret += string(getShieldLevel(n));
        }

        ret += ")";
    }

    // Missile weapon data
    if (weapon_tube_count != ship_template->weapon_tube_count)
        ret += ":setWeaponTubeCount(" + string(weapon_tube_count) + ")";

    for(int n=0; n<weapon_tube_count; n++)
    {
        WeaponTube& tube = weapon_tube[n];
        auto& template_tube = ship_template->weapon_tube[n];
        if (tube.getDirection() != template_tube.direction)
        {
            ret += ":setWeaponTubeDirection(" + string(n) + ", " + string(tube.getDirection(), 0) + ")";
        }
        //TODO: Weapon tube "type_allowed_mask"
        //TODO: Weapon tube "load_time"
        if (tube.getSize() != template_tube.size)
        {
            ret += ":setTubeSize(" + string(n) + ",\"" + getMissileSizeString(tube.getSize()) + "\")";
        }
    }
    for(int n=0; n<MW_Count; n++)
    {
        if (weapon_storage_max[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorageMax(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage_max[n]) + ")";
        if (weapon_storage[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorage(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage[n]) + ")";
    }

    // Beam weapon data
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (beam_weapons[n].getArc() != ship_template->beams[n].getArc()
         || beam_weapons[n].getDirection() != ship_template->beams[n].getDirection()
         || beam_weapons[n].getRange() != ship_template->beams[n].getRange()
         || beam_weapons[n].getTurretArc() != ship_template->beams[n].getTurretArc()
         || beam_weapons[n].getTurretDirection() != ship_template->beams[n].getTurretDirection()
         || beam_weapons[n].getTurretRotationRate() != ship_template->beams[n].getTurretRotationRate()
         || beam_weapons[n].getCycleTime() != ship_template->beams[n].getCycleTime()
         || beam_weapons[n].getDamage() != ship_template->beams[n].getDamage())
        {
            ret += ":setBeamWeapon(" + string(n) + ", " + string(beam_weapons[n].getArc(), 0) + ", " + string(beam_weapons[n].getDirection(), 0) + ", " + string(beam_weapons[n].getRange(), 0) + ", " + string(beam_weapons[n].getCycleTime(), 1) + ", " + string(beam_weapons[n].getDamage(), 1) + ")";
            ret += ":setBeamWeaponTurret(" + string(n) + ", " + string(beam_weapons[n].getTurretArc(), 0) + ", " + string(beam_weapons[n].getTurretDirection(), 0) + ", " + string(beam_weapons[n].getTurretRotationRate(), 0) + ")";
        }
    }

    return ret;
}

string getMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return "Homing";
    case MW_Nuke:
        return "Nuke";
    case MW_Mine:
        return "Mine";
    case MW_EMP:
        return "EMP";
    case MW_HVLI:
        return "HVLI";
    default:
        return "UNK: " + string(int(missile));
    }
}

string getLocaleMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return tr("missile","Homing");
    case MW_Nuke:
        return tr("missile","Nuke");
    case MW_Mine:
        return tr("missile","Mine");
    case MW_EMP:
        return tr("missile","EMP");
    case MW_HVLI:
        return tr("missile","HVLI");
    default:
        return "UNK: " + string(int(missile));
    }
}


float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency)
{
    if (beam_frequency < 0 || shield_frequency < 0)
        return 1.f;

    float diff = static_cast<float>(abs(beam_frequency - shield_frequency));
    float f1 = sinf(Tween<float>::linear(diff, 0, SpaceShip::max_frequency, 0, float(M_PI) * (1.2f + shield_frequency * 0.05f)) + float(M_PI) / 2.0f);
    f1 = f1 * Tween<float>::easeInCubic(diff, 0, SpaceShip::max_frequency, 1.f, 0.1f);
    f1 = Tween<float>::linear(f1, 1.f, -1.f, 0.5f, 1.5f);
    return f1;
}

string frequencyToString(int frequency)
{
    return string(400 + (frequency * 20)) + "THz";
}

#include "spaceship.hpp"

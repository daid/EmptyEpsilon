#include "spaceship.h"

#include <array>

#include <i18n.h>

#include "mesh.h"
#include "random.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "textureManager.h"
#include "multiplayer_client.h"
#include "gameGlobalInfo.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/shields.h"
#include "components/hull.h"
#include "components/missiletubes.h"
#include "components/target.h"
#include "components/shiplog.h"
#include "ecs/query.h"

#include "scriptInterface.h"

#include <SDL_assert.h>

/// A SpaceShip is a ShipTemplateBasedObject controlled by either the AI (CpuShip) or players (PlayerSpaceship).
/// It can carry and deploy weapons, dock with or carry docked ships, and move using impulse, jump, or warp drives.
/// It's also subject to being moved by collision physics, unlike SpaceStations, which remain stationary.
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
    //TODO?: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    /// Returns whether this SpaceShip has been fully scanned by the given faction.
    //TODO?: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
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
    //TODO?: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    /// Returns whether this SpaceShip has been fully scanned by the given faction.
    /// See also SpaceObject:isScannedByFaction().
    /// Example: ship:isFullyScannedByFaction("Kraylor")
    //TODO?: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
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
    //TODO?: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDockingState);
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
    /// CpuShips don't consume energy. Setting this value has no effect on their behavior or functionality.
    /// For PlayerSpaceships, see PlayerSpaceship:setEnergyLevelMax().
    /// Example: ship:setMaxEnergy(800)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setMaxEnergy);
    /// Returns this SpaceShip's energy level.
    /// Example: ship:getEnergy()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getEnergy);
    /// Sets this SpaceShip's energy level.
    /// Valid values are any greater than 0 and less than the energy capacity (getMaxEnergy()).
    /// Invalid values are ignored.
    /// CpuShips don't consume energy. Setting this value has no effect on their behavior or functionality.
    /// For PlayerSpaceships, see PlayerSpaceship:setEnergyLevel().
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
    /// CpuShips don't generate or manage heat. Setting this has no effect on them.
    /// Valid range is 0.0 (fully disabled) to 1.0 (undamaged).
    /// Example: ship:setSystemHeat("impulse", 0.5) -- sets the ship's impulse drive heat to half of capacity
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeat);
    /// Returns the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
    /// Example: ship:getSystemHeatRate("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeatRate);
    /// Sets the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
    /// CpuShips don't generate or manage heat. Setting this has no effect on them.
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
    /// CpuShips don't consume energy. Setting this has no effect.
    /// Example: ship:setSystemPowerRate("impulse", 0.4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPowerRate);
    /// Returns the relative power drain factor for the given system.
    /// Example: ship:getSystemPowerFactor("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPowerFactor);
    /// Sets the relative power drain factor? for the given system in this SpaceShip.
    /// "reactor" has a negative value because it generates power rather than draining it.
    /// CpuShips don't consume energy. Setting this has no effect.
    /// Example: ship:setSystemPowerFactor("impulse", 4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPowerFactor);
    /// Returns the coolant distribution for the given system in this SpaceShip.
    /// Returns a value between 0.0 (none) and 1.0 (capacity).
    /// Example: ship:getSystemCoolant("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolant);
    /// Sets the coolant quantity for the given system in this SpaceShip.
    /// CpuShips don't generate or manage heat. Setting this has no effect on them.
    /// Valid range is 0.0 (none) to 1.0 (capacity).
    /// Example: ship:setSystemPowerFactor("impulse", 4)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemCoolant);
    /// Returns the rate at which the given system in this SpaceShip takes coolant, in points per second?
    /// Example: ship:getSystemCoolantRate("impulse")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolantRate);
    /// Sets the rate at which the given system in this SpaceShip takes coolant, in points per second?
    /// CpuShips don't generate or manage heat. Setting this has no effect on them.
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
    //TODO?: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRadarTrace);
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

SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
    // Ships can have dynamic signatures. Initialize a default baseline value
    // from which clients derive the dynamic signature on update.
    setRadarSignatureInfo(0.05f, 0.2f, 0.2f);

    if (game_server)
        setCallSign(gameGlobalInfo->getNextShipCallsign());

    if (entity) {
        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.flags |= RadarTrace::ArrowIfNotScanned;

        auto shields = entity.getComponent<Shields>();
        if (shields)
            shields->frequency = irandom(0, BeamWeaponSys::max_frequency);
    }
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
SpaceShip::~SpaceShip()
{
}

void SpaceShip::applyTemplateValues()
{
    /*
    for(int n=0; n<16; n++)
    {
        if (ship_template->beams[n].getRange() > 0.0f) {
            auto& beamweaponsystem = entity.getOrAddComponent<BeamWeaponSys>();
            beamweaponsystem.mounts.resize(n);
            auto& mount = beamweaponsystem.mounts[n];
            mount.position = ship_template->model_data->getBeamPosition(n);
            mount.arc = ship_template->beams[n].getArc();
            mount.direction = ship_template->beams[n].getDirection();
            mount.range = ship_template->beams[n].getRange();
            mount.turret_arc = ship_template->beams[n].getTurretArc();
            mount.turret_direction = ship_template->beams[n].getTurretDirection();
            mount.turret_rotation_rate = ship_template->beams[n].getTurretRotationRate();
            mount.cycle_time = ship_template->beams[n].getCycleTime();
            mount.damage = ship_template->beams[n].getDamage();
            mount.texture = ship_template->beams[n].getBeamTexture();
            mount.energy_per_beam_fire = ship_template->beams[n].getEnergyPerFire();
            mount.heat_per_beam_fire = ship_template->beams[n].getHeatPerFire();
        }
    }

    if (ship_template->energy_storage_amount) {
        auto& reactor = entity.getOrAddComponent<Reactor>();
        reactor.energy = reactor.max_energy = ship_template->energy_storage_amount;
    }
    

    if (ship_template->impulse_speed) {
        auto& engine = entity.getOrAddComponent<ImpulseEngine>();
        engine.max_speed_forward = ship_template->impulse_speed;
        engine.max_speed_reverse = ship_template->impulse_reverse_speed;
        engine.acceleration_forward = ship_template->impulse_acceleration;
        engine.acceleration_reverse = ship_template->impulse_reverse_acceleration;
        engine.sound = ship_template->impulse_sound_file;
    }
    
    if (ship_template->turn_speed) {
        auto& thrusters = entity.getOrAddComponent<ManeuveringThrusters>();
        thrusters.speed = ship_template->turn_speed;
    }
    if (ship_template->combat_maneuver_boost_speed || ship_template->combat_maneuver_strafe_speed) {
        auto& thrusters = entity.getOrAddComponent<CombatManeuveringThrusters>();
        thrusters.boost.speed = ship_template->combat_maneuver_boost_speed;
        thrusters.strafe.speed = ship_template->combat_maneuver_strafe_speed;
    }

    if (ship_template->warp_speed > 0.0f) {
        auto& warp = entity.getOrAddComponent<WarpDrive>();
        warp.speed_per_level = ship_template->warp_speed;
    }
    if (ship_template->has_jump_drive) {
        auto& jump = entity.getOrAddComponent<JumpDrive>();
        jump.min_distance = ship_template->jump_drive_min_distance;
        jump.max_distance = ship_template->jump_drive_max_distance;
    }
    if (ship_template->weapon_tube_count) {
        auto& tubes = entity.getOrAddComponent<MissileTubes>();
        tubes.mounts.resize(ship_template->weapon_tube_count);
        for(int n=0; n<ship_template->weapon_tube_count; n++)
        {
            auto& tube = tubes.mounts[n];
            tube.load_time = ship_template->weapon_tube[n].load_time;
            tube.direction = ship_template->weapon_tube[n].direction;
            tube.size = ship_template->weapon_tube[n].size;
            tube.type_allowed_mask = ship_template->weapon_tube[n].type_allowed_mask;
        }
        for(int n=0; n<MW_Count; n++)
            tubes.storage[n] = tubes.storage_max[n] = ship_template->weapon_storage[n];
    }

    ship_template->setCollisionData(this);
    //model_info.setData(ship_template->model_data);
    */
}

void SpaceShip::draw3DTransparent()
{
    //if (!ship_template) return;
    ShipTemplateBasedObject::draw3DTransparent();
/*  TODO
    auto jump = entity.getComponent<JumpDrive>();
    if ((jump && jump->delay > 0.0f) ||
        (wormhole_alpha > 0.0f))
    {
        float delay = jump ? jump->delay : 0.0f;
        if (wormhole_alpha > 0.0f)
            delay = wormhole_alpha;
        float alpha = 1.0f - (delay / 10.0f);
        model_info.renderOverlay(getModelMatrix(), textureManager.getTexture("texture/electric_sphere_texture.png"), alpha);
    }
    */
}

void SpaceShip::updateDynamicRadarSignature()
{
    // Adjust radar_signature dynamically based on current state and activity.
    // radar_signature becomes the ship's baseline radar signature.
    DynamicRadarSignatureInfo signature_delta;

    // For each ship system ...
    for(int n = 0; n < ShipSystem::COUNT; n++)
    {
        auto ship_system = static_cast<ShipSystem::Type>(n);

        // ... increase the biological band based on system heat, offset by
        // coolant.
        signature_delta.biological += std::max(
            0.0f,
            std::min(
                1.0f,
                getSystemHeat(ship_system) - (getSystemCoolant(ship_system) / 10.0f)
            )
        );

        // ... adjust the electrical band if system power allocation is not 100%.
        if (ship_system == ShipSystem::Type::JumpDrive)
        {
            auto jump = entity.getComponent<JumpDrive>();
            if (jump && jump->charge < jump->max_distance) {
                // ... elevate electrical after a jump, since recharging jump consumes energy.
                signature_delta.electrical += std::clamp(getSystemPower(ship_system) * (jump->charge + 0.01f / jump->max_distance), 0.0f, 1.0f);
            }
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
    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
    {
        signature_delta.gravity += std::clamp((1.0f / jump->delay + 0.01f) + 0.25f, 0.0f, 1.0f);
    }
    auto warp = entity.getComponent<WarpDrive>();
    if (warp && warp->current > 0.0f)
    {
        signature_delta.gravity += warp->current;
    }

    // Update the signature by adding the delta to its baseline.
    if (entity)
        entity.addComponent<DynamicRadarSignatureInfo>(signature_delta);
}

void SpaceShip::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    /*TODO
    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
        model_info.warp_scale = (10.0f - jump->delay) / 10.0f;
    else
        model_info.warp_scale = 0.f;
    */
    
    updateDynamicRadarSignature();
}

P<SpaceObject> SpaceShip::getTarget()
{
    auto target = entity.getComponent<Target>();
    if (!target)
        return nullptr;
    auto obj = target->entity.getComponent<SpaceObject*>();
    if (!obj)
        return nullptr;
    return *obj;
}

void SpaceShip::collide(SpaceObject* other, float force)
{
}

bool SpaceShip::useEnergy(float amount)
{
    // Try to consume an amount of energy. If it works, return true.
    // If it doesn't, return false.
    auto reactor = entity.getComponent<Reactor>();
    if (reactor)
        return reactor->useEnergy(amount);
    return true;
}

void SpaceShip::setScanState(ScanState::State state)
{
    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        setScannedStateForFaction(faction_entity, state);
    }
}

void SpaceShip::setScanStateByFaction(string faction_name, ScanState::State state)
{
    setScannedStateForFaction(Faction::find(faction_name), state);
}

bool SpaceShip::isFriendOrFoeIdentified()
{
    LOG(WARNING) << "Deprecated \"isFriendOrFoeIdentified\" function called, use isFriendOrFoeIdentifiedBy or isFriendOrFoeIdentifiedByFaction.";
    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if (getScannedStateForFaction(faction_entity) > ScanState::State::NotScanned)
            return true;
    }
    return false;
}

bool SpaceShip::isFullyScanned()
{
    LOG(WARNING) << "Deprecated \"isFullyScanned\" function called, use isFullyScannedBy or isFullyScannedByFaction.";
    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if (getScannedStateForFaction(faction_entity) >= ScanState::State::FullScan)
            return true;
    }
    return false;
}

bool SpaceShip::isFriendOrFoeIdentifiedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other->entity) >= ScanState::State::FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other->entity) >= ScanState::State::FullScan;
}

bool SpaceShip::isFriendOrFoeIdentifiedByFaction(sp::ecs::Entity faction_entity)
{
    return getScannedStateForFaction(faction_entity) >= ScanState::State::FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedByFaction(sp::ecs::Entity faction_entity)
{
    return getScannedStateForFaction(faction_entity) >= ScanState::State::FullScan;
}

void SpaceShip::hackFinished(sp::ecs::Entity source, ShipSystem::Type target)
{
    auto sys = ShipSystem::get(entity, target);
    if (sys)
        sys->hacked_level = std::min(1.0f, sys->hacked_level + 0.5f);
}

bool SpaceShip::hasSystem(ShipSystem::Type system)
{
    return ShipSystem::get(entity, system) != nullptr;
}

float SpaceShip::getBeamWeaponArc(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponDirection(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponRange(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponTurretArc(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponTurretDirection(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponTurretRotationRate(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponCycleTime(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponDamage(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponEnergyPerFire(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponHeatPerFire(int index) { return 0.0f; /* TODO */ }

int SpaceShip::getBeamFrequency() { return 0; /* TODO */ }

void SpaceShip::setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage) { /* TODO */ }

void SpaceShip::setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate) { /* TODO */ }

void SpaceShip::setBeamWeaponTexture(int index, string texture) { /* TODO */ }

void SpaceShip::setBeamWeaponEnergyPerFire(int index, float energy) { /* TODO */ }
void SpaceShip::setBeamWeaponHeatPerFire(int index, float heat) { /* TODO */ }
void SpaceShip::setBeamWeaponArcColor(int index, float r, float g, float b, float fire_r, float fire_g, float fire_b) { /* TODO */ }
void SpaceShip::setBeamWeaponDamageType(int index, DamageType type) { /* TODO */ }


void SpaceShip::setWeaponTubeCount(int amount)
{
    //TODO
}

int SpaceShip::getWeaponTubeCount()
{
    //TODO
    return 0;
}

EMissileWeapons SpaceShip::getWeaponTubeLoadType(int index)
{
    //TODO
    return MW_None;
}

void SpaceShip::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    //TODO
    return;
}

void SpaceShip::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    //TODO
    return;
}

void SpaceShip::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    //TODO
    return;
}

void SpaceShip::setWeaponTubeDirection(int index, float direction)
{
    //TODO
    return;
}

void SpaceShip::setTubeSize(int index, EMissileSizes size)
{
    //TODO
    return;
}

EMissileSizes SpaceShip::getTubeSize(int index)
{
    //TODO
    return MS_Medium;
}

float SpaceShip::getTubeLoadTime(int index)
{
    //TODO
    return 0;
}

void SpaceShip::setTubeLoadTime(int index, float time)
{
    return;
}

void SpaceShip::addBroadcast(FactionRelation threshold, string message)
{
    if ((int(threshold) < 0) || (int(threshold) > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(Error, "Invalid threshold: ", int(threshold));
        threshold = FactionRelation::Enemy;
    }

    message = this->getCallSign() + " : " + message; //append the callsign at the start of broadcast

    glm::u8vec4 color = glm::u8vec4(255, 204, 51, 255); //default : yellow, should never be seen

    for(auto [ship, logs] : sp::ecs::Query<ShipLog>())
    {
        bool addtolog = false;
        if (Faction::getRelation(entity, ship) == FactionRelation::Friendly)
        {
            color = glm::u8vec4(154, 255, 154, 255); //ally = light green
            addtolog = true;
        }
        else if (Faction::getRelation(entity, ship) == FactionRelation::Neutral && int(threshold) >= int(FactionRelation::Neutral))
        {
            color = glm::u8vec4(128,128,128, 255); //neutral = grey
            addtolog = true;
        }
        else if (Faction::getRelation(entity, ship) == FactionRelation::Enemy && threshold == FactionRelation::Enemy)
        {
            color = glm::u8vec4(255,102,102, 255); //enemy = light red
            addtolog = true;
        }

        if (addtolog)
        {
            logs.entries.push_back({gameGlobalInfo->getMissionTime() + string(": "), message, color});
        }
    }
}

bool SpaceShip::isDocked(P<SpaceObject> target)
{
    if (!entity) return false; 
    auto port = entity.getComponent<DockingPort>();
    if (!port) return false;
    return port->state == DockingPort::State::Docked && *port->target.getComponent<SpaceObject*>() == *target;
}

P<SpaceObject> SpaceShip::getDockedWith()
{
    if (!entity) return nullptr; 
    auto port = entity.getComponent<DockingPort>();
    if (!port) return nullptr;
    if (port->state != DockingPort::State::Docked) return nullptr;
    return *port->target.getComponent<SpaceObject*>();
}

DockingPort::State SpaceShip::getDockingState()
{
    if (!entity) return DockingPort::State::NotDocking; 
    auto port = entity.getComponent<DockingPort>();
    if (!port) return DockingPort::State::NotDocking;
    return port->state;
}

float SpaceShip::getMaxEnergy() { return 0.0f; } // TODO
void SpaceShip::setMaxEnergy(float amount) {} // TODO
float SpaceShip::getEnergy() { return 0.0f; } // TODO
void SpaceShip::setEnergy(float amount) {} // TODO

Speeds SpaceShip::getAcceleration()
{
    //TODO
    return {0.0f, 0.0f};
}

void SpaceShip::setAcceleration(float acceleration, std::optional<float> reverse_acceleration)
{
    //TODO
}

Speeds SpaceShip::getImpulseMaxSpeed()
{
    //TODO
    return {0.0f, 0.0f};
}
void SpaceShip::setImpulseMaxSpeed(float forward_speed, std::optional<float> reverse_speed)
{
    //TODO
}

string SpaceShip::getScriptExportModificationsOnTemplate()
{
    // Exports attributes common to ships as Lua script function calls.
    // Initialize the exported string.
    string ret = "";

    // If traits don't differ from the ship template, don't bother exporting
    // them.
    //if (getTypeName() != ship_template->getName())
    //    ret += ":setTypeName(\"" + getTypeName() + "\")";
    //if (hull_max != ship_template->hull)
    //    ret += ":setHullMax(" + string(hull_max, 0) + ")";
    //if (hull_strength != ship_template->hull)
    //    ret += ":setHull(" + string(hull_strength, 0) + ")";
    //if (impulse_max_speed != ship_template->impulse_speed)
    //    ret += ":setImpulseMaxSpeed(" + string(impulse_max_speed, 1) + ")";
    //if (impulse_max_reverse_speed != ship_template->impulse_reverse_speed)
    //    ret += ":setImpulseMaxReverseSpeed(" + string(impulse_max_reverse_speed, 1) + ")";
    //if (turn_speed != ship_template->turn_speed)
    //    ret += ":setRotationMaxSpeed(" + string(turn_speed, 1) + ")";
    //if (has_jump_drive != ship_template->has_jump_drive)
    //    ret += ":setJumpDrive(" + string(has_jump_drive ? "true" : "false") + ")";
    //if (jump_drive_min_distance != ship_template->jump_drive_min_distance
    //    || jump_drive_max_distance != ship_template->jump_drive_max_distance)
    //    ret += ":setJumpDriveRange(" + string(jump_drive_min_distance) + ", " + string(jump_drive_max_distance) + ")";
    //if (has_warp_drive != (ship_template->warp_speed > 0))
    //    ret += ":setWarpDrive(" + string(has_warp_drive ? "true" : "false") + ")";
    //if (warp_speed_per_warp_level != ship_template->warp_speed)
    //    ret += ":setWarpSpeed(" + string(warp_speed_per_warp_level) + ")";

    // Shield data
    // Determine whether to export shield data.
    //bool add_shields_max_line = getShieldCount() != ship_template->shield_count;
    //bool add_shields_line = getShieldCount() != ship_template->shield_count;

    // If shield max and level don't differ from the template, don't bother
    // exporting them.
    /*
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
    */

    // Missile weapon data
    /*
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
    */
    // Beam weapon data
    /*
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
*/
    return ret;
}

#include "spaceship.hpp"

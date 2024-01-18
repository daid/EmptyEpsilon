local Entity = getLuaEntityFunctionTable()

--- A SpaceShip is a ShipTemplateBasedObject controlled by either the AI (CpuShip) or players (PlayerSpaceship).
--- It can carry and deploy weapons, dock with or carry docked ships, and move using impulse, jump, or warp drives.
--- It's also subject to being moved by collision physics, unlike SpaceStations, which remain stationary.
--- This is the parent class of CpuShip and PlayerSpaceship objects, which inherit all STBO and SpaceShip functions.
--- Objects of this class can't be created by scripts, but its child classes can.

--- [DEPRECATED]
--- Use SpaceShip:isFriendOrFoeIdentifiedBy() or SpaceShip:isFriendOrFoeIdentifiedByFaction().
function Entity:isFriendOrFoeIdentified()
    if self.scan_state then
        for n=1,#self.scan_state do
            if self.scan_state[n].state != "none" then return true end
        end
    end
    return false
end
--- [DEPRECATED]
--- Use SpaceShip:isFullyScannedBy() or SpaceShip:isFullyScannedByFaction().
function Entity:isFullyScanned()
    if self.scan_state then
        for n=1,#self.scan_state do
            if self.scan_state[n].state == "full" then return true end
        end
    end
    return false
end
--- Returns whether this SpaceShip has been identified by the given ship as either hostile or friendly.
function Entity:isFriendOrFoeIdentifiedBy(faction)
    --TODO
end
--- Returns whether this SpaceShip has been identified by the given faction as either hostile or friendly.
function Entity:isFriendOrFoeIdentifiedByFaction(faction)
    --TODO
end
--- Returns whether this SpaceShip has been fully scanned by the given faction.
function Entity:isFullyScannedByFaction(faction)
    --TODO
end
--- Returns whether this SpaceShip has been identified by the given SpaceObject as either hostile or friendly.
--- Example: ship:isFriendOrFoeIdentifiedBy(enemy)
function Entity:isFriendOrFoeIdentifiedBy(enemy)
    --TODO
end
--- Returns whether this SpaceShip has been fully scanned by the given SpaceObject.
--- See also SpaceObject:isScannedBy().
--- Example: ship:isFullyScannedBy(enemy)
function Entity:isFullyScannedBy(enemy)
    --TODO
end
--- Returns whether this SpaceShip has been identified by the given faction as either hostile or friendly.
--- Example: ship:isFriendOrFoeIdentifiedByFaction("Kraylor")
function Entity:isFriendOrFoeIdentifiedByFaction(faction)
    --TODO
end
--- Returns whether this SpaceShip has been fully scanned by the given faction.
--- See also SpaceObject:isScannedByFaction().
--- Example: ship:isFullyScannedByFaction("Kraylor")
function Entity:isFullyScannedByFaction(faction)
    --TODO
end
--- Returns whether this SpaceShip is docked with the given SpaceObject.
--- Example: ship:isDocked(base) -- returns true if `ship` is fully docked with `base`
function Entity:isDocked(target)
    if self.docking_port and self.docking_port.state == "docked" then
        return self.docking_port.target == target
    end
end
--- Returns the SoaceObject with which this SpaceShip is docked.
--- Example: base = ship:getDockedWith()
function Entity:getDockedWith()
    if self.docking_port and self.docking_port.state == "docked" then
        return self.docking_port.target
    end
end
--- Returns the EDockingState value of this SpaceShip.
--- 0 = Not docked
--- 1 = Docking in progress
--- 2 = Docked
--- Example: ds = ship:getDockingState()
function Entity:getDockingState()
    if self.docking_port then
        local state = self.docking_port.state
        if state == "docking" then return 1 end
        if state == "docked" then return 2 end
    end
    return 0
end
--- Returns this SpaceShip's weapons target.
--- For a CpuShip, this can differ from its orders target.
--- Example: target = ship:getTarget()
function Entity:getTarget()
    if self.weapons_target then
        return self.weapons_target.entity
    end
    return nil
end
--- Returns the number of the given weapon type stocked by this SpaceShip.
--- Example: homing = ship:getWeaponStorage("Homing")
function Entity:getWeaponStorage(weapon_type)
    --TODO
end
--- Returns this SpaceShip's capacity for the given weapon type.
--- Example: homing_max = ship:getWeaponStorageMax("Homing")
function Entity:getWeaponStorageMax(weapon_type)
    --TODO
end
--- Sets the number of the given weapon type stocked by this SpaceShip.
--- Example: ship:setWeaponStorage("Homing", 2) -- this ship has 2 Homing missiles
function Entity:setWeaponStorage(weapon_type, amount)
    --TODO
end
--- Sets this SpaceShip's capacity for the given weapon type.
--- If this ship has more stock of that weapon type than the new capacity, its stock is reduced.
--- However, if this ship's capacity for a weapon type is increased, its stocks are not.
--- Use SpaceShip:setWeaponStorage() to update the stocks.
--- Example: ship:setWeaponStorageMax("Homing", 4) -- this ship can carry 4 Homing missiles
function Entity:setWeaponStorageMax(weapon_type, amount)
    --TODO
end
--- Returns this SpaceShip's shield frequency index.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Example:
--- frequency = ship:getShieldsFrequency() -- frequency index is 10
--- -- Outputs "Ship's shield frequency is 600THz"
--- print("Ship's shield frequency is " .. (frequency * 20) + 400 .. "THz")
function Entity:getShieldsFrequency()
    --TODO
end
--- Sets this SpaceShip's shield frequency index.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Valid values are 0 (400THz) to 20 (800THz). Defaults to a random value.
--- Unlike PlayerSpaceship:commandSetShieldFrequency(), this instantly changes the frequency with no calibration delay.
--- Example: frequency = ship:setShieldsFrequency(10) -- frequency is 600THz
function Entity:setShieldsFrequency(frequency)
    --TODO
end
--- Returns this SpaceShip's beam weapon frequency.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Example:
--- frequency = ship:getBeamFrequency() -- frequency index is 10
--- -- Outputs "Ship's beam frequency is 600THz"
--- print("Ship's beam frequency is " .. (frequency * 20) + 400 .. "THz")
function Entity:getBeamFrequency()
    --TODO
end
--- Returns this SpaceShip's energy capacity.
--- Example: ship:getMaxEnergy()
function Entity:getMaxEnergy()
    --TODO
end
--- Sets this SpaceShip's energy capacity.
--- CpuShips don't consume energy. Setting this value has no effect on their behavior or functionality.
--- For PlayerSpaceships, see PlayerSpaceship:setEnergyLevelMax().
--- Example: ship:setMaxEnergy(800)
function Entity:setMaxEnergy(amount)
    --TODO
end
--- Returns this SpaceShip's energy level.
--- Example: ship:getEnergy()
function Entity:getEnergy()
    --TODO
end
--- Sets this SpaceShip's energy level.
--- Valid values are any greater than 0 and less than the energy capacity (getMaxEnergy()).
--- Invalid values are ignored.
--- CpuShips don't consume energy. Setting this value has no effect on their behavior or functionality.
--- For PlayerSpaceships, see PlayerSpaceship:setEnergyLevel().
--- Example: ship:setEnergy(1000) -- sets the ship's energy to 1000 if its capacity is 1000 or more
function Entity:setEnergy(amount)
    --TODO
end
--- Returns whether this SpaceShip has the given system.
--- Example: ship:hasSystem("impulse") -- returns true if the ship has impulse drive
function Entity:hasSystem(system_name)
    --TODO
end
--- Returns the hacked level for the given system on this SpaceShip.
--- Returns a value between 0.0 (unhacked) and 1.0 (fully hacked).
--- Example: ship:getSystemHackedLevel("impulse")
function Entity:getSystemHackedLevel(system_name)
    --TODO
end
--- Sets the hacked level for the given system on this SpaceShip.
--- Valid range is 0.0 (unhacked) to 1.0 (fully hacked).
--- Example: ship:setSystemHackedLevel("impulse",0.5) -- sets the ship's impulse drive to half hacked
function Entity:setSystemHackedLevel(system_name)
    --TODO
end
--- Returns the given system's health on this SpaceShip.
--- System health is related to damage, and is separate from its hacked level.
--- Returns a value between 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:getSystemHealth("impulse")
function Entity:getSystemHealth(system_name)
    --TODO
end
--- Sets the given system's health on this SpaceShip.
--- System health is related to damage, and is separate from its hacked level.
--- Valid range is 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:setSystemHealth("impulse",0.5) -- sets the ship's impulse drive to half damaged
function Entity:setSystemHealth(system_name, amount)
    --TODO
end
--- Returns the given system's maximum health on this SpaceShip.
--- Returns a value between 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:getSystemHealthMax("impulse")
function Entity:getSystemHealthMax(system_name)
    --TODO
end
--- Sets the given system's maximum health on this SpaceShip.
--- Valid range is 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:setSystemHealthMax("impulse", 0.5) -- limits the ship's impulse drive health to half
function Entity:setSystemHealthMax(system_name, amount)
    --TODO
end
--- Returns the given system's heat level on this SpaceShip.
--- Returns a value between 0.0 (no heat) and 1.0 (overheating).
--- Example: ship:getSystemHeat("impulse")
function Entity:getSystemHeat(system_name)
    --TODO
end
--- Sets the given system's heat level on this SpaceShip.
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Valid range is 0.0 (fully disabled) to 1.0 (undamaged).
--- Example: ship:setSystemHeat("impulse", 0.5) -- sets the ship's impulse drive heat to half of capacity
function Entity:setSystemHeat(system_name)
    --TODO
end
--- Returns the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
--- Example: ship:getSystemHeatRate("impulse")
function Entity:getSystemHeatRate(system_name)
    --TODO
end
--- Sets the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Example: ship:setSystemHeatRate("impulse", 0.05)
function Entity:setSystemHeatRate(system_name, amount)
    --TODO
end
--- Returns the given system's power level on this SpaceShip.
--- Returns a value between 0.0 (unpowered) and 1.0 (fully powered).
--- Example: ship:getSystemPower("impulse")
function Entity:getSystemPower(system_name)
    --TODO
end
--- Sets the given system's power level.
--- Valid range is 0.0 (unpowered) to 1.0 (fully powered).
--- Example: ship:setSystemPower("impulse", 0.5) -- sets the ship's impulse drive to half power
function Entity:setSystemPower(system_name, amount)
    --TODO
end
--- Returns the given system's rate of consuming power, in points per second?, in this SpaceShip.
--- Example: ship:getSystemPowerRate("impulse")
function Entity:getSystemPowerRate(system_name)
    --TODO
end
--- Sets the given system's rate of consuming power, in points per second?, in this SpaceShip.
--- CpuShips don't consume energy. Setting this has no effect.
--- Example: ship:setSystemPowerRate("impulse", 0.4)
function Entity:setSystemPowerRate(system_name, amount)
    --TODO
end
--- Returns the relative power drain factor for the given system.
--- Example: ship:getSystemPowerFactor("impulse")
function Entity:getSystemPowerFactor(system_name)
    --TODO
end
--- Sets the relative power drain factor? for the given system in this SpaceShip.
--- "reactor" has a negative value because it generates power rather than draining it.
--- CpuShips don't consume energy. Setting this has no effect.
--- Example: ship:setSystemPowerFactor("impulse", 4)
function Entity:setSystemPowerFactor(system_name, amount)
    --TODO
end
--- Returns the coolant distribution for the given system in this SpaceShip.
--- Returns a value between 0.0 (none) and 1.0 (capacity).
--- Example: ship:getSystemCoolant("impulse")
function Entity:getSystemCoolant(system_name)
    --TODO
end
--- Sets the coolant quantity for the given system in this SpaceShip.
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Valid range is 0.0 (none) to 1.0 (capacity).
--- Example: ship:setSystemPowerFactor("impulse", 4)
function Entity:setSystemCoolant(system_name, amount)
    --TODO
end
--- Returns the rate at which the given system in this SpaceShip takes coolant, in points per second?
--- Example: ship:getSystemCoolantRate("impulse")
function Entity:getSystemCoolantRate(system_name)
    --TODO
end
--- Sets the rate at which the given system in this SpaceShip takes coolant, in points per second?
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Example: ship:setSystemCoolantRate("impulse", 1.2)
function Entity:setSystemCoolantRate(system_name, amount)
    --TODO
end
--- Returns this SpaceShip's forward and reverse impulse speed limits.
--- Examples:
--- forward,reverse = getImpulseMaxSpeed()
--- forward = getImpulseMaxSpeed() -- forward speed only
function Entity:getImpulseMaxSpeed()
    --TODO
end
--- Sets this SpaceShip's maximum forward and reverse impulse speeds.
--- The reverse maximum speed value is optional.
--- Calling this with a single argument sets both forward and reverse maximum speeds to the same value.
--- Examples:
--- ship:setImpulseMaxSpeed(30,20) -- sets the max forward speed to 30 and reverse to 20
--- ship:setImpulseMaxSpeed(30) -- sets the max forward and reverse speed to 30
function Entity:setImpulseMaxSpeed(forward, reverse)
    --TODO
end
--- Returns this SpaceShip's maximum rotational speed, in degrees per second?
--- Example: ship:getRotationMaxSpeed()
function Entity:getRotationMaxSpeed()
    --TODO
end
--- Sets this SpaceShip's maximum rotational speed, in degrees per second?
--- Example: ship:setRotationMaxSpeed(10)
function Entity:setRotationMaxSpeed(speed)
    --TODO
end
--- Returns the SpaceShip's forward and reverse impulse acceleration values, in (unit?)
--- Examples:
--- forward,reverse = getAcceleration()
--- forward = getAcceleration() -- forward acceleration only
function Entity:getAcceleration()
    --TODO
end
--- Sets the SpaceShip's forward and reverse impulse acceleration values, in (unit?)
--- The reverse acceleration value is optional.
--- Calling with a single argument sets both forward and reverse acceleration to the same value.
--- Examples:
--- ship:setAcceleration(5,3.5) -- sets the max forward acceleration to 5 and reverse to 3.5
--- ship:setAcceleration(5) -- sets the max forward and reverse acceleration to 5
function Entity:setAcceleration(forward, reverse)
    --TODO
end
--- Sets the SpaceShip's combat maneuvering capacities.
--- The boost value sets the forward maneuver capacity, and the strafe value sets the lateral maneuver capacity.
--- Example: ship:setCombatManeuver(400,250) -- sets boost capacity to 400 and lateral to 250
function Entity:setCombatManeuver(boost, strafe)
    --TODO
end
--- Returns whether the SpaceShip has a jump drive.
--- Example: ship:hasJumpDrive()
function Entity:hasJumpDrive()
    --TODO
end
--- Defines whether the SpaceShip has a jump drive.
--- If true, this ship gains jump drive controls and a "jumpdrive" ship system.
--- Example: ship:setJumpDrive(true) -- gives this ship a jump drive
function Entity:setJumpDrive(enabled)
    --TODO
end
--- Sets the minimum and maximum jump distances for this SpaceShip.
--- Defaults to (5000,50000) if not set by the ShipTemplate.
--- Example: ship:setJumpDriveRange(2500,25000) -- sets the minimum jump distance to 2.5U and maximum to 25U
function Entity:setJumpDriveRange(min_range, max_range)
    --TODO
end
--- Sets this SpaceShip's current jump drive charge.
--- Jumping depletes the ship's jump drive charge by a value equal to the distance jumped.
--- For example, a 5U jump depletes the charge by 5000.
--- A SpaceShip with a jump drive can jump only when this value is equal to or greater than the ship's maximum jump range.
--- Any numeric value is valid, including negative values (longer to recharge) and values larger than the ship's maximum jump range (can jump again with a shorter, or no, recharge required).
--- Jump drive charge regenerates at a rate modified by the "jumpdrive" system's effectiveness.
--- Example: ship:setJumpDriveCharge(50000)
function Entity:setJumpDriveCharge(charge)
    --TODO
end
--- Returns this SpaceShip's current jump drive charge.
--- Example: jump_charge = ship:getJumpDriveCharge()
function Entity:getJumpDriveCharge()
    --TODO
end
--- Returns the time required by this SpaceShip to complete a jump once initiated.
--- A ship can't perform certain actions, such as docking, while its jump delay is not 0.
--- Returns a value between 0.0 (no delay, ready to jump) to 10.0.
--- With normal "jumpdrive" system effectiveness, this delay is 10 seconds.
--- System effectiveness can modify this delay.
--- Example: ship:getJumpDelay()
function Entity:getJumpDelay()
    --TODO
end
--- Returns whether this SpaceShip has a warp drive.
--- Example: ship:hasWarpDrive()
function Entity:hasWarpDrive()
    --TODO
end
--- Defines whether this SpaceShip has a warp drive.
--- If true, this ship gains warp drive controls and a "warp" ship system.
--- Example: ship:setWarpDrive(true)
function Entity:setWarpDrive(enabled)
    --TODO
end
--- Sets this SpaceShip's warp speed factor.
--- Valid values are any greater than 0. Ships don't tend to go faster than 24000 (1400U/min) due to engine limitations.
--- Unlike ShipTemplate:setWarpSpeed(), setting this value does NOT also grant this ship a warp drive.
--- Example: ship:setWarpSpeed(1000);
function Entity:setWarpSpeed(speed)
    --TODO
end
--- Returns this SpaceShip's warp speed factor.
--- Actual warp speed can be modified by "warp" system effectiveness.
--- Example: ship:getWarpSpeed(()
function Entity:getWarpSpeed()
    --TODO
end
--- Returns the arc, in degrees, for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponArc(0); -- returns beam weapon 0's arc
function Entity:getBeamWeaponArc(index)
    --TODO
end
--- Returns the direction, in degrees relative to the ship's forward bearing, for the arc's center of the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponDirection(0); -- returns beam weapon 0's direction
function Entity:getBeamWeaponDirection(index)
    --TODO
end
--- Returns the range for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponRange(0); -- returns beam weapon 0's range
function Entity:getBeamWeaponRange(index)
    --TODO
end
--- Returns the turret arc, in degrees, for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponTurretArc(0); -- returns beam weapon 0's turret arc
function Entity:getBeamWeaponTurretArc(index)
    --TODO
end
--- Returns the direction, in degrees relative to the ship's forward bearing, for the turret arc's center for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponTurretDirection(0); -- returns beam weapon 0's turret direction
function Entity:getBeamWeaponTurretDirection(index)
    --TODO
end
--- Returns the base firing delay, in seconds, for the BeamWeapon with the given index on this SpaceShip.
--- Actual cycle time can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponCycleTime(0); -- returns beam weapon 0's cycle time
function Entity:getBeamWeaponCycleTime(index)
    --TODO
end
--- Returns the base damage dealt by the BeamWeapon with the given index on this SpaceShip.
--- Actual damage can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponDamage(0); -- returns beam weapon 0's damage
function Entity:getBeamWeaponDamage(index)
    --TODO
end
--- Returns how much of this SpaceShip's energy is drained each time the BeamWeapon with the given index is fired.
--- Actual drain can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponEnergyPerFire(0); -- returns beam weapon 0's energy use per firing
function Entity:getBeamWeaponEnergyPerFire(index)
    --TODO
end
--- Returns the heat generated by each firing of the BeamWeapon with the given index on this SpaceShip.
--- Actual heat generation can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponHeatPerFire(0); -- returns beam weapon 0's heat generation per firing
function Entity:getBeamWeaponHeatPerFire(index)
    --TODO
end
--- Defines the traits of a BeamWeapon with the given index on this SpaceShip.
--- - index: Each beam weapon on this SpaceShip must have a unique index.
--- - arc: Sets the arc of its firing capability, in degrees.
--- - direction: Sets the default center angle of the arc, in degrees relative to the ship's forward bearing. Accepts 0, negative, and positive values.
--- - range: Sets how far away the beam can fire.
--- - cycle_time: Sets the base firing delay, in seconds. System effectiveness modifies the cycle time.
--- - damage: Sets the base damage done by the beam to the target. System effectiveness modifies the damage.
--- To create a turreted beam, also add SpaceShip:setBeamWeaponTurret(), and set the beam weapon's arc to be smaller than the turret's arc.
--- Example:
--- -- Creates a beam weapon with index 0, arc of 90 degrees, direction pointing backward, range of 1U, base cycle time of 1 second, and base damage of 1 point
--- ship:setBeamWeapon(0,90,180,1000,1,1)
function Entity:setBeamWeapon(index, arc, direction, range, cycle_time, damage)
    --TODO
end
--- Converts a BeamWeapon with the given index on this SpaceShip into a turret and defines its traits.
--- A turreted beam weapon rotates within its turret arc toward the weapons target at the given rotation rate.
--- - index: Must match the index of an existing beam weapon on this SpaceShip.
--- - arc: Sets the turret's maximum targeting angles, in degrees. The turret arc must be larger than the associated beam weapon's arc.
--- - direction: Sets the default center angle of the turret arc, in degrees relative to the ship's forward bearing. Accepts 0, negative, and positive values.
--- - rotation_rate: Sets how many degrees per tick (unit?) that the associated beam weapon's direction can rotate toward the target within the turret arc. System effectiveness modifies the turret's rotation rate.
--- To create a turreted beam, also add SpaceShip:setBeamWeapon(), and set the beam weapon's arc to be smaller than the turret's arc.
--- Example:
--- -- Makes beam weapon 0 a turret with a 200-degree turret arc centered on 90 degrees from forward, rotating at 5 degrees per tick (unit?)
--- ship:setBeamWeaponTurret(0,200,90,5)
function Entity:setBeamWeaponTurret(index, arc, direction, rotation_rate)
    --TODO
end
--- Sets the BeamEffect texture, by filename, for the BeamWeapon with the given index on this SpaceShip.
--- See BeamEffect:setTexture().
--- Example: ship:setBeamWeaponTexture(0,"texture/beam_blue.png")
function Entity:setBeamWeaponTexture(index, texture)
    --TODO
end
--- Sets how much energy is drained each time the BeamWeapon with the given index is fired on this SpaceShip.
--- Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
--- Example: ship:setBeamWeaponEnergyPerFire(0,1) -- sets beam 0 to use 1 energy per firing
function Entity:setBeamWeaponEnergyPerFire(index, energy)
    --TODO
end
--- Sets how much "beamweapon" system heat is generated, in percentage of total system heat capacity, each time the BeamWeapon with the given index is fired on this SpaceShip.
--- Only PlayerSpaceships generate and manage heat. Setting this for other ShipTemplateBasedObject types has no effect.
--- Example: ship:setBeamWeaponHeatPerFire(0,0.02) -- sets beam 0 to generate 0.02 (2%) system heat per firing
function Entity:setBeamWeaponHeatPerFire(index, heat)
    --TODO
end
--- Sets the colors used to draw the radar arc for the BeamWeapon with the given index on this SpaceShip.
--- The first three-number value sets the RGB color for the arc when idle, and the second sets the color when firing.
--- Example: ship:setBeamWeaponArcColor(0,0,128,0,0,255,0) -- makes beam 0's arc green
function Entity:setBeamWeaponArcColor(index, idle_r, idle_g, idle_b, fire_r, fire_g, fire_b)
    --TODO
end
--- Sets the damage type dealt by the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:setBeamWeaponDamageType(0,"emp") -- makes beam 0 deal EMP damage
function Entity:setBeamWeaponDamageType(index, damage_type)
    --TODO
end
--- Sets the number of WeaponTubes for this SpaceShip.
--- Weapon tubes are 0-indexed. For example, 3 tubes would be indexed 0, 1, and 2.
--- Ships are limited to a maximum of 16 weapon tubes.
--- Example: ship:setWeaponTubeCount(4)
function Entity:setWeaponTubeCount(amount)
    --TODO
end
--- Returns the number of WeaponTube on this SpaceShip.
--- Example: ship:getWeaponTubeCount()
function Entity:getWeaponTubeCount()
    --TODO
end
--- Returns the weapon type loaded into the WeaponTube with the given index on this SpaceShip.
--- Returns no value if no weapon is loaded, which includes the tube being in a loading or unloading state.
--- Example: ship:getWeaponTubeLoadType(0)
function Entity:getWeaponTubeLoadType(index)
    --TODO
end
--- Sets which weapon types the WeaponTube with the given index on this SpaceShip can load.
--- Note the spelling of "missle".
--- Example: ship:weaponTubeAllowMissle(0,"Homing") -- allows Homing missiles to be loaded in WeaponTube 0
function Entity:weaponTubeAllowMissle(index, weapon_type)
    --TODO
end
--- Sets which weapon types the WeaponTube with the given index can't load on this SpaceShip.
--- Note the spelling of "missle".
--- Example: ship:weaponTubeDisallowMissle(0,"Homing") -- prevents Homing missiles from being loaded in tube 0
function Entity:weaponTubeDisallowMissle(index, weapon_type)
    --TODO
end
--- Sets a weapon tube with the given index on this SpaceShip to allow loading only the given weapon type.
--- Example: ship:setWeaponTubeExclusiveFor(0,"Homing") -- allows only Homing missiles to be loaded in tube 0
function Entity:setWeaponTubeExclusiveFor(index, weapon_type)
    --TODO
end
--- Sets the angle, relative to this SpaceShip's forward bearing, toward which the WeaponTube with the given index on this SpaceShip points.
--- Accepts 0, negative, and positive values.
--- Example:
--- -- Sets tube 0 to point 90 degrees right of forward, and tube 1 to point 90 degrees left of forward
--- ship:setWeaponTubeDirection(0,90):setWeaponTubeDirection(1,-90)
function Entity:setWeaponTubeDirection(index, direction)
    --TODO
end
--- Sets the weapon size launched from the WeaponTube with the given index on this SpaceShip.
--- Example: ship:setTubeSize(0,"large") -- sets tube 0 to fire large weapons
function Entity:setTubeSize(index, size)
    --TODO
end
--- Returns the size of the weapon tube with the given index on this SpaceShip.
--- Example: ship:getTubeSize(0)
function Entity:getTubeSize(index)
    --TODO
end
--- Returns the delay, in seconds, for loading and unloading the WeaponTube with the given index on this SpaceShip.
--- Example: ship:getTubeLoadTime(0)
function Entity:getTubeLoadTime(index)
    --TODO
end
--- Sets the time, in seconds, required to load the weapon tube with the given index on this SpaceShip.
--- Example: ship:setTubeLoadTime(0,12) -- sets the loading time for tube 0 to 12 seconds
function Entity:setTubeLoadTime(index, load_time)
    --TODO
end
--- Returns the dynamic gravitational radar signature value emitted by this SpaceShip.
--- Ship functions can dynamically modify this SpaceShip's radar signature values.
--- Example: ship:getDynamicRadarSignatureGravity()
function Entity:getDynamicRadarSignatureGravity()
    --TODO
end
--- Returns the dynamic electrical radar signature value emitted by this SpaceShip.
--- Ship functions can dynamically modify this SpaceShip's radar signature values.
--- Example: ship:getDynamicRadarSignatureElectrical()
function Entity:getDynamicRadarSignatureElectrical()
    --TODO
end
--- Returns the dynamic biological radar signature value emitted by this SpaceShip.
--- Ship functions can dynamically modify this SpaceShip's radar signature values.
--- Example: ship:getDynamicRadarSignatureBiological()
function Entity:getDynamicRadarSignatureBiological()
    --TODO
end
--- Broadcasts a message from this SpaceShip to the comms of all other SpaceShips matching the threshold.
--- The threshold value can be an integer equivalent of EFactionVsFactionState:
--- 0: Broadcast to all friendly SpaceShips
--- 1: Broadcast to all friendly and neutral SpaceShips
--- 2: Broadcast to all SpaceShips, including enemies
--- Providing an invalid threshold value defaults to broadcasting only to friendly SpaceShips.
--- Examples:
--- ship:addBroadcast(1, "Help!")
--- ship:addBroadcast(2, "We're taking over!")
function Entity:addBroadcast(target, message)
    --TODO
end
--- Sets the scan state of this SpaceShip for every faction.
--- Example: ship:setScanState("fullscan") -- every faction treats this ship as fully scanned
function Entity:setScanState(state)
    --TODO
end
--- Sets the scan state of this SpaceShip for a given faction.
--- Example: ship:setScanStateByFaction("Kraylor","fullscan") -- Kraylor faction treats this ship as fully scanned
function Entity:setScanStateByFaction(faction, state)
    --TODO
end

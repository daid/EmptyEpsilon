local Entity = getLuaEntityFunctionTable()

--- A SpaceShip is a ShipTemplateBasedObject controlled by either the AI (CpuShip) or players (PlayerSpaceship).
--- It can carry and deploy weapons, dock with or carry docked ships, and move using impulse, jump, or warp drives.
--- It's also subject to being moved by collision physics, unlike SpaceStations, which remain stationary.
--- This is the parent class of CpuShip and PlayerSpaceship objects, which inherit all STBO and SpaceShip functions.
--- Objects of this class can't be created by scripts, but its child classes can.

--- [DEPRECATED]
--- Use SpaceShip:isFriendOrFoeIdentifiedBy() or SpaceShip:isFriendOrFoeIdentifiedByFaction().
function Entity:isFriendOrFoeIdentified()
    if self.components.scan_state then
        for n=1,#self.components.scan_state do
            if self.components.scan_state[n].state ~= "none" then return true end
        end
    end
    return false
end
--- [DEPRECATED]
--- Use SpaceShip:isFullyScannedBy() or SpaceShip:isFullyScannedByFaction().
function Entity:isFullyScanned()
    if self.components.scan_state then
        for n=1,#self.components.scan_state do
            if self.components.scan_state[n].state == "full" then return true end
        end
    end
    return false
end

--- Returns whether this SpaceShip has been identified by the given SpaceObject as either hostile or friendly.
--- Example: ship:isFriendOrFoeIdentifiedBy(enemy)
function Entity:isFriendOrFoeIdentifiedBy(enemy)
    local scan_state = self.components.scan_state
    if enemy == nil or not enemy:isValid() then return false end
    local faction = enemy.components.faction
    if faction == nil then return false end
    faction = faction.entity
    if scan_state then
        for n=1,#scan_state do
            if scan_state[n].faction == faction then return scan_state[n].state ~= "none" end
        end
    end
    return false
end
--- Returns whether this SpaceShip has been fully scanned by the given SpaceObject.
--- See also SpaceObject:isScannedBy().
--- Example: ship:isFullyScannedBy(enemy)
function Entity:isFullyScannedBy(enemy)
    local scan_state = self.components.scan_state
    if enemy == nil or not enemy:isValid() then return false end
    local faction = enemy.components.faction
    if faction == nil then return false end
    faction = faction.entity
    if scan_state then
        for n=1,#scan_state do
            if scan_state[n].faction == faction then return scan_state[n].state == "full" end
        end
    end
    return false
end
--- Returns whether this SpaceShip has been identified by the given faction as either hostile or friendly.
--- Example: ship:isFriendOrFoeIdentifiedByFaction("Kraylor")
function Entity:isFriendOrFoeIdentifiedByFaction(faction)
    local scan_state = self.components.scan_state
    if enemy == nil or not enemy:isValid() then return false end
    faction = getFactionInfo(faction)
    if faction == nil then return false end
    if scan_state then
        for n=1,#scan_state do
            if scan_state[n].faction == faction then return scan_state[n].state ~= "none" end
        end
    end
    return false
end
--- Returns whether this SpaceShip has been fully scanned by the given faction.
--- See also SpaceObject:isScannedByFaction().
--- Example: ship:isFullyScannedByFaction("Kraylor")
function Entity:isFullyScannedByFaction(faction)
    local scan_state = self.components.scan_state
    if enemy == nil or not enemy:isValid() then return false end
    faction = getFactionInfo(faction)
    if faction == nil then return false end
    if scan_state then
        for n=1,#scan_state do
            if scan_state[n].faction == faction then return scan_state[n].state == "full" end
        end
    end
    return false

end
--- Returns whether this SpaceShip is docked with the given SpaceObject.
--- Example: ship:isDocked(base) -- returns true if `ship` is fully docked with `base`
function Entity:isDocked(target)
    if self.components.docking_port and self.components.docking_port.state == "docked" then
        return self.components.docking_port.target == target
    end
    return false
end
--- Returns the SoaceObject with which this SpaceShip is docked.
--- Example: base = ship:getDockedWith()
function Entity:getDockedWith()
    if self.components.docking_port and self.components.docking_port.state == "docked" then
        return self.components.docking_port.target
    end
    return false
end
--- Returns the EDockingState value of this SpaceShip.
--- 0 = Not docked
--- 1 = Docking in progress
--- 2 = Docked
--- Example: ds = ship:getDockingState()
function Entity:getDockingState()
    if self.components.docking_port then
        local state = self.components.docking_port.state
        if state == "docking" then return 1 end
        if state == "docked" then return 2 end
    end
    return 0
end

--- Returns the number of the given weapon type stocked by this SpaceShip.
--- Example: homing = ship:getWeaponStorage("Homing")
function Entity:getWeaponStorage(weapon_type)
    if self.components.missile_tubes then
        weapon_type = string.lower(weapon_type)
        if weapon_type == "homing" then return self.components.missile_tubes.storage_homing end
        if weapon_type == "nuke" then return self.components.missile_tubes.storage_nuke end
        if weapon_type == "mine" then return self.components.missile_tubes.storage_mine end
        if weapon_type == "emp" then return self.components.missile_tubes.storage_emp end
        if weapon_type == "hvli" then return self.components.missile_tubes.storage_hvli end
    end
    return 0
end
--- Returns this SpaceShip's capacity for the given weapon type.
--- Example: homing_max = ship:getWeaponStorageMax("Homing")
function Entity:getWeaponStorageMax(weapon_type)
    if self.components.missile_tubes then
        weapon_type = string.lower(weapon_type)
        if weapon_type == "homing" then return self.components.missile_tubes.max_homing end
        if weapon_type == "nuke" then return self.components.missile_tubes.max_nuke end
        if weapon_type == "mine" then return self.components.missile_tubes.max_mine end
        if weapon_type == "emp" then return self.components.missile_tubes.max_emp end
        if weapon_type == "hvli" then return self.components.missile_tubes.max_hvli end
    end
    return 0
end
--- Sets the number of the given weapon type stocked by this SpaceShip.
--- Example: ship:setWeaponStorage("Homing", 2) -- this ship has 2 Homing missiles
--- Sets the weapon type and amount restocked upon pickup when a SpaceShip collides with this SupplyDrop.
--- Example: supply_drop:setWeaponStorage("Homing",6)
function Entity:setWeaponStorage(weapon_type, amount)
    if self.components.missile_tubes then
        weapon_type = string.lower(weapon_type)
        if weapon_type == "homing" then self.components.missile_tubes.storage_homing = amount end
        if weapon_type == "nuke" then self.components.missile_tubes.storage_nuke = amount end
        if weapon_type == "mine" then self.components.missile_tubes.storage_mine = amount end
        if weapon_type == "emp" then self.components.missile_tubes.storage_emp = amount end
        if weapon_type == "hvli" then self.components.missile_tubes.storage_hvli = amount end
    end
    if self.components.pickup then
        weapon_type = string.lower(weapon_type)
        if weapon_type == "homing" then self.components.pickup.give_homing = amount end
        if weapon_type == "nuke" then self.components.pickup.give_nuke = amount end
        if weapon_type == "mine" then self.components.pickup.give_mine = amount end
        if weapon_type == "emp" then self.components.pickup.give_emp = amount end
        if weapon_type == "hvli" then self.components.pickup.give_hvli = amount end
    end
    return self
end
--- Sets this SpaceShip's capacity for the given weapon type.
--- If this ship has more stock of that weapon type than the new capacity, its stock is reduced.
--- However, if this ship's capacity for a weapon type is increased, its stocks are not.
--- Use SpaceShip:setWeaponStorage() to update the stocks.
--- Example: ship:setWeaponStorageMax("Homing", 4) -- this ship can carry 4 Homing missiles
function Entity:setWeaponStorageMax(weapon_type, amount)
    if self.components.missile_tubes then
        weapon_type = string.lower(weapon_type)
        if weapon_type == "homing" then self.components.missile_tubes.max_homing = amount end
        if weapon_type == "nuke" then self.components.missile_tubes.max_nuke = amount end
        if weapon_type == "mine" then self.components.missile_tubes.max_mine = amount end
        if weapon_type == "emp" then self.components.missile_tubes.max_emp = amount end
        if weapon_type == "hvli" then self.components.missile_tubes.max_hvli = amount end
    end
    return self
end
--- Returns this SpaceShip's shield frequency index.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Example:
--- frequency = ship:getShieldsFrequency() -- frequency index is 10
--- -- Outputs "Ship's shield frequency is 600THz"
--- print("Ship's shield frequency is " .. (frequency * 20) + 400 .. "THz")
function Entity:getShieldsFrequency()
    if self.components.shields then return self.components.shields.frequency end
    return 0
end
--- Sets this SpaceShip's shield frequency index.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Valid values are 0 (400THz) to 20 (800THz). Defaults to a random value.
--- Unlike PlayerSpaceship:commandSetShieldFrequency(), this instantly changes the frequency with no calibration delay.
--- Example: frequency = ship:setShieldsFrequency(10) -- frequency is 600THz
function Entity:setShieldsFrequency(frequency)
    if self.components.shields then self.components.shields.frequency = frequency end
    return self
end
--- Returns this SpaceShip's beam weapon frequency.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Example:
--- frequency = ship:getBeamFrequency() -- frequency index is 10
--- -- Outputs "Ship's beam frequency is 600THz"
--- print("Ship's beam frequency is " .. (frequency * 20) + 400 .. "THz")
function Entity:getBeamFrequency()
    if self.components.beam_weapons then return self.components.beam_weapons.frequency end
    return 0
end
--- Returns this SpaceShip's energy capacity.
--- Example: ship:getMaxEnergy()
function Entity:getMaxEnergy()
    if self.components.reactor then return self.components.reactor.max_energy end
    return 1000
end
--- Sets this SpaceShip's energy capacity.
--- CpuShips don't consume energy. Setting this value has no effect on their behavior or functionality.
--- For PlayerSpaceships, see PlayerSpaceship:setEnergyLevelMax().
--- Example: ship:setMaxEnergy(800)
function Entity:setMaxEnergy(amount)
    if self.components.reactor then self.components.reactor.max_energy = amount end
    return self
end
--- Returns this SpaceShip's energy level.
--- Example: ship:getEnergy()
function Entity:getEnergy()
    if self.components.reactor then return self.components.reactor.energy end
    return 1000
end


function __getSystemByName(entity, system_name)
    system_name = string.lower(system_name)
    if system_name == "reactor" then return entity.components.reactor end
    if system_name == "beamweapons" then return entity.components.beam_weapons end
    if system_name == "missilesystem" then return entity.components.missile_tubes end
    if system_name == "maneuver" then return entity.components.maneuvering_thrusters end
    if system_name == "impulse" then return entity.components.impulse_engine end
    if system_name == "warp" then return entity.components.warp_drive end
    if system_name == "jumpdrive" then return entity.components.jump_drive end
    if system_name == "frontshield" then return entity.components.shields end
    if system_name == "rearshield" and entity.components.shields and #entity.components.shields > 1 then return entity.components.shields end
    return nil
end

function __getSystemPropertyByName(entity, system_name, property)
    system_name = string.lower(system_name)
    local sys = __getSystemByName(entity, system_name)
    if sys == nil then return 0.0 end
    if system_name == "frontshield" then return sys["front_" .. property] end
    if system_name == "rearshield" then return sys["rear_" .. property] end
    return sys[property]
end

function __setSystemPropertyByName(entity, system_name, property, value)
    system_name = string.lower(system_name)
    local sys = __getSystemByName(entity, system_name)
    if sys == nil then return end
    if system_name == "frontshield" then sys["front_" .. property] = value
    elseif system_name == "rearshield" then sys["rear_" .. property] = value
    else sys[property] = value end
end

--- Returns whether this SpaceShip has the given system.
--- Example: ship:hasSystem("impulse") -- returns true if the ship has impulse drive
function Entity:hasSystem(system_name)
    return __getSystemByName(self, system_name) ~= nil
end
--- Returns the hacked level for the given system on this SpaceShip.
--- Returns a value between 0.0 (unhacked) and 1.0 (fully hacked).
--- Example: ship:getSystemHackedLevel("impulse")
function Entity:getSystemHackedLevel(system_name)
    return __getSystemPropertyByName(self, system_name, "hacked_level")
end
--- Sets the hacked level for the given system on this SpaceShip.
--- Valid range is 0.0 (unhacked) to 1.0 (fully hacked).
--- Example: ship:setSystemHackedLevel("impulse",0.5) -- sets the ship's impulse drive to half hacked
function Entity:setSystemHackedLevel(system_name, level)
    __setSystemPropertyByName(self, system_name, "hacked_level", level)
    return self
end
--- Returns the given system's health on this SpaceShip.
--- System health is related to damage, and is separate from its hacked level.
--- Returns a value between 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:getSystemHealth("impulse")
function Entity:getSystemHealth(system_name)
    return __getSystemPropertyByName(self, system_name, "health")
end
--- Sets the given system's health on this SpaceShip.
--- System health is related to damage, and is separate from its hacked level.
--- Valid range is 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:setSystemHealth("impulse",0.5) -- sets the ship's impulse drive to half damaged
function Entity:setSystemHealth(system_name, amount)
    __setSystemPropertyByName(self, system_name, "health", amount)
    return self
end
--- Returns the given system's maximum health on this SpaceShip.
--- Returns a value between 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:getSystemHealthMax("impulse")
function Entity:getSystemHealthMax(system_name)
    return __getSystemPropertyByName(self, system_name, "health_max")
end
--- Sets the given system's maximum health on this SpaceShip.
--- Valid range is 0.0 (fully disabled) and 1.0 (undamaged).
--- Example: ship:setSystemHealthMax("impulse", 0.5) -- limits the ship's impulse drive health to half
function Entity:setSystemHealthMax(system_name, amount)
    __setSystemPropertyByName(self, system_name, "health_max", amount)
    return self
end
--- Returns the given system's heat level on this SpaceShip.
--- Returns a value between 0.0 (no heat) and 1.0 (overheating).
--- Example: ship:getSystemHeat("impulse")
function Entity:getSystemHeat(system_name)
    return __getSystemPropertyByName(self, system_name, "heat_level")
end
--- Sets the given system's heat level on this SpaceShip.
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Valid range is 0.0 (fully disabled) to 1.0 (undamaged).
--- Example: ship:setSystemHeat("impulse", 0.5) -- sets the ship's impulse drive heat to half of capacity
function Entity:setSystemHeat(system_name, amount)
    __setSystemPropertyByName(self, system_name, "heat_level", amount)
    return self
end
--- Returns the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
--- Example: ship:getSystemHeatRate("impulse")
function Entity:getSystemHeatRate(system_name)
    return __getSystemPropertyByName(self, system_name, "heat_add_rate_per_second")
end
--- Sets the given system's rate of heating or cooling, in percent (0.01 = 1%) per second?, on this SpaceShip.
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Example: ship:setSystemHeatRate("impulse", 0.05)
function Entity:setSystemHeatRate(system_name, amount)
    __setSystemPropertyByName(self, system_name, "heat_add_rate_per_second", amount)
    return self
end
--- Returns the given system's power level on this SpaceShip.
--- Returns a value between 0.0 (unpowered) and 1.0 (fully powered).
--- Example: ship:getSystemPower("impulse")
function Entity:getSystemPower(system_name)
    return __getSystemPropertyByName(self, system_name, "power_level")
end
--- Sets the given system's power level.
--- Valid range is 0.0 (unpowered) to 1.0 (fully powered).
--- Example: ship:setSystemPower("impulse", 0.5) -- sets the ship's impulse drive to half power
function Entity:setSystemPower(system_name, amount)
    __setSystemPropertyByName(self, system_name, "power_level", amount)
    return self
end
--- Returns the given system's rate of consuming power, in points per second?, in this SpaceShip.
--- Example: ship:getSystemPowerRate("impulse")
function Entity:getSystemPowerRate(system_name)
    return __getSystemPropertyByName(self, system_name, "power_change_rate_per_second")
end
--- Sets the given system's rate of consuming power, in points per second?, in this SpaceShip.
--- CpuShips don't consume energy. Setting this has no effect.
--- Example: ship:setSystemPowerRate("impulse", 0.4)
function Entity:setSystemPowerRate(system_name, amount)
    __setSystemPropertyByName(self, system_name, "power_change_rate_per_second", amount)
    return self
end
--- Returns the relative power drain factor for the given system.
--- Example: ship:getSystemPowerFactor("impulse")
function Entity:getSystemPowerFactor(system_name)
    return __getSystemPropertyByName(self, system_name, "power_factor")
end
--- Sets the relative power drain factor? for the given system in this SpaceShip.
--- "reactor" has a negative value because it generates power rather than draining it.
--- CpuShips don't consume energy. Setting this has no effect.
--- Example: ship:setSystemPowerFactor("impulse", 4)
function Entity:setSystemPowerFactor(system_name, amount)
    __setSystemPropertyByName(self, system_name, "power_factor", amount)
    return self
end
--- Returns the coolant distribution for the given system in this SpaceShip.
--- Returns a value between 0.0 (none) and 1.0 (capacity).
--- Example: ship:getSystemCoolant("impulse")
function Entity:getSystemCoolant(system_name)
    return __getSystemPropertyByName(self, system_name, "coolant_level")
end
--- Sets the coolant quantity for the given system in this SpaceShip.
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Valid range is 0.0 (none) to 1.0 (capacity).
--- Example: ship:setSystemPowerFactor("impulse", 4)
function Entity:setSystemCoolant(system_name, amount)
    __setSystemPropertyByName(self, system_name, "coolant_level", amount)
    return self
end
--- Returns the rate at which the given system in this SpaceShip takes coolant, in points per second?
--- Example: ship:getSystemCoolantRate("impulse")
function Entity:getSystemCoolantRate(system_name)
    return __getSystemPropertyByName(self, system_name, "coolant_change_rate_per_second")
end
--- Sets the rate at which the given system in this SpaceShip takes coolant, in points per second?
--- CpuShips don't generate or manage heat. Setting this has no effect on them.
--- Example: ship:setSystemCoolantRate("impulse", 1.2)
function Entity:setSystemCoolantRate(system_name, amount)
    __setSystemPropertyByName(self, system_name, "coolant_change_rate_per_second", amount)
    return self
end
--- Returns this SpaceShip's forward and reverse impulse speed limits.
--- Examples:
--- forward,reverse = getImpulseMaxSpeed()
--- forward = getImpulseMaxSpeed() -- forward speed only
function Entity:getImpulseMaxSpeed()
    if self.components.impulse_engine then return self.components.impulse_engine.max_speed_forward, self.components.impulse_engine.max_speed_reverse end
    return 0.0, 0.0
end
--- Sets this SpaceShip's maximum forward and reverse impulse speeds.
--- The reverse maximum speed value is optional.
--- Calling this with a single argument sets both forward and reverse maximum speeds to the same value.
--- Examples:
--- ship:setImpulseMaxSpeed(30,20) -- sets the max forward speed to 30 and reverse to 20
--- ship:setImpulseMaxSpeed(30) -- sets the max forward and reverse speed to 30
function Entity:setImpulseMaxSpeed(forward, reverse)
    if self.components.impulse_engine then
        self.components.impulse_engine.max_speed_forward = forward
        if reverse == nil then
            self.components.impulse_engine.max_speed_reverse = forward
        else
            self.components.impulse_engine.max_speed_reverse = reverse
        end
    end
    return self
end
--- Returns this SpaceShip's maximum rotational speed, in degrees per second?
--- Example: ship:getRotationMaxSpeed()
function Entity:getRotationMaxSpeed()
    if self.components.maneuvering_thrusters then return self.components.maneuvering_thrusters.speed end
    return 0.0
end
--- Sets this SpaceShip's maximum rotational speed, in degrees per second?
--- Example: ship:setRotationMaxSpeed(10)
function Entity:setRotationMaxSpeed(speed)
    if self.components.maneuvering_thrusters then self.components.maneuvering_thrusters.speed = speed end
    return self
end
--- Returns the SpaceShip's forward and reverse impulse acceleration values, in (unit?)
--- Examples:
--- forward,reverse = getAcceleration()
--- forward = getAcceleration() -- forward acceleration only
function Entity:getAcceleration()
    if self.components.impulse_engine then return self.components.impulse_engine.acceleration_forward end
    return 0.0
end
--- Sets the SpaceShip's forward and reverse impulse acceleration values, in (unit?)
--- The reverse acceleration value is optional.
--- Calling with a single argument sets both forward and reverse acceleration to the same value.
--- Examples:
--- ship:setAcceleration(5,3.5) -- sets the max forward acceleration to 5 and reverse to 3.5
--- ship:setAcceleration(5) -- sets the max forward and reverse acceleration to 5
function Entity:setAcceleration(forward, reverse)
    if self.components.impulse_engine then
        self.components.impulse_engine.acceleration_forward = forward
        if reverse == nil then
            self.components.impulse_engine.acceleration_reverse = forward
        else
            self.components.impulse_engine.acceleration_reverse = reverse
        end
    end
    return self
end
--- Sets the SpaceShip's combat maneuvering capacities.
--- The boost value sets the forward maneuver capacity, and the strafe value sets the lateral maneuver capacity.
--- Example: ship:setCombatManeuver(400,250) -- sets boost capacity to 400 and lateral to 250
function Entity:setCombatManeuver(boost, strafe)
    self.components.combat_maneuvering_thrusters = {boost_speed=boost, strafe_speed=strafe}
    return self
end
--- Returns whether the SpaceShip has a jump drive.
--- Example: ship:hasJumpDrive()
function Entity:hasJumpDrive()
    return self.components.jump_drive ~= nil
end
--- Defines whether the SpaceShip has a jump drive.
--- If true, this ship gains jump drive controls and a "jumpdrive" ship system.
--- Example: ship:setJumpDrive(true) -- gives this ship a jump drive
function Entity:setJumpDrive(enabled)
    if enabled then self.components.jump_drive = {} else self.components.jump_drive = nil end
    return self
end
--- Sets the minimum and maximum jump distances for this SpaceShip.
--- Defaults to (5000,50000) if not set by the ShipTemplate.
--- Example: ship:setJumpDriveRange(2500,25000) -- sets the minimum jump distance to 2.5U and maximum to 25U
function Entity:setJumpDriveRange(min_range, max_range)
    if self.components.jump_drive then
        self.components.jump_drive.min_distance = min_range
        self.components.jump_drive.max_distance = max_range
    end
    return self
end
--- Sets this SpaceShip's current jump drive charge.
--- Jumping depletes the ship's jump drive charge by a value equal to the distance jumped.
--- For example, a 5U jump depletes the charge by 5000.
--- A SpaceShip with a jump drive can jump only when this value is equal to or greater than the ship's maximum jump range.
--- Any numeric value is valid, including negative values (longer to recharge) and values larger than the ship's maximum jump range (can jump again with a shorter, or no, recharge required).
--- Jump drive charge regenerates at a rate modified by the "jumpdrive" system's effectiveness.
--- Example: ship:setJumpDriveCharge(50000)
function Entity:setJumpDriveCharge(charge)
    if self.components.jump_drive then self.components.jump_drive.charge = charge end
    return self
end
--- Returns this SpaceShip's current jump drive charge.
--- Example: jump_charge = ship:getJumpDriveCharge()
function Entity:getJumpDriveCharge()
    if self.components.jump_drive then return self.components.jump_drive.charge end
    return 0.0
end
--- Returns the time required by this SpaceShip to complete a jump once initiated.
--- A ship can't perform certain actions, such as docking, while its jump delay is not 0.
--- Returns a value between 0.0 (no delay, ready to jump) to 10.0.
--- With normal "jumpdrive" system effectiveness, this delay is 10 seconds.
--- System effectiveness can modify this delay.
--- Example: ship:getJumpDelay()
function Entity:getJumpDelay()
    if self.components.jump_drive then return self.components.jump_drive.delay end
    return 0.0

end
--- Returns whether this SpaceShip has a warp drive.
--- Example: ship:hasWarpDrive()
function Entity:hasWarpDrive()
    return self.components.warp_drive ~= nil
end
--- Defines whether this SpaceShip has a warp drive.
--- If true, this ship gains warp drive controls and a "warp" ship system.
--- Example: ship:setWarpDrive(true)
function Entity:setWarpDrive(enabled)
    if enabled then self.components.warp_drive = {} else self.components.warp_drive = nil end
    return self
end
--- Sets this SpaceShip's warp speed factor.
--- Valid values are any greater than 0. Ships don't tend to go faster than 24000 (1400U/min) due to engine limitations.
--- Unlike ShipTemplate:setWarpSpeed(), setting this value does NOT also grant this ship a warp drive.
--- Example: ship:setWarpSpeed(1000);
function Entity:setWarpSpeed(speed)
    if self.components.warp_drive then self.components.warp_drive.speed_per_level = speed end
    return self
end
--- Returns this SpaceShip's warp speed factor.
--- Actual warp speed can be modified by "warp" system effectiveness.
--- Example: ship:getWarpSpeed(()
function Entity:getWarpSpeed()
    if self.components.warp_drive then return self.components.warp_drive.speed_per_level end
    return 0.0
end
--- Returns the arc, in degrees, for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponArc(0); -- returns beam weapon 0's arc
function Entity:getBeamWeaponArc(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].arc end
    return 0.0
end
--- Returns the direction, in degrees relative to the ship's forward bearing, for the arc's center of the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponDirection(0); -- returns beam weapon 0's direction
function Entity:getBeamWeaponDirection(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].direction end
    return 0.0
end
--- Returns the range for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponRange(0); -- returns beam weapon 0's range
function Entity:getBeamWeaponRange(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].range end
    return 0.0
end
--- Returns the turret arc, in degrees, for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponTurretArc(0); -- returns beam weapon 0's turret arc
function Entity:getBeamWeaponTurretArc(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].turret_arc end
    return 0.0
end
--- Returns the direction, in degrees relative to the ship's forward bearing, for the turret arc's center for the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:getBeamWeaponTurretDirection(0); -- returns beam weapon 0's turret direction
function Entity:getBeamWeaponTurretDirection(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].turret_direction end
    return 0.0
end
function Entity:getBeamWeaponTurretRotationRate(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].turret_rotation_rate end
    return 0.0
end
--- Returns the base firing delay, in seconds, for the BeamWeapon with the given index on this SpaceShip.
--- Actual cycle time can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponCycleTime(0); -- returns beam weapon 0's cycle time
function Entity:getBeamWeaponCycleTime(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].cycle_time end
    return 0.0
end
--- Returns the base damage dealt by the BeamWeapon with the given index on this SpaceShip.
--- Actual damage can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponDamage(0); -- returns beam weapon 0's damage
function Entity:getBeamWeaponDamage(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].damage end
    return 0.0
end
--- Returns how much of this SpaceShip's energy is drained each time the BeamWeapon with the given index is fired.
--- Actual drain can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponEnergyPerFire(0); -- returns beam weapon 0's energy use per firing
function Entity:getBeamWeaponEnergyPerFire(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].energy_per_beam_fire end
    return 0.0
end
--- Returns the heat generated by each firing of the BeamWeapon with the given index on this SpaceShip.
--- Actual heat generation can be modified by "beamweapon" system effectiveness.
--- Example: ship:getBeamWeaponHeatPerFire(0); -- returns beam weapon 0's heat generation per firing
function Entity:getBeamWeaponHeatPerFire(index)
    if self.components.beam_weapons and #self.components.beam_weapons > index then return self.components.beam_weapons[index+1].heat_per_beam_fire end
    return 0.0
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
    if self.components.beam_weapons == nil then self.components.beam_weapons = {} end
    while #self.components.beam_weapons < index + 1 do
        self.components.beam_weapons[#self.components.beam_weapons + 1] = {}
    end
    self.components.beam_weapons[index + 1] = {arc=arc, direction=direction, range=range, cycle_time=cycle_time, damage=damage}
    return self
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
    if self.components.beam_weapons == nil or #self.components.beam_weapons <= index then return self end
    self.components.beam_weapons[index + 1].turret_arc = arc
    self.components.beam_weapons[index + 1].turret_direction = direction
    self.components.beam_weapons[index + 1].turret_rotation_rate = rotation_rate
    return self
end
--- Sets the BeamEffect texture, by filename, for the BeamWeapon with the given index on this SpaceShip.
--- See BeamEffect:setTexture().
--- Example: ship:setBeamWeaponTexture(0,"texture/beam_blue.png")
function Entity:setBeamWeaponTexture(index, texture)
    if self.components.beam_weapons == nil or #self.components.beam_weapons <= index then return self end
    self.components.beam_weapons[index + 1].texture = texture
    return self
end
--- Sets how much energy is drained each time the BeamWeapon with the given index is fired on this SpaceShip.
--- Only PlayerSpaceships consume energy. Setting this for other ShipTemplateBasedObject types has no effect.
--- Example: ship:setBeamWeaponEnergyPerFire(0,1) -- sets beam 0 to use 1 energy per firing
function Entity:setBeamWeaponEnergyPerFire(index, energy)
    if self.components.beam_weapons == nil or #self.components.beam_weapons <= index then return self end
    self.components.beam_weapons[index + 1].energy_per_beam_fire = energy
    return self
end
--- Sets how much "beamweapon" system heat is generated, in percentage of total system heat capacity, each time the BeamWeapon with the given index is fired on this SpaceShip.
--- Only PlayerSpaceships generate and manage heat. Setting this for other ShipTemplateBasedObject types has no effect.
--- Example: ship:setBeamWeaponHeatPerFire(0,0.02) -- sets beam 0 to generate 0.02 (2%) system heat per firing
function Entity:setBeamWeaponHeatPerFire(index, heat)
    if self.components.beam_weapons == nil or #self.components.beam_weapons <= index then return self end
    self.components.beam_weapons[index + 1].heat_per_beam_fire = heat
    return self
end
--- Sets the colors used to draw the radar arc for the BeamWeapon with the given index on this SpaceShip.
--- The first three-number value sets the RGB color for the arc when idle, and the second sets the color when firing.
--- Example: ship:setBeamWeaponArcColor(0,0,128,0,0,255,0) -- makes beam 0's arc green
function Entity:setBeamWeaponArcColor(index, idle_r, idle_g, idle_b, fire_r, fire_g, fire_b)
    if self.components.beam_weapons == nil or #self.components.beam_weapons <= index then return self end
    self.components.beam_weapons[index + 1].arc_color = {idle_r, idle_g, idle_b, 255}
    self.components.beam_weapons[index + 1].arc_color_fire = {fire_r, fire_g, fire_b, 255}
    return self
end
--- Sets the damage type dealt by the BeamWeapon with the given index on this SpaceShip.
--- Example: ship:setBeamWeaponDamageType(0,"emp") -- makes beam 0 deal EMP damage
function Entity:setBeamWeaponDamageType(index, damage_type)
    if self.components.beam_weapons == nil or #self.components.beam_weapons <= index then return self end
    self.components.beam_weapons[index + 1].damage_type = damage_type
    return self
end
--- Sets the number of WeaponTubes for this SpaceShip.
--- Weapon tubes are 0-indexed. For example, 3 tubes would be indexed 0, 1, and 2.
--- Example: ship:setWeaponTubeCount(4)
function Entity:setWeaponTubeCount(amount)
    if self.components.missile_tubes == nil then self.components.missile_tubes = {} end
    for n=1,amount do
        self.components.missile_tubes[n] = {}
    end
    while #self.components.missile_tubes > amount do
        self.components.missile_tubes[#self.components.missile_tubes] = nil
    end
    return self
end
--- Returns the number of WeaponTube on this SpaceShip.
--- Example: ship:getWeaponTubeCount()
function Entity:getWeaponTubeCount()
    if self.components.missile_tubes then return #self.components.missile_tubes end
    return 0
end
--- Returns the weapon type loaded into the WeaponTube with the given index on this SpaceShip.
--- Returns no value if no weapon is loaded, which includes the tube being in a loading or unloading state.
--- Example: ship:getWeaponTubeLoadType(0)
function Entity:getWeaponTubeLoadType(index)
    local tubes = self.components.missile_tubes
    local missile_type = "none"
    if  tubes and index >= 0 and index < #tubes then missile_type = tubes[index+1].type_loaded end
    if missile_type == "none" then return nil end
    return missile_type
end
--- Sets which weapon types the WeaponTube with the given index on this SpaceShip can load.
--- Note the spelling of "missle".
--- Example: ship:weaponTubeAllowMissle(0,"Homing") -- allows Homing missiles to be loaded in WeaponTube 0
function Entity:weaponTubeAllowMissle(index, weapon_type)
    local tubes = self.components.missile_tubes
    if tubes and index >= 0 and index < #tubes then tubes[index+1]["allow_"..string.lower(weapon_type)] = true end
    return self
end
--- Sets which weapon types the WeaponTube with the given index can't load on this SpaceShip.
--- Note the spelling of "missle".
--- Example: ship:weaponTubeDisallowMissle(0,"Homing") -- prevents Homing missiles from being loaded in tube 0
function Entity:weaponTubeDisallowMissle(index, weapon_type)
    local tubes = self.components.missile_tubes
    if tubes and index >= 0 and index < #tubes then tubes[index+1]["allow_"..string.lower(weapon_type)] = false end
    return self
end
--- Sets a weapon tube with the given index on this SpaceShip to allow loading only the given weapon type.
--- Example: ship:setWeaponTubeExclusiveFor(0,"Homing") -- allows only Homing missiles to be loaded in tube 0
function Entity:setWeaponTubeExclusiveFor(index, weapon_type)
    local tubes = self.components.missile_tubes
    if tubes and index >= 0 and index < #tubes then
        tubes[index+1]["allow_homing"] = false
        tubes[index+1]["allow_nuke"] = false
        tubes[index+1]["allow_mine"] = false
        tubes[index+1]["allow_emp"] = false
        tubes[index+1]["allow_hvli"] = false
        tubes[index+1]["allow_"..string.lower(weapon_type)] = true
    end
    return self
end
--- Sets the angle, relative to this SpaceShip's forward bearing, toward which the WeaponTube with the given index on this SpaceShip points.
--- Accepts 0, negative, and positive values.
--- Example:
--- -- Sets tube 0 to point 90 degrees right of forward, and tube 1 to point 90 degrees left of forward
--- ship:setWeaponTubeDirection(0,90):setWeaponTubeDirection(1,-90)
function Entity:setWeaponTubeDirection(index, direction)
    if self.components.missile_tubes then self.components.missile_tubes[index+1].direction = direction end
    return self
end
--- Sets the weapon size launched from the WeaponTube with the given index on this SpaceShip.
--- Example: ship:setTubeSize(0,"large") -- sets tube 0 to fire large weapons
function Entity:setTubeSize(index, size)
    if self.components.missile_tubes then self.components.missile_tubes[index+1].size = size end
    return self
end
--- Returns the size of the weapon tube with the given index on this SpaceShip.
--- Example: ship:getTubeSize(0)
function Entity:getTubeSize(index)
    if self.components.missile_tubes then return self.components.missile_tubes[index+1].size end
    return "medium"
end
--- Returns the delay, in seconds, for loading and unloading the WeaponTube with the given index on this SpaceShip.
--- Example: ship:getTubeLoadTime(0)
function Entity:getTubeLoadTime(index)
    if self.components.missile_tubes then return self.components.missile_tubes[index+1].load_time end
    return 0.0
end
--- Sets the time, in seconds, required to load the weapon tube with the given index on this SpaceShip.
--- Example: ship:setTubeLoadTime(0,12) -- sets the loading time for tube 0 to 12 seconds
function Entity:setTubeLoadTime(index, load_time)
    if self.components.missile_tubes then self.components.missile_tubes[index+1].load_time = load_time end
    return self
end
--- Returns the dynamic gravitational radar signature value emitted by this SpaceShip.
--- Ship functions can dynamically modify this SpaceShip's radar signature values.
--- Example: ship:getDynamicRadarSignatureGravity()
function Entity:getDynamicRadarSignatureGravity()
    if self.components.dynamic_radar_signature then return self.components.dynamic_radar_signature.gravity end
    return 0.0
end
--- Returns the dynamic electrical radar signature value emitted by this SpaceShip.
--- Ship functions can dynamically modify this SpaceShip's radar signature values.
--- Example: ship:getDynamicRadarSignatureElectrical()
function Entity:getDynamicRadarSignatureElectrical()
    if self.components.dynamic_radar_signature then return self.components.dynamic_radar_signature.electrical end
    return 0.0
end
--- Returns the dynamic biological radar signature value emitted by this SpaceShip.
--- Ship functions can dynamically modify this SpaceShip's radar signature values.
--- Example: ship:getDynamicRadarSignatureBiological()
function Entity:getDynamicRadarSignatureBiological()
    if self.components.dynamic_radar_signature then return self.components.dynamic_radar_signature.biological end
    return 0.0
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
    if target < 0 or target > 2 then target = 0 end

    local fullMessage = self:getCallSign() .. " : " .. message;

    for idx, ent in ipairs(getEntitiesWithComponent("ship_log")) do
        local add = false
        local color = {255, 204, 51, 255}

        if ent:isFriendly(self) then
            add = true
            color = {154, 255, 154, 255}

        elseif not ent:isEnemy(self) and target >= 1 then
            add = true
            color = {255, 102, 102, 255}

        elseif target >= 2 then
            add = true
            color = {128, 128, 128, 255}
        end

        if add then
            addEntryToShipsLog(ent, fullMessage, color)
        end
    end
    return self
end
--- Sets the scan state of this SpaceShip for every faction.
--- Example: ship:setScanState("fullscan") -- every faction treats this ship as fully scanned
function Entity:setScanState(state)
    local ss = self.components.scan_state
    if ss ~= nil then
        for name, faction in pairs(__faction_info) do
            self:setScanStateByFaction(name, state)
        end
    end
    return self
end
--- Sets the scan state of this SpaceShip for a given faction.
--- Example: ship:setScanStateByFaction("Kraylor","fullscan") -- Kraylor faction treats this ship as fully scanned
function Entity:setScanStateByFaction(faction, state)
    local ss = self.components.scan_state
    if ss ~= nil then
        local f = getFactionInfo(faction)
        if f ~= nil then
            for n=1,#ss do
                if ss[n].faction == f then
                    ss[n].state = state
                    return self
                end
            end
            ss[#ss+1] = {faction=f, state=state}
        end
    end
    return self
end

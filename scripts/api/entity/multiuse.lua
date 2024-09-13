local Entity = getLuaEntityFunctionTable()

-- Functions that have multiple implementations as a result of the old object code are here and interact with multiple components.


--- Sets this faction's internal string name, used to reference this faction regardless of EmptyEpsilon's language setting.
--- If no locale name is defined, this sets the locale name to the same value.
--- Example: faction:setName("USN")
--- Sets this ScienceDatabase entry's displayed name.
--- Example: entry:setName("Species")
function Entity:setName(name)
    if self.components.faction_info then
        self.components.faction_info.name = name
        __faction_info[name] = self
    end
    if self.components.science_database then
        self.components.science_database.name = name
    end
    return self
end

--- Sets this faction's longform description as shown in its Factions ScienceDatabase child entry.
--- Wrap the string in the _() function to make it available for translation.
--- Example: faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
--- As setDescriptions, but sets the same description for both unscanned and scanned states.
--- Example: obj:setDescription("A refitted Atlantis X23 for more ...")
function Entity:setDescription(description)
    if self.components.faction_info then
        self.components.faction_info.description = description
    else
        self.components.science_description = {not_scanned=description, friend_or_foe_identified=description, simple_scan=description, full_scan=description}
    end
    return self
end

--- Sets this SpaceShip's energy level.
--- Valid values are any greater than 0 and less than the energy capacity (getMaxEnergy()).
--- Invalid values are ignored.
--- CpuShips don't consume energy. Setting this value has no effect on their behavior or functionality.
--- For PlayerSpaceships, see PlayerSpaceship:setEnergyLevel().
--- Example: ship:setEnergy(1000) -- sets the ship's energy to 1000 if its capacity is 1000 or more
--- Sets the amount of energy recharged upon pickup when a PlayerSpaceship collides with this SupplyDrop.
--- Example: supply_drop:setEnergy(500)
function Entity:setEnergy(amount)
    if self.components.reactor then self.components.reactor.energy = amount end
    if self.components.pickup then self.components.pickup.give_energy = amount end
    return self
end

--- Returns this SpaceShip's weapons target.
--- For a CpuShip, this can differ from its orders target.
--- Example: target = ship:getTarget()
--- Returns this ScanProbe's target coordinates.
--- Example: targetX,targetY = probe:getTarget()
function Entity:getTarget()
    if self.components.weapons_target then
        return self.components.weapons_target.entity
    end
    if self.components.move_to then
        local target = self.components.move_to.target
        return target[1], target[2]
    end
    return nil
end

--- Returns this ScanProbe's owner SpaceObject.
--- Example: probe:getOwner()
function Entity:getOwner()
    if self.components.delayed_explode_on_touch then
        return self.components.delayed_explode_on_touch.owner
    end
    if self.components.allow_radar_link then
        return self.components.allow_radar_link.owner
    end
    return self
end

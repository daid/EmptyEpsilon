local Entity = getLuaEntityFunctionTable()

----- Template-based entity functions -----

--- These functions apply to entities created from a ShipTemplate, such as those created by CpuShip(), PlayerSpaceship(), and SpaceStation().
--- Use setTemplate() to apply a ShipTemplate's properties to an entity.

--- Sets this ShipTemplate that defines this entity's traits, and then applies them to this entity.
--- ShipTemplates define the entity's class, weapons, hull and shield strength, 3D appearance, and more.
--- See the ShipTemplate class for details, and files in scripts/shiptemplates/ for the default templates.
--- ShipTemplate string names are case-sensitive.
--- Examples:
--- CpuShip():setTemplate("Phobos T3")
--- PlayerSpaceship():setTemplate("Phobos M3P")
--- SpaceStation():setTemplate("Large Station")
function Entity:setTemplate(template_name)
    local template = __ship_templates[template_name]
    local comp = self.components
    if template == nil then
        error("Failed to find template: " .. tostring(template_name), 2)
    end
    -- print("Setting template:" .. template_name)
    for key, value in next, template, nil do
        if string.sub(key, 1, 2) ~= "__" then
            comp[key] = value
        end
    end
    if template.__type == "station" then
        comp.physics.type = "static"
    elseif template.__type == "playership" then
        if comp.shields then comp.shields.active = false end
    end

    if comp.reactor then
        local reactor_power_factor = 0
        if comp.beam_weapons then comp.beam_weapons.power_factor = 3.0; reactor_power_factor = reactor_power_factor - 3.0 end
        if comp.missile_tubes then comp.missile_tubes.power_factor = 1.0; reactor_power_factor = reactor_power_factor - 1.0 end
        if comp.maneuvering_thrusters then comp.maneuvering_thrusters.power_factor = 2.0; reactor_power_factor = reactor_power_factor - 2.0 end
        if comp.impulse_engine then comp.impulse_engine.power_factor = 4.0; reactor_power_factor = reactor_power_factor - 4.0 end
        if comp.warp_drive then comp.warp_drive.power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0 end
        if comp.jump_drive then comp.jump_drive.power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0 end
        if comp.shields then
            comp.shields.front_power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0
            comp.shields.rear_power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0
        end
        comp.reactor.power_factor = reactor_power_factor
    end
    if comp.internal_rooms and template.__repair_crew_count and template.__repair_crew_count > 0 then
        for n=1,template.__repair_crew_count do
            local crew = createEntity()
            crew.components.internal_crew = {ship=self}
            crew.components.internal_repair_crew = {}
        end
    end
    if comp.shields and template.__type ~= "station" then
        comp.shields.frequency = irandom(0, 20)
    end
    if comp.internal_rooms == nil then -- No internal rooms, so auto-repair
        if comp.beam_weapons then comp.beam_weapons.auto_repair_per_second = 0.005; end
        if comp.missile_tubes then comp.missile_tubes.auto_repair_per_second = 0.005 end
        if comp.maneuvering_thrusters then comp.maneuvering_thrusters.auto_repair_per_second = 0.005 end
        if comp.impulse_engine then comp.impulse_engine.auto_repair_per_second = 0.005 end
        if comp.warp_drive then comp.warp_drive.auto_repair_per_second = 0.005 end
        if comp.jump_drive then comp.jump_drive.auto_repair_per_second = 0.005 end
        if comp.shields then
            comp.shields.front_auto_repair_per_second = 0.005
            comp.shields.rear_auto_repair_per_second = 0.005
        end
        if comp.reactor then comp.reactor.auto_repair_per_second = 0.005 end
    end
    return self
end
--- [DEPRECATED]
--- Use setTemplate().
function Entity:setShipTemplate(template_name)
    print("Called DEPRECATED setShipTemplate function")
    return self:setTemplate(template_name)
end
--- Sets this entity's vessel classification name, such as "Starfighter" or "Cruiser".
--- This overrides the vessel class name provided by the ShipTemplate.
--- Example: stbo:setTypeName("Prototype")
function Entity:setTypeName(type_name)
    self.components.typename = {type_name=type_name, localized=type_name}
    return self
end
--- Returns this entity's vessel classification name.
--- Example:
--- stbo:setTypeName("Prototype")
--- stbo:getTypeName() -- returns "Prototype"
function Entity:getTypeName()
    return self.components.typename.type_name
end
--- Returns this entity's hull points.
--- Example: stbo:getHull()
function Entity:getHull()
    if self.components.hull then return self.components.hull.current end
    return 0
end
--- Returns this entity's maximum limit of hull points.
--- Example: stbo:getHullMax()
function Entity:getHullMax()
    if self.components.hull then return self.components.hull.max end
    return 0
end
--- Sets this entity's hull points.
--- If set to a value larger than the maximum, this sets the value to the limit.
--- If set to a value less than 0, this sets the value to 0.
--- Note that setting this value to 0 doesn't immediately destroy the entity.
--- Example: stbo:setHull(100) -- sets the hull point limit to either 100, or the limit if less than 100
function Entity:setHull(amount)
    if self.components.hull then self.components.hull.current = amount end
    return self
end
--- Sets this entity's maximum limit of hull points.
--- Note that stations can't repair their own hull, so this only changes the percentage of remaining hull.
--- Example: stbo:setHullMax(100) -- sets the hull point limit to 100
function Entity:setHullMax(amount)
    if self.components.hull then self.components.hull.max = amount end
    return self
end
--- Defines whether this entity can be destroyed by damage.
--- Defaults to true.
--- Example: stbo:setCanBeDestroyed(false) -- prevents the entity from being destroyed by damage
function Entity:setCanBeDestroyed(allow_destroy)
    if self.components.hull then self.components.hull.allow_destruction = allow_destroy end
    return self    
end
--- Returns whether the entity can be destroyed by damage.
--- Example: stbo:getCanBeDestroyed()
function Entity:getCanBeDestroyed()
    if self.components.hull then return self.components.hull.allow_destruction end
    return false
end
--- Returns the shield points for this entity's shield segment with the given index.
--- Shield segments are 0-indexed.
--- Example for a ship with two shield segments:
--- stbo:getShieldLevel(0) -- returns front shield points
--- stbo:getShieldLevel(1) -- returns rear shield points
function Entity:getShieldLevel(index)
    if self.components.shields and index < #self.components.shields then
        return self.components.shields[index+1].level
    end
    return 0
end
--- Returns this entity's number of shield segments.
--- Each segment divides the 360-degree shield arc equally for each segment, up to a maximum of 8 segments.
--- The segments' order starts with the front-facing segment, then proceeds clockwise.
--- Example: stbo:getShieldCount()
function Entity:getShieldCount()
    if self.components.shields then return #self.components.shields end
    return 0
end
--- Returns the maximum shield points for the entity's shield segment with the given index.
--- Example: stbo:getShieldMax(0) -- returns the max shield strength for segment 0
function Entity:getShieldMax(index)
    if self.components.shields and index < #self.components.shields then
        return self.components.shields[index+1].max
    end
    return 0
end
--- Sets this entity's shield points.
--- Each number provided as a parameter sets the points for a corresponding shield segment.
--- Note that the segments' order starts with the front-facing segment, then proceeds clockwise.
--- If more parameters are provided than the ship has shield segments, the excess parameters are discarded.
--- Example:
--- -- On a ship with 4 segments, this sets the forward shield segment to 50, right to 40, rear 30, left 20
--- -- On a ship with 2 segments, this sets forward 50, rear 40
--- stbo:setShields(50,40,30,20)
function Entity:setShields(...)
    if self.components.shields then
        for i, level in ipairs({...}) do
            if i <= #self.components.shields then
                self.components.shields[i].level = level
            end
        end
    end
    return self
end
--- Sets this entity's maximum shield points per segment, and can also create new segments.
--- The number of parameters defines the entity's number of shield segments, to a maximum of 8 segments.
--- The segments' order starts with the front-facing segment, then proceeds clockwise.
--- If more parameters are provided than the entity has shield segments, the excess parameters create new segments with the current shield points set to the defined max.
--- An entity with one shield segment has only a front shield generator system, and an entity with two or more segments has only front and rear generator systems.
--- Increasing the maximum value to a higher value than the current points does NOT automatically increase the current points,
--- which requires a separate call to setShields().
--- Example:
--- -- On a ship with 4 segments, this sets the forward shield max to 50, right to 40, rear 30, left 20
--- -- On a ship with 2 segments, this does the same, but its current rear shield points become right shield points, and the new rear and left shield segments have 0 points
--- stbo:setShieldsMax(50,40,30,20)
function Entity:setShieldsMax(...)
    if self.components.shields then
        for i, max in ipairs({...}) do
            if self.components.shields[i] then
                self.components.shields[i].max = max
            else
                self.components.shields[i] = {max=max, level=max}
            end
        end
        while select('#', ...) < #self.components.shields do
            self.components.shields[#self.components.shields] = nil
        end
    end
    return self
end
--- Sets the radar trace image for this entity.
--- Valid values are filenames of PNG images relative to the resources/radar directory.
--- Radar trace images should be white with a transparent background.
--- Only scanned ships use a specific radar trace image. Unscanned ships always display as an arrow.
--- Example: stbo:setRadarTrace("arrow.png") -- sets the radar trace to resources/radar/arrow.png
--- Example: ship:setRadarTrace("blip.png") -- displays a dot for this ship on radar when scanned
function Entity:setRadarTrace(filename)
    if self.components.radar_trace then
        self.components.radar_trace.icon = "radar/" .. filename
    end
end

--- Sets this entity's impulse engine sound effect.
--- Valid values are filenames of WAV files relative to the resources/ directory.
--- Use a looping sound file that tolerates being pitched up and down as the ship's impulse speed changes.
--- Example: stbo:setImpulseSoundFile("sfx/engine_fighter.wav") -- sets the impulse sound to resources/sfx/engine_fighter.wav
function Entity:setImpulseSoundFile(filename)
    if self.components.impulse_engine then self.components.impulse_engine.sound = filename end
    return self
end
--- Returns whether this entity's shields are activated.
--- Always returns true except for player ships, because only players can deactivate shields.
--- Example: stbo:getShieldsActive() -- returns true if up, false if down
function Entity:getShieldsActive()
    if self.components.shields then return self.components.shields.active end
    return false
end
--- Returns whether this entity supplies energy to docked player ships.
--- Example: stbo:getSharesEnergyWithDocked()
function Entity:getSharesEnergyWithDocked()
    if self.components.docking_bay then return self.components.docking_bay.share_energy end
    return false
end
--- Defines whether this entity supplies energy to docked player ships.
--- Example: stbo:setSharesEnergyWithDocked(false)
function Entity:setSharesEnergyWithDocked(allow_energy_share)
    if self.components.docking_bay then self.components.docking_bay.share_energy = allow_energy_share end
    return self
end
--- Returns whether this entity repairs docked ships.
--- Example: stbo:getRepairDocked()
function Entity:getRepairDocked()
    if self.components.docking_bay then return self.components.docking_bay.repair end
    return false
end
--- Defines whether this entity repairs docked ships.
--- Example: stbo:setRepairDocked(true)
function Entity:setRepairDocked(allow_repair)
    if self.components.docking_bay then self.components.docking_bay.repair = allow_repair end
    return self
end
--- Returns whether the entity restocks scan probes for docked player ships.
--- Example: stbo:getRestocksScanProbes()
function Entity:getRestocksScanProbes()
    if self.components.docking_bay then return self.components.docking_bay.restock_probes end
    return false
end
--- Defines whether the entity restocks scan probes for docked player ships.
--- Example: stbo:setRestocksScanProbes(true)
function Entity:setRestocksScanProbes(allow_restock)
    if self.components.docking_bay then self.components.docking_bay.restock_probes = allow_restock end
    return self
end
--- Returns whether this entity restocks missiles for docked CPU ships.
--- Example: stbo:getRestocksMissilesDocked()
function Entity:getRestocksMissilesDocked()
    if self.components.docking_bay then return self.components.docking_bay.restock_missiles end
    return false
end
--- Defines whether this entity restocks missiles for docked CPU ships.
--- To restock docked player ships' weapons, use a comms script. See setCommsScript() and :setCommsFunction().
--- Example: stbo:setRestocksMissilesDocked(true)
function Entity:setRestocksMissilesDocked(allow_restock)
    if self.components.docking_bay then self.components.docking_bay.restock_missiles = allow_restock end
    return self
end
--- [DEPRECATED]
--- Use getShieldLevel() with an index value.
function Entity:getFrontShield()
    return self.getShieldLevel(0)
end
--- [DEPRECATED]
--- Use getShieldMax() with an index value.
function Entity:getFrontShieldMax()
    return self.getShieldMax(0)
end
--- [DEPRECATED]
--- Use setShields() with an index value.
function Entity:setFrontShield(amount)
    if self.components.shields then self.components.shields[1].level = amount end
    return self
end
--- [DEPRECATED]
--- Use setShieldsMax() with the appropriate number of arguments.
function Entity:setFrontShieldMax(amount)
    if self.components.shields then self.components.shields[1].max = amount end
    return self
end
--- [DEPRECATED]
--- Use getShieldLevel() with an index value.
function Entity:getRearShield()
    return self.getShieldLevel(1)
end
--- [DEPRECATED]
--- Use getShieldMax() with an index value.
function Entity:getRearShieldMax()
    return self.getShieldMax(1)
end
--- [DEPRECATED]
--- Use setShields() with an index value.
function Entity:setRearShield(amount)
    if self.components.shields then self.components.shields[2].level = amount end
    return self
end
--- [DEPRECATED]
--- Use setShieldsMax() with the appropriate number of arguments.
function Entity:setRearShieldMax(amount)
    if self.components.shields then self.components.shields[2].max = amount end
    return self
end
--- Defines a function to call when this entity takes damage.
--- Passes the object taking damage and the instigator entity (or nil) to the function.
--- Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was damaged by " .. instigator:getCallSign()) end)
function Entity:onTakingDamage(callback)
    if self.components.hull then self.components.hull.on_taking_damage = callback end
    return self
end
--- Defines a function to call when this entity is destroyed by taking damage.
--- Passes the object taking damage and the instigator entity that delivered the destroying damage (or nil) to the function.
--- Example: stbo:onDestruction(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was destroyed by " .. instigator:getCallSign()) end)
function Entity:onDestruction(callback)
    if self.components.hull then self.components.hull.on_destruction = callback end
    return self
end

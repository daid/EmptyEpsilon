local Entity = getLuaEntityFunctionTable()

----- Old ShipTemplateBasedObject API -----

--- A ShipTemplateBasedObject (STBO) is an object class created from a ShipTemplate.
--- This is the parent class of SpaceShip (CpuShip, PlayerSpaceship) and SpaceStation objects, which inherit all STBO functions and can be created by scripts.
--- Objects of this class can't be created by scripts, but SpaceStation and child classes of SpaceShip can.

--- Sets this ShipTemplate that defines this STBO's traits, and then applies them to this STBO.
--- ShipTemplates define the STBO's class, weapons, hull and shield strength, 3D appearance, and more.
--- See the ShipTemplate class for details, and files in scripts/shiptemplates/ for the default templates.
--- ShipTemplate string names are case-sensitive.
--- Examples:
--- CpuShip():setTemplate("Phobos T3")
--- PlayerSpaceship():setTemplate("Phobos M3P")
--- SpaceStation():setTemplate("Large Station")
function Entity:setTemplate(template_name)
    local template = __ship_templates[template_name]
    if template == nil then
        return error("Failed to find template: " .. template_name)
    end
    -- print("Setting template:" .. template_name)
    for key, value in next, template, nil do
        if string.sub(key, 1, 2) ~= "__" then
            self[key] = value
        end
    end
    if template.__type == "station" then
        self.physics.type = "static"
    elseif template.__type == "playership" then
        if self.shields then self.shields.active = false end
    end

    if self.reactor then
        local reactor_power_factor = 0
        if self.beam_weapons then self.beam_weapons.power_factor = 3.0; reactor_power_factor = reactor_power_factor - 3.0 end
        if self.missile_tubes then self.missile_tubes.power_factor = 1.0; reactor_power_factor = reactor_power_factor - 1.0 end
        if self.maneuvering_thrusters then self.maneuvering_thrusters.power_factor = 2.0; reactor_power_factor = reactor_power_factor - 2.0 end
        if self.impulse_engine then self.impulse_engine.power_factor = 4.0; reactor_power_factor = reactor_power_factor - 4.0 end
        if self.warp_drive then self.warp_drive.power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0 end
        if self.jump_drive then self.jump_drive.power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0 end
        if self.shields then
            self.shields.front_power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0
            self.shields.rear_power_factor = 5.0; reactor_power_factor = reactor_power_factor - 5.0
        end
        self.reactor.power_factor = reactor_power_factor
    end
    return self
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setTemplate().
function Entity:setShipTemplate(template_name)
    print("Called DEPRECATED setShipTemplate function")
    return self:setTemplate(template_name)
end
--- Sets this STBO's vessel classification name, such as "Starfighter" or "Cruiser".
--- This overrides the vessel class name provided by the ShipTemplate.
--- Example: stbo:setTypeName("Prototype")
function Entity:setTypeName(type_name)
    e.typename = {type_name=type_name}
end
--- Returns this STBO's vessel classification name.
--- Example:
--- stbo:setTypeName("Prototype")
--- stbo:getTypeName() -- returns "Prototype"
function Entity:getTypeName()
    return e.typename.type_name
end
--- Returns this STBO's hull points.
--- Example: stbo:getHull()
function Entity:getHull()
    if self.hull then return self.hull.current end
    return 0
end
--- Returns this STBO's maximum limit of hull points.
--- Example: stbo:getHullMax()
function Entity:getHullMax()
    if self.hull then return self.hull.max end
    return 0
end
--- Sets this STBO's hull points.
--- If set to a value larger than the maximum, this sets the value to the limit.
--- If set to a value less than 0, this sets the value to 0.
--- Note that setting this value to 0 doesn't immediately destroy the STBO.
--- Example: stbo:setHull(100) -- sets the hull point limit to either 100, or the limit if less than 100
function Entity:setHull(amount)
    if self.hull then self.hull.current = amount end
    return self
end
--- Sets this STBO's maximum limit of hull points.
--- Note that SpaceStations can't repair their own hull, so this only changes the percentage of remaining hull.
--- Example: stbo:setHullMax(100) -- sets the hull point limit to 100
function Entity:setHullMax(amount)
    if self.hull then self.hull.max = amount end
    return self
end
--- Defines whether this STBO can be destroyed by damage.
--- Defaults to true.
--- Example: stbo:setCanBeDestroyed(false) -- prevents the STBO from being destroyed by damage
function Entity:setCanBeDestroyed(allow_destroy)
    if self.hull then self.hull.allow_destruction = allow_destroy end
    return self    
end
--- Returns whether the STBO can be destroyed by damage.
--- Example: stbo:getCanBeDestroyed()
function Entity:getCanBeDestroyed()
    if self.hull then return self.hull.allow_destruction end
    return false
end
--- Returns the shield points for this STBO's shield segment with the given index.
--- Shield segments are 0-indexed.
--- Example for a ship with two shield segments:
--- stbo:getShieldLevel(0) -- returns front shield points
--- stbo:getShieldLevel(1) -- returns rear shield points
function Entity:getShieldLevel(index)
    --TODO
end
--- Returns this STBO's number of shield segments.
--- Each segment divides the 360-degree shield arc equally for each segment, up to a maximum of 8 segments.
--- The segments' order starts with the front-facing segment, then proceeds clockwise.
--- Example: stbo:getShieldCount()
function Entity:getShieldCount()
    if self.shields then return #self.shields end
    return 0
end
--- Returns the maximum shield points for the STBO's shield segment with the given index.
--- Example: stbo:getShieldMax(0) -- returns the max shield strength for segment 0
function Entity:getShieldMax(index)
    --TODO
end
--- Sets this STBO's shield points.
--- Each number provided as a parameter sets the points for a corresponding shield segment.
--- Note that the segments' order starts with the front-facing segment, then proceeds clockwise.
--- If more parameters are provided than the ship has shield segments, the excess parameters are discarded.
--- Example:
--- -- On a ship with 4 segments, this sets the forward shield segment to 50, right to 40, rear 30, left 20
--- -- On a ship with 2 segments, this sets forward 50, rear 40
--- stbo:setShields(50,40,30,20)
function Entity:setShields(...)
    --TODO
end
--- Sets this STBO's maximum shield points per segment, and can also create new segments.
--- The number of parameters defines the STBO's number of shield segments, to a maximum of 8 segments.
--- The segments' order starts with the front-facing segment, then proceeds clockwise.
--- If more parameters are provided than the STBO has shield segments, the excess parameters create new segments with the defined max but 0 current shield points.
--- A STBO with one shield segment has only a front shield generator system, and a STBO with two or more segments has only front and rear generator systems.
--- Setting a lower maximum points value than the segment's current number of points also reduces the points to the limit.
--- However, increasing the maximum value to a higher value than the current points does NOT automatically increase the current points,
--- which requires a separate call to ShipTemplateBasedObject:setShield().
--- Example:
--- -- On a ship with 4 segments, this sets the forward shield max to 50, right to 40, rear 30, left 20
--- -- On a ship with 2 segments, this does the same, but its current rear shield points become right shield points, and the new rear and left shield segments have 0 points
--- stbo:setShieldsMax(50,40,30,20)
function Entity:setShieldsMax(...)
    --TODO
end
--- Sets this STBO's trace image.
--- Valid values are filenames of PNG images relative to the resources/radar directory.
--- Radar trace images should be white with a transparent background.
--- Example: stbo:setRadarTrace("arrow.png") -- sets the radar trace to resources/radar/arrow.png
function Entity:setRadarTrace(filename)
    --TODO
end
--- Sets this STBO's impulse engine sound effect.
--- Valid values are filenames of WAV files relative to the resources/ directory.
--- Use a looping sound file that tolerates being pitched up and down as the ship's impulse speed changes.
--- Example: stbo:setImpulseSoundFile("sfx/engine_fighter.wav") -- sets the impulse sound to resources/sfx/engine_fighter.wav
function Entity:setImpulseSoundFile(filename)
    --TODO
end
--- Defines whether this STBO's shields are activated.
--- Always returns true except for PlayerSpaceships, because only players can deactivate shields.
--- Example stbo:getShieldsActive() -- returns true if up, false if down
function Entity:getShieldsActive()
    --TODO
end
--- Returns whether this STBO supplies energy to docked PlayerSpaceships.
--- Example: stbo:getSharesEnergyWithDocked()
function Entity:getSharesEnergyWithDocked()
    --TODO
end
--- Defines whether this STBO supplies energy to docked PlayerSpaceships.
--- Example: stbo:getSharesEnergyWithDocked(false)
function Entity:setSharesEnergyWithDocked(allow_energy_share)
    --TODO
end
--- Returns whether this STBO repairs docked SpaceShips.
--- Example: stbo:getRepairDocked()
function Entity:getRepairDocked()
    --TODO
end
--- Defines whether this STBO repairs docked SpaceShips.
--- Example: stbo:setRepairDocked(true)
function Entity:setRepairDocked(allow_repair)
    --TODO
end
--- Returns whether the STBO restocks scan probes for docked PlayerSpaceships.
--- Example: stbo:getRestocksScanProbes()
function Entity:getRestocksScanProbes()
    --TODO
end
--- Defines whether the STBO restocks scan probes for docked PlayerSpaceships.
--- Example: stbo:setRestocksScanProbes(true)
function Entity:setRestocksScanProbes(allow_restock)
    --TODO
end
--- Returns whether this STBO restocks missiles for docked CpuShips.
--- Example: stbo:getRestocksMissilesDocked()
function Entity:getRestocksMissilesDocked()
    --TODO
end
--- Defines whether this STBO restocks missiles for docked CpuShips.
--- To restock docked PlayerSpaceships' weapons, use a comms script. See ShipTemplateBasedObject:setCommsScript() and :setCommsFunction().
--- Example: stbo:setRestocksMissilesDocked(true)
function Entity:setRestocksMissilesDocked(allow_restock)
    --TODO
end
--- Returns this STBO's long-range radar range.
--- Example: stbo:getLongRangeRadarRange()
function Entity:getLongRangeRadarRange()
    --TODO
end
--- Sets this STBO's long-range radar range.
--- PlayerSpaceships use this range on the science and operations screens' radar.
--- AI orders of CpuShips use this range to detect potential targets.
--- Example: stbo:setLongRangeRadarRange(20000) -- sets the long-range radar range to 20U
function Entity:setLongRangeRadarRange(range)
    --TODO
end
--- Returns this STBO's short-range radar range.
function Entity:getShortRangeRadarRange()
    --TODO
end
--- Sets this STBO's short-range radar range.
--- PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
--- AI orders of CpuShips use this range to decide when to disengage pursuit of fleeing targets.
--- This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
--- Example: stbo:setShortRangeRadarRange(4000) -- sets the short-range radar range to 4U
function Entity:setShortRangeRadarRange(range)
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:getShieldLevel() with an index value.
function Entity:getFrontShield()
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setShieldsMax().
function Entity:getFrontShieldMax()
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setShieldLevel() with an index value.
function Entity:setFrontShield(amount)
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setShieldsMax().
function Entity:setFrontShieldMax(amount)
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:getShieldLevel() with an index value.
function Entity:getRearShield()
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setShieldsMax().
function Entity:getRearShieldMax()
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setShieldLevel() with an index value.
function Entity:setRearShield(amount)
    --TODO
end
--- [DEPRECATED]
--- Use ShipTemplateBasedObject:setShieldsMax().
function Entity:setRearShieldMax(amount)
    --TODO
end
--- Defines a function to call when this STBO takes damage.
--- Passes the object taking damage and the instigator SpaceObject (or nil) to the function.
--- Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was damaged by " .. instigator:getCallSign()) end)
function Entity:onTakingDamage(callback)
    --TODO
end
--- Defines a function to call when this STBO is destroyed by taking damage.
--- Passes the object taking damage and the instigator SpaceObject that delivered the destroying damage (or nil) to the function.
--- Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was destroyed by " .. instigator:getCallSign()) end)
function Entity:onDestruction(callback)
    --TODO
end

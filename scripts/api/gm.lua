function getSpawnableGMObjects()
    local result = {}
    result[#result+1] = {function() return Artifact() end, _("create", "Artifact"), _("create", "Various")}
    result[#result+1] = {function() return WarpJammer() end, _("create", "Warp Jammer"), _("create", "Various")}
    result[#result+1] = {function() return Mine() end, _("create", "Mine"), _("create", "Various")}
    result[#result+1] = {function() return SupplyDrop():setEnergy(500):setWeaponStorage('Nuke', 1):setWeaponStorage('Homing', 4):setWeaponStorage('Mine', 2):setWeaponStorage('EMP', 1) end, _("create", "Supply Drop"), _("create", "Various")}
    result[#result+1] = {function() return Asteroid() end, _("create", "Asteroid"), _("create", "Various")}
    result[#result+1] = {function() return VisualAsteroid() end, _("create", "Visual Asteroid"), _("create", "Various")}
    result[#result+1] = {function() return Planet() end, _("create", "Planet"), _("create", "Various")}
    result[#result+1] = {function() return BlackHole() end, _("create", "BlackHole"), _("create", "Various")}
    result[#result+1] = {function() return Nebula() end, _("create", "Nebula"), _("create", "Various")}
    result[#result+1] = {function() return WormHole() end, _("create", "Worm Hole"), _("create", "Various")}

    for k, v in pairs(__ship_templates) do
        if not v.__hidden then
            if v.__type == "playership" then
                result[#result+1] = {__spawnPlayerShipFunc(v.typename.type_name), v.typename.localized, _("create", "player ship"), v.__description}
            elseif v.__type == "station" then
                result[#result+1] = {__spawnStationFunc(v.typename.type_name), v.typename.localized, _("create", "station"), v.__description}
            else
                result[#result+1] = {__spawnCpuShipFunc(v.typename.type_name), v.typename.localized, _("create", "cpu ship"), v.__description}
            end
        end
    end

    return result
end

function __spawnStationFunc(key)
    return function() return SpaceStation():setTemplate(key):setRotation(random(0, 360)) end
end
function __spawnCpuShipFunc(key)
    return function() return CpuShip():setTemplate(key):setRotation(random(0, 360)):orderRoaming() end
end

function getEntityExportString(entity)
    if entity.components.player_control and entity.components.typename then
        -- Likely a player ship
        for k, v in pairs(__ship_templates) do
            if v.__type == "playership" and v.typename.type_name == entity.components.typename.type_name then
                return "PlayerSpaceship():setTemplate('" .. k .. "')" .. __exportShipChanges(entity, v)
            end
        end
    end
    if entity.components.ai_controller and entity.components.typename then
        -- Likely a CPU ship
        for k, v in pairs(__ship_templates) do
            if (v.__type == "ship" or v.__type == nil) and v.typename.type_name == entity.components.typename.type_name then
                return "CpuShip():setTemplate('" .. k .. "')" .. __exportShipChanges(entity, v)
            end
        end
    end
    if entity.components.typename and entity.components.physics and entity.components.physics.type == "static" then
        -- Likely a station
        for k, v in pairs(__ship_templates) do
            if v.__type == "station" and v.typename.type_name == entity.components.typename.type_name then
                return "SpaceStation():setTemplate('" .. k .. "')" .. __exportShipChanges(entity, v)
            end
        end
    end
    if entity.components.explode_on_touch and entity.components.physics and entity.components.physics.type == "sensor" then
        -- Likely an asteroid
        return "Asteroid()" .. __exportBasics(entity)
    end
    if entity.components.delayed_explode_on_touch and entity.components.physics and entity.components.physics.type == "sensor" then
        -- Likely an Mine
        return "Mine()" .. __exportBasics(entity)
    end
    if entity.components.radar_block and entity.components.nebula_renderer then
        -- Likely an Nebula
        return "Nebula()" .. __exportBasics(entity)
    end
    return ""
end

function __exportBasics(entity)
    local x, y = entity:getPosition()
    local extras = string.format(":setPosition(%.0f, %.0f)", x, y)
    local rotation = entity:getRotation()
    if rotation ~= 0 then
        extras = extras .. string.format(":setRotation(%.0f)", rotation)
    end
    local faction = entity:getFaction()
    if faction ~= nil and faction ~= "" then
        extras = extras .. ":setFaction('" .. faction .. "')"
    end
    return extras
end

function __exportShipChanges(entity, v)
    local extras = __exportBasics(entity)
    return extras
end
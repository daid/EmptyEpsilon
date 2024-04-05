function getSpawnableGMObjects()
    local result = {}
    result[#result+1] = {function() return Artifact() end, _("create", "Artifact"), _("create", "Various")}
    result[#result+1] = {function() return WarpJammer() end, _("create", "Warp Jammer"), _("create", "Various")}
    result[#result+1] = {function() return Mine() end, _("create", "Mine"), _("create", "Various")}
    result[#result+1] = {function() return SupplyDrop():setEnergy(500):setWeaponStorage('Nuke', 1):setWeaponStorage('Homing', 4):setWeaponStorage('Mine', 2):setWeaponStorage('EMP', 1) end, _("create", "Supply Drop"), _("create", "Various")}
    result[#result+1] = {function() return Asteroid() end, _("create", "Mine"), _("create", "Various")}
    result[#result+1] = {function() return Asteroid() end, _("create", "Asteroid"), _("create", "Various")}
    result[#result+1] = {function() return VisualAsteroid() end, _("create", "Visual Asteroid"), _("create", "Various")}
    result[#result+1] = {function() return Planet() end, _("create", "Planet"), _("create", "Various")}
    result[#result+1] = {function() return BlackHole() end, _("create", "BlackHole"), _("create", "Various")}
    result[#result+1] = {function() return Nebula() end, _("create", "Nebula"), _("create", "Various")}
    result[#result+1] = {function() return WormHole() end, _("create", "Worm Hole"), _("create", "Various")}

    for i, v in ipairs(__ship_templates) do
        if not v.__hidden then
            if self.__type == "playership" then
                result[#result+1] = {__spawnPlayerShipFunc(v.typename.type_name), v.typename.localized, _("create", "player ship")}
            elseif self.__type == "station" then
                result[#result+1] = {__spawnStationFunc(v.typename.type_name), v.typename.localized, _("create", "station")}
            else
                result[#result+1] = {__spawnCpuShipFunc(v.typename.type_name), v.typename.localized, _("create", "cpu ship")}
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

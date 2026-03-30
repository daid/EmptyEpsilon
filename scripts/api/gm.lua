function getSpawnableGMObjects()
    local result = {}
    result[#result+1] = {function() return Artifact() end, _("create", "Artifact"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return WarpJammer() end, _("create", "Warp jammer"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return Mine() end, _("create", "Mine"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return SupplyDrop():setEnergy(500):setWeaponStorage('Nuke', 1):setWeaponStorage('Homing', 4):setWeaponStorage('Mine', 2):setWeaponStorage('EMP', 1) end, _("create", "Supply drop"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return ScanProbe() end, _("create", "Scan probe"), _("create", "Various"), "", "radar/probe.png"}
    result[#result+1] = {function() return Asteroid() end, _("create", "Asteroid"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return VisualAsteroid() end, _("create", "Visual asteroid"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return Planet() end, _("create", "Planet"), _("create", "Various"), "", "radar/blip.png"}
    result[#result+1] = {function() return BlackHole() end, _("create", "Black hole"), _("create", "Various"), "", "radar/blackHole.png"}
    result[#result+1] = {function() return Nebula() end, _("create", "Nebula"), _("create", "Various"), "", "Nebula1.png"}
    result[#result+1] = {function() return WormHole() end, _("create", "Worm hole"), _("create", "Various"), "", "radar/wormHole.png"}

    for k, v in pairs(__ship_templates) do
        if not v.__hidden then
            if v.__type == "playership" then
                result[#result+1] = {__spawnPlayerShipFunc(v.typename.type_name), v.typename.localized, _("create", "Player ship"), v.__description, v.radar_trace.icon}
            elseif v.__type == "station" then
                result[#result+1] = {__spawnStationFunc(v.typename.type_name), v.typename.localized, _("create", "Station"), v.__description, v.radar_trace.icon}
            else
                result[#result+1] = {__spawnCpuShipFunc(v.typename.type_name), v.typename.localized, _("create", "CPU ship"), v.__description, v.radar_trace.icon}
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
    if entity.components.explosion_effect or entity.components.beam_effect then
        return ""
    end
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
    -- Terrain: Asteroid has spin, avoid_object, and explode_on_touch
    if entity.components.spin and entity.components.avoid_object and entity.components.explode_on_touch then
        return "Asteroid()" .. __exportBasics(entity)
    end
    -- Terrain: VisualAsteroid has spin and mesh_render but no physics or avoid_object
    if entity.components.spin and entity.components.mesh_render and not entity.components.physics and not entity.components.avoid_object then
        return "VisualAsteroid()" .. __exportBasics(entity)
    end
    -- Mine has delayed_explode_on_touch and constant_particle_emitter
    if entity.components.delayed_explode_on_touch and entity.components.constant_particle_emitter then
        return "Mine()" .. __exportBasics(entity)
    end
    -- Nebula has nebula_renderer
    if entity.components.nebula_renderer then
        return "Nebula()" .. __exportBasics(entity)
    end
    -- Planet has planet_render
    if entity.components.planet_render then
        return "Planet()" .. __exportPlanet(entity)
    end
    -- BlackHole has gravity with damage=true and billboard_render
    if entity.components.gravity and entity.components.billboard_render and entity.components.gravity.damage then
        return "BlackHole()" .. __exportBasics(entity)
    end
    -- WormHole has gravity with damage=false and a non-zero wormhole_target
    if entity.components.gravity and entity.components.billboard_render and not entity.components.gravity.damage then
        local wt = entity.components.gravity.wormhole_target
        if wt and (wt[1] ~= 0 or wt[2] ~= 0) then
            return "WormHole()" .. __exportWormHole(entity)
        end
    end
    -- SupplyDrop has pickup with at least one supply > 0
    if entity.components.pickup then
        local p = entity.components.pickup
        if (p.give_energy and p.give_energy > 0)
            or (p.give_homing and p.give_homing > 0)
            or (p.give_nuke and p.give_nuke > 0)
            or (p.give_mine and p.give_mine > 0)
            or (p.give_emp and p.give_emp > 0)
            or (p.give_hvli and p.give_hvli > 0)
        then
            return "SupplyDrop()" .. __exportSupplyDrop(entity)
        end
    end
    -- Artifact has mesh_render with an "mesh/Artifact" mesh
    if entity.components.mesh_render and entity.components.mesh_render.mesh
        and string.sub(entity.components.mesh_render.mesh, 1, 13) == "mesh/Artifact"
    then
        return "Artifact()" .. __exportArtifact(entity)
    end
    -- WarpJammer has warp_jammer
    if entity.components.warp_jammer then
        return "WarpJammer()" .. __exportWarpJammer(entity)
    end
    -- ScanProbe has allow_radar_link
    if entity.components.allow_radar_link then
        return "ScanProbe()" .. __exportScanProbe(entity)
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
    if entity.components.callsign then
        extras = extras .. ":setCallSign('" .. entity.components.callsign.callsign .. "')"
    end
    local ss = entity.components.scan_state
    if ss then
        local complexity = ss.complexity or 0
        local depth = ss.depth or 0
        if complexity ~= -1 or depth ~= -1 then
            extras = extras .. string.format(":setScanningParameters(%d, %d)", complexity, depth)
        end
        local states = {}
        local first_state = nil
        local all_same = true
        for n = 1, #ss do
            local entry = ss[n]
            if entry.faction and entry.faction.components and entry.faction.components.faction_info then
                local name = entry.faction.components.faction_info.name
                local state = entry.state
                states[#states+1] = {name=name, state=state}
                if first_state == nil then
                    first_state = state
                elseif state ~= first_state then
                    all_same = false
                end
            end
        end
        if #states > 0 then
            if all_same and first_state ~= "none" then
                extras = extras .. ":setScanState('" .. first_state .. "')"
            elseif not all_same then
                for _, entry in ipairs(states) do
                    if entry.state ~= "none" then
                        extras = extras .. ":setScanStateByFaction('" .. entry.name .. "', '" .. entry.state .. "')"
                    end
                end
            end
        end
    end
    return extras
end

function __exportShipChanges(entity, template)
    local extras = __exportBasics(entity)

    -- Hull: export max if changed from template, current if damaged, allow_destruction if changed
    local hull = entity.components.hull
    local t_hull = template.hull
    if hull then
        if t_hull and hull.max ~= t_hull.max then
            extras = extras .. string.format(":setHullMax(%.0f)", hull.max)
        end
        if hull.current ~= hull.max then
            extras = extras .. string.format(":setHull(%.0f)", hull.current)
        end
        if hull.allow_destruction == false then
            extras = extras .. ":setCanBeDestroyed(false)"
        end
    end

    -- Shields: export max per segment if changed from template, current level if depleted
    local shields = entity.components.shields
    local t_shields = template.shields
    if shields and t_shields then
        local any_max_diff = false
        for i = 1, #shields do
            if not t_shields[i] or shields[i].max ~= t_shields[i].max then
                any_max_diff = true
                break
            end
        end
        if any_max_diff then
            local maxes = {}
            for i = 1, #shields do
                maxes[i] = string.format("%.0f", shields[i].max)
            end
            extras = extras .. ":setShieldsMax(" .. table.concat(maxes, ", ") .. ")"
        end
        local any_level_diff = false
        for i = 1, #shields do
            if shields[i].level ~= shields[i].max then
                any_level_diff = true
                break
            end
        end
        if any_level_diff then
            local levels = {}
            for i = 1, #shields do
                levels[i] = string.format("%.0f", shields[i].level)
            end
            extras = extras .. ":setShields(" .. table.concat(levels, ", ") .. ")"
        end
    end

    -- Missile tubes: export changed max capacities first, then depleted stocks
    local mt = entity.components.missile_tubes
    local t_mt = template.missile_tubes
    if mt and t_mt then
        local weapon_types = {
            {"Homing", "max_homing",  "storage_homing"},
            {"Nuke",   "max_nuke",    "storage_nuke"},
            {"Mine",   "max_mine",    "storage_mine"},
            {"EMP",    "max_emp",     "storage_emp"},
            {"HVLI",   "max_hvli",    "storage_hvli"},
        }
        for _, wt in ipairs(weapon_types) do
            local name, max_key, storage_key = wt[1], wt[2], wt[3]
            local t_max = t_mt[max_key] or 0
            local e_max = mt[max_key] or 0
            local e_storage = mt[storage_key] or 0
            if e_max ~= t_max then
                extras = extras .. string.format(":setWeaponStorageMax('%s', %d)", name, e_max)
            end
            if e_storage ~= e_max then
                extras = extras .. string.format(":setWeaponStorage('%s', %d)", name, e_storage)
            end
        end
    end

    return extras
end

function __exportPlanet(entity)
    local extras = __exportBasics(entity)
    local pr = entity.components.planet_render
    if pr then
        if pr.size then
            extras = extras .. string.format(":setPlanetRadius(%.0f)", pr.size)
        end
        if pr.texture then
            extras = extras .. ":setPlanetSurfaceTexture('" .. pr.texture .. "')"
        end
        if pr.atmosphere_texture then
            extras = extras .. ":setPlanetAtmosphereTexture('" .. pr.atmosphere_texture .. "')"
        end
        if pr.atmosphere_color then
            extras = extras .. string.format(":setPlanetAtmosphereColor(%.2f, %.2f, %.2f)", pr.atmosphere_color[1], pr.atmosphere_color[2], pr.atmosphere_color[3])
        end
        if pr.cloud_texture then
            extras = extras .. ":setPlanetCloudTexture('" .. pr.cloud_texture .. "')"
        end
        if pr.cloud_size and pr.size and math.abs(pr.cloud_size - pr.size * 1.05) > 1 then
            extras = extras .. string.format(":setPlanetCloudRadius(%.0f)", pr.cloud_size)
        end
        if pr.distance_from_movement_plane and pr.distance_from_movement_plane ~= 0 then
            extras = extras .. string.format(":setDistanceFromMovementPlane(%.0f)", pr.distance_from_movement_plane)
        end
    end
    if entity.components.spin then
        local rate = entity.components.spin.rate
        if rate and rate ~= 0 then
            extras = extras .. string.format(":setAxialRotationTime(%.2f)", 360.0 / rate)
        end
    end
    return extras
end

function __exportWormHole(entity)
    local extras = __exportBasics(entity)
    local g = entity.components.gravity
    if g and g.wormhole_target then
        local tx, ty = g.wormhole_target[1], g.wormhole_target[2]
        if tx ~= 0 or ty ~= 0 then
            extras = extras .. string.format(":setTargetPosition(%.0f, %.0f)", tx, ty)
        end
    end
    return extras
end

function __exportArtifact(entity)
    local extras = __exportBasics(entity)
    if entity.components.spin then
        local rate = entity.components.spin.rate
        if rate and rate ~= 0 then
            extras = extras .. string.format(":setSpin(%.2f)", rate)
        end
    end
    return extras
end

function __exportSupplyDrop(entity)
    local extras = __exportBasics(entity)
    local p = entity.components.pickup
    if p then
        if p.give_energy and p.give_energy > 0 then
            extras = extras .. string.format(":setEnergy(%.0f)", p.give_energy)
        end
        if p.give_homing and p.give_homing > 0 then
            extras = extras .. string.format(":setWeaponStorage('Homing', %d)", p.give_homing)
        end
        if p.give_nuke and p.give_nuke > 0 then
            extras = extras .. string.format(":setWeaponStorage('Nuke', %d)", p.give_nuke)
        end
        if p.give_mine and p.give_mine > 0 then
            extras = extras .. string.format(":setWeaponStorage('Mine', %d)", p.give_mine)
        end
        if p.give_emp and p.give_emp > 0 then
            extras = extras .. string.format(":setWeaponStorage('EMP', %d)", p.give_emp)
        end
        if p.give_hvli and p.give_hvli > 0 then
            extras = extras .. string.format(":setWeaponStorage('HVLI', %d)", p.give_hvli)
        end
    end
    return extras
end

function __exportWarpJammer(entity)
    local extras = __exportBasics(entity)
    local wj = entity.components.warp_jammer
    if wj and wj.range then
        extras = extras .. string.format(":setRange(%.0f)", wj.range)
    end
    return extras
end

function __exportScanProbe(entity)
    local extras = __exportBasics(entity)
    local lt = entity.components.lifetime
    if lt and lt.lifetime then
        extras = extras .. string.format(":setLifetime(%.0f)", lt.lifetime)
    end
    local mt = entity.components.move_to
    if mt and mt.speed then
        extras = extras .. string.format(":setSpeed(%.0f)", mt.speed)
    end
    return extras
end

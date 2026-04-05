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
                return "PlayerSpaceship():setTemplate('" .. k .. "')" .. __exportShipChanges(entity, v, "full")
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
    -- Zone has zone component
    if entity.components.zone then
        return "Zone()" .. __exportZone(entity)
    end

    -- No matching API function
    return ""
end

-- default_scan_state: the scan state the entity type has by default (before any explicit setScanState call).
-- PlayerSpaceship() initialises all factions to "fullscan"; everything else defaults to "none".
function __exportBasics(entity, default_scan_state)
    default_scan_state = default_scan_state or "none"
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
        local cs = entity.components.callsign.callsign:gsub("\\", "\\\\"):gsub("'", "\\'")
        extras = extras .. ":setCallSign('" .. cs .. "')"
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
            if all_same and first_state ~= default_scan_state then
                extras = extras .. ":setScanState('" .. first_state .. "')"
            elseif not all_same then
                for _, entry in ipairs(states) do
                    if entry.state ~= default_scan_state then
                        extras = extras .. ":setScanStateByFaction('" .. entry.name .. "', '" .. entry.state .. "')"
                    end
                end
            end
        end
    end
    return extras
end

function __exportShipChanges(entity, template, default_scan_state)
    local extras = __exportBasics(entity, default_scan_state)

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

    -- Impulse engine
    local ie = entity.components.impulse_engine
    local t_ie = template.impulse_engine
    if ie then
        if not t_ie or ie.max_speed_forward ~= t_ie.max_speed_forward or ie.max_speed_reverse ~= t_ie.max_speed_reverse then
            if ie.max_speed_forward == ie.max_speed_reverse then
                extras = extras .. string.format(":setImpulseMaxSpeed(%.1f)", ie.max_speed_forward)
            else
                extras = extras .. string.format(":setImpulseMaxSpeed(%.1f, %.1f)", ie.max_speed_forward, ie.max_speed_reverse)
            end
        end
        if not t_ie or ie.acceleration_forward ~= t_ie.acceleration_forward or ie.acceleration_reverse ~= t_ie.acceleration_reverse then
            if ie.acceleration_forward == ie.acceleration_reverse then
                extras = extras .. string.format(":setAcceleration(%.1f)", ie.acceleration_forward)
            else
                extras = extras .. string.format(":setAcceleration(%.1f, %.1f)", ie.acceleration_forward, ie.acceleration_reverse)
            end
        end
        if ie.sound and ie.sound ~= "" and (not t_ie or ie.sound ~= t_ie.sound) then
            extras = extras .. ":setImpulseSoundFile('" .. ie.sound .. "')"
        end
    end

    -- Maneuvering thrusters
    local man_thrusters = entity.components.maneuvering_thrusters
    local t_man_thrusters = template.maneuvering_thrusters
    if man_thrusters and (not t_man_thrusters or man_thrusters.speed ~= t_man_thrusters.speed) then
        extras = extras .. string.format(":setRotationMaxSpeed(%.1f)", man_thrusters.speed)
    end

    -- Combat maneuvering thrusters
    local cmt = entity.components.combat_maneuvering_thrusters
    local t_cmt = template.combat_maneuvering_thrusters
    if cmt and (not t_cmt or cmt.boost_speed ~= t_cmt.boost_speed or cmt.strafe_speed ~= t_cmt.strafe_speed) then
        extras = extras .. string.format(":setCombatManeuver(%.0f, %.0f)", cmt.boost_speed, cmt.strafe_speed)
    end

    -- Warp drive (C++ default speed_per_level=1000; setWarpDrive(true) without setWarpSpeed leaves it nil in template)
    local wd = entity.components.warp_drive
    local t_wd = template.warp_drive
    if wd then
        if not t_wd then
            extras = extras .. ":setWarpDrive(true)"
        end
        local t_warp_speed = (t_wd and t_wd.speed_per_level) or 1000
        if wd.speed_per_level ~= t_warp_speed then
            extras = extras .. string.format(":setWarpSpeed(%.0f)", wd.speed_per_level)
        end
    end

    -- Jump drive (C++ defaults min=5000, max=50000; setJumpDrive(true) without setJumpDriveRange leaves them nil)
    local jd = entity.components.jump_drive
    local t_jd = template.jump_drive
    if jd then
        if not t_jd then
            extras = extras .. ":setJumpDrive(true)"
        end
        local t_jd_min = (t_jd and t_jd.min_distance) or 5000
        local t_jd_max = (t_jd and t_jd.max_distance) or 50000
        if jd.min_distance ~= t_jd_min or jd.max_distance ~= t_jd_max then
            extras = extras .. string.format(":setJumpDriveRange(%.0f, %.0f)", jd.min_distance, jd.max_distance)
        end
    end

    -- Beam weapons (0-based index for setters, 1-based for ECS component array)
    local bw = entity.components.beam_weapons
    local t_bw = template.beam_weapons
    if bw then
        for i = 1, #bw do
            local b = bw[i]
            local tb = t_bw and t_bw[i]
            local idx = i - 1
            if not tb or b.arc ~= tb.arc or b.direction ~= tb.direction or b.range ~= tb.range
                or b.cycle_time ~= tb.cycle_time or b.damage ~= tb.damage
            then
                extras = extras .. string.format(":setBeamWeapon(%d, %.1f, %.1f, %.0f, %.1f, %.1f)",
                    idx, b.arc, b.direction, b.range, b.cycle_time, b.damage)
            end
            if b.turret_arc and b.turret_arc ~= 0 then
                if not tb or b.turret_arc ~= tb.turret_arc or b.turret_direction ~= tb.turret_direction
                    or b.turret_rotation_rate ~= tb.turret_rotation_rate
                then
                    extras = extras .. string.format(":setBeamWeaponTurret(%d, %.1f, %.1f, %.1f)",
                        idx, b.turret_arc, b.turret_direction, b.turret_rotation_rate)
                end
            end
            -- For properties not stored in the Lua template, fall back to C++ struct defaults
            local tb_texture = (tb and tb.texture) or "texture/beam_orange.png"
            if b.texture and b.texture ~= "" and b.texture ~= tb_texture then
                extras = extras .. string.format(":setBeamWeaponTexture(%d, '%s')", idx, b.texture)
            end
            local tb_energy = (tb and tb.energy_per_beam_fire) or 3.0
            if b.energy_per_beam_fire and b.energy_per_beam_fire ~= tb_energy then
                extras = extras .. string.format(":setBeamWeaponEnergyPerFire(%d, %.2f)", idx, b.energy_per_beam_fire)
            end
            local tb_heat = (tb and tb.heat_per_beam_fire) or 0.02
            if b.heat_per_beam_fire and math.abs(b.heat_per_beam_fire - tb_heat) > 1e-5 then
                extras = extras .. string.format(":setBeamWeaponHeatPerFire(%d, %.3f)", idx, b.heat_per_beam_fire)
            end
            -- arc_color is u8vec4 {r,g,b,a} (0-255); setBeamWeaponArcColor takes floats 0-1.
            -- ShipTemplate has no setBeamWeaponArcColor, so compare against C++ defaults:
            -- arc_color default={255,0,0,128}, arc_color_fire default={255,255,0,128}
            local ac = b.arc_color
            local acf = b.arc_color_fire
            if ac and (ac[1] ~= 255 or ac[2] ~= 0 or ac[3] ~= 0
                or (acf and (acf[1] ~= 255 or acf[2] ~= 255 or acf[3] ~= 0)))
            then
                local fr = acf and acf[1] / 255.0 or 1.0
                local fg = acf and acf[2] / 255.0 or 1.0
                local fb = acf and acf[3] / 255.0 or 0.0
                extras = extras .. string.format(":setBeamWeaponArcColor(%d, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f)",
                    idx, ac[1] / 255.0, ac[2] / 255.0, ac[3] / 255.0, fr, fg, fb)
            end
            if b.damage_type and b.damage_type ~= "energy" and (not tb or b.damage_type ~= tb.damage_type) then
                extras = extras .. string.format(":setBeamWeaponDamageType(%d, '%s')", idx, b.damage_type)
            end
        end
    end

    -- Docking bay: DockingBay uses a bitfield (default flags=0), so unset template fields are nil
    -- while entity fields are false. Normalise both to boolean with == true before comparing.
    local db = entity.components.docking_bay
    local t_db = template.docking_bay
    if db then
        local e_share   = db.share_energy == true
        local e_repair  = db.repair == true
        local e_probes  = db.restock_probes == true
        local e_missiles = db.restock_missiles == true
        local t_share   = t_db and t_db.share_energy == true
        local t_repair  = t_db and t_db.repair == true
        local t_probes  = t_db and t_db.restock_probes == true
        local t_missiles = t_db and t_db.restock_missiles == true
        if e_share ~= t_share then
            extras = extras .. ":setSharesEnergyWithDocked(" .. tostring(e_share) .. ")"
        end
        if e_repair ~= t_repair then
            extras = extras .. ":setRepairDocked(" .. tostring(e_repair) .. ")"
        end
        if e_probes ~= t_probes then
            extras = extras .. ":setRestocksScanProbes(" .. tostring(e_probes) .. ")"
        end
        if e_missiles ~= t_missiles then
            extras = extras .. ":setRestocksMissilesDocked(" .. tostring(e_missiles) .. ")"
        end
    end

    -- Repair crew: only export if we found actual crew entities and the count differs from template.
    -- internal_crew entities are not always instantiated, so a count of 0 is not reliable.
    local crew_count = __countShipCrew(entity)
    local template_crew_count = template.__repair_crew_count or 0
    if crew_count > 0 and crew_count ~= template_crew_count then
        extras = extras .. string.format(":setRepairCrewCount(%d)", crew_count)
    end

    -- AI controller (CPU ships only): export AI name and non-entity-targeted orders
    local ai = entity.components.ai_controller
    local t_ai = template.ai_controller
    if ai then
        if ai.new_name and ai.new_name ~= "" and ai.new_name ~= "default" and ai.new_name ~= t_ai.new_name then
            extras = extras .. ":setAI('" .. ai.new_name .. "')"
        end
        local orders = ai.orders
        local loc = ai.order_target_location
        if orders == "idle" then
            extras = extras .. ":orderIdle()"
        elseif orders == "roaming" then
            if loc and (loc[1] ~= 0 or loc[2] ~= 0) then
                extras = extras .. string.format(":orderRoamingAt(%.0f, %.0f)", loc[1], loc[2])
            else
                extras = extras .. ":orderRoaming()"
            end
        elseif orders == "stand_ground" then
            extras = extras .. ":orderStandGround()"
        elseif orders == "defend_location" and loc then
            extras = extras .. string.format(":orderDefendLocation(%.0f, %.0f)", loc[1], loc[2])
        elseif orders == "fly_towards" and loc then
            extras = extras .. string.format(":orderFlyTowards(%.0f, %.0f)", loc[1], loc[2])
        elseif orders == "fly_towards_blind" and loc then
            extras = extras .. string.format(":orderFlyTowardsBlind(%.0f, %.0f)", loc[1], loc[2])
        -- entity-targeted orders (defend_target, attack, dock, fly_formation) cannot be serialized
        end
    end

    return extras
end

-- Returns the number of internal repair crew belonging to `entity`.
function __countShipCrew(entity)
    local n = 0
    for _, crew in ipairs(getEntitiesWithComponent("internal_crew")) do
        if crew.components.internal_crew and crew.components.internal_crew.ship == entity then
            n = n + 1
        end
    end
    return n
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

function __exportZone(entity)
    local extras = ""
    local z = entity.components.zone
    if not z then return extras end
    -- Color: C++ default is {255,255,255,0} (white); setColor takes integers 0-255
    if z.color and (z.color[1] ~= 255 or z.color[2] ~= 255 or z.color[3] ~= 255) then
        extras = extras .. string.format(":setColor(%d, %d, %d)", z.color[1], z.color[2], z.color[3])
    end
    -- Label
    if z.label and z.label ~= "" then
        extras = extras .. ":setLabel('" .. z.label .. "')"
    end
    -- Local skybox
    if z.skybox and z.skybox ~= "" then
        local fade = z.skybox_fade_distance or 0
        if fade ~= 0 then
            extras = extras .. string.format(":setLocalSkybox('%s', %.0f)", z.skybox, fade)
        else
            extras = extras .. ":setLocalSkybox('" .. z.skybox .. "')"
        end
    end
    -- Outline points: z.points is {{x1,y1},{x2,y2},...}; setPoints takes a flat coord list
    if z.points and #z.points > 0 then
        local coords = {}
        for _, pt in ipairs(z.points) do
            coords[#coords+1] = string.format("%.0f", pt[1])
            coords[#coords+1] = string.format("%.0f", pt[2])
        end
        extras = extras .. ":setPoints(" .. table.concat(coords, ", ") .. ")"
    end
    return extras
end

-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Development

--- Scenario
-- @script scenario_10_empty

function init()
	ECS = false
	if createEntity then
		ECS = true
	end
    --SpaceStation():setPosition(1000, 1000):setTemplate('Small Station'):setFaction("Human Navy"):setRotation(random(0, 360))
    --SpaceStation():setPosition(-1000, 1000):setTemplate('Medium Station'):setFaction("Human Navy"):setRotation(random(0, 360))
    --SpaceStation():setPosition(1000, -1000):setTemplate('Large Station'):setFaction("Human Navy"):setRotation(random(0, 360))
    --SpaceStation():setPosition(-1000, -1000):setTemplate('Huge Station'):setFaction("Human Navy"):setRotation(random(0, 360))
    --player1 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setRotation(200)
    --player2 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setRotation(0)
    --Nebula():setPosition(-5000, 0)
    --Artifact():setPosition(1000, 9000):setModel("small_frigate_1"):setDescription(_("scienceDescription-artifact", "An old space derelict."))
    --Artifact():setPosition(9000, 2000):setModel("small_frigate_1"):setDescription(_("scienceDescription-artifact", "A wrecked ship."))
    --Artifact():setPosition(3000, 4000):setModel("small_frigate_1"):setDescription(_("scienceDescription-artifact", "Tons of rotting plasteel."))
    --addGMFunction(_("buttonGM", "move 1 to 2"), function() player1:transferPlayersToShip(player2) end)
    --addGMFunction(_("buttonGM", "move 2 to 1"), function() player2:transferPlayersToShip(player1) end)
    --CpuShip():setTemplate("Adder MK5"):setPosition(0, 0):setRotation(0):setFaction("Human Navy")
    --CpuShip():setTemplate("Piranha F12"):setPosition(2000, 0):setRotation(-90):setFaction("Kraylor")
    local planet1 = Planet():setPosition(5000, 5000):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 1.0)
    local moon1 = Planet():setPosition(5000, 0):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/moon-1.png"):setAxialRotationTime(20.0)
    local sun1 = Planet():setPosition(5000, 15000):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0, 1.0, 1.0)
    planet1:setOrbit(sun1, 40)
    moon1:setOrbit(planet1, 20.0)

    addGMFunction(
        _("buttonGM", "Random asteroid field"),
        function()
            cleanup()
            for n = 1, 1000 do
                Asteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
                VisualAsteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
            end
        end
    )
    addGMFunction(
        _("buttonGM", "Random nebula field"),
        function()
            cleanup()
            for n = 1, 50 do
                Nebula():setPosition(random(-50000, 50000), random(-50000, 50000))
            end
        end
    )
    addGMFunction(
        _("buttonGM", "Delete unselected"),
        function()
            local gm_selection = getGMSelection()
            for idx, obj in ipairs(getAllObjects()) do
                local found = false
                for idx2, obj2 in ipairs(gm_selection) do
                    if obj == obj2 then
                        found = true
                    end
                end
                if not found then
                    obj:destroy()
                end
            end
        end
    )
end
function isObjectType(obj,typ,qualifier)
	if obj ~= nil and obj:isValid() then
		if typ ~= nil then
			if ECS then
				if typ == "SpaceStation" then
					return obj.components.docking_bay and obj.components.physics and obj.components.physics.type == "static"
				elseif typ == "PlayerSpaceship" then
					return obj.components.player_control
				elseif typ == "ScanProbe" then
					return obj.components.allow_radar_link
				elseif typ == "CpuShip" then
					return obj.ai_controller
				elseif typ == "Asteroid" then
					return obj.components.mesh_render and string.sub(obj.components.mesh_render.mesh, 7) == "Astroid"
				elseif typ == "Nebula" then
					return obj.components.nebula_renderer
				elseif typ == "Planet" then
					return obj.components.planet_render
				elseif typ == "SupplyDrop" then
					return obj.components.pickup and obj.components.radar_trace.icon == "radar/blip.png" and obj.components.radar_trace.color_by_faction
				elseif typ == "BlackHole" then
					return obj.components.gravity and obj.components.billboard_render.texture == "blackHole3d.png"
				elseif typ == "WarpJammer" then
					return obj.components.warp_jammer
				elseif typ == "Mine" then
					return obj.components.delayed_explode_on_touch and obj.components.constant_particle_emitter
				elseif typ == "EMPMissile" then
					return obj.components.radar_trace.icon == "radar/missile.png" and obj.components.explode_on_touch.damage_type == "emp"
				elseif typ == "Nuke" then
					return obj.components.radar_trace.icon == "radar/missile.png" and obj.components.explosion_sfx == "sfx/nuke_explosion.wav"
				elseif typ == "Zone" then
					return obj.components.zone
				else
					if qualifier == "MovingMissile" then
						if typ == "HomingMissile" or typ == "HVLI" or typ == "Nuke" or typ == "EMPMissile" then
							return obj.components.radar_trace.icon == "radar/missile.png"
						else
							return false
						end
					elseif qualifier == "SplashMissile" then
						if typ == "Nuke" or typ == "EMPMissile" then
							if obj.components.radar_trace.icon == "radar/missile.png" then
								if typ == "Nuke" then
									return obj.components.explosion_sfx == "sfx/nuke_explosion.wav"
								else	--EMP
									return obj.components.explode_on_touch.damage_type == "emp"
								end
							else
								return false
							end
						else
							return false
						end
					else
						return false
					end
				end
			else
				return obj.typeName == typ
			end
		else
			return false
		end
	else
		return false
	end
end
function cleanup()
    -- Clean up the current play field. Find all objects and destroy everything that is not a player.
    -- If it is a player, position him in the center of the scenario.
    for idx, obj in ipairs(getAllObjects()) do
        if isObjectType(obj,"PlayerSpaceship") then
            obj:setPosition(random(-100, 100), random(-100, 100))
        else
            obj:destroy()
        end
    end
end

function update(delta)
    -- No victory condition
end

-- Set callback function
onNewPlayerShip(
    function(ship)
        -- Decide what you do with new ships:
        if ECS then
        	print(ship, ship:getTypeName(), ship:getCallSign())
        else
	        print(ship, ship.typeName, ship:getTypeName(), ship:getCallSign())
	    end
        -- ship:destroy()
    end
)

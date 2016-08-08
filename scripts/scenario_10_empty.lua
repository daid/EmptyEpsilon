-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Basic

function init()
	--SpaceStation():setPosition(1000, 1000):setTemplate('Small Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--SpaceStation():setPosition(-1000, 1000):setTemplate('Medium Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--SpaceStation():setPosition(1000, -1000):setTemplate('Large Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--SpaceStation():setPosition(-1000, -1000):setTemplate('Huge Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--player1 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setRotation(200)
    --player2 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setRotation(0)
	--Nebula():setPosition(-5000, 0)
    --Artifact():setPosition(1000, 9000):setModel("small_frigate_1"):setDescription("An old space derelict.")
    --Artifact():setPosition(9000, 2000):setModel("small_frigate_1"):setDescription("A wrecked ship.")
    --Artifact():setPosition(3000, 4000):setModel("small_frigate_1"):setDescription("Tons of rotting plasteel.")
    --addGMFunction("move 1 to 2", function() player1:transferPlayersToShip(player2) end)
    --addGMFunction("move 2 to 1", function() player2:transferPlayersToShip(player1) end)
    --CpuShip():setTemplate("Adder MK5"):setPosition(0, 0):setRotation(0):setFaction("Human Navy")
    --CpuShip():setTemplate("Piranha F12"):setPosition(2000, 0):setRotation(-90):setFaction("Kraylor")
    Planet():setPosition(5000, 5000):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
    Planet():setPosition(5000, 0):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/moon-1.png")
    Planet():setPosition(5000, 10000):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)
    
    addGMFunction("Random asteroid field", function()
        cleanup()
        for n=1,1000 do
			Asteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
			VisualAsteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
        end
    end)
    addGMFunction("Random nebula field", function()
        cleanup()
        for n=1,50 do
			Nebula():setPosition(random(-50000, 50000), random(-50000, 50000))
        end
    end)
    addGMFunction("Delete unselected", function()
        local gm_selection = getGMSelection()
        for _, obj in ipairs(getAllObjects()) do
            local found = false
            for _, obj2 in ipairs(gm_selection) do
                if obj == obj2 then
                    found = true
                end
            end
            if not found then
                obj:destroy()
            end
        end
    end)
end

function cleanup()
    --Clean up the current play field. Find all objects and destroy everything that is not a player.
    -- If it is a player, position him in the center of the scenario.
    for _, obj in ipairs(getAllObjects()) do
        if obj.typeName == "PlayerSpaceship" then
            obj:setPosition(random(-100, 100), random(-100, 100))
        else
            obj:destroy()
        end
    end
end

function update(delta)
	--No victory condition
end

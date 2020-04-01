-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Basic

function init()
	SpaceStation():setPosition(0, 1000):setTemplate("Small Station"):setFaction("Human Navy"):setRotation(random(0, 360))
	SpaceStation():setPosition(-1000, 0):setTemplate('Medium Station'):setFaction("Human Navy"):setRotation(random(0, 360))
    SpaceStation():setPosition(0, -1000):setTemplate('Large Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	SpaceStation():setPosition(1000, 0):setTemplate('Huge Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	player1 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")

    CpuShip():setTemplate("Adder MK5"):setPosition(0, 0):setRotation(0):setFaction("Human Navy")
    CpuShip():setTemplate("Piranha F12"):setPosition(2000, 0):setRotation(-90):setFaction("Kraylor")

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

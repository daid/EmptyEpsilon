-- Name: Empty space
-- Description: Empty scenario with no ships or terrain. Game masters can use this to set up a scenario in the GM screen. Use the F5 key or "Copy scenario" and "Copy selection" buttons on the GM screen to copy Lua code of the layout to the clipboard for use in scenario scripts.
-- Type: Development

--- Scenario
-- @script scenario_10_empty

-- Add functions from utils.lua, particularly isObjectType()
require("utils.lua")

function init()
    -- Check if EE is running the ECS branch (true) or the legacy branch false.
    ECS = createEntity ~= nil

    --[[
    Several example entities follow. Remove the comments from these examples, or copy and paste them onto new lines, to add them to the scenario.

    For more a detailed scripting reference, see the script_reference.html file included with your EmptyEpsilon install. For a tutorial, see https://daid.github.io/EmptyEpsilon/#tabs=4.
    ]]--

    -- Example entities:

    --[[ Create a small Human Navy space station at coordinates 1000, 10000 with a random rotation:

    SpaceStation()
        :setPosition(2000, 2000)
        :setTemplate("Small Station")
        :setFaction("Human Navy")
        :setRotation(random(0, 360))
    ]]--
    --SpaceStation():setPosition(-2000, 2000):setTemplate("Medium Station"):setFaction("Human Navy"):setRotation(random(0, 360))
    --SpaceStation():setPosition(2000, -2000):setTemplate("Large Station"):setFaction("Human Navy"):setRotation(random(0, 360))
    --SpaceStation():setPosition(-2000, -2000):setTemplate("Huge Station"):setFaction("Human Navy"):setRotation(random(0, 360))

    --[[ Create a player Atlantis ship of the Human Navy faction. Place it at coordinates 100, 100 with a heading of 270 (facing west). Set its callsign to "Player 1". Assign it to the Lua variable player1.

    player1 = PlayerSpaceship()
        :setTemplate("Atlantis")
        :setFaction("Human Navy")
        :setPosition(-250, 100)
        :setHeading(270)
        :setCallSign(_("Player 1"))
    ]]--
    --player2 = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(250, 100):setHeading(0):setCallSign(_("Player 2"))

    --[[ Create an AI-controlled Adder MK5 ship of the Human Navy faction. Place it at coordinates 0, 0 with a heading of 90 (facing east). Set its callsign to "Friendly 1" and its orders to "Defend location" at coordinates 0, 0. Assign it to the Lua variable defender.

    defender = CpuShip()
        :setTemplate("Adder MK5")
        :setFaction("Human Navy")
        :setPosition(0, -100)
        :setHeading(90)
        :setCallSign(_("Friendly 1"))
    defender:orderDefendLocation(0, 0)
    ]]--
    --CpuShip():setTemplate("Piranha F12"):setFaction("Kraylor"):setPosition(10000, 0):setHeading(270):setCallSign(_("Hostile 1")):orderFlyTowards(0, 0)

    --[[ Create a wormhole that teleports entities that enter its center to coordinates within 0.1U^2 of 0, 0.

    WormHole()
        :setTargetPosition(random(-100, 100), random(-100, 100))
        :onTeleportation(function(this_wormhole,teleported_object) print(teleported_object:getCallSign() .. " teleported to " .. this_wormhole:getTargetPosition()) end)
        :setPosition(-15000, 15000)
    ]]--
    --Nebula():setPosition(-15000, -15000)
    --BlackHole():setPosition(15000, -15000)

    --[[ Create an artifact that uses the small_frigate_1 model. Place it at coordinates 1000, 9000 and add a localizable description that appears on the Science scanner.

    Artifact()
        :setModel("small_frigate_1")
        :setPosition(1000, 9000)
        :setDescription(_("scienceDescription-artifact", "An old space derelict."))
    ]]--
    --Artifact():setPosition(9000, 2000):setModel("small_frigate_1"):setDescription(_("scienceDescription-artifact", "A wrecked ship."))
    --Artifact():setPosition(3000, 4000):setModel("small_frigate_1"):setDescription(_("scienceDescription-artifact", "Tons of rotting plasteel."))

    --[[ Create a planet at coordinates 5000, 5000 with a 3U radius positioned 2U below the movement plane. Set its surface, cloud, and atmosphere textures from images in EmptyEpsilon's resources/planets directory. Set the atmosphere color to a shade of blue (red 20%, green 20%, blue 100%). Assign it to the local variable planet1.

    local planet1 = Planet()
        :setPosition(5000, 5000)
        :setPlanetRadius(3000)
        :setDistanceFromMovementPlane(-2000)
        :setPlanetSurfaceTexture("planets/planet-1.png")
        :setPlanetCloudTexture("planets/clouds-1.png")
        :setPlanetAtmosphereTexture("planets/atmosphere.png")
        :setPlanetAtmosphereColor(0.2, 0.2, 1.0)
    ]]--
    --local moon1 = Planet():setPosition(5000, 0):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/moon-1.png"):setAxialRotationTime(20.0)
    --local sun1 = Planet():setPosition(5000, 15000):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0, 1.0, 1.0)

    --[[ Set the planet assigned to local variable planet 1 to orbit around the sun (assigned to local variable sun1) once every 40 seconds. Set the moon assigned to local variable moon1 to orbit around planet1 every 20 seconds

    planet1:setOrbit(sun1, 40)
    moon1:setOrbit(planet1, 20)
    ]]--

    -- Example GM functions:

    -- Delete all entities except for player ships, and generate a new 100U^2 field of 2,000 randomly placed asteroids centered around coordinates 0, 0. Move the player ships to coordinates near 0, 0. Spawn half of the asteroids on the same movement plane as ships and the other half as decoration above and below the plane.
    addGMFunction(
        _("buttonGM", "Reset to asteroids"),
        function()
            cleanup()
            for n = 1, 1000 do
                Asteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
                VisualAsteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
            end
        end
    )
    -- Delete all entities except for player ships, and generate a new 100U^2 field of 50 randomly placed nebulae centered around coordinates 0, 0. Move the player ships to coordinates near 0, 0.
    addGMFunction(
        _("buttonGM", "Reset to nebulae"),
        function()
            cleanup()
            for n = 1, 50 do
                Nebula():setPosition(random(-50000, 50000), random(-50000, 50000))
            end
        end
    )
    -- Delete all entities not currently selected on the GM screen.
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

-- Clean up the current play field. Find all objects and destroy everything that is not a player ship.
-- If it is a player ship, position it near the center of the play field.
function cleanup()
    for idx, obj in ipairs(getAllObjects()) do
        if isObjectType(obj, "PlayerSpaceship") then
            obj:setPosition(random(-100, 100), random(-100, 100))
        else
            obj:destroy()
        end
    end
end

function update(delta)
    -- No victory condition, continue indefinitely
end

-- Set a callback function to run whenever a player ship is created.
onNewPlayerShip(
    function(ship)
        -- Print the new ship's callsign.
        if ECS then
            print(ship, ship:getTypeName(), ship:getCallSign())
        else
            print(ship, ship.typeName, ship:getTypeName(), ship:getCallSign())
        end
    end
)

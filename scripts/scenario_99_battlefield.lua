-- Name: Battlefield
-- Description: More than 60 Human Navy and Exuari ships face off in all-out war near a neutral station.
---
--- (This scenario is designed for performance testing.)
-- Type: Basic
-- Variation[Large]: Larger battle. This increases the fleet sizes to 100 ships per side.
-- Variation[Huge]: Huge battle. This increases the fleet sizes to 500 ships per side.

--- Scenario
-- @script scenario_99_battlefield

function init()
    neutral_station = SpaceStation():setTemplate("Large Station"):setPosition(0, -15000):setRotation(random(0, 360)):setFaction("Independent")
    -- Set up the neutral station to provide supplydrops to anyone, but mines only to friendlies (which rules out the player).
    neutral_station.comms_data = {supplydrop = "neutral", weapons = {Mine = "friend"}}
    friendly_station = SpaceStation():setTemplate("Large Station"):setPosition(-10000, -25000):setRotation(random(0, 360)):setFaction("Human Navy")

    -- Put some mines around the friendly station.
    for n = 1, 30 do
        setCirclePos(Mine(), -10000, -25000, n * 10, 5000)
    end

    -- Put some neutral tugs around the neutral station, just as cannon fodder.
    for n = 1, 5 do
        setCirclePos(CpuShip():setTemplate("Flavia"):setFaction("Independent"):setScanned(true), 0, -15000, random(0, 360), random(1000, 5000))
    end

    -- Scale fleet sizes based on the scenario variation.
    if getScenarioVariation() == "Large" then
        battle_scale = 3.3
        location_scale = 1.5
    elseif getScenarioVariation() == "Huge" then
        battle_scale = 16.6
        location_scale = 3
    else
        battle_scale = 1
        location_scale = 1
    end

    local faction

    -- Set up the Human Navy fleet.
    faction = "Human Navy"

    for n = 1, 20 * battle_scale do
        CpuShip():setTemplate("MT52 Hornet"):setPosition(random(-10000 * location_scale, 10000 * location_scale), random(0, 3000)):setRotation(90):setFaction(faction):orderRoaming():setScanned(true)
    end

    for n = 1, 10 * battle_scale do
        CpuShip():setTemplate("Phobos T3"):setPosition(random(-10000 * location_scale, 10000 * location_scale), random(0, 2000)):setRotation(90):setFaction(faction):orderRoaming():setScanned(true)
    end

    -- Set up the Exuari fleet.
    faction = "Exuari"

    for n = 1, 20 * battle_scale do
        CpuShip():setTemplate("MT52 Hornet"):setPosition(random(-13000 * location_scale, 13000 * location_scale), random(5000, 8000)):setRotation(-90):setFaction(faction):orderRoaming():setScanned(true)
    end

    for n = 1, 10 * battle_scale do
        CpuShip():setTemplate("Phobos T3"):setPosition(random(-13000 * location_scale, 13000 * location_scale), random(5000, 8000)):setRotation(-90):setFaction(faction):orderRoaming()
    end

    for n = 1, 3 * battle_scale do
        CpuShip():setTemplate("Piranha F12"):setPosition(random(-13000 * location_scale, 13000 * location_scale), 5000):setRotation(-90):setFaction(faction):orderRoaming()
    end

    for n = 1, 1 * battle_scale do
        CpuShip():setTemplate("Atlantis X23"):setPosition(random(-3000 * location_scale, 3000 * location_scale), 7000):setRotation(-90):setFaction(faction):orderRoaming()
    end
end

function update(delta)
    -- No victory condition
end

-- Given an angle and length, return a relative vector (x, y coordinates).
function vectorFromAngle(angle, length)
    return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end

-- Place an object relative to a vector. Returns the object with its position set to the resulting coordinates.
function setCirclePos(obj, x, y, angle, distance)
    local dx, dy = vectorFromAngle(angle, distance)
    return obj:setPosition(x + dx, y + dy)
end
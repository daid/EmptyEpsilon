-- Name: utils
-- Description: Bunch of useful utility functions that can be used in any scenario script.

--[[ These functions should be as generic as possible, so they are highly usable. --]]

-- Given enough information, find the distance between two positions.
-- This function can be called four ways:
--
-- distance(obj1, obj2)
--   Returns the distance between two objects.
--
--   obj1, obj2: Two objects. Calls getPosition() on each.
--
--   Example:
--     rock1 = Asteroid():setPosition(-100, 100)
--     rock2 = Asteroid():setPosition(0, 100)
--     distance(rock1, rock2) -- Returns 100
--
-- distance(obj, x, y)
-- distance(x, y, obj)
--   Find the distance from an object to a position,
--   or vice versa.
--
--   obj: An object. Calls getPosition() on it.
--   x, y: Coordinates of a position.
--
--   Example:
--     distance(rock1, 0, 100) -- Returns 100
--     distance(0, 100, rock1) -- Returns 100
--
-- distance(x1, y1, x2, y2)
--   Find the distance between two positions.
--
--   x1, y1: Origin position's coordinates.
--   x2, y2: Destination position's coordinates.
--
--   Example:
--     distance(-100, 100, 0, 100) -- Returns 100
function distance(a, b, c, d)
    local x1, y1 = 0, 0
    local x2, y2 = 0, 0
    if type(a) == "table" and type(b) == "table" then
        -- a and b are bth tables.
        -- Assume distance(obj1, obj2)
        x1, y1 = a:getPosition()
        x2, y2 = b:getPosition()
    elseif type(a) == "table" and type(b) == "number" and type(c) == "number" then
        -- Assume distance(obj, x, y)
        x1, y1 = a:getPosition()
        x2, y2 = b, c
    elseif type(a) == "number" and type(b) == "number" and type(c) == "table" then
        -- Assume distance(x, y, obj)
        x1, y1 = a, b
        x2, y2 = c:getPosition()
    elseif type(a) == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number" then
        -- a and b are both tables.
        -- Assume distance(obj1, obj2)
        x1, y1 = a, b
        x2, y2 = c, d
    else
        -- Not a valid use of the distance function. Throw an error.
        print(type(a), type(b), type(c), type(d))
        error("distance() function used incorrectly", 2)
    end
    local xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

-- Given an angle and length, return a relative vector (x, y coordinates).
--
-- vectorFromAngle(angle, length)
--   angle: Relative heading, in degrees
--   length: Relative distance, in thousandths of an in-game unit (1000 = 1U)
--
-- Example: For relative x and y coordinates 1000 units away at a heading of
-- 45 degrees, run:
--   vectorFromAngle(45, 1000).
function vectorFromAngle(angle, length)
    return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end

-- Place an object relative to a vector. Returns the object with its position
-- set to the resulting coordinates.
--
-- setCirclePos(obj, x, y, angle, distance)
--   obj: An object.
--   x, y: Origin coordinates.
--   angle, distance: Relative heading and distance from the origin.
--
-- Returns the object with its position set to the resulting coordinates, by
-- calling setPosition().
--
-- Example: To create a space station 10000 units from coordinates 100, -100
-- at a heading of 45 degrees, run
--   setCirclePos(SpaceStation():setTemplate("Small Station"):setFaction("Independent"), 100, -100, 45, 10000)
function setCirclePos(obj, x, y, angle, distance)
    local dx, dy = vectorFromAngle(angle, distance)
    return obj:setPosition(x + dx, y + dy)
end

-- Create objects along a line between two vectors, optionally with grid
-- placement and randomization.
--
-- createObjectsOnLine(x1, y1, x2, y2, spacing, object_type, rows, chance, randomize)
--   x1, y1: Starting coordinates
--   x2, y2: Ending coordinates
--   spacing: The distance between each object.
--   object_type: The object type. Calls `object_type():setPosition()`.
--   rows (optional): The number of rows, minimum 1. Defaults to 1.
--   chance (optional): The percentile chance an object will be created,
--     minimum 1. Defaults to 100 (always).
--   randomize (optional): If present, randomize object placement by this
--     amount. Defaults to 0 (grid).
--
--   Examples: To create a mine field, run:
--     createObjectsOnLine(0, 0, 10000, 0, 1000, Mine, 4)
--   This creates 4 rows of mines from 0,0 to 10000,0, with mines spaced 1U
--   apart.
--
--   The `randomize` parameter adds chaos to the pattern. This works well for
--   asteroid fields:
--     createObjectsOnLine(0, 0, 10000, 0, 300, Asteroid, 4, 100, 800)
function createObjectsOnLine(x1, y1, x2, y2, spacing, object_type, rows, chance, randomize)
    if rows == nil then rows = 1 end
    if chance == nil then chance = 100 end
    if randomize == nil then randomize = 0 end
    local d = distance(x1, y1, x2, y2)
    local xd = (x2 - x1) / d
    local yd = (y2 - y1) / d
    for cnt_x=0,d,spacing do
        for cnt_y=0,(rows-1)*spacing,spacing do
            local px = x1 + xd * cnt_x + yd * (cnt_y - (rows - 1) * spacing * 0.5) + random(-randomize, randomize)
            local py = y1 + yd * cnt_x - xd * (cnt_y - (rows - 1) * spacing * 0.5) + random(-randomize, randomize)
            if random(0, 100) < chance then
                object_type():setPosition(px, py)
            end
        end
    end
end

-- Merge data from table B into table A. Every key not set in table A is filled
-- by the data from table B.
--
-- This function can fill in incomplete configuration data. See the
-- comms_station.lua script as example.
function mergeTables(table_a, table_b)
    for key, value in pairs(table_b) do
        if table_a[key] == nil then
            table_a[key] = value
        elseif type(table_a[key]) == "table" and type(value) then
            mergeTables(table_a[key], value)
        end
    end
end

-- create amount of object_type, at a distance between dist_min and dist_max around the point (x0, y0)
function placeRandomAroundPoint(object_type, amount, dist_min, dist_max, x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
        object_type():setPosition(x, y)
    end
end

-- Place semi-random object_types around point (x,y) in a (x_grids by y_grids) area
-- Perlin Noise is used to create a sort of natural look to the created objects.
-- Use the perlin_z-parameter together with density to control amound of placed objects
-- Sensible values for perlin_z are in a range of {0.1 .. 0.5}
--
-- Example:
--
--   -- Creates a 10x10 grid space filled with some asteroids and nebulas
--   placeRandomObjects(Asteroid, 30, 0.3, 0, 0, 10, 10)
--   placeRandomObjects(VisualAsteroid, 30, 0.3, 0, 0, 10, 10)
--   placeRandomObjects(Nebula, 15, 0.3, 0, 0, 10, 10)
function placeRandomObjects(object_type, density, perlin_z, x, y, x_grids, y_grids)
    -- Prepare the Perlin Noise generator (if needed)
    require("perlin_noise.lua")
    perlin:load()

    -- Size of EE grid
    local grid_size = 20000

    -- Z-axis of Perlin distribution.
    local perlin_magic_z = perlin_z

    -- Perlin noise is not random, so we'll pick a random spot in its distribution
    perlin_section_i = random(0, 1000)
    perlin_section_j = random(0, 1000)

    -- Create a XY intensity map
    for i=1,x_grids do
        for j=1,y_grids do

            -- Get intensity from perlin distribution, and do a very rough normalization to {0 .. 0.6}
            local intensity = (perlin:noise(i+perlin_section_i, j+perlin_section_j, perlin_magic_z) + perlin_magic_z)

            -- Cube it to get blobs of objects
            intensity = intensity * intensity * intensity

            -- Use it to fill patches of space with randomly placed objects
            if (intensity > 0) then
                local nr_of_objects = intensity * density
                local x_start = ((i-x_grids/2) * grid_size) + x
                local y_start = ((j-x_grids/2) * grid_size ) + y

                placeRandomAroundPoint(object_type, nr_of_objects, 0, grid_size/1.5, x_start, y_start)
            end
        end
    end
end

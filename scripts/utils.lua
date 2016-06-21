-- Name: utils
-- Description: Bunch of useful utility functions that can be used in any scenario script.

--[[ These functions should be as generic as possible, so they are highly usable. --]]

--Distance function. Can be used 4 ways:
--distance(obj1, obj2)
--distance(obj, x, y)
--distance(x, y, obj)
--distance(x1, y1, x2, y2)
function distance(a, b, c, d)
    local x1, y1 = 0, 0
    local x2, y2 = 0, 0
    if type(a) == "table" and type(b) == "table" then
        --both a and b are tables.
        --Assume distance(obj1, obj2)
        x1, y1 = a:getPosition()
        x2, y2 = b:getPosition()
    elseif type(a) == "table" and type(b) == "number" and type(c) == "number" then
        --Assume distance(obj, x, y)
        x1, y1 = a:getPosition()
        x2, y2 = b, c
    elseif type(a) == "number" and type(b) == "number" and type(c) == "table" then
        --Assume distance(x, y, obj)
        x1, y1 = a, b:getPosition()
        x2, y2 = c:getPosition()
    elseif type(a) == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number" then
        --both a and b are tables.
        --Assume distance(obj1, obj2)
        x1, y1 = a, b
        x2, y2 = c, d
    else
        -- Not a valid usage of the distance function, throw an error.
        print(type(a), type(b), type(c), type(d))
        error("distance function incorrectly used", 2)
    end
    local xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

--Function to create objects in a line formation.
-- Per default this creates a grid/line formation of objects. For example a mine field will look like:
-- createObjectsOnLine(0, 0, 10000, 0, 1000, Mine, 4)
-- As this creates 4 rows of mines from 0,0 to 10000,0 with a spacing of 1000 between each mine.
-- The randomize parameter can be used to add more chaos to the pattern. This works well for asteroids, example:
-- createObjectsOnLine(0, 0, 10000, 0, 300, Asteroid, 4, 100, 800)
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

--Function to merge data from table B into table A. Every key that is not set in table A is filled by the data from table B.
-- this function can be used to fill in incomplete configuration data. See the comms_station script as example.
function mergeTables(table_a, table_b)
    for key, value in pairs(table_b) do
        if table_a[key] == nil then
            table_a[key] = value
        elseif type(table_a[key]) == "table" and type(value) then
            mergeTables(table_a[key], value)
        end
    end
end

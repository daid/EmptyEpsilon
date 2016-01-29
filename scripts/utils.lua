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
        error("distance function incorrectly used", 2)
    end
    local xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

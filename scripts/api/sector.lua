-- Sector naming conventions

-- The game map is divided into 20U (20,000) square sectors.
-- By default, sectors are named with a letter (Y axis) and a number (X axis) with the origin coordinates 0,0 at the northwest corner of sector F5.
-- Access sector names and coordinates using global functions Sector.getSectorName(x, y) and Sector.sectorToXY(sector_name), or their legacy wrappers without the Sector namespacing.
--
-- Scenarios can override the naming scheme by assigning to the Sector-namespaced functions.
--
-- Override examples:
--
-- - Name sectors numerically (i.e. "2, 4" for two right and four down from origin)
--
--   Sector.getSectorName = function(x, y)
--       return string.format("%d,%d", math.floor(x / 20000), math.floor(y / 20000))
--   end
--   Sector.sectorToXY = function(name)
--       local x, y = name:match("(-?%d+),(-?%d+)")
--       if not x then return 0, 0, false end
--       return tonumber(x) * 20000, tonumber(y) * 20000, true
--   end

Sector = {}
local SECTOR_SIZE = 20000

-- Truncate float division
local function truncDiv(a, b)
    if a >= 0 then
        return math.floor(a / b)
    else
        return math.ceil(a / b)
    end
end

local function truncMod(a, b)
    return a - truncDiv(a, b) * b
end

--- string Sector.getSectorName(float x, float y)
--- Given x/y coordinates, return the name of the sector that contains those coordinates as a single string.
--- This function and Sector.sectorToXY() define the naming scheme for sectors. To change how sectors are named in a scenario, override these functions to translate coordinate values.
--- Sectors are always rendered in EmptyEpsilon radar views as 20U in size and square in shape. Overriding this function changes only how the sector grid labels are named.
--- Example:
--- Sector.getSectorName(0, 0) -- returns "F5" by default
function Sector.getSectorName(x, y)
    local sector_x = math.floor(x / SECTOR_SIZE) + 5
    local sector_y = math.floor(y / SECTOR_SIZE) + 5
    local y_str
    local x_str

    if sector_y >= 0 then
        if sector_y < 26 then
            y_str = string.char(string.byte('A') + sector_y)
        else
            y_str = string.char(string.byte('A') - 1 + math.floor(sector_y / 26)) ..
                    string.char(string.byte('A') + (sector_y % 26))
        end
    else
        y_str = string.char(string.byte('z') + truncDiv(sector_y + 1, 26))
        if truncMod(sector_y, 26) == 0 then
            y_str = y_str .. "a"
        else
            y_str = y_str .. string.char(string.byte('z') + 1 + truncMod(sector_y, 26))
        end
    end

    x_str = tostring(sector_x)
    return y_str .. x_str
end

--- float x, float y, bool is_valid Sector.sectorToXY(string sector_name)
--- Given a sector name, return the x/y coordinates for the sector's northwest (top-left) corner point.
--- This also returns a third Boolean value that returns true if the given sector name was valid, or false if not. Check the input's returned validity before applying the returned coordinate values.
--- This function and Sector.getSectorName() define the naming scheme for sectors. To change how sectors are named in a scenario, override these functions to translate coordinate values.
--- Sectors are always rendered in EmptyEpsilon radar views as 20U in size and square in shape. Overriding this function changes only how coordinates translate to labels.
--- Example:
--- Sector.sectorToXY("F5") -- returns 0, 0, true
function Sector.sectorToXY(sector_name)
    if #sector_name < 2 then
        return 0, 0, false
    end

    local x, y
    local intpart

    local a1 = string.sub(sector_name, 1, 1)
    local a2 = string.sub(sector_name, 2, 2)

    if string.byte(a1) >= string.byte('A') and string.byte(a2) >= string.byte('A') then
        intpart = tonumber(string.sub(sector_name, 3))
        if not intpart then
            return 0, 0, false
        end
        if string.byte(a1) > string.byte('a') then
            y = ((string.byte('z') - string.byte(a1)) * 26 + (string.byte('z') - string.byte(a2) + 6)) * -SECTOR_SIZE
        else
            y = ((string.byte(a1) - string.byte('A')) * 26 + (string.byte(a2) - string.byte('A') + 21)) * SECTOR_SIZE
        end
    else
        local alpha = string.upper(a1)
        intpart = tonumber(string.sub(sector_name, 2))
        if not intpart then
            return 0, 0, false
        end
        y = (string.byte(alpha) - string.byte('F')) * SECTOR_SIZE
    end

    x = (intpart - 5) * SECTOR_SIZE
    return x, y, true
end

function getSectorName(x, y)
    return Sector.getSectorName(x, y)
end

function sectorToXY(sector_name)
    return Sector.sectorToXY(sector_name)
end

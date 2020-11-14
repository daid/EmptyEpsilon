--- Extension of Lua's standard library.
--
-- Lua's standard library is a bit minimalistic.
-- This module provides useful additions to `math`, `string`, and `table`.
--
-- Only general functions that could be in the standard library
-- are added to these modules.
--
-- Require this module in scenario files or modules:
--
--     require("luax.lua")
--
-- **Version history**
--
-- Version 0.2
--
-- - add `table.contains`
-- - add `table.filter`
--
-- @author Tom
-- @module luax

--- maths.
--
-- Functions for `maths`
-- in addition to <https://www.lua.org/manual/5.3/manual.html#6.7>.
--
-- @section maths

--- string.
--
-- Functions for `string`
-- in addition to <https://www.lua.org/manual/5.3/manual.html#6.4>.
--
-- @section string

--- table.
--
-- Functions for `table`
-- in addition to <https://www.lua.org/manual/5.3/manual.html#6.6>.
--
-- As in `table`, the functions here ignore non-numeric keys
-- in the tables given as arguments, more precisely, they only
-- consider the positions `1, ..., #list`.
--
-- @section table

--- Checks whether a value is contained in a list.
--
-- Returns `true` if the list `list` contains the element `value`
-- at one of the positions `1, 2, ..., #list`, otherwise `false`.
--
-- @tparam table list the list to search
-- @tparam any value the value to look for
-- @treturn boolean `true` if `value` is contained in `list`, otherwise `false`
function table.contains(list, value)
    for pos = 1, #list do
        if list[pos] == value then
            return true
        end
    end
    return false
end

--- Filters a list in place.
--
-- Filters the list `list` and keep all elements that pass the test implemented
-- by the boolean-valued function `predicate`,
-- i.e. that return a value considered `true`.
-- The result is the list with the filtered elements
-- at the positions 1 to the new length (without gaps).
--
-- As usual, only `list[1]` to `list[#list]` are affected,
-- non-list keys are ignored and kept.
--
-- @tparam table list the list to filter in place
-- @tparam function predicate the function applied the values in the list
-- @usage
-- -- (1) Generate a list of all Kraylor CpuShips
-- local function isKraylorCpuShip(obj)
--   return obj.typeName == "CpuShip" and obj:getFaction() == "Kraylor"
-- end
-- local enemies = getAllObjects()
-- table.filter(enemies, isKraylorCpuShip)
--
-- -- (2) Function to filter a list to keep only the valid objects
-- local function filterValid(objList)
--   table.filter(
--     objList,
--     function(obj)
--       return obj:isValid()
--     end
--   )
-- end
-- -- maybe some of the enemies from above got destroyed
-- filterValid(enemies)
-- print("Enemies left:", #enemies)
function table.filter(list, predicate)
    local pos_new = 1
    local len_orig = #list
    for pos, value in ipairs(list) do
        if predicate(value, pos) then
            list[pos_new] = value
            pos_new = pos_new + 1
        end
    end
    for pos = pos_new, len_orig do
        list[pos] = nil
    end
end

--- Shuffle the list `list` in place.
--
-- Uses the efficient Fisher-Yates shuffle.
--
-- Note that the quality of the shuffle is limited by the random number generator.
--
-- @tparam table list the array to shuffle
function table.shuffle(list)
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

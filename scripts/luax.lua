--- Extension of Lua's standard library.
--
-- Lua's standard library is a bit minimalistic.
-- This module provides useful additions to `math`, `string`, and `table`.
--
-- Only general functions that could be in the standard library
-- are added to these modules.
--
-- Naming as in Lua's library: lowercase without underscores.
-- Several functions are inspired by Python.
--
-- Require this module in scenario files or modules:
--
--     require("luax.lua")
--
-- **Version history**
--
-- Version 0.4
--
-- - add `table.equals`
-- - add `table.extend`
-- - add `table.clear`
--
-- Version 0.3
--
-- - add `table.contains`
-- - add `table.filter`
-- - add `table.shuffle`
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
-- Naming:
--
-- - The imperative `table.shuffle` operates in place,
-- - the past participle `table.shuffled` would return a new list.
-- - Third person `table.contains` returns a boolean.
--
-- Note:
--
-- - for `append` use `table.insert`
-- - for `pop` use `table.remove`
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
-- @usage
-- table.contains({"a", "b"}, "a") -- true
-- table.contains({"a", "b"}, "A") -- false
-- table.contains({"a", "b", key = "c"}, "c") -- false
function table.contains(list, value)
    for k = 1, #list do
        if list[k] == value then
            return true
        end
    end
    return false
end

--- Return `true` if the two list are equal, otherwise `false`.
--
-- The lists are compared at position 1, 2, ... until both (or one) are `nil`.
--
-- Complexity: O(m), where m is the length of the shorter list.
--
-- @tparam table list1 the first list
-- @tparam table list2 the second list
-- @tparam ?function comp comparison function, default is `==`
-- @treturn boolean result of comparison
-- @usage
-- {"a", "b"} == {"a", "b"} -- false
-- table.equals({"a", "b"}, {"a", "b"}) -- true
-- table.equals({"a", "b"}, {"a", "b", key = "c"}) -- true
-- table.equals({"a", "b"}, {"b", "a"}) -- false
function table.equals(list1, list2, comp)
    if not comp then
        comp = function(l1, l2)
            return l1 == l2
        end
    end

    if #list1 ~= #list2 then
        return false
    end

    for k = 1, #list1 do
        if list1[k] ~= list2[k] then
            return false
        end
    end
    return true
end

--- Extend the list `list` by appending all the items from `list2`.
--
-- As usual, non-list entries are maintained in `list` and ignored in `list2`.
-- If `list` has integer keys greater than `#list`,
-- they will simply be overwritten once these positions are reached.
--
-- Complexity: O(m), where m is the length of the second list.
--
-- @tparam table list the list to exend
-- @tparam table list2 the list to be appended element by element to `list`
-- @usage
-- local list = {"a", "b", "c"}
-- table.extend(list, {"D", "E"})
-- assert(table.concat(list) == "abcDE")
function table.extend(list, list2)
    local k = #list
    for j = 1, #list2 do
        list[k + j] = list2[j]
    end
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

--- Remove all items from the list.
--
-- Use this function in particular if you have several references to the list.
--
-- As usual, non-list keys are ignored.
-- This means, `#list` is 0 after `clear`, but there might still be other keys.
--
-- @tparam table list the list to clear
-- @usage
-- -- do
-- local list = {"a", "b"}
-- local ref = list
-- print(#list, #ref) -- 2   2
-- table.clear(list)
-- print(#list, #ref) -- 0   0
-- print(list == ref) -- true
-- -- (usually) do not
-- local list = {"a", "b"}
-- local ref = list
-- print(#list, #ref) -- 2   2
-- list = {}
-- print(#list, #ref) -- 0   2
-- print(list == ref) -- false
function table.clear(list)
    for k = #list, 1, -1 do
        list[k] = nil
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

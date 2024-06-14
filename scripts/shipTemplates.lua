--[[
Base of the ship templates, from here different classes of ships are included to be used within the game.
Each sub-file defines it's own set of ship classes.

Player ships are in general large frigates to small corvette class
--]]
require("shipTemplates_o_playerships.lua")
require("shipTemplates_o_humans.lua")
require("shipTemplates_o_machines.lua")



--[[require("shiptemplates/stations.lua")
require("shiptemplates/starFighters.lua")
require("shiptemplates/frigates.lua")
require("shiptemplates/corvette.lua")
require("shiptemplates/dreadnaught.lua")
require("shiptemplates/exuari.lua")
require("shiptemplates/ktlitan.lua")
require("shiptemplates/transport.lua")
require("shiptemplates/satellites.lua")
--]]

--For now, we add our old ship templates as well. These should be removed at some point.

--require("shipTemplates_OLD.lua")
--[[
Base of the ship templates, from here different classes of ships are included to be used within the game.
Each sub-file defines it's own set of ship classes.

These are:
* Stations: For different kinds of space stations, from tiny to huge.
* Starfighters: Smallest ships in the game.
* Frigates: Medium sized ships. Operate on a small crew.
* Corvette: Large, slower, less maneuverable ships.
* Dreadnaught: Huge things. Everything in here is really really big, and generally really really deadly.
* Exuari: Ships with a similar style, designed (but not limited) for the Exuari faction.

Player ships are in general large frigates to small corvette class
--]]
require("shiptemplates/stations.lua")
require("shiptemplates/starFighters.lua")
require("shiptemplates/frigates.lua")
require("shiptemplates/corvette.lua")
require("shiptemplates/dreadnaught.lua")
require("shiptemplates/exuari.lua")
require("shiptemplates/ktlitan.lua")
require("shiptemplates/transport.lua")
require("shiptemplates/satellites.lua")

--For now, we add our old ship templates as well. These should be removed at some point.
require("shiptemplates/OLD.lua")

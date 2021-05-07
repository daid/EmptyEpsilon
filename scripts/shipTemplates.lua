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
require("shipTemplates_Stations.lua")
require("shipTemplates_StarFighters.lua")
require("shipTemplates_Frigates.lua")
require("shipTemplates_Corvette.lua")
require("shipTemplates_Dreadnaught.lua")
require("shipTemplates_Exuari.lua")
--For now, we add our old ship templates as well. These should be removed at some point.
require("shipTemplates_OLD.lua")

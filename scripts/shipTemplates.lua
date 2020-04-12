--[[ Base Ship Templates
This file includes ship templates for each ship class to be used within the game.
Each sub-file also defines its own set of ship subclasses.

These are:

* Stations: For different kinds of space stations, from tiny to huge.
* Starfighters: Smallest ships in the game.
* Frigates: Medium-sized ships that operate with a small crew.
* Covettes: Large, slower, less maneuverable ships.
* Dreadnoughts: Huge things. Everything in here is really really big, and generally really really deadly.

Most player ships range from large frigates to small corvettes.
--]]
require("shipTemplates_Stations.lua")
require("shipTemplates_Starfighters.lua")
require("shipTemplates_Frigates.lua")
require("shipTemplates_Corvettes.lua")
require("shipTemplates_Dreadnoughts.lua")
--[[ For now, we also add our old ship templates. These should be removed at some point. ]]
require("shipTemplates_OLD.lua")

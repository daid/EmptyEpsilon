-- Name: Basics and Captain (Main Screen / Radar)
-- Description: [Station Tutorial]
--- -------------------
--- -This goes over the basics of map awareness and radar systems. Recommended introduction.
---
--- [Station Info]
--- -------------------
--- This tutorial covers not only the captain's tasks, but also some basics for other stations (except for Engineering).
--- Without direct control of the ship, the Captain keeps the crew focused on their goal and makes tactical decisions in combat. 
--- The ship's main screen should be set up on a large monitor or projector so that all players can track their ship's status.
--- 
--- The Captain's tasks include:
--- -Planning the next actions
--- -Co-ordinating combat tactics
--- -Preventing mutiny
--- -Setting priorities
-- Type: Tutorial
require("utils.lua")
require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        mainscreenTutorial,
		radarTutorial,
        endOfTutorial
    }
    startTutorial()
end

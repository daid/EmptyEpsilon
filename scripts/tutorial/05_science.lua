-- Name: Science
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over science station.
---
--- [Station Info]
--- -------------------
--- Long-range Radar: 
--- -The Science station has a long-range radar that can locate ships and objects at a great distance. The Science officer's most important task is to report the sector's status and any changes within it. On the edge of the radar are colored bands of signal interference that can vaguely suggest the presence of objects or space hazards even further from the ship, but it's up to the Science officer to interpret them.
---
--- Scanning: 
--- -You can scan ships to get more information about them. The Science officer must align two of the ship's scanning frequencies with a target to complete the scan. Most ships are unknown (gray) to your crew at the start of a scenario and must be scanned before they can be identified as a friend (green), foe (red), or neutral (blue). A scan also identifies the ship's type, which the Science officer can use to identify its capabilities in the station's database.
---
--- Deep Scans: 
--- -A second, more difficult scan yields more information about the ship, including its shield and beam frequencies. The Science officer must align both the frequency and modulation of each scan type to complete a deep scan. The helms and weapons screen can also see the firing arcs of deep-scanned ships, which help them guide your ship from being shot by their beams.
---
--- Nebulae: 
--- -Nebulae block the ship's long-range scanner. The Science officer cannot see what's inside or behind them, and while in a nebula the ship's radars cannot detect what's outside of it. These traits make nebulae ideal places to hide for repairs or stage an ambush. To avoid surprises around nebulae, relay information about where you can and cannot see objects to both the Captain and the Relay officer.
---
--- Probe View: 
--- -The Relay officer can launch probes and link one to the Science station. The Science officer can view the probe's short-range sensor data to scan ships within its range, even if the probe is far from the ship's long-range scanners or in a nebula.
---
--- Database: 
--- -The Science officer can access the ship's database of all known ships, as well as data about weapons and space hazards. This can be vital when assessing a ship's capabilities without a deep scan, or for help navigating a black hole, wormhole, or other anomaly.
-- Type: Tutorial

require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        scienceTutorial,
        endOfTutorial
    }
    startTutorial()
end

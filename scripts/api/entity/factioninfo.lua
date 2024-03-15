local Entity = getLuaEntityFunctionTable()
----- Old FactionInfo API -----

--- A FactionInfo object contains presentation details and faction relationships for member SpaceObjects.
--- EmptyEpsilon has a hardcoded limit of 32 factions.
---
--- SpaceObjects belong to a faction that determines which objects are friendly, neutral, or hostile toward them.
--- For example, these relationships determine whether a SpaceObject can be targeted by weapons, docked with, or receive comms from another SpaceObject.
--- If a faction doesn't have a relationship with another faction, it treats those factions as neutral.
--- Friendly and hostile faction relationships are automatically reciprocated when set with setEnemy() and setFriendly().
---
--- If this faction consideres another faction to be hostile, it can target and fire weapons at it, and CpuShips with certain orders might pursue it.
--- If neutral, this faction can't target and fire weapons at the other faction, and other factions can dock with its stations or dockable ships.
--- If friendly, this faction acts as neutral but also shares short-range radar with PlayerSpaceships in Relay, and can grant reputation points to PlayerSpaceships of the same faction.
---
--- Many scenario and comms scripts also give friendly factions benefits at a reputation cost that netural factions do not.
--- Factions are loaded from resources/factionInfo.lua upon launching a scenario, and accessed by using the getFactionInfo() global function.
---
--- Example:
--- human_navy = getFactionInfo("Human Navy")
--- exuari = getFactionInfo("Exuari")
--- faction = FactionInfo():setName("USN"):setLocaleName(_("USN")) -- sets the internal and translatable faction names
--- faction:setGMColor(255,128,255) -- uses purple icons for this faction's SpaceObjects in GM and Spectator views
--- faction:setFriendly(human_navy):setEnemy(exuari) -- sets this faction's friendly and hostile relationships
--- faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
__faction_info = {}
function FactionInfo()
    local fi = createEntity()
    fi.faction_info = {}
    fi:__setFactionRelation(fi, "friendly")
    return fi
end
function getFactionInfo(name)
    return __faction_info[name]
end

--- Sets this faction's name as presented in the user interface.
--- Wrap the string in the _() function to make it available for translation.
--- Example: faction:setLocaleName(_("USN"))
function Entity:setLocaleName(name)
    if self.faction_info then
        self.faction_info.locale_name = name
    end
    return self
end
--- Sets the RGB color used for SpaceObjects of this faction as seen on the GM and Spectator views.
--- Defaults to white (255,255,255).
--- Example: faction:setGMColor(255,0,0) -- sets the color to red
function Entity:setGMColor(r, g, b)
    if self.faction_info then
        self.faction_info.gm_color = {r, g, b, 255}
    end
    return self
end
--- Sets the given faction to appear as hostile to SpaceObjects of this faction.
--- For example, Spaceships of this faction can target and fire at SpaceShips of the given faction.
--- Defaults to no hostile factions.
--- Warning: A faction can be designated as hostile to itself, but the behavior is not well-defined.
--- Example: faction:setEnemy(exuari) -- sets the Exuari to appear as hostile to this faction
function Entity:setEnemy(other_faction)
    if self.faction_info == nil then error("setEnemy can only be called on factions.") end
    if other_faction.faction_info == nil then error("setEnemy can only be called on factions.") end
    self:__setFactionRelation(other_faction, "enemy")
    other_faction:__setFactionRelation(self, "enemy")
    return self
end
--- Sets the given faction to appear as friendly to SpaceObjects of this faction.
--- For example, PlayerSpaceships of this faction can gain reputation with it.
--- Defaults to no friendly factions.
--- Example: faction:setFriendly(exuari) -- sets the Human Navy to appear as friendly to this faction
function Entity:setFriendly(other_faction)
    if self.faction_info == nil then error("setFriendly can only be called on factions.") end
    if other_faction.faction_info == nil then error("setFriendly can only be called on factions.") end
    self:__setFactionRelation(other_faction, "friendly")
    other_faction:__setFactionRelation(self, "friendly")
    return self
end
--- Sets the given faction to appear as neutral to SpaceObjects of this faction.
--- This removes any existing faction relationships between the two factions.
--- Example: faction:setNeutral(human_navy) -- sets the Human Navy to appear as neutral to this faction
function Entity:setNeutral(other_faction)
    if self.faction_info == nil then error("setNeutral can only be called on factions.") end
    if other_faction.faction_info == nil then error("setNeutral can only be called on factions.") end
    self:__setFactionRelation(other_faction, "neutral")
    other_faction:__setFactionRelation(self, "neutral")
    return self
end

function Entity:__setFactionRelation(other_faction, relation)
    for n=1, #self.faction_info do
        if self.faction_info[n].other_faction == other_faction then
            self.faction_info[n].relation = relation
            return
        end
    end
    self.faction_info[#self.faction_info+1] = {other_faction=other_faction, relation=relation}
end

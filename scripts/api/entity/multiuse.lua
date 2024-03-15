local Entity = getLuaEntityFunctionTable()

-- Functions that have multiple implementations as a result of the old object code are here and interact with multiple components.


--- Sets this faction's internal string name, used to reference this faction regardless of EmptyEpsilon's language setting.
--- If no locale name is defined, this sets the locale name to the same value.
--- Example: faction:setName("USN")
--- Sets this ScienceDatabase entry's displayed name.
--- Example: entry:setName("Species")
function Entity:setName(name)
    if self.faction_info then
        self.faction_info.name = name
        __faction_info[name] = self
    end
    if self.science_database then
        self.science_database.name = name
    end
    return self
end

--- Sets this faction's longform description as shown in its Factions ScienceDatabase child entry.
--- Wrap the string in the _() function to make it available for translation.
--- Example: faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
--- As setDescriptions, but sets the same description for both unscanned and scanned states.
--- Example: obj:setDescription("A refitted Atlantis X23 for more ...")
function Entity:setDescription(description)
    if self.faction_info then
        self.faction_info.description = description
    else
        self.science_description = {not_scanned=description, friend_or_foe_identified=description, simple_scan=description, full_scan=description}
    end
    return self
end


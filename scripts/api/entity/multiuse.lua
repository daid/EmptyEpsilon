local Entity = getLuaEntityFunctionTable()

-- Functions that have multiple implementations as a result of the old object code are here and interact with multiple components.


function Entity:setName(name)
    --- Sets this faction's internal string name, used to reference this faction regardless of EmptyEpsilon's language setting.
    --- If no locale name is defined, this sets the locale name to the same value.
    --- Example: faction:setName("USN")
    if self.faction_info then
        self.faction_info.name = name
        __faction_info[name] = self
    end
    --- Sets this ScienceDatabase entry's displayed name.
    --- Example: entry:setName("Species")
    if self.science_database then
        self.science_database.name = name
    end
    return self
end

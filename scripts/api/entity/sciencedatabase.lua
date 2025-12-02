local Entity = getLuaEntityFunctionTable()
--- A ScienceDatabase entry stores information displayed to all players in the Science database tab or Database standalone screen.
--- Each ScienceDatabase entry can contain key/value pairs, an image, and a 3D ModelData.
---
--- A ScienceDatabase entry can also be the parent of many ScienceDatabases or the child of one ScienceDatabase, creating a hierarchical structure.
--- Each ScienceDatabase without a parent is a top-level entry in the player-viewed database interface.
--- Each child ScienceDatabase entry is displayed only when its parent entry is selected.
---
--- By default, EmptyEpsilon creates parentless entries for Factions, "Natural" (terrain), Ships, and Weapons.
--- Their child entries are populated by EmptyEpsilon upon launching a scenario, either with hardcoded details, entries loaded from scripts/science_db.lua, or the contents of script-defined objects such as ShipTemplates and FactionInfo.
--- Entries for ShipTemplates are also linked to from Science radar info of scanned ships of that template.
---
--- Each ScienceDatabase entry has a unique identifier regardless of its displayed order, and multiple entries can have the same name.
--- Changes to ScienceDatabases appear in the UI only after a player opens the Database or selects an entry.
---
--- To retrieve a 1-indexed table of all parentless entries, use the global function getScienceDatabases().
--- You can then use this class's functions to get child entries and entry data.
---
--- Example:
--- -- Creates a new parentless entry named "Species", with an entry containing a key/value
--- ScienceDatabase():setName("Species"):addEntry("Canines"):addKeyValue("Legs","4")
--- sdb = getScienceDatabases() -- returns a 1-indexed table of top-level entries
---
--- for i,db in pairs(sdb) do
---   if (db:getName() == "Species") then
---     entry = db -- assigns the ScienceDatabase with the name "Species"
---  end
--- end
---
--- species = entry:getEntries()[1] -- species = "Canines"
--- legs = species:getKeyValue("Legs") -- legs = "4"
function ScienceDatabase()
    local e = createEntity()
    e.components.science_database = {}
    return e
end

--- Returns this ScienceDatabase entry's displayed name.
--- Example: entry:getName()
function Entity:getName()
    if self.components.science_database then return self.components.science_database.name end
    return ""
end
--- Returns this ScienceDatabase entry's unique multiplayer_id.
--- Examples: entry:getId() -- returns the entry's ID
function Entity:getId()
    return self
end
--- Return this ScienceDatabase entry's parent entry's unique multiplayer_id.
--- Returns 0 if the entry has no parent.
--- Example: entry:getParentId() -- returns the parent entry's ID
function Entity:getParentId()
    if self.components.science_database then return self.components.science_database.parent end
end
--- Creates a ScienceDatabase entry with the given name as a child of this ScienceDatabase entry.
--- Returns the newly created entry. Chaining addEntry() creates a child of the new child entry.
--- Examples:
--- species:addEntry("Canines") -- adds an entry named "Canines" as a child of ScienceDatabase species
--- -- Adds an entry named "Felines" as a child of species, and an entry named "Calico" as a child of "Felines"
--- species:addEntry("Felines"):addEntry("Calico")
function Entity:addEntry(name)
    if not self.components.science_database then return end
    local child = ScienceDatabase()
    child.components.science_database.name = name
    child.components.science_database.parent = self
    return child
end
--- Returns the first child ScienceDatabase entry of this ScienceDatabase entry found with the given case-insensitive name.
--- Multiple entries can have the same name.
--- Returns nil if no entry is found.
--- Example: entry:getEntryByName("canines") -- returns the "Canines" entry in sdb
function Entity:getEntryByName(name)
    name = string.lower(name)
    for idx, e in ipairs(getEntitiesWithComponent("science_database")) do
        if e.components.science_database.parent == self and string.lower(e.components.science_database.name) == name then return e end
    end
    return nil
end
--- Returns a 1-indexed table of all child entries in this ScienceDatabase entry, in arbitrary order.
--- To return parentless top-level ScienceDatabase entries, use the global function getScienceDatabases().
--- Examples:
--- entry = getScienceDatabases()[1] -- returns the first parentless entry
--- entry:getEntries() -- returns all of its child entries
function Entity:getEntries()
    local result = {}
    for idx, e in ipairs(getEntitiesWithComponent("science_database")) do
        if e.components.science_database.parent == self then table.insert(result, e) end
    end
    return result
end
--- Returns true if this ScienceDatabase entry has child entries.
--- Example: entry:hasEntries()
function Entity:hasEntries()
    return #getEntries() > 0
end
--- Adds a key/value pair to this ScienceDatabase entry's key/value data.
--- The Database view's center column displays all key/value data when its entry is selected.
--- Chaining addKeyValue() adds each key/value to the same entry.
--- Warning: addKeyValue() can add entries with duplicate keys. To avoid this, use setKeyValue() instead.
--- Example:
--- -- Adds "Legs","4" and "Ears","2" to the entry's key/value data.
--- entry:addKeyValue("Legs","4"):addKeyValue("Ears","2")
--- entry:addKeyValue("Legs","2") -- adds "Legs","2", even if "Legs","4" is already present
function Entity:addKeyValue(key, value)
    if not self.components.science_database then return self end
    self.components.science_database[#self.components.science_database+1] = {key=key, value=value}
    return self
end
--- Sets the value of all key/value pairs matching the given case-insensitive key in this ScienceDatabase entry's key/value data.
--- If the key already exists, this changes its value.
--- If duplicate matching keys exist, this changes all of their values.
--- If the key doesn't exist, this acts as addKeyValue().
--- Examples:
--- -- Assuming entry already has "Legs","4" as a key/value
--- entry:setKeyValue("Legs","2") -- changes this entry's "Legs" value to "2"
--- entry:setKeyValue("Arms","2") -- adds "Arms","2" to the entry's key/value data
function Entity:setKeyValue(key, value)
    if not self.components.science_database then return self end
    for n=1,#self.components.science_database do
        if self.components.science_database[n].key == key then
            self.components.science_database[n].value = value
            return self
        end
    end
    return self:addKeyValue(key, value)
end
--- Returns the value of the first matching case-insensitive key found in this ScienceDatabase entry's key/value data.
--- Returns an empty string if the key doesn't exist.
--- Example: entry:getKeyValue("Legs") -- returns the value if found or "" if not
function Entity:getKeyValue(key)
    if not self.components.science_database then return "" end
    for n=1,#self.components.science_database do
        if self.components.science_database[n].key == key then
            return self.components.science_database[n].value
        end
    end
    return ""
end
--- Returns a table containing all key/value pairs in this ScienceDatabase entry.
--- Warning: Duplicate keys appear only once, with the last value found.
--- Example:
--- entry:getKeyValues() -- returns the key/value table for this entry
--- for k,v in pairs(kv) do print(k,v) end -- Print each key/value pair for this entry to the console
function Entity:getKeyValues()
    if not self.components.science_database then return {} end
    local result = {}
    for n=1,#self.components.science_database do
        result[self.components.science_database[n].key] = self.components.science_database[n].value
    end
    return result
end
--- Removes all key/value pairs matching the given case-insensitive key in this ScienceDatabase entry's key/value data.
--- If duplicate matching keys exist, this removes all of them.
--- Example: entry:removeKey("Legs") -- removes all key/value data with the key "Legs"
function Entity:removeKey(key)
    if not self.components.science_database then return self end

    local n = 1
    while n <= #self.components.science_database do
        -- If this entry's key matches the key to be removed, move the remaining entries down one place and remove the last one.
        if self.components.science_database[n].key == key then
            for m = n, #self.components.science_database - 1 do
                self.components.science_database[m] = {
                    key = self.components.science_database[m + 1].key,
                    value = self.components.science_database[m + 1].value
                }
            end

            self.components.science_database[#self.components.science_database] = nil
        else
            n = n + 1
        end
    end
    return self
end
--- Sets this ScienceDatabase entry's longform description to the given string.
--- The Database view's right column displays the longform description when its entry is selected.
--- Example: entry:setLongDescription("This species is known for its loyalty...")
function Entity:setLongDescription(description)
    if self.components.science_database then self.components.science_database.description = description end
    return self
end
--- Returns this ScienceDatabase entry's longform description.
--- Returns an empty string if no description is set.
--- Example: entry:getLongDescription()
function Entity:getLongDescription()
    if self.components.science_database then return self.components.science_database.description end
    return ""
end
--- Sets this ScienceDatabase entry's image file to the given filename.
--- Valid values are filenames to PNG files relative to the resources/ directory.
--- An empty string removes any set image.
--- Example: entry:setImage("retriever.png") -- sets the entry's image to the file "resources/retriever.png"
function Entity:setImage(image)
    if self.components.science_database then self.components.science_database.image = image end
    return self
end
--- Returns this ScienceDatabase entry's image filename.
--- Returns an empty string if no image is set.
--- Example: entry:getImage()
function Entity:getImage()
    if self.components.science_database then return self.components.science_database.image end
    return ""
end
--- Sets the 3D appearance, by ModelData name, used for this ScienceDatabase entry.
--- ModelData objects define a 3D mesh, textures, adjustments, and collision box, and are loaded from scripts/model_data.lua when EmptyEpsilon is launched.
--- Example: entry:setModelDataName("AtlasHeavyFighterYellow") -- uses the ModelData named "AtlasHeavyFighterYellow"
function Entity:setModelDataName(model_data_name)
    if __model_data[model_data_name] then
        self.components.mesh_render = __model_data[model_data_name].mesh_render
    else
        self.components.mesh_render = nil
    end
    return self
end


--- ScienceDatabase queryScienceDatabase(...)
--- Returns the first ScienceDatabase entry with a matching case-insensitive name within the ScienceDatabase hierarchy.
--- You must provide the full path to the entry by using multiple arguments, starting with the top-level entry.
--- Returns nil if no entry is found.
--- Example: queryScienceDatabase("weapons", "mine") -- returns the entry named "Mine" with the parent named "Weapons"
function queryScienceDatabase(...)
    local names = {...}
    local db_entities = getEntitiesWithComponent("science_database")

    local parent = nil
    for idx, name in ipairs(names) do
        name = string.lower(name)
        local found = false
        for db_idx, db in ipairs(db_entities) do
            if ((parent == nil and not db.components.science_database.parent.valid) or parent == db.components.science_database.parent) and string.lower(db.components.science_database.name) == name then
                parent = db
                found = true
                break
            end
        end
        if not found then return nil end
    end
    return parent
end

#include "scienceDatabase.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "spaceObjects/spaceship.h"
#include "components/faction.h"
#include "ecs/query.h"

#include "scriptInterface.h"

#include <set>

/// A ScienceDatabase entry stores information displayed to all players in the Science database tab or Database standalone screen.
/// Each ScienceDatabase entry can contain key/value pairs, an image, and a 3D ModelData.
///
/// A ScienceDatabase entry can also be the parent of many ScienceDatabases or the child of one ScienceDatabase, creating a hierarchical structure.
/// Each ScienceDatabase without a parent is a top-level entry in the player-viewed database interface.
/// Each child ScienceDatabase entry is displayed only when its parent entry is selected.
///
/// By default, EmptyEpsilon creates parentless entries for Factions, "Natural" (terrain), Ships, and Weapons.
/// Their child entries are populated by EmptyEpsilon upon launching a scenario, either with hardcoded details, entries loaded from scripts/science_db.lua, or the contents of script-defined objects such as ShipTemplates and FactionInfo.
/// Entries for ShipTemplates are also linked to from Science radar info of scanned ships of that template.
///
/// Each ScienceDatabase entry has a unique identifier regardless of its displayed order, and multiple entries can have the same name.
/// Changes to ScienceDatabases appear in the UI only after a player opens the Database or selects an entry.
///
/// To retrieve a 1-indexed table of all parentless entries, use the global function getScienceDatabases().
/// You can then use this class's functions to get child entries and entry data.
///
/// Example:
/// -- Creates a new parentless entry named "Species", with an entry containing a key/value
/// ScienceDatabase():setName("Species"):addEntry("Canines"):addKeyValue("Legs","4")
/// sdb = getScienceDatabases() -- returns a 1-indexed table of top-level entries
///
/// for i,db in pairs(sdb) do
///   if (db:getName() == "Species") then
///     entry = db -- assigns the ScienceDatabase with the name "Species"
///  end
/// end
///
/// species = entry:getEntries()[1] -- species = "Canines"
/// legs = species:getKeyValue("Legs") -- legs = "4"
REGISTER_SCRIPT_CLASS(ScienceDatabase)
{
    /// Sets this ScienceDatabase entry's displayed name.
    /// Example: entry:setName("Species")
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setName);
    /// Returns this ScienceDatabase entry's displayed name.
    /// Example: entry:getName()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getName);
    /// Returns this ScienceDatabase entry's unique multiplayer_id.
    /// Examples: entry:getId() -- returns the entry's ID
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getId);
    /// Return this ScienceDatabase entry's parent entry's unique multiplayer_id.
    /// Returns 0 if the entry has no parent.
    /// Example: entry:getParentId() -- returns the parent entry's ID
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getParentId);
    /// Creates a ScienceDatabase entry with the given name as a child of this ScienceDatabase entry.
    /// Returns the newly created entry. Chaining addEntry() creates a child of the new child entry.
    /// Examples:
    /// species:addEntry("Canines") -- adds an entry named "Canines" as a child of ScienceDatabase species
    /// -- Adds an entry named "Felines" as a child of species, and an entry named "Calico" as a child of "Felines"
    /// species:addEntry("Felines"):addEntry("Calico")
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addEntry);
    /// Returns the first child ScienceDatabase entry of this ScienceDatabase entry found with the given case-insensitive name.
    /// Multiple entries can have the same name.
    /// Returns nil if no entry is found.
    /// Example: entry:getEntryByName("canines") -- returns the "Canines" entry in sdb
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getEntryByName);
    /// Returns a 1-indexed table of all child entries in this ScienceDatabase entry, in arbitrary order.
    /// To return parentless top-level ScienceDatabase entries, use the global function getScienceDatabases().
    /// Examples:
    /// entry = getScienceDatabases()[1] -- returns the first parentless entry
    /// entry:getEntries() -- returns all of its child entries
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getEntries);
    /// Returns true if this ScienceDatabase entry has child entries.
    /// Example: entry:hasEntries()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, hasEntries);
    /// Adds a key/value pair to this ScienceDatabase entry's key/value data.
    /// The Database view's center column displays all key/value data when its entry is selected.
    /// Chaining addKeyValue() adds each key/value to the same entry.
    /// Warning: addKeyValue() can add entries with duplicate keys. To avoid this, use setKeyValue() instead.
    /// Example:
    /// -- Adds "Legs","4" and "Ears","2" to the entry's key/value data.
    /// entry:addKeyValue("Legs","4"):addKeyValue("Ears","2")
    /// entry:addKeyValue("Legs","2") -- adds "Legs","2", even if "Legs","4" is already present
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addKeyValue);
    /// Sets the value of all key/value pairs matching the given case-insensitive key in this ScienceDatabase entry's key/value data.
    /// If the key already exists, this changes its value.
    /// If duplicate matching keys exist, this changes all of their values.
    /// If the key doesn't exist, this acts as addKeyValue().
    /// Examples:
    /// -- Assuming entry already has "Legs","4" as a key/value
    /// entry:setKeyValue("Legs","2") -- changes this entry's "Legs" value to "2"
    /// entry:setKeyValue("Arms","2") -- adds "Arms","2" to the entry's key/value data
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setKeyValue);
    /// Returns the value of the first matching case-insensitive key found in this ScienceDatabase entry's key/value data.
    /// Returns an empty string if the key doesn't exist.
    /// Example: entry:getKeyValue("Legs") -- returns the value if found or "" if not
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getKeyValue);
    /// Returns a table containing all key/value pairs in this ScienceDatabase entry.
    /// Warning: Duplicate keys appear only once, with the last value found.
    /// Example:
    /// entry:getKeyValues() -- returns the key/value table for this entry
    /// for k,v in pairs(kv) do print(k,v) end -- Print each key/value pair for this entry to the console
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getKeyValues);
    /// Removes all key/value pairs matching the given case-insensitive key in this ScienceDatabase entry's key/value data.
    /// If duplicate matching keys exist, this removes all of them.
    /// Example: entry:removeKey("Legs") -- removes all key/value data with the key "Legs"
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, removeKey);
    /// Sets this ScienceDatabase entry's longform description to the given string.
    /// The Database view's right column displays the longform description when its entry is selected.
    /// Example: entry:setLongDescription("This species is known for its loyalty...")
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setLongDescription);
    /// Returns this ScienceDatabase entry's longform description.
    /// Returns an empty string if no description is set.
    /// Example: entry:getLongDescription()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getLongDescription);
    /// Sets this ScienceDatabase entry's image file to the given filename.
    /// Valid values are filenames to PNG files relative to the resources/ directory.
    /// An empty string removes any set image.
    /// Example: entry:setImage("retriever.png") -- sets the entry's image to the file "resources/retriever.png"
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setImage);
    /// Returns this ScienceDatabase entry's image filename.
    /// Returns an empty string if no image is set.
    /// Example: entry:getImage()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getImage);
    /// Sets the 3D appearance, by ModelData name, used for this ScienceDatabase entry.
    /// ModelData objects define a 3D mesh, textures, adjustments, and collision box, and are loaded from scripts/model_data.lua when EmptyEpsilon is launched.
    /// Example: entry:setModelDataName("AtlasHeavyFighterYellow") -- uses the ModelData named "AtlasHeavyFighterYellow"
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setModelDataName);
}

PVector<ScienceDatabase> ScienceDatabase::science_databases;

REGISTER_MULTIPLAYER_CLASS(ScienceDatabase, "ScienceDatabase");
ScienceDatabase::ScienceDatabase()
: MultiplayerObject("ScienceDatabase")
{
    registerMemberReplication(&parent_id);
    registerMemberReplication(&name);
    registerMemberReplication(&model_data_name);
    registerMemberReplication(&long_description);
    registerMemberReplication(&image);
    registerMemberReplication(&keyValuePairs);

    science_databases.push_back(this);
    name = "???";
}

void ScienceDatabase::destroy()
{
    // if this code is used in the client, the server could try to destroy an object that has already been destroyed
    if(this->isDestroyed()) return;

    auto my_id = this->getId();
    MultiplayerObject::destroy();
    ScienceDatabase::science_databases.remove(this);

    while (true)
    {
        // we don't save a iterator between each loop as when we call ScienceDatabase::destroy our iterator may be invalidated
        auto it=find_if(ScienceDatabase::science_databases.begin(),ScienceDatabase::science_databases.end(),[my_id](P<ScienceDatabase> db){return !db->isDestroyed() && db->getParentId() == my_id;});
        if (it == ScienceDatabase::science_databases.end())
        {
            break;
        }
        (*it)->destroy();
    }
}

P<ScienceDatabase> ScienceDatabase::addEntry(string name)
{
    P<ScienceDatabase> e = new ScienceDatabase();
    e->parent_id = this->getId();
    e->setName(name);
    return e;
}

void ScienceDatabase::addKeyValue(string key, string value)
{
    keyValuePairs.push_back(KeyValue(key, value));
}

string ScienceDatabase::getKeyValue(string key)
{
    auto normalized_key = normalizeName(key);

    for (auto kv : keyValuePairs)
    {
        if (kv.getNormalizedKey() == normalized_key)
        {
            return kv.getValue();
        }
    }
    return "";
}

void ScienceDatabase::setKeyValue(string key, string value)
{
    bool is_set = false;
    auto normalized_key = normalizeName(key);

    for (auto& kv : keyValuePairs)
    {
        if (kv.getNormalizedKey() == normalized_key)
        {
            kv.setValue(value);
            is_set = true;
        }
    }
    if (!is_set) { addKeyValue(key, value); }
}

void ScienceDatabase::removeKey(string key)
{
    auto normalized_key = normalizeName(key);
    keyValuePairs.erase(std::remove_if(keyValuePairs.begin(), keyValuePairs.end(), [normalized_key](KeyValue& kv) { return kv.getNormalizedKey() == normalized_key; }), keyValuePairs.end());
}

std::map<string, string> ScienceDatabase::getKeyValues()
{
    std::map<string, string> map;
    for (auto kv : keyValuePairs)
    {
        map.insert(std::make_pair(kv.getKey(), kv.getValue()));
    }

    return map;
}

void ScienceDatabase::setLongDescription(string text)
{
    long_description = text;
}


void ScienceDatabase::setModelData(P<ModelData> model_data)
{
    this->model_data_name = model_data->getName();
}

void ScienceDatabase::setModelDataName(string model_data_name)
{
    this->model_data_name = model_data_name;
}

bool ScienceDatabase::hasModelData()
{
    return model_data_name != "";
}

P<ModelData> ScienceDatabase::getModelData()
{
    if (hasModelData())
    {
        return ModelData::getModel(model_data_name);
    }
    else
    {
        return nullptr;
    }
}

P<ScienceDatabase> ScienceDatabase::getEntryByName(string name)
{
    return queryScienceDatabase(name, this->getId());
}

P<ScienceDatabase> ScienceDatabase::getEntryById(int32_t id)
{
    P<ScienceDatabase> entry;

    for(auto sd : ScienceDatabase::science_databases)
    {
        if (sd->getId() == id)
        {
            entry = sd;
        }
    }

    return entry;
}

bool ScienceDatabase::hasEntries()
{
    for(auto sd : ScienceDatabase::science_databases)
    {
        if (sd->getParentId() == this->getId())
        {
            return true;
        }
    }

    return false;
}

PVector<ScienceDatabase> ScienceDatabase::getEntries()
{
    PVector<ScienceDatabase> entries;
    for(auto sd : ScienceDatabase::science_databases)
    {
        if (sd->getParentId() == this->getId())
        {
            entries.push_back(sd);
        }
    }

    return entries;
}

P<ScienceDatabase> ScienceDatabase::queryScienceDatabase(string name, int32_t parent_id = 0)
{
    name = normalizeName(name);

    for(auto sd : ScienceDatabase::science_databases)
    {
        if (sd->getParentId() == parent_id && sd->getNormalizedName() == name)
        {
            return sd;
        }
    }

    return nullptr;
}

static int queryScienceDatabaseById(lua_State* L)
{
    P<ScienceDatabase> entry = nullptr;
    entry = ScienceDatabase::getEntryById(luaL_checknumber(L, 1));

    if (!entry)
    {
        // No entry with this multiplayer_id.
        return 0;
    }

    return convert<P<ScienceDatabase> >::returnType(L, entry);
}

/// P<ScienceDatabase> queryScienceDatabaseById(int id)
/// Returns the ScienceDatabase entry with the given unique multiplayer_id.
/// Returns nil if no entry is found.
/// Example: queryScienceDatabaseById(4) -- returns the entry with ID 4
REGISTER_SCRIPT_FUNCTION(queryScienceDatabaseById);

static int queryScienceDatabase(lua_State* L)
{
    P<ScienceDatabase> entry = nullptr;

    for(int i=1; i<=lua_gettop(L); i++)
    {
        string segment = string(luaL_checkstring(L, i));
        entry = ScienceDatabase::queryScienceDatabase(segment, entry ? entry->getId() : 0);

        if (!entry)
        {
            // no entry at that path
            return 0;
        }
    }

    return convert<P<ScienceDatabase> >::returnType(L, entry);
}

/// P<ScienceDatabase> queryScienceDatabase(std::vector<string> path)
/// Returns the first ScienceDatabase entry with a matching case-insensitive name within the ScienceDatabase hierarchy.
/// You must provide the full path to the entry by using multiple arguments, starting with the top-level entry.
/// Returns nil if no entry is found.
/// Example: queryScienceDatabase("natural", "mine") -- returns the entry named "Mine" with the parent named "Natural"
REGISTER_SCRIPT_FUNCTION(queryScienceDatabase);

static int getScienceDatabases(lua_State* L)
{
    PVector<ScienceDatabase> entries;
    for(auto sd : ScienceDatabase::science_databases)
    {
        if (sd->getParentId() == 0)
        {
            entries.push_back(sd);
        }
    }

    return convert<PVector<ScienceDatabase>>::returnType(L, entries);;
}

/// PVector<ScienceDatabase> getScienceDatabases()
/// Returns a 1-indexed table of all ScienceDatabase entries that don't have a parent entry.
/// Use ScienceDatabase:getEntries() or ScienceDatabase:getEntryByName() to inspect the result.
/// See also queryScienceDatabase().
/// Example:
/// sdbs = getScienceDatabases() -- returns all top-level science databases
/// entry = sdbs[1] -- returns the first top-level entry
REGISTER_SCRIPT_FUNCTION(getScienceDatabases);

static string directionLabel(float direction)
{
    string name = "?";
    if (std::abs(angleDifference(0.0f, direction)) <= 45)
        name = tr("database direction", "Front");
    if (std::abs(angleDifference(90.0f, direction)) < 45)
        name = tr("database direction", "Right");
    if (std::abs(angleDifference(-90.0f, direction)) < 45)
        name = tr("database direction", "Left");
    if (std::abs(angleDifference(180.0f, direction)) <= 45)
        name = tr("database direction", "Rear");
    return name;
}

void flushDatabaseData()
{
    while(!ScienceDatabase::science_databases.empty()) {
        if (!ScienceDatabase::science_databases.back()->isDestroyed())
        {
            ScienceDatabase::science_databases.back()->destroy();
        }
        else
        {
            ScienceDatabase::science_databases.pop_back();
        }
    }
}

// Populate default ScienceDatabase entries.
void fillDefaultDatabaseData()
{
    // Populate the Factions top-level entry.
    P<ScienceDatabase> factionDatabase = new ScienceDatabase();
    factionDatabase->setName(tr("database", "Factions"));
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>()) {
        P<ScienceDatabase> entry = factionDatabase->addEntry(info.locale_name);
        for(auto [entity2, info2] : sp::ecs::Query<FactionInfo>()) {
            if (info.name == info2.name) continue;

            string stance = tr("stance", "Neutral");
            switch(info.getRelation(entity2))
            {
                case FactionRelation::Neutral: stance = tr("stance", "Neutral"); break;
                case FactionRelation::Enemy: stance = tr("stance", "Enemy"); break;
                case FactionRelation::Friendly: stance = tr("stance", "Friendly"); break;
            }
            entry->addKeyValue(info2.locale_name, stance);
        }
        entry->setLongDescription(info.description);
    }

    // Populate the Ships top-level entry.
    P<ScienceDatabase> ship_database = new ScienceDatabase();
    ship_database->setName(tr("database", "Ships"));
    ship_database->setLongDescription(tr("Spaceships are vessels capable of withstanding the dangers of travel through deep space. They can fill many functions and vary broadly in size, from small tugs to massive dreadnoughts."));

    std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::Ship);
    std::sort(template_names.begin(), template_names.end());

    std::vector<string> class_list;
    std::set<string> class_set;

    // Populate list of ship hull classes
    for(string& template_name : template_names)
    {
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);

        if (!ship_template->visible)
            continue;

        string class_name = ship_template->getClass();
        string subclass_name = ship_template->getSubClass();

        if (class_set.find(class_name) == class_set.end())
        {
            class_list.push_back(class_name);
            class_set.insert(class_name);
        }
    }

    std::sort(class_list.begin(), class_list.end());
    std::map<string, P<ScienceDatabase> > class_database_entries;

    // Populate each ship hull class with members
    for(string& class_name : class_list)
    {
        class_database_entries[class_name] = ship_database->addEntry(class_name);
    }

    // Populate each ship's entry
    for(string& template_name : template_names)
    {
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
        if (!ship_template->visible)
            continue;
        P<ScienceDatabase> entry = class_database_entries[ship_template->getClass()]->addEntry(ship_template->getLocaleName());

        entry->setModelData(ship_template->model_data);
        entry->setImage(ship_template->radar_trace);

        entry->addKeyValue(tr("database", "Class"), ship_template->getClass());
        entry->addKeyValue(tr("database", "Sub-class"), ship_template->getSubClass());
        entry->addKeyValue(tr("database", "Size"), string(int(ship_template->model_data->getRadius())));

        if (ship_template->shield_count > 0)
        {
            string shield_info = "";
            for(int n=0; n<ship_template->shield_count; n++)
            {
                if (n > 0)
                    shield_info += "/";
                shield_info += string(int(ship_template->shield_level[n]));
            }
            entry->addKeyValue(tr("database", "Shield"), shield_info);
        }

        entry->addKeyValue(tr("Hull"), string(int(ship_template->hull)));

        if (ship_template->impulse_speed > 0.0f)
        {
            entry->addKeyValue(tr("database", "Move speed"), string(ship_template->impulse_speed * 60 / 1000, 1) + " u/min");
            entry->addKeyValue(tr("database", "Reverse move speed"), string(ship_template->impulse_reverse_speed * 60 / 1000, 1) + " u/min");
        }
        if (ship_template->turn_speed > 0.0f) {
            entry->addKeyValue(tr("database", "Turn speed"), string(ship_template->turn_speed, 1) + " deg/sec");
        }
        if (ship_template->warp_speed > 0.0f)
        {
            entry->addKeyValue(tr("database", "Warp speed"), string(ship_template->warp_speed * 60 / 1000, 1) + " u/min");
        }
        if (ship_template->has_jump_drive)
        {
            entry->addKeyValue(tr("database", "Jump range"), string(ship_template->jump_drive_min_distance / 1000, 0) + " - " + string(ship_template->jump_drive_max_distance / 1000, 0) + " u");
        }

        for(int n=0; n<max_beam_weapons; n++)
        {
            if (ship_template->beams[n].getRange() > 0)
            {
                entry->addKeyValue(
                    tr("{direction} beam weapon").format({{"direction", directionLabel(ship_template->beams[n].getDirection())}}),
                    tr("database", "{damage} Dmg / {interval} sec").format({
                        {"damage", string(ship_template->beams[n].getDamage(), 1)},
                        {"interval", string(ship_template->beams[n].getCycleTime(), 1)}
                    })
                );
            }
        }

        for(int n=0; n<ship_template->weapon_tube_count; n++)
        {
            string key = tr("database", "{direction} tube");
            if (ship_template->weapon_tube[n].size == MS_Small)
            {
                key = tr("database", "{direction} small tube");
            }
            if (ship_template->weapon_tube[n].size == MS_Large)
            {
                key = tr("database", "{direction} large tube");
            }
            entry->addKeyValue(
                key.format({{"direction", directionLabel(ship_template->weapon_tube[n].direction)}}),
                tr("database", "{loadtime} sec").format({{"loadtime", string(int(ship_template->weapon_tube[n].load_time))}})
            );
        }

        for(int n=0; n < MW_Count; n++)
        {
            if (ship_template->weapon_storage[n] > 0)
            {
                entry->addKeyValue(tr("Storage {weapon}").format({{"weapon", getLocaleMissileWeaponName(EMissileWeapons(n))}}), string(ship_template->weapon_storage[n]));
            }
        }

        if (ship_template->getDescription().length() > 0)
            entry->setLongDescription(ship_template->getDescription());
    }

    // Populate the Stations top-level entry.
    P<ScienceDatabase> stations_database = new ScienceDatabase();
    stations_database->setName(tr("database", "Stations"));
    stations_database->setLongDescription(tr("Space stations are permanent, immobile structures ranging in scale from small outposts to city-sized communities. Many provide restocking and repair services to neutral and friendly ships."));

    std::vector<string> station_names = ShipTemplate::getTemplateNameList(ShipTemplate::Station);
    std::sort(template_names.begin(), template_names.end());

    // Populate each station's entry
    for(string& station_name : station_names)
    {
        P<ShipTemplate> station_template = ShipTemplate::getTemplate(station_name);

        if (!station_template->visible)
        {
            continue;
        }

        P<ScienceDatabase> entry = stations_database->addEntry(station_template->getLocaleName());

        entry->setModelData(station_template->model_data);
        entry->setImage(station_template->radar_trace);

        if (station_template->shield_count > 0)
        {
            string shield_info = "";

            for(int n = 0; n < station_template->shield_count; n++)
            {
                if (n > 0)
                {
                    shield_info += "/";
                }

                shield_info += string(int(station_template->shield_level[n]));
            }

            entry->addKeyValue(tr("database", "Shield"), shield_info);
        }

        entry->addKeyValue(tr("Hull"), string(int(station_template->hull)));

        if (station_template->getDescription().length() > 0)
        {
            entry->setLongDescription(station_template->getDescription());
        }
    }
#ifdef DEBUG
    // If debug mode is enabled, populate the ModelData entry.
    P<ScienceDatabase> models_database = new ScienceDatabase();
    models_database->setName("Models (debug)");
    for(string name : ModelData::getModelDataNames())
    {
        P<ScienceDatabase> entry = models_database->addEntry(name);
        entry->setModelDataName(name);
    }
#endif
}

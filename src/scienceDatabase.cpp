#include "scienceDatabase.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "spaceObjects/spaceship.h"

#include "scriptInterface.h"

REGISTER_SCRIPT_CLASS(ScienceDatabase)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addEntry);
    /// returns a child entry by its case-insensitive name
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getEntryByName);
    /// returns a table of all child entries in arbitrary order
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getEntries);
    /// returns true if this entry has child entries
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, hasEntries);
    /// add a new key-value pair in the center column of the database
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addKeyValue);
    /// if an entry with this key exists already, its value will be changed. If not, the pair is created.
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setKeyValue);
    /// get the value of the key value-pair with the given key. returns empty string when key does not exist.
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getKeyValue);
    /// get all the key value pairs as a table. Warning: if there are duplicate keys only appear once with the last value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getKeyValues);
    /// remove all key value pairs with the case-insensitive key value name
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, removeKey);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setLongDescription);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getLongDescription);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setImage);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, getImage);
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

ScienceDatabase::~ScienceDatabase()
{
}

void ScienceDatabase::destroy()
{
    // if this code is used in the client, the server could try to destroy an object that has already been destroyed
    if(this->isDestroyed()) return;

    auto my_id = this->getId();
    ScienceDatabase::science_databases.remove(this);
    MultiplayerObject::destroy();

    PVector<ScienceDatabase>::iterator it = ScienceDatabase::science_databases.begin();

    while(it != ScienceDatabase::science_databases.end()) {
        if (!(*it)->isDestroyed() && (*it)->getParentId() == my_id)
        {
            (*it)->destroy();
        }
        else
        {
            ++it;
        }
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

/// finds a ScienceDatabase entry by its case-insensitive name. You have to give the full path to the entry by using multiple arguments.
/// Returns nil if no entry is found.
/// e.g. local mine_db = queryScienceDatabase("Natural", "Mine")
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

/// get all ScienceDatabases that do not have a parent. Use getEntries() or getEntryByName() to navigate.
REGISTER_SCRIPT_FUNCTION(getScienceDatabases);

static string directionLabel(float direction)
{
    string name = "?";
    if (std::abs(sf::angleDifference(0.0f, direction)) <= 45)
        name = tr("database direction", "Front");
    if (std::abs(sf::angleDifference(90.0f, direction)) < 45)
        name = tr("database direction", "Right");
    if (std::abs(sf::angleDifference(-90.0f, direction)) < 45)
        name = tr("database direction", "Left");
    if (std::abs(sf::angleDifference(180.0f, direction)) <= 45)
        name = tr("database direction", "Rear");
    return name;
}

void flushDatabaseData()
{
    PVector<ScienceDatabase>::iterator it = ScienceDatabase::science_databases.begin();

    while(it != ScienceDatabase::science_databases.end()) {
        if (!(*it)->isDestroyed())
        {
            (*it)->destroy();
        }
        else
        {
            ++it;
        }
    }
    ScienceDatabase::science_databases.resize(0);
}

void fillDefaultDatabaseData()
{
    P<ScienceDatabase> factionDatabase = new ScienceDatabase();
    factionDatabase->setName(tr("database", "Factions"));
    for(unsigned int n=0; n<factionInfo.size(); n++)
    {
        P<ScienceDatabase> entry = factionDatabase->addEntry(factionInfo[n]->getLocaleName());
        for(unsigned int m=0; m<factionInfo.size(); m++)
        {
            if (n == m) continue;

            string stance = tr("stance", "Neutral");
            switch(factionInfo[n]->states[m])
            {
                case FVF_Neutral: stance = tr("stance", "Neutral"); break;
                case FVF_Enemy: stance = tr("stance", "Enemy"); break;
                case FVF_Friendly: stance = tr("stance", "Friendly"); break;
            }
            entry->addKeyValue(factionInfo[m]->getLocaleName(), stance);
        }
        entry->setLongDescription(factionInfo[n]->getDescription());
    }

    P<ScienceDatabase> shipDatabase = new ScienceDatabase();
    shipDatabase->setName(tr("database", "Ships"));

    std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::Ship);
    std::sort(template_names.begin(), template_names.end());

    std::vector<string> class_list;
    std::set<string> class_set;
    for(string& template_name : template_names)
    {
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
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
    for(string& class_name : class_list)
    {
        class_database_entries[class_name] = shipDatabase->addEntry(class_name);
    }

    for(string& template_name : template_names)
    {
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
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

        if (ship_template->impulse_speed > 0.0)
        {
            entry->addKeyValue(tr("database", "Move speed"), string(ship_template->impulse_speed * 60 / 1000, 1) + " u/min");
        }
        if (ship_template->turn_speed > 0.0) {
            entry->addKeyValue(tr("database", "Turn speed"), string(ship_template->turn_speed, 1) + " deg/sec");
        }
        if (ship_template->warp_speed > 0.0)
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
#ifdef DEBUG
    P<ScienceDatabase> models_database = new ScienceDatabase();
    models_database->setName("Models (debug)");
    for(string name : ModelData::getModelDataNames())
    {
        P<ScienceDatabase> entry = models_database->addEntry(name);
        entry->setModelDataName(name);
    }
#endif
}

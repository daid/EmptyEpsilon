#ifndef SCIENCE_DATABASE_H
#define SCIENCE_DATABASE_H

#include "engine.h"
#include "shipTemplate.h"

/*!
 * \brief An entry for the science database that is formed by a number of key value pairs.
 *  The database is build up in a tree structure, where every node can have key/value pairs and a long description.
 *  As well as a 3D model assigned to it.
 */
class ScienceDatabase : public MultiplayerObject
{
public:
    /*!
     * \brief Simple key value pair for database.
     */
    class KeyValue
    {
    public:
        string key, value;
        KeyValue() {}
        KeyValue(string key, string value) : key(key), value(value) {}
        string getValue() { return this->value; }
        void setValue(string value) { this->value = value; }
        string getKey() { return this->key; }
        void setKey(string key) {
            this->key = key;
            this->normalized_key = "";
        }

        string getNormalizedKey()
        {
            if(normalized_key == "") { normalized_key = normalizeName(key); }
            return normalized_key;
        }

        bool operator!=(const KeyValue& kv) { return key != kv.key || value != kv.value; }
    private:
        string normalized_key;
    };

    int32_t parent_id = 0;

    string name;
    std::vector<KeyValue> keyValuePairs;
    string long_description;
    string model_data_name = "";
    string image;

    ScienceDatabase();
    virtual ~ScienceDatabase();

    int32_t getId() { return this->getMultiplayerId(); }
    int32_t getParentId() { return this->parent_id; }

    void setName(string name)
    {
        this->name = name;
        this->normalized_name = "";
    }
    string getName() { return this->name; }
    string getNormalizedName()
    {
        if(normalized_name == "") { normalized_name = normalizeName(name); }
        return normalized_name;
    }

    void addKeyValue(string key, string value);
    void setKeyValue(string key, string value);
    string getKeyValue(string key);
    void removeKey(string key);
    std::map<string, string> getKeyValues();

    void setLongDescription(string text);
    string getLongDescription()
    {
        return long_description;
    }

    void setImage(string path)
    {
        image = path;
    }
    string getImage()
    {
        return image;
    }

    void setModelData(P<ModelData> model_data);
    void setModelDataName(string model_data_name);
    bool hasModelData();
    P<ModelData> getModelData();

    P<ScienceDatabase> addEntry(string name);

    virtual void destroy();

    P<ScienceDatabase> getEntryByName(string name);
    bool hasEntries();
    PVector<ScienceDatabase> getEntries();
    static P<ScienceDatabase> queryScienceDatabase(string name, int32_t parent_id);
private:
    string normalized_name; // used for sorting and querying
    string directionLabel(float direction);

    static string normalizeName(string name) {
        transform(name.begin(), name.end(), name.begin(), ::tolower);
        return name;
    }

public: /* static members */
    static PVector<ScienceDatabase> science_databases;
};

//Called during startup to fill the database with faction and ship data.
void fillDefaultDatabaseData();
void flushDatabaseData();

static inline bool operator < (P<ScienceDatabase> a, P<ScienceDatabase> b) {
    return a->getNormalizedName() < b->getNormalizedName();
}

static inline sf::Packet& operator << (sf::Packet& packet, const ScienceDatabase::KeyValue& kv) { return packet << kv.key << kv.value; }
static inline sf::Packet& operator >> (sf::Packet& packet, ScienceDatabase::KeyValue& kv) { return packet >> kv.key >> kv.value; }

#endif//SCIENCE_DATABASE_H

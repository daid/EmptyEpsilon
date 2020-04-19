#ifndef SCIENCE_DATABASE_H
#define SCIENCE_DATABASE_H

#include "engine.h"
#include "shipTemplate.h"
/*!
 * \brief Simple key value pair for database.
 */
class ScienceDatabaseKeyValue
{
public:
    string key, value;
    ScienceDatabaseKeyValue() {}
    ScienceDatabaseKeyValue(string key, string value) : key(key), value(value) {}

    bool operator!=(const ScienceDatabaseKeyValue& kv) { return key != kv.key || value != kv.value; }
};

static inline sf::Packet& operator << (sf::Packet& packet, const ScienceDatabaseKeyValue& kv) { return packet << kv.key << kv.value; }
static inline sf::Packet& operator >> (sf::Packet& packet, ScienceDatabaseKeyValue& kv) { return packet >> kv.key >> kv.value; }

/*!
 * \brief An entry for the science database that is formed by a number of key value pairs.
 *  The database is build up in a tree structure, where every node can have key/value pairs and a long description.
 *  As well as a 3D model assigned to it.
 */
class ScienceDatabase : public MultiplayerObject
{
public:
    int32_t parent_id = 0;

    string name;
    std::vector<ScienceDatabaseKeyValue> keyValuePairs;
    string longDescription;
    string model_data_name = "";
    string image;

    ScienceDatabase();
    virtual ~ScienceDatabase();

    void addKeyValue(string key, string value);
    void setLongDescription(string text);

    void setName(string name) { this->name = name; }
    void setImage(string path) {
        image = path;
    }
    P<ScienceDatabase> addEntry(string name);
    int32_t getId() { return this->getMultiplayerId(); }
    int32_t getParentId() { return this->parent_id; }
    void setModelData(P<ModelData> model_data);
    void setModelDataName(string model_data_name);
    bool hasModelData();
    P<ModelData> getModelData();
    string getName() {return this->name;}
private:
    string directionLabel(float direction);

public: /* static members */
    static PVector<ScienceDatabase> science_databases;
};

//Called during startup to fill the database with faction and ship data.
void fillDefaultDatabaseData();
void flushDatabaseData();

#endif//SCIENCE_DATABASE_H

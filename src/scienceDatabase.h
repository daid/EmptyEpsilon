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
    ScienceDatabaseKeyValue(string key, string value) : key(key), value(value) {}
};
/*!
 * \brief An entry for the science database that is formed by a number of key value pairs.
 *  The database is build up in a tree structure, where every node can have key/value pairs and a long description.
 *  As well as a 3D model assigned to it.
 */
class ScienceDatabase : public virtual PObject
{
public:
    PVector<ScienceDatabase> items;
    P<ScienceDatabase> parent;

    string name;
    std::vector<ScienceDatabaseKeyValue> keyValuePairs;
    string longDescription;
    P<ModelData> model_data;

    ScienceDatabase();
    ScienceDatabase(P<ScienceDatabase> parent, string name);
    virtual ~ScienceDatabase();

    void addKeyValue(string key, string value);
    void setLongDescription(string text);

    void setName(string name) { this->name = name; }
    P<ScienceDatabase> addEntry(string name);
    string getName() {return this->name;}
private:

public: /* static members */
    static PVector<ScienceDatabase> science_databases;
};

//Called during startup to fill the database with faction and ship data.
void fillDefaultDatabaseData();

#endif//SCIENCE_DATABASE_H

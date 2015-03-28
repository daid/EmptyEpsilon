#ifndef SCIENCE_DATABASE_H
#define SCIENCE_DATABASE_H

#include "engine.h"
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
 */
class ScienceDatabaseEntry : public virtual PObject
{
public:
    string name;
    std::vector<ScienceDatabaseKeyValue> keyValuePairs;
    string longDescription;

    ScienceDatabaseEntry(string name);
    virtual ~ScienceDatabaseEntry();

    void addKeyValue(string key, string value);
    void setLongDescription(string text);
};
/*!
 * \brief The database for science, that is formed of database entries.
 */
class ScienceDatabase : public virtual PObject
{
public:
    PVector<ScienceDatabaseEntry> items;

    ScienceDatabase();
    virtual ~ScienceDatabase();

    void setName(string name) { this->name = name; }
    P<ScienceDatabaseEntry> addEntry(string name);
    string getName() {return this->name;}
public:
    static PVector<ScienceDatabase> scienceDatabaseList;

private:
    string name;
};

//Called during startup to fill the database with faction and ship data.
void fillDefaultDatabaseData();

#endif//SCIENCE_DATABASE_H

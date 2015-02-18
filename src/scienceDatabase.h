#ifndef SCIENCE_DATABASE_H
#define SCIENCE_DATABASE_H

#include "engine.h"

class ScienceDatabaseKeyValue
{
public:
    string key, value;
    
    ScienceDatabaseKeyValue(string key, string value) : key(key), value(value) {}
};

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

class ScienceDatabase : public virtual PObject
{
public:
    string name;
    PVector<ScienceDatabaseEntry> items;
    
    ScienceDatabase();
    virtual ~ScienceDatabase();
    
    void setName(string name) { this->name = name; }
    P<ScienceDatabaseEntry> addEntry(string name);
public:
    static PVector<ScienceDatabase> scienceDatabaseList;
};

//Called during startup to fill the database with faction and ship data.
void fillDefaultDatabaseData();

#endif//SCIENCE_DATABASE_H

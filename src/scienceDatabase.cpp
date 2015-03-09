#include "scienceDatabase.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "spaceObjects/spaceship.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS_NO_CREATE(ScienceDatabaseEntry)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabaseEntry, addKeyValue);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabaseEntry, setLongDescription);
}

REGISTER_SCRIPT_CLASS(ScienceDatabase)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addEntry);
}


PVector<ScienceDatabase> ScienceDatabase::scienceDatabaseList;

ScienceDatabase::ScienceDatabase()
{
    scienceDatabaseList.push_back(this);
    name = "???";
}

ScienceDatabase::~ScienceDatabase()
{
}

P<ScienceDatabaseEntry> ScienceDatabase::addEntry(string name)
{
    P<ScienceDatabaseEntry> e = new ScienceDatabaseEntry(name);
    items.push_back(e);
    return e;
}

ScienceDatabaseEntry::ScienceDatabaseEntry(string name)
: name(name)
{
}

ScienceDatabaseEntry::~ScienceDatabaseEntry()
{
}

void ScienceDatabaseEntry::addKeyValue(string key, string value)
{
    keyValuePairs.push_back(ScienceDatabaseKeyValue(key, value));
}

void ScienceDatabaseEntry::setLongDescription(string text)
{
    longDescription = text;
}

void fillDefaultDatabaseData()
{
    P<ScienceDatabase> factionDatabase = new ScienceDatabase();
    factionDatabase->setName("Factions");
    for(unsigned int n=0; n<factionInfo.size(); n++)
    {
        P<ScienceDatabaseEntry> entry = factionDatabase->addEntry(factionInfo[n]->getName());
        for(unsigned int m=0; m<factionInfo.size(); m++)
        {
            if (n == m) continue;

            string stance = "Neutral";
            switch(factionInfo[n]->states[m])
            {
                case FVF_Neutral: stance = "Neutral"; break;
                case FVF_Enemy: stance = "Enemy"; break;
                case FVF_Friendly: stance = "Friendly"; break;
            }
            entry->addKeyValue(factionInfo[m]->getName(), stance);
        }
        entry->setLongDescription(factionInfo[n]->getDescription());
    }

    P<ScienceDatabase> shipDatabase = new ScienceDatabase();
    shipDatabase->setName("Ships");

    std::vector<string> template_names = ShipTemplate::getTemplateNameList();
    std::sort(template_names.begin(), template_names.end());
    for(unsigned int n=0; n<template_names.size(); n++)
    {
        P<ScienceDatabaseEntry> entry = shipDatabase->addEntry(template_names[n]);
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_names[n]);

        entry->addKeyValue("Size", string(int(ship_template->radius)));
        entry->addKeyValue("Shield", string(int(ship_template->frontShields)) + "/" + string(int(ship_template->rearShields)));
        entry->addKeyValue("Hull", string(int(ship_template->hull)));
        entry->addKeyValue("Move speed", string(int(ship_template->impulseSpeed)));
        entry->addKeyValue("Turn speed", string(int(ship_template->turnSpeed)));
        if (ship_template->warpSpeed > 0.0)
        {
            entry->addKeyValue("Has warp drive", "True");
            entry->addKeyValue("Warp speed", string(int(ship_template->warpSpeed)));
        }
        if (ship_template->jumpDrive)
        {
            entry->addKeyValue("Has jump drive", "True");
        }
        for(int n=0; n<maxBeamWeapons; n++)
        {
            if (ship_template->beams[n].range > 0)
            {
                string name = "?";
                if (ship_template->beams[n].direction < 45 || ship_template->beams[n].direction > 315)
                    name = "Front";
                else if (ship_template->beams[n].direction > 45 && ship_template->beams[n].direction < 135)
                    name = "Right";
                else if (ship_template->beams[n].direction > 135 && ship_template->beams[n].direction < 225)
                    name = "Rear";
                else if (ship_template->beams[n].direction > 225 && ship_template->beams[n].direction < 315)
                    name = "Left";
                entry->addKeyValue(name + " beam weapon", string(ship_template->beams[n].damage / ship_template->beams[n].cycle_time, 2) + " DPS");
            }
        }
        if (ship_template->weapon_tubes > 0)
        {
            entry->addKeyValue("Missile tubes", string(ship_template->weapon_tubes));
            entry->addKeyValue("Missile load time", string(int(ship_template->tube_load_time)));
        }
        for(int n=0; n < MW_Count; n++)
        {
            if (ship_template->weapon_storage[n] > 0)
            {
                entry->addKeyValue("Storage " + getMissileWeaponName(EMissileWeapons(n)), string(ship_template->weapon_storage[n]));
            }
        }
        if (ship_template->description.length() > 0)
            entry->setLongDescription(ship_template->description);
    }
}

#include "scienceDatabase.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "spaceObjects/spaceship.h"

#include "scriptInterface.h"

REGISTER_SCRIPT_CLASS(ScienceDatabase)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addEntry);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, addKeyValue);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScienceDatabase, setLongDescription);
}


PVector<ScienceDatabase> ScienceDatabase::science_databases;

ScienceDatabase::ScienceDatabase()
{
    science_databases.push_back(this);
    name = "???";
}

ScienceDatabase::ScienceDatabase(P<ScienceDatabase> parent, string name)
{
    this->parent = parent;
    this->name = name;
}

ScienceDatabase::~ScienceDatabase()
{
}

P<ScienceDatabase> ScienceDatabase::addEntry(string name)
{
    P<ScienceDatabase> e = new ScienceDatabase(this, name);
    items.push_back(e);
    return e;
}

void ScienceDatabase::addKeyValue(string key, string value)
{
    keyValuePairs.push_back(ScienceDatabaseKeyValue(key, value));
}

void ScienceDatabase::setLongDescription(string text)
{
    longDescription = text;
}

void fillDefaultDatabaseData()
{
    P<ScienceDatabase> factionDatabase = new ScienceDatabase();
    factionDatabase->setName("Factions");
    for(unsigned int n=0; n<factionInfo.size(); n++)
    {
        P<ScienceDatabase> entry = factionDatabase->addEntry(factionInfo[n]->getName());
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
        P<ScienceDatabase> entry = shipDatabase->addEntry(template_names[n]);
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_names[n]);
        
        entry->model_template = ship_template;

        entry->addKeyValue("Size", string(int(ship_template->model_data->getRadius())));
        string shield_info = "";
        for(int n=0; n<ship_template->shield_count; n++)
        {
            if (n > 0)
                shield_info += "/";
            shield_info += string(int(ship_template->shield_level[n]));
        }
        entry->addKeyValue("Shield", shield_info);
        entry->addKeyValue("Hull", string(int(ship_template->hull)));
        entry->addKeyValue("Move speed", string(int(ship_template->impulse_speed)));
        entry->addKeyValue("Turn speed", string(int(ship_template->turn_speed)));
        if (ship_template->warp_speed > 0.0)
        {
            entry->addKeyValue("Has warp drive", "True");
            entry->addKeyValue("Warp speed", string(int(ship_template->warp_speed)));
        }
        if (ship_template->has_jump_drive)
        {
            entry->addKeyValue("Has jump drive", "True");
        }
        for(int n=0; n<max_beam_weapons; n++)
        {
            if (ship_template->beams[n].getRange() > 0)
            {
                string name = "?";
                if (ship_template->beams[n].getDirection() < 45 || ship_template->beams[n].getDirection() > 315)
                    name = "Front";
                else if (ship_template->beams[n].getDirection() > 45 && ship_template->beams[n].getDirection() < 135)
                    name = "Right";
                else if (ship_template->beams[n].getDirection() > 135 && ship_template->beams[n].getDirection() < 225)
                    name = "Rear";
                else if (ship_template->beams[n].getDirection() > 225 && ship_template->beams[n].getDirection() < 315)
                    name = "Left";
                entry->addKeyValue(name + " beam weapon", string(ship_template->beams[n].getDamage() / ship_template->beams[n].getCycleTime(), 2) + " DPS");
            }
        }
        if (ship_template->weapon_tube_count > 0)
        {
            entry->addKeyValue("Missile tubes", string(ship_template->weapon_tube_count));
            entry->addKeyValue("Missile load time", string(int(ship_template->weapon_tube[0].load_time)));
        }
        for(int n=0; n < MW_Count; n++)
        {
            if (ship_template->weapon_storage[n] > 0)
            {
                entry->addKeyValue("Storage " + getMissileWeaponName(EMissileWeapons(n)), string(ship_template->weapon_storage[n]));
            }
        }
        if (ship_template->getDescription().length() > 0)
            entry->setLongDescription(ship_template->getDescription());
    }
}

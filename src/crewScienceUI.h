#ifndef CREW_SCIENCE_UI
#define CREW_SCIENCE_UI

#include "crewUI.h"

enum ScienceDatabaseType
{
    SDT_None,
    SDT_Factions,
    SDT_Ships,
    SDT_Weapons
};

class CrewScienceUI : public CrewUI
{
    P<SpaceObject> scienceTarget;
    float science_radar_distance;
    bool science_show_radar;
    ScienceDatabaseType science_database_type;
    int science_sub_selection;

public:
    CrewScienceUI();
    
    virtual void onCrewUI();
};

#endif//CREW_SCIENCE_UI

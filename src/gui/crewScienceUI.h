#ifndef CREW_SCIENCE_UI
#define CREW_SCIENCE_UI

#include "crewUI.h"

class CrewScienceUI : public CrewUI
{
    P<SpaceObject> scienceTarget;
    int science_radar_zoom;
    enum {
        radar,
        database
    } science_section;
    int science_database_selection;
    int science_sub_selection;
    int science_description_line_nr;

public:
    CrewScienceUI();
    
    virtual void onCrewUI();
    
    void onRadarUI();
    void onDatabaseUI();
};

#endif//CREW_SCIENCE_UI

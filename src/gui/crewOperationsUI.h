#ifndef CREW_OPERATIONS_UI
#define CREW_OPERATIONS_UI

#include "crewUI.h"
#include "crewCommsUI.h"

class CrewOperationsUI : public CrewUI
{
    CommsStationMode mode;
    
    CommsSelectionType selection_type;
    P<SpaceObject> selection_object;
    unsigned int selection_waypoint_index;
    int science_radar_zoom;
    enum {
        radar,
        database
    } science_section;
    int science_database_selection;
    int science_sub_selection;
    int science_description_line_nr;

    string comms_player_message;
    unsigned int comms_reply_view_offset;
public:
    CrewOperationsUI();
    
    virtual void onCrewUI();
    
    void onRadarUI();
    void onDatabaseUI();
    void drawCommsChannel();
};

#endif//CREW_SCIENCE_UI

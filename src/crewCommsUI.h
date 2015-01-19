#ifndef CREW_COMMS_UI
#define CREW_COMMS_UI

#include "crewUI.h"

enum CommsStationMode
{
    mode_default,
    mode_place_waypoint
};
enum CommsSelectionType
{
    select_none,
    select_object,
    select_waypoint
};

class CrewCommsUI : public CrewUI
{
    sf::Vector2f previous_mouse;
    sf::Vector2f radar_view_position;
    float radar_distance;
    CommsStationMode mode;
    CommsSelectionType selection_type;
    P<SpaceObject> selection_object;
    unsigned int selection_waypoint_index;
    
    string comms_player_message;
    unsigned int comms_reply_view_offset;
public:
    CrewCommsUI();
    
    virtual void onCrewUI();
    
    void drawCommsRadar();
    void drawCommsChannel();
};

#endif//CREW_SCIENCE_UI


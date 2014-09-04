#ifndef CREW_COMMS_UI
#define CREW_COMMS_UI

#include "crewUI.h"

enum CommsStationMode
{
    mode_default,
    mode_place_waypoint
};

class CrewCommsUI : public CrewUI
{
    sf::Vector2f previous_mouse;
    sf::Vector2f radar_view_position;
    CommsStationMode mode;
    CommsOpenChannelType comms_open_channel_type;
    string comms_player_message;
public:
    CrewCommsUI();
    
    virtual void onCrewUI();
};

#endif//CREW_SCIENCE_UI


#ifndef CREW_COMMS_UI
#define CREW_COMMS_UI

#include "crewUI.h"

class CrewCommsUI : public CrewUI
{
    CommsOpenChannelType comms_open_channel_type;
    string comms_player_message;
public:
    CrewCommsUI();
    
    virtual void onCrewUI();
};

#endif//CREW_SCIENCE_UI


#ifndef CREW_SINGLE_PILOT_H
#define CREW_SINGLE_PILOT_H

#include "crewUI.h"

class CrewSinglePilotUI : public CrewUI
{
    float jump_distance;
    float cruise_control_setpoint;
    EMissileWeapons tube_load_type;
    string comms_player_message;
public:
    CrewSinglePilotUI();
    
    virtual void onCrewUI();
};


#endif//CREW_SINGLE_PILOT_H

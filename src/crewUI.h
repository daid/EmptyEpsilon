#ifndef CREW_UI_H
#define CREW_UI_H

#include "mainUI.h"
#include "playerInfo.h"
#include "spaceship.h"
#include "repairCrew.h"

enum CommsOpenChannelType
{
    OCT_None,
    OCT_Station,
    OCT_FriendlyShip,
    OCT_NeutralShip,
    OCT_EnemyShip,
    OCT_UnknownShip,
};

class CrewUI : public MainUI
{
    ECrewPosition showPosition;
    EMissileWeapons tubeLoadType;
    float jumpDistance;
    P<RepairCrew> selected_crew;
    
    P<SpaceObject> scienceTarget;
    float scienceRadarDistance;
    
    CommsOpenChannelType comms_open_channel_type;
public:
    CrewUI();
    
    virtual void onGui();
    
    void helmsUI();
    void weaponsUI();
    void engineeringUI();
    void scienceUI();
    void commsUI();
};

#endif//CREW_UI_H

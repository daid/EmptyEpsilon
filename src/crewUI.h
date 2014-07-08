#ifndef CREW_UI_H
#define CREW_UI_H

#include "mainUIBase.h"
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

class CrewUI : public MainUIBase
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

    void singlePilotUI();
    
    
    void impulseSlider(sf::FloatRect rect, float text_size);
    void warpSlider(sf::FloatRect rect, float text_size);
    void jumpSlider(sf::FloatRect rect, float text_size);
    void dockingButton(sf::FloatRect rect, float text_size);
    void weaponTube(int n, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size);
};

#endif//CREW_UI_H

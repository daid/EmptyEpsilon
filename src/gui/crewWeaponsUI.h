#ifndef CREW_WEAPONS_UI
#define CREW_WEAPONS_UI

#include "crewUI.h"

class CrewWeaponsUI : public CrewUI
{
public:
    EMissileWeapons tube_load_type;
    float missile_target_angle;
    bool missile_targeting;
    
    CrewWeaponsUI();
    
    virtual void onCrewUI();
    virtual void onPauseHelpGui();
};

#endif//CREW_WEAPONS_UI

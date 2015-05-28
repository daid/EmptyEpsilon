#ifndef CREW_TACTICAL_UI
#define CREW_TACTICAL_UI

#include "crewUI.h"
#include "crewHelmsUI.h"

class CrewTacticalUI : public CrewUI
{
public:
    EMissileWeapons tube_load_type;
    float missile_target_angle;
    bool missile_targeting;
    
    float jump_distance;
    float ghost_delay;
    std::vector<HelmsGhostDot> ghost_dot;
    
    CrewTacticalUI();
    
    virtual void update(float delta);
    virtual void onCrewUI();
};

#endif//CREW_HELMS_UI

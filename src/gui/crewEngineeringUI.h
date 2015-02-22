#ifndef CREW_ENGINEERING_UI
#define CREW_ENGINEERING_UI

#include "crewUI.h"

class CrewEngineeringUI : public CrewUI
{
    P<RepairCrew> selected_crew;
    bool self_destruct_open;
    
    ESystem selected_system;
    int shield_new_frequency;
public:
    CrewEngineeringUI();
    
    virtual void onCrewUI();
    virtual void onPauseHelpGui();
};

#endif//CREW_ENGINEERING_UI

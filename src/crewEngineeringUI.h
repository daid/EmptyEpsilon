#ifndef CREW_ENGINEERING_UI
#define CREW_ENGINEERING_UI

#include "crewUI.h"

class CrewEngineeringUI : public CrewUI
{
public:
    P<RepairCrew> selected_crew;
    
    ESystem selected_system;
    int shield_new_frequency;
    
    CrewEngineeringUI();
    
    virtual void onCrewUI();
};

#endif//CREW_ENGINEERING_UI

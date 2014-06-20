#ifndef CREW_UI_H
#define CREW_UI_H

#include "mainUI.h"
#include "playerInfo.h"
#include "spaceship.h"

class CrewUI : public MainUI
{
    ECrewPosition showPosition;
    EMissileWeapons tubeLoadType;
    float jumpDistance;
    P<SpaceObject> scienceTarget;
public:
    CrewUI();
    
    virtual void onGui();
    
    void helmsUI();
    void weaponsUI();
    void scienceUI();
};
#endif//CREW_UI_H

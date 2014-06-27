#ifndef CREW_UI_H
#define CREW_UI_H

#include "mainUI.h"
#include "playerInfo.h"
#include "spaceship.h"

class CrewUI : public MainUI
{
    ECrewPosition show_position;
    EMissileWeapons tubeLoadType;
    float jump_distance;
public:
    CrewUI();

    virtual void onGui();

    void helmsUI();
    void tacticalUI();
};
#endif//CREW_UI_H

#ifndef SHIP_SELECTION_SCREEN_H
#define SHIP_SELECTION_SCREEN_H

#include "gui.h"
#include "playerInfo.h"

class ShipSelectionScreen : public GUI
{
public:
    ShipSelectionScreen();
    
    virtual void onGui();
};

#endif//SHIP_SELECTION_SCREEN_H

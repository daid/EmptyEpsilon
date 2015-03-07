#ifndef SHIP_SELECTION_SCREEN_H
#define SHIP_SELECTION_SCREEN_H

#include "gui.h"

class ShipSelectionScreen : public GUI
{
    int ship_template_index;                //Server only
    bool alternative_screen_selection;
    int window_angle;
public:
    ShipSelectionScreen();
    
    virtual void onGui();
    
    bool canDoMainScreen() { return PostProcessor::isEnabled() && sf::Shader::isAvailable(); }
};

#endif//SHIP_SELECTION_SCREEN_H

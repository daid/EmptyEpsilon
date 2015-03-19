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

    /**!
     * \brief check if this console can be mainscreen.
     * Being a main screen requires a bit more than the normal GUI, so we need to do some checks.
     */
    bool canDoMainScreen() { return PostProcessor::isEnabled() && sf::Shader::isAvailable(); }
};

#endif//SHIP_SELECTION_SCREEN_H

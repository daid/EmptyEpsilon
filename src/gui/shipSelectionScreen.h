#ifndef SHIP_SELECTION_SCREEN_H
#define SHIP_SELECTION_SCREEN_H

#include "gui.h"

class ShipSelectionScreen : public GUI
{
    int ship_template_index;                //Server only
    
    enum EScreenSelection
    {
        SS_MIN = -1,
        SS_6players,
        SS_1player,
        SS_Other,
        SS_MAX
    };
    
    EScreenSelection screen_selection;
    int window_angle;
public:
    ShipSelectionScreen();

    virtual void onGui();

private:
    /**!
     * \brief check if this console can be mainscreen.
     * Being a main screen requires a bit more than the normal GUI, so we need to do some checks.
     */
    bool canDoMainScreen() { return PostProcessor::isEnabled() && sf::Shader::isAvailable(); }
    
    void selectCrewPosition(bool main_screen_option, int crew_pos_min, int crew_pos_max);
};

#endif//SHIP_SELECTION_SCREEN_H

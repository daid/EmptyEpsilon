#ifndef SHIP_SELECTION_SCREEN_H
#define SHIP_SELECTION_SCREEN_H

#include "spaceObjects/playerSpaceship.h"
#include "gui2.h"

class ShipSelectionScreen : public GuiCanvas, public Updatable
{
private:
    GuiLabel* no_ships_label;
    GuiListbox* player_ship_list;
    GuiButton* ready_button;
    
    GuiToggleButton* main_screen_button;
    GuiToggleButton* crew_position_button[max_crew_positions];
    
    enum EScreenSelection
    {
        SS_MIN = -1,
        SS_6players,
        SS_4players,
        SS_1player,
        SS_Other,
        SS_MAX
    };
    
    EScreenSelection screen_selection;
    int window_angle;
    
public:
    ShipSelectionScreen();

    virtual void update(float delta);
private:
    /**!
     * \brief check if this console can be mainscreen.
     * Being a main screen requires a bit more than the normal GUI, so we need to do some checks.
     */
    bool canDoMainScreen() { return PostProcessor::isEnabled() && sf::Shader::isAvailable(); }
    
    void updateReadyButton();
};

#endif//SHIP_SELECTION_SCREEN_H

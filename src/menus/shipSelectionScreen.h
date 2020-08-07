#ifndef SHIP_SELECTION_SCREEN_H
#define SHIP_SELECTION_SCREEN_H

#include "playerInfo.h"
#include "gui/gui2_canvas.h"

class GuiAutoLayout;
class GuiLabel;
class GuiListbox;
class GuiOverlay;
class GuiSelector;
class GuiSlider;
class GuiPanel;
class GuiButton;
class GuiToggleButton;
class GuiTextEntry;

class ShipSelectionScreen : public GuiCanvas, public Updatable
{
private:
    GuiAutoLayout* container;
    GuiElement* left_container;
    GuiElement* right_container;

    GuiLabel* no_ships_label;
    GuiListbox* player_ship_list;
    GuiButton* ready_button;
    GuiSelector* crew_type_selector;
    GuiOverlay* password_overlay;
    GuiLabel* password_label;
    GuiPanel* password_entry_box;
    GuiTextEntry* password_entry;
    GuiButton* password_entry_ok;
    GuiButton* password_cancel;
    GuiButton* password_confirmation;

    GuiToggleButton* main_screen_button;
    GuiToggleButton* crew_position_button[max_crew_positions];
    GuiToggleButton* main_screen_controls_button;
    GuiToggleButton* game_master_button;
    GuiToggleButton* spectator_button;
    GuiAutoLayout* window_button_row;
    GuiToggleButton* window_button;
    GuiSlider* window_angle;
    GuiLabel* window_angle_label;
    GuiToggleButton* topdown_button;
    GuiToggleButton* cinematic_view_button;

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
    void updateCrewTypeOptions();

    void onReadyClick();
};

#endif//SHIP_SELECTION_SCREEN_H

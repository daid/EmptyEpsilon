#ifndef SHIP_SELECTION_SCREEN_H
#define SHIP_SELECTION_SCREEN_H

#include "playerInfo.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_panel.h"

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
class CrewPositionSelection;
class PasswordDialog;

class ShipSelectionScreen : public GuiCanvas, public Updatable
{
private:
    GuiAutoLayout* container;
    GuiElement* left_container;
    GuiElement* right_container;

    GuiLabel* no_ships_label;
    GuiListbox* player_ship_list;

    GuiOverlay* crew_position_selection_overlay;
    CrewPositionSelection* crew_position_selection;

    PasswordDialog* password_dialog;
public:
    ShipSelectionScreen();

    virtual void update(float delta) override;
};

class CrewPositionSelection : public GuiPanel
{
public:
    CrewPositionSelection(GuiContainer* owner, string id, int window_index, std::function<void()> on_cancel, std::function<void()> on_ready);

    virtual void onUpdate() override;
    void spawnUI(RenderLayer* render_layer);
private:
    void disableAllExcept(GuiToggleButton* button);

    int window_index;
    GuiButton* ready_button;
    GuiToggleButton* main_screen_button;
    GuiToggleButton* crew_position_button[max_crew_positions];
    GuiToggleButton* main_screen_controls_button;
    GuiToggleButton* window_button;
    GuiSlider* window_angle;
    GuiLabel* window_angle_label;
    GuiToggleButton* topdown_button;
};

#endif//SHIP_SELECTION_SCREEN_H

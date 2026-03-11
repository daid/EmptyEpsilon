#pragma once

#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_panel.h"

class GuiScrollText;
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
    void joinPlayerShip(string entity_string);

    GuiElement* container;
    GuiElement* left_container;
    GuiElement* left_column;
    GuiPanel* left_panel;
    GuiPanel* left_panel_2;
    GuiLabel* left_panel_2_label;
    GuiScrollText* left_panel_2_text;
    GuiElement* right_container;
    GuiElement* right_column;
    GuiPanel* right_panel;
    GuiPanel* right_panel_2;
    GuiLabel* right_panel_2_label;
    GuiScrollText* right_panel_2_text;

    GuiElement* ship_action_row;
    GuiSelector* ship_template_selector;
    GuiButton* ship_template_button;
    GuiLabel* no_ships_label;
    GuiListbox* player_ship_list;

    GuiOverlay* crew_position_selection_overlay;
    CrewPositionSelection* crew_position_selection;

    PasswordDialog* password_dialog;
    std::vector<GameGlobalInfo::ShipSpawnInfo> ship_spawn_info;

    int last_selection_index = -1;
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
    void unselectSingleOptions();

    int window_index;
    GuiButton* ready_button;
    GuiToggleButton* main_screen_button;
    GuiToggleButton* crew_position_button[static_cast<int>(CrewPosition::MAX)];
    GuiToggleButton* main_screen_controls_button;
    GuiToggleButton* window_button;
    GuiTextEntry* window_angle;
    GuiLabel* window_angle_label;
    GuiScrollText* station_players;
};

class SecondMonitorScreen : public GuiCanvas, public Updatable
{
public:
    SecondMonitorScreen(int window_index);

    virtual void update(float delta) override;
private:
    int monitor_index;
    CrewPositionSelection* crew_position_selection = nullptr;
};


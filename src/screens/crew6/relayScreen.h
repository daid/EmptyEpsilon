#ifndef RELAY_SCREEN_H
#define RELAY_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"

class GuiRadarView;
class GuiKeyValueDisplay;
class GuiAutoLayout;
class GuiButton;
class GuiToggleButton;
class GuiSlider;
class GuiLabel;
class GuiHackingDialog;
class GuiTextEntry;

class RelayScreen : public GuiOverlay
{
private:
    enum EMode
    {
        TargetSelection,
        WaypointPlacement,
        LaunchProbe,
        MoveWaypoint
    };

    EMode mode;
    TargetsContainer targets;
    int drag_waypoint_index;
    GuiRadarView* radar;

    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_faction;

    GuiKeyValueDisplay* info_reputation;
    GuiAutoLayout* option_buttons;
    GuiButton* hack_target_button;
    GuiToggleButton* link_to_science_button;
    GuiToggleButton* link_to_3D_port_button;
    GuiButton* delete_waypoint_button;
    GuiButton* launch_probe_button;
    GuiAutoLayout* view_controls;
    bool sector_name_custom;
    GuiTextEntry* sector_name_text;

    GuiToggleButton* alert_level_button;
    std::vector<GuiButton*> alert_level_buttons;

    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;
    
    GuiHackingDialog* hacking_dialog;

    sf::Vector2f mouse_down_position;
    const float max_distance = 10000000.0f;
    const float min_distance = 6250.0f;
public:
    RelayScreen(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//RELAY_SCREEN_H

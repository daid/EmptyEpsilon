#ifndef RELAY_SCREEN_H
#define RELAY_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"

class GuiRadarView;
class GuiKeyValueDisplay;
class GuiButton;
class GuiToggleButton;
class GuiSlider;
class GuiLabel;
class GuiHackingDialog;

class RelayScreen : public GuiOverlay
{
public:
    enum class Variant
    {
        relay,
        stategic_map,
        captains_map
    };

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
    GuiKeyValueDisplay* info_clock;
    GuiElement* option_buttons;
    GuiButton* hack_target_button;
    GuiToggleButton* link_to_science_button;
    GuiButton* delete_waypoint_button;
    GuiButton* launch_probe_button;

    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;

    GuiHackingDialog* hacking_dialog;

    glm::vec2 mouse_down_position{};

    Variant variant;

public:
    RelayScreen(GuiContainer* owner, Variant variant);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//RELAY_SCREEN_H

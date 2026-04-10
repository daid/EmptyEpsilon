#pragma once

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"

class GuiButton;
class GuiHackingDialog;
class GuiKeyValueDisplay;
class GuiLabel;
class GuiRadarView;
class GuiRadarZoomSlider;
class GuiSlider;
class GuiToggleButton;

class RelayScreen : public GuiOverlay
{
private:
    enum EMode
    {
        TargetSelection,
        WaypointPlacement,
        LaunchProbe,
        MoveWaypoint
    } mode = TargetSelection;

    const float MIN_ZOOM_DISTANCE = 6250.0f;
    const float MAX_ZOOM_DISTANCE = 50000.0f;

    TargetsContainer targets;
    int drag_waypoint_index;
    GuiRadarView* radar;

    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_faction;

    GuiKeyValueDisplay* info_reputation;
    GuiKeyValueDisplay* info_clock;
    GuiElement* option_buttons;
    GuiButton* cancel_button;
    GuiButton* hack_target_button;
    GuiToggleButton* link_to_science_button;
    GuiButton* delete_waypoint_button;
    GuiButton* launch_probe_button;
    GuiToggleButton* center_button;

    GuiRadarZoomSlider* zoom_slider;
    GuiLabel* zoom_label;

    GuiHackingDialog* hacking_dialog;

    glm::vec2 mouse_down_position{};
public:
    RelayScreen(GuiContainer* owner, bool allow_comms);

    virtual void onDraw(sp::RenderTarget& target) override;
};

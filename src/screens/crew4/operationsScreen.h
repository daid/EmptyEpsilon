#pragma once

#include <array>
#include "gui/gui2_overlay.h"

class GuiElement;
class GuiOverlay;
class GuiKeyValueDisplay;
class GuiButton;
class GuiSelector;
class GuiToggleButton;
class ScienceScreen;

class OperationScreen : public GuiOverlay
{
private:
    enum EMode
    {
        TargetSelection,
        WaypointPlacement,
        MoveWaypoint
    };

    EMode mode;
    int drag_waypoint_index;
    int drag_waypoint_set;
    int active_waypoint_set = 1;

    ScienceScreen* science;

    GuiKeyValueDisplay* info_reputation;
    GuiKeyValueDisplay* info_clock;

    GuiToggleButton* place_waypoint_button;
    GuiButton* delete_waypoint_button;
    GuiSelector* waypoint_set_selector;
    std::array<GuiToggleButton*, 4> waypoint_set_buttons{};
    GuiToggleButton* route_toggle;

    glm::vec2 mouse_down_position{0, 0};
public:
    OperationScreen(GuiContainer* owner);
    virtual void onDraw(sp::RenderTarget& target) override;
};

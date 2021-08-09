#ifndef OPERATIONS_SCREEN_H
#define OPERATIONS_SCREEN_H

#include "gui/gui2_overlay.h"

class GuiOverlay;
class GuiKeyValueDisplay;
class GuiButton;
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

    ScienceScreen* science;

    GuiKeyValueDisplay* info_reputation;
    GuiKeyValueDisplay* info_clock;

    GuiButton* place_waypoint_button;
    GuiButton* delete_waypoint_button;

    glm::vec2 mouse_down_position{0, 0};
public:
    OperationScreen(GuiContainer* owner);
    virtual void onDraw(sp::RenderTarget& target);
};
#endif//OPERATIONS_SCREEN_H

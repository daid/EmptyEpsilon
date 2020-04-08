#ifndef OPERATIONS_SCREEN_H
#define OPERATIONS_SCREEN_H

#include "gui/gui2_overlay.h"

class GuiOverlay;
class GuiKeyValueDisplay;
class GuiButton;

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

    GuiButton* place_waypoint_button;
    GuiButton* delete_waypoint_button;

    sf::Vector2f mouse_down_position;
public:
    OperationScreen(GuiContainer* owner);
};
#endif//OPERATIONS_SCREEN_H

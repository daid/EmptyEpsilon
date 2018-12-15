#ifndef NAVIGATION_SCREEN_H
#define NAVIGATION_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "screenComponents/navigationView.h"
#include "gui/gui2_overlay.h"

class NavigationView;
class GuiKeyValueDisplay;
class GuiAutoLayout;
class GuiButton;
class GuiToggleButton;
class GuiSlider;
class GuiLabel;
class GuiTextEntry;

class NavigationScreen : public GuiOverlay
{
private:
    enum EMode
    {
        TargetSelection,
        WaypointPlacement,
        MoveWaypoint
    };

    EMode mode;
    TargetsContainer targets;
    int drag_waypoint_index;
    NavigationView* radar;
    GuiAutoLayout* option_buttons;
    GuiAutoLayout* waypoint_place_controls;
    GuiToggleButton* waypoint_place_multiple_toggle;
    GuiAutoLayout* view_controls;
    GuiButton* delete_waypoint_button;

    bool position_text_custom;
    GuiTextEntry* position_text;

    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;
    
    sf::Vector2f mouse_down_position;
    const float max_distance = 10000000.0f; // has to match relay max_distance to have same zoom scale
    const float min_distance = 909090.0f; // not to zoom in too much
    
    void stopPlacingWaypoint();
    void placeWaypoint(sf::Vector2f position);
public:
    NavigationScreen(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//NAVIGATION_SCREEN_H

#ifndef RELAY_SCREEN_H
#define RELAY_SCREEN_H

#include "gui/gui2.h"

#include "screenComponents/targetsContainer.h"
#include "gui/gui2.h"

class GuiRadarView;

class RelayScreen : public GuiOverlay
{
private:
    enum EMode
    {
        TargetSelection,
        WaypointPlacement,
        LaunchProbe
    };
    
    EMode mode;
    TargetsContainer targets;
    GuiRadarView* radar;

    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_distance;
    GuiKeyValueDisplay* info_heading;
    GuiKeyValueDisplay* info_relspeed;

    GuiKeyValueDisplay* info_faction;
    GuiKeyValueDisplay* info_type;
    GuiKeyValueDisplay* info_shields;
    
    GuiKeyValueDisplay* info_reputation;
    GuiAutoLayout* option_buttons;
    GuiButton* delete_waypoint_button;
    GuiButton* launch_probe_button;
    
    GuiToggleButton* alert_level_button;
    std::vector<GuiButton*> alert_level_buttons;
    
    sf::Vector2f mouse_down_position;
public:
    RelayScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//RELAY_SCREEN_H


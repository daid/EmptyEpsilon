#ifndef RELAY_SCREEN_H
#define RELAY_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"

class GuiRadarView;
class GuiKeyValueDisplay;
class GuiAutoLayout;
class GuiButton;
class GuiToggleButton;

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
    GuiKeyValueDisplay* info_faction;

    GuiKeyValueDisplay* info_reputation;
    GuiAutoLayout* option_buttons;
    GuiButton* link_to_science_button;
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


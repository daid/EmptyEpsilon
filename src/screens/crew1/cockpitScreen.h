#ifndef COCKPIT_SCREEN_H
#define COCKPIT_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiViewport3D;
class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;
class GuiCombatManeuver;
class GuiLabel;
class GuiImage;
class GuiAutoLayout;

class CockpitScreen : public GuiOverlay
{
private:
    enum ECockpitView
    {
        CV_Forward = 0,
        CV_Right,
        CV_Back,
        CV_Left,
    };

    ECockpitView view_state;
    bool first_person;
    bool targeting_mode;
    GuiViewport3D* viewport;

    GuiAutoLayout* stats;
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiKeyValueDisplay* shields_display;

    GuiAutoLayout* target_stats;
    GuiKeyValueDisplay* target_callsign_display;
    GuiKeyValueDisplay* target_distance_display;
    GuiKeyValueDisplay* target_bearing_display;
    GuiKeyValueDisplay* target_relspeed_display;
    GuiKeyValueDisplay* target_faction_display;
    GuiKeyValueDisplay* target_type_display;
    GuiKeyValueDisplay* target_shields_display;
    GuiKeyValueDisplay* target_hull_display;

    GuiElement* warp_controls;
    GuiElement* jump_controls;
    GuiCombatManeuver* combat_maneuver;

    TargetsContainer targets;
    GuiRadarView* radar;
    float view_rotation;
    float target_rotation;
    GuiRotationDial* missile_aim;
    GuiRotationDial* steering_wheel;
    GuiImage* missile_aim_icon;
    GuiImage* steering_wheel_icon;
    GuiMissileTubeControls* tube_controls;
    GuiToggleButton* lock_aim;
    GuiToggleButton* targeting_mode_button;
public:
    CockpitScreen(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual bool onJoystickAxis(const AxisAction& axisAction) override;

    void setTargetingMode(bool new_mode);
};

#endif//COCKPIT_SCREEN_H

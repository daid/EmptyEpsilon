#ifndef COCKPIT_VIEW_H
#define COCKPIT_VIEW_H

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

class CockpitView : public GuiOverlay
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

    GuiAutoLayout* ship_stats;
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiKeyValueDisplay* shields_display;
    GuiKeyValueDisplay* reputation_display;
    GuiKeyValueDisplay* clock_display;

    GuiAutoLayout* target_stats;
    GuiKeyValueDisplay* target_callsign;
    GuiKeyValueDisplay* target_distance;
    GuiKeyValueDisplay* target_bearing;
    GuiKeyValueDisplay* target_relspeed;
    GuiKeyValueDisplay* target_faction;
    GuiKeyValueDisplay* target_type;
    GuiKeyValueDisplay* target_shields;
    GuiKeyValueDisplay* target_hull;

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
    CockpitView(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual bool onJoystickAxis(const AxisAction& axisAction) override;

    void setTargetingMode(bool new_mode);
};

#endif//COCKPIT_VIEW_H

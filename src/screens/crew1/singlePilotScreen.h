#ifndef SINGLE_PILOT_SCREEN_H
#define SINGLE_PILOT_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/radarView.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiViewport3D;
class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;
class GuiViewport3D;

class SinglePilotScreen : public GuiOverlay
{
private:
    const float RADAR_SIZE_LARGE = 650.0f;
    const float RADAR_SIZE_SMALL = 300.0f;
    bool first_person = false;

    GuiOverlay* background_gradient;
    GuiOverlay* background_crosses;
    GuiViewport3D* viewport;

    TargetsContainer targets;
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiKeyValueDisplay* shields_display;
    GuiRadarView* radar;
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;
    GuiToggleButton* lock_aim;
    GuiElement* warp_controls;
    GuiElement* jump_controls;

    void toggleRadarSize(float size);
    void toggleViewport(bool is_visible);
public:
    SinglePilotScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual bool onJoystickAxis(const AxisAction& axisAction) override;
};

#endif//SINGLE_PILOT_SCREEN_H

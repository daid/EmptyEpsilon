#ifndef WEAPONS_SCREEN_H
#define WEAPONS_SCREEN_H

#include "screens/baseShipScreen.h"
#include "screenComponents/radarView.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiMissileTubeControls;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;

class WeaponsScreen : public BaseShipScreen
{
private:
    TargetsContainer targets;
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* front_shield_display;
    GuiKeyValueDisplay* rear_shield_display;
    GuiRadarView* radar;
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;
    GuiToggleButton* lock_aim;
    GuiElement* beam_info_box;
public:
    WeaponsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//WEAPONS_SCREEN_H

#ifndef TACTICAL_SCREEN_H
#define TACTICAL_SCREEN_H

#include "screens/baseShipScreen.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;

class TacticalScreen : public BaseShipScreen
{
private:
    GuiElement* warp_controls;
    GuiElement* jump_controls;

    TargetsContainer targets;
    GuiRadarView* radar;
    GuiRotationDial* missile_aim;
    GuiMissileTubeControls* tube_controls;
    GuiToggleButton* lock_aim;
    bool drag_rotate;
public:
    TacticalScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//TACTICAL_SCREEN_H

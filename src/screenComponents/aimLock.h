#ifndef GUI_AIM_LOCK_H
#define GUI_AIM_LOCK_H

#include "gui/gui2_togglebutton.h"

class GuiMissileTubeControls;
class GuiRotationDial;

class AimLockButton : public GuiToggleButton
{
public:
    AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim);
private:
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;
};

#endif//GUI_AIM_LOCK_H

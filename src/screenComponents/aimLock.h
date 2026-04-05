#pragma once

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_rotationdial.h"

class GuiMissileTubeControls;
class GuiRadarView;

class AimLockButton : public GuiToggleButton
{
public:
    AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim);

    virtual void onUpdate() override;
private:
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;

    void setAimLock(bool value);
};


class AimLock : public GuiRotationDial
{
public:
    AimLock(GuiContainer* owner, string id, GuiRadarView* radar, float min_value, float max_value, float start_value, func_t func);

    virtual void onUpdate() override;
private:
    GuiRadarView* radar;
};

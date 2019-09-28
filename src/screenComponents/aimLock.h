#ifndef AIM_LOCK_H
#define AIM_LOCK_H

#include "gui/gui2_togglebutton.h"

class GuiMissileTubeControls;
class GuiRotationDial;

class AimLockButton : public GuiToggleButton
{
public:
    AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
private:
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;

    void setAimLock(bool value);
};

#endif//AIM_LOCK_H

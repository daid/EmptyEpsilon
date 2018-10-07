#ifndef AIM_LOCK_H
#define AIM_LOCK_H

#include "gui/gui2_togglebutton.h"
#include "P.h"

class GuiMissileTubeControls;
class GuiRotationDial;
class PlayerSpaceship;
class AimLockButton : public GuiToggleButton
{
private:
    P<PlayerSpaceship>& target_spaceship;
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;

public:
    AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim, P<PlayerSpaceship>& targetSpaceship);
    
    virtual void onHotkey(const HotkeyResult& key) override;
private:
    void setAimLock(bool value);
};

#endif//AIM_LOCK_H

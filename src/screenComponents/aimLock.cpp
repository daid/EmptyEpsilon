#include "aimLock.h"

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "missileTubeControls.h"

#include "gui/gui2_rotationdial.h"

AimLockButton::AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim, P<PlayerSpaceship>& targetSpaceship)
: GuiToggleButton(owner, id, "Lock", [this](bool value){setAimLock(value);}), target_spaceship(targetSpaceship)
{
    this->tube_controls = tube_controls;
    this->missile_aim = missile_aim;

    setValue(true);
    setIcon("gui/icons/lock");
}

void AimLockButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "WEAPONS" && target_spaceship)
    {
        if (key.hotkey == "TOGGLE_AIM_LOCK")
        {
            setAimLock(!getValue());
            setValue(!getValue());
        }
        if (key.hotkey == "ENABLE_AIM_LOCK")
        {
            setAimLock(true);
            setValue(true);
        }
        if (key.hotkey == "DISABLE_AIM_LOCK")
        {
            setAimLock(false);
            setValue(false);
        }
    }
}

void AimLockButton::setAimLock(bool value)
{
    this->tube_controls->setManualAim(!value);
    this->missile_aim->setVisible(!value);
    if (!value && target_spaceship)
    {
        this->missile_aim->setValue(target_spaceship->getRotation());
        this->tube_controls->setMissileTargetAngle(target_spaceship->getRotation());
    }
}

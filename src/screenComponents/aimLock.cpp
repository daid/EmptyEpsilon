#include "aimLock.h"

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "missileTubeControls.h"

#include "gui/gui2_rotationdial.h"

AimLockButton::AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim)
: GuiToggleButton(owner, id, "Lock", [this](bool value)
    {
        setAimLock(value);
    })
{
    this->tube_controls = tube_controls;
    this->missile_aim = missile_aim;

    setValue(!my_spaceship->manual_aim);
    setIcon("gui/icons/lock");
}

void AimLockButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "WEAPONS" && my_spaceship)
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

    if (!value && my_spaceship)
    {
        this->missile_aim->setValue(my_spaceship->getRotation());
        this->tube_controls->setMissileTargetAngle(my_spaceship->getRotation());
    }
}

void AimLockButton::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship) {
        setValue(!my_spaceship->manual_aim);
    }

    GuiToggleButton::onDraw(window);
}

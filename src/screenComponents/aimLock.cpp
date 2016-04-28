#include "aimLock.h"

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "missileTubeControls.h"

#include "gui/gui2_rotationdial.h"

AimLockButton::AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim)
: GuiToggleButton(owner, id, "Lock", [this](bool value)
    {
        this->tube_controls->setManualAim(!value);
        this->missile_aim->setVisible(!value);
        if (!value && my_spaceship)
        {
            this->missile_aim->setValue(my_spaceship->getRotation());
            this->tube_controls->setMissileTargetAngle(my_spaceship->getRotation());
        }
    })
{
    this->tube_controls = tube_controls;
    this->missile_aim = missile_aim;

    setValue(true);
    setIcon("gui/icons/lock");
}

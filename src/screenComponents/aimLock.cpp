#include "aimLock.h"
#include <i18n.h>

#include "playerInfo.h"
#include "missileTubeControls.h"
#include "components/collision.h"

#include "gui/theme.h"
#include "screenComponents/radarView.h"

AimLockButton::AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim)
: GuiToggleButton(owner, id, tr("missile", "Lock"), [this](bool value)
    {
        setAimLock(value);
    }
)
{
    this->tube_controls = tube_controls;
    this->missile_aim = missile_aim;

    setValue(true);
    setIcon("gui/icons/lock");
}

void AimLockButton::onUpdate()
{
    if (!isVisible()) return;

    // Handle AimLock visibility keybinds.
    if (keys.weapons_toggle_aim_lock.getDown())
    {
        setAimLock(!getValue());
        setValue(!getValue());
    }

    if (keys.weapons_enable_aim_lock.getDown())
    {
        setAimLock(true);
        setValue(true);
    }

    if (keys.weapons_disable_aim_lock.getDown())
    {
        setAimLock(false);
        setValue(false);
    }
}

void AimLockButton::setAimLock(bool value)
{
    this->tube_controls->setManualAim(!value);
    this->missile_aim->setVisible(!value);
    if (!value && my_spaceship)
    {
        if (auto transform = my_spaceship.getComponent<sp::Transform>())
        {
            this->missile_aim->setValue(transform->getRotation());
            this->tube_controls->setMissileTargetAngle(transform->getRotation());
        }
    }
}


AimLock::AimLock(GuiContainer* owner, string id, GuiRadarView* radar, float min_value, float max_value, float start_value, func_t func)
: GuiRotationDial(owner, id, min_value, max_value, start_value, 0.0f, 0.0f, func), radar(radar)
{
    back_style = theme->getStyle("rotationdial.back");
    front_style = theme->getStyle("rotationdial.front");
}

void AimLock::onUpdate()
{
    rotation_offset = radar->getViewRotation();
}

#include <i18n.h>
#include "aimLock.h"

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "missileTubeControls.h"

#include "gui/gui2_rotationdial.h"

AimLockButton::AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim)
: GuiToggleButton(owner, id, tr("missile","Lock"), [this](bool value)
    {
        setAimLock(value);
    })
{
    this->tube_controls = tube_controls;
    this->missile_aim = missile_aim;

    setValue(true);
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


AimLock::AimLock(GuiContainer* owner, string id, GuiRadarView* radar, float min_value, float max_value, float start_value, func_t func)
: GuiRotationDial(owner, id, min_value, max_value, start_value, func), radar(radar)
{
}

void AimLock::onDraw(sp::RenderTarget& renderer)
{
    auto center = getCenterPoint();
    float view_rotation = radar->getViewRotation();
    float radius = std::min(rect.size.x, rect.size.y);

    renderer.drawSprite("gui/widget/dial_background.png", center, radius);
    renderer.drawRotatedSprite("gui/widget/dial_button.png", center, radius, (value - min_value) / (max_value - min_value) * 360.0f - view_rotation);
}

bool AimLock::onMouseDown(glm::vec2 position)
{
    return GuiRotationDial::onMouseDown(position);
}

void AimLock::onMouseDrag(glm::vec2 position)
{
    float view_rotation = radar->getViewRotation();

    auto center = getCenterPoint();

    auto diff = position - center;

    float new_value = ((vec2ToAngle(diff) + 90.0f) + view_rotation) / 360.0f;
    if (new_value < 0.0f)
        new_value += 1.0f;
    if (new_value > 1.0f)
        new_value -= 1.0f;
    new_value = min_value + (max_value - min_value) * new_value;
    if (value != new_value)
    {
        value = new_value;
        if (func)
            func(value);
    }
}

void AimLock::onMouseUp(glm::vec2 position)
{
}

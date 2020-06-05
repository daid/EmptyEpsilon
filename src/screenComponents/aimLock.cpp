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

void AimLock::onDraw(sf::RenderTarget& window)
{
    sf::Vector2f center = getCenterPoint();
    float view_rotation = radar->getViewRotation();
    float radius = std::min(rect.width, rect.height) / 2.0f;
    
    sf::Sprite sprite;
    textureManager.setTexture(sprite, "dial_background.png");
    sprite.setPosition(center);
    sprite.setScale(radius * 2 / sprite.getTextureRect().height, radius * 2 / sprite.getTextureRect().height);
    window.draw(sprite);

    textureManager.setTexture(sprite, "dial_button.png");
    sprite.setPosition(center);
    sprite.setScale(radius * 2 / sprite.getTextureRect().height, radius * 2 / sprite.getTextureRect().height);
    sprite.setRotation((value - min_value) / (max_value - min_value) * 360.0f - view_rotation);
    window.draw(sprite);
}

bool AimLock::onMouseDown(sf::Vector2f position)
{
    return GuiRotationDial::onMouseDown(position);
}

void AimLock::onMouseDrag(sf::Vector2f position)
{
    float view_rotation = radar->getViewRotation();

    sf::Vector2f center = getCenterPoint();
    
    sf::Vector2f diff = position - center;

    float new_value = ((sf::vector2ToAngle(diff) + 90.0f) + view_rotation) / 360.0f;
    if (new_value < 0.0f)
        new_value += 1.0f;
    new_value = min_value + (max_value - min_value) * new_value;
    if (min_value < max_value)
    {
        if (new_value < min_value)
            new_value = min_value;
        if (new_value > max_value)
            new_value = max_value;
    }else{
        if (new_value > min_value)
            new_value = min_value;
        if (new_value < max_value)
            new_value = max_value;
    }
    if (value != new_value)
    {
        value = new_value;
        if (func)
            func(value);
    }
}

void AimLock::onMouseUp(sf::Vector2f position)
{
}


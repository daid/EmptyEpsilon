#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "combatManeuver.h"
#include "powerDamageIndicator.h"
#include "snapSlider.h"

#include "gui/gui2_progressbar.h"

GuiCombatManeuver::GuiCombatManeuver(GuiContainer* owner, string id, P<PlayerSpaceship>& targetSpaceship)
: GuiElement(owner, id), target_spaceship(targetSpaceship)
{
    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 1.0, 0.0);
    charge_bar->setColor(sf::Color(192, 192, 192, 64));
    charge_bar->setPosition(0, 0, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(charge_bar, "CHARGE_LABEL", "Combat maneuver", 20))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    slider = new GuiSnapSlider2D(this, id + "_STRAFE", sf::Vector2f(-1.0, 1.0), sf::Vector2f(1.0, 0.0), sf::Vector2f(0.0, 0.0), [this](sf::Vector2f value) {
        if (target_spaceship)
        {
            target_spaceship->commandCombatManeuverBoost(value.y);
            target_spaceship->commandCombatManeuverStrafe(value.x);
        }
    });
    slider->setPosition(0, -50, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 165);
    
    (new GuiPowerDamageIndicator(slider, id + "_STRAFE_INDICATOR", SYS_Maneuver, ACenterLeft, target_spaceship))->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(slider, id + "_BOOST_INDICATOR", SYS_Impulse, ABottomLeft, target_spaceship))->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiCombatManeuver::onDraw(sf::RenderTarget& window)
{
    if (target_spaceship)
    {
        if (target_spaceship->combat_maneuver_boost_speed <= 0.0 && target_spaceship->combat_maneuver_strafe_speed <= 0.0)
        {
            charge_bar->hide();
            slider->hide();
        }else{
            charge_bar->setValue(target_spaceship->combat_maneuver_charge)->show();
            slider->show();
        }
    }
}

void GuiCombatManeuver::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && target_spaceship)
    {
        if (key.hotkey == "COMBAT_LEFT")
        {}//TODO
        else if (key.hotkey == "COMBAT_RIGHT")
        {}//TODO
        else if (key.hotkey == "COMBAT_BOOST")
        {}//TODO
    }
}

void GuiCombatManeuver::setBoostValue(float value)
{
    slider->setValue(sf::Vector2f(slider->getValue().x, value));
}

void GuiCombatManeuver::setStrafeValue(float value)
{
    slider->setValue(sf::Vector2f(value, slider->getValue().y));
}

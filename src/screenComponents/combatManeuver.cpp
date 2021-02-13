#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "combatManeuver.h"
#include "powerDamageIndicator.h"
#include "snapSlider.h"

#include "gui/gui2_progressbar.h"

GuiCombatManeuver::GuiCombatManeuver(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 1.0, 0.0);
    charge_bar->setColor(sf::Color(192, 192, 192, 64));
    charge_bar->setPosition(0, 0, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(charge_bar, "CHARGE_LABEL", tr("Combat maneuver"), 20))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    slider = new GuiSnapSlider2D(this, id + "_STRAFE", sf::Vector2f(-1.0, 1.0), sf::Vector2f(1.0, 0.0), sf::Vector2f(0.0, 0.0), [](sf::Vector2f value) {
        if (my_spaceship)
        {
            my_spaceship->commandCombatManeuverBoost(value.y);
            my_spaceship->commandCombatManeuverStrafe(value.x);
        }
    });
    slider->setPosition(0, -50, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 165);

    was_strafe_key_pressed = false;
    was_boost_key_pressed = false;

    (new GuiPowerDamageIndicator(slider, id + "_STRAFE_INDICATOR", SYS_Maneuver, ACenterLeft))->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(slider, id + "_BOOST_INDICATOR", SYS_Impulse, ABottomLeft))->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiCombatManeuver::onUpdate()
{
    // Only if this ship has combat maneuvers...
    if (my_spaceship && my_spaceship->getCanCombatManeuver())
    {
        // Show these controls.
        setVisible(true);
        sf::Vector2f new_value = slider->getValue();
        bool is_strafe_key_pressed = false;
        bool is_boost_key_pressed = false;

        // Implement hotkeys in the update loop.
        // onHotkey doesn't support reading isKeyPressed, but we want to retain
        // hotkey mapping, so it's implemented in onUpdate with isKeyPressed.

        // Adjust lateral value on left/right hotkeys.
        if (sf::Keyboard::isKeyPressed(hotkeys.getKeyByHotkey("HELMS", "COMBAT_LEFT")))
        {
            new_value.x = -1.0f;
            was_strafe_key_pressed = true;
            is_strafe_key_pressed = true;
        }
        else if (sf::Keyboard::isKeyPressed(hotkeys.getKeyByHotkey("HELMS", "COMBAT_RIGHT")))
        {
            new_value.x = 1.0f;
            was_strafe_key_pressed = true;
            is_strafe_key_pressed = true;
        }
        else if (was_strafe_key_pressed && !is_strafe_key_pressed)
        {
            // If either was pressed but isn't now, reset to 0.
            // Otherwise, do nothing.
            was_strafe_key_pressed = false;
            new_value.x = 0.0f;
        }

        // Adjust boost on boost hotkey.
        if (sf::Keyboard::isKeyPressed(hotkeys.getKeyByHotkey("HELMS", "COMBAT_BOOST")))
        {
            new_value.y = 1.0f;
            was_boost_key_pressed = true;
            is_boost_key_pressed = true;
        }
        else if (was_boost_key_pressed && !is_boost_key_pressed)
        {
            // If boost was pressed but isn't now, reset to 0.
            // Otherwise, do nothing.
            was_boost_key_pressed = false;
            new_value.y = 0.0f;
        }

        // Apply values.
        slider->setValue(new_value);
        my_spaceship->commandCombatManeuverStrafe(new_value.x);
        my_spaceship->commandCombatManeuverBoost(new_value.y);
    }
}

void GuiCombatManeuver::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->combat_maneuver_boost_speed <= 0.0 && my_spaceship->combat_maneuver_strafe_speed <= 0.0)
        {
            charge_bar->hide();
            slider->hide();
        }else{
            charge_bar->setValue(my_spaceship->combat_maneuver_charge)->show();
            slider->show();
        }
    }
}

void GuiCombatManeuver::onHotkey(const HotkeyResult& key)
{
    // Hotkeys handled in onUpdate.
}

void GuiCombatManeuver::setBoostValue(float value)
{
    slider->setValue(sf::Vector2f(slider->getValue().x, value));
}

void GuiCombatManeuver::setStrafeValue(float value)
{
    slider->setValue(sf::Vector2f(value, slider->getValue().y));
}

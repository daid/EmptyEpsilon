#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "combatManeuver.h"
#include "powerDamageIndicator.h"
#include "snapSlider.h"
#include "preferenceManager.h"
#include "gui/gui2_progressbar.h"

GuiCombatManeuver::GuiCombatManeuver(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
	string combat_left_key=PreferencesManager::get("HOTKEY.HELMS.COMBAT_LEFT");
	string combat_right_key=PreferencesManager::get("HOTKEY.HELMS.COMBAT_RIGHT");
	string combat_boost_key=PreferencesManager::get("HOTKEY.HELMS.COMBAT_BOOST");

	combat_left_keycode=HotkeyConfig::stringToKeycode(combat_left_key);
	combat_right_keycode=HotkeyConfig::stringToKeycode(combat_right_key);
	combat_boost_keycode=HotkeyConfig::stringToKeycode(combat_boost_key);

    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 1.0, 0.0);
    charge_bar->setColor(sf::Color(192, 192, 192, 64));
    charge_bar->setPosition(0, 0, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(charge_bar, "CHARGE_LABEL", "Combat maneuver", 20))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    slider = new GuiSnapSlider2D(this, id + "_STRAFE", sf::Vector2f(-1.0, 1.0), sf::Vector2f(1.0, 0.0), sf::Vector2f(0.0, 0.0), [](sf::Vector2f value) {
        if (my_spaceship)
        {
            my_spaceship->commandCombatManeuverBoost(value.y);
            my_spaceship->commandCombatManeuverStrafe(value.x);
        }
    });
    slider->setPosition(0, -50, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 165);
    
    (new GuiPowerDamageIndicator(slider, id + "_STRAFE_INDICATOR", SYS_Maneuver, ACenterLeft))->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(slider, id + "_BOOST_INDICATOR", SYS_Impulse, ABottomLeft))->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiCombatManeuver::onDraw(sf::RenderTarget& window)
{
	// combat maneuver hotkeys
	if (slider->getValue().x ==0 && slider->getValue().y==0)
	{
		if (!strafing)
		{
			if (sf::Keyboard::isKeyPressed(combat_left_keycode))
			{
				strafing=true;
				my_spaceship->commandCombatManeuverStrafe(-1.0);
			}
			else if (sf::Keyboard::isKeyPressed(combat_right_keycode))
			{
				strafing=true;
				my_spaceship->commandCombatManeuverStrafe(1.0);
			}
		}
		else if (!sf::Keyboard::isKeyPressed(combat_right_keycode) && !sf::Keyboard::isKeyPressed(combat_left_keycode))
		{
			strafing=false;
			my_spaceship->commandCombatManeuverStrafe(0.0);
		}

		if (sf::Keyboard::isKeyPressed(combat_boost_keycode) && !boosting)
		{
			boosting=true;
			my_spaceship->commandCombatManeuverBoost(1.0);
		}

		if (!sf::Keyboard::isKeyPressed(combat_boost_keycode) && boosting){
			boosting=false;
			my_spaceship->commandCombatManeuverBoost(0.0);
		}
	}

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
    if (key.category == "HELMS" && my_spaceship)
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

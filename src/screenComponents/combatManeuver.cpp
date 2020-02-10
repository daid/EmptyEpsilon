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
	static std::vector<std::pair<string, sf::Keyboard::Key> > sfml_key_names = {
	    {"A", sf::Keyboard::A},
	    {"B", sf::Keyboard::B},
	    {"C", sf::Keyboard::C},
	    {"D", sf::Keyboard::D},
	    {"E", sf::Keyboard::E},
	    {"F", sf::Keyboard::F},
	    {"G", sf::Keyboard::G},
	    {"H", sf::Keyboard::H},
	    {"I", sf::Keyboard::I},
	    {"J", sf::Keyboard::J},
	    {"K", sf::Keyboard::K},
	    {"L", sf::Keyboard::L},
	    {"M", sf::Keyboard::M},
	    {"N", sf::Keyboard::N},
	    {"O", sf::Keyboard::O},
	    {"P", sf::Keyboard::P},
	    {"Q", sf::Keyboard::Q},
	    {"R", sf::Keyboard::R},
	    {"S", sf::Keyboard::S},
	    {"T", sf::Keyboard::T},
	    {"U", sf::Keyboard::U},
	    {"V", sf::Keyboard::V},
	    {"W", sf::Keyboard::W},
	    {"X", sf::Keyboard::X},
	    {"Y", sf::Keyboard::Y},
	    {"Z", sf::Keyboard::Z},
	    {"Num0", sf::Keyboard::Num0},
	    {"Num1", sf::Keyboard::Num1},
	    {"Num2", sf::Keyboard::Num2},
	    {"Num3", sf::Keyboard::Num3},
	    {"Num4", sf::Keyboard::Num4},
	    {"Num5", sf::Keyboard::Num5},
	    {"Num6", sf::Keyboard::Num6},
	    {"Num7", sf::Keyboard::Num7},
	    {"Num8", sf::Keyboard::Num8},
	    {"Num9", sf::Keyboard::Num9},
	    {"Escape", sf::Keyboard::Escape},
	    {"LControl", sf::Keyboard::LControl},
	    {"LShift", sf::Keyboard::LShift},
	    {"LAlt", sf::Keyboard::LAlt},
	    {"LSystem", sf::Keyboard::LSystem},
	    {"RControl", sf::Keyboard::RControl},
	    {"RShift", sf::Keyboard::RShift},
	    {"RAlt", sf::Keyboard::RAlt},
	    {"RSystem", sf::Keyboard::RSystem},
	    {"Menu", sf::Keyboard::Menu},
	    {"LBracket", sf::Keyboard::LBracket},
	    {"RBracket", sf::Keyboard::RBracket},
	    {"SemiColon", sf::Keyboard::SemiColon},
	    {"Comma", sf::Keyboard::Comma},
	    {"Period", sf::Keyboard::Period},
	    {"Quote", sf::Keyboard::Quote},
	    {"Slash", sf::Keyboard::Slash},
	    {"BackSlash", sf::Keyboard::BackSlash},
	    {"Tilde", sf::Keyboard::Tilde},
	    {"Equal", sf::Keyboard::Equal},
	    {"Dash", sf::Keyboard::Dash},
	    {"Space", sf::Keyboard::Space},
	    {"Return", sf::Keyboard::Return},
	    {"BackSpace", sf::Keyboard::BackSpace},
	    {"Tab", sf::Keyboard::Tab},
	    {"PageUp", sf::Keyboard::PageUp},
	    {"PageDown", sf::Keyboard::PageDown},
	    {"End", sf::Keyboard::End},
	    {"Home", sf::Keyboard::Home},
	    {"Insert", sf::Keyboard::Insert},
	    {"Delete", sf::Keyboard::Delete},
	    {"Add", sf::Keyboard::Add},
	    {"Subtract", sf::Keyboard::Subtract},
	    {"Multiply", sf::Keyboard::Multiply},
	    {"Divide", sf::Keyboard::Divide},
	    {"Left", sf::Keyboard::Left},
	    {"Right", sf::Keyboard::Right},
	    {"Up", sf::Keyboard::Up},
	    {"Down", sf::Keyboard::Down},
	    {"Numpad0", sf::Keyboard::Numpad0},
	    {"Numpad1", sf::Keyboard::Numpad1},
	    {"Numpad2", sf::Keyboard::Numpad2},
	    {"Numpad3", sf::Keyboard::Numpad3},
	    {"Numpad4", sf::Keyboard::Numpad4},
	    {"Numpad5", sf::Keyboard::Numpad5},
	    {"Numpad6", sf::Keyboard::Numpad6},
	    {"Numpad7", sf::Keyboard::Numpad7},
	    {"Numpad8", sf::Keyboard::Numpad8},
	    {"Numpad9", sf::Keyboard::Numpad9},
	    {"F1", sf::Keyboard::F1},
	    {"F2", sf::Keyboard::F2},
	    {"F3", sf::Keyboard::F3},
	    {"F4", sf::Keyboard::F4},
	    {"F5", sf::Keyboard::F5},
	    {"F6", sf::Keyboard::F6},
	    {"F7", sf::Keyboard::F7},
	    {"F8", sf::Keyboard::F8},
	    {"F9", sf::Keyboard::F9},
	    {"F10", sf::Keyboard::F10},
	    {"F11", sf::Keyboard::F11},
	    {"F12", sf::Keyboard::F12},
	    {"F13", sf::Keyboard::F13},
	    {"F14", sf::Keyboard::F14},
	    {"F15", sf::Keyboard::F15},
	    {"Pause", sf::Keyboard::Pause},
	};

	string combat_left_key=PreferencesManager::get("HOTKEY.HELMS.COMBAT_LEFT");
	string combat_right_key=PreferencesManager::get("HOTKEY.HELMS.COMBAT_RIGHT");
	string combat_boost_key=PreferencesManager::get("HOTKEY.HELMS.COMBAT_BOOST");

	for(auto key_name : sfml_key_names)
    {
		if (key_name.first == combat_left_key){
			combat_left_keycode=key_name.second;
		}
		if (key_name.first == combat_right_key){
			combat_right_keycode=key_name.second;
		}
		if (key_name.first == combat_boost_key){
			combat_boost_keycode=key_name.second;
		}
	}

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
	float strafe_amount=0.0;
	float boost_amount=0.0;
	if (sf::Keyboard::isKeyPressed(combat_left_keycode)){
		strafe_amount=-1.0;
	}
	if (sf::Keyboard::isKeyPressed(combat_right_keycode)){
		strafe_amount=1.0;
	}
	if (sf::Keyboard::isKeyPressed(combat_boost_keycode)){
		boost_amount=1.0;
	}
	setStrafeValue(strafe_amount);
	my_spaceship->commandCombatManeuverStrafe(strafe_amount);
	setBoostValue(boost_amount);
	my_spaceship->commandCombatManeuverBoost(boost_amount);


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

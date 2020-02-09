#ifndef COMBAT_MANEUVER_H
#define COMBAT_MANEUVER_H

#include "gui/gui2_element.h"

class GuiSnapSlider2D;
class GuiProgressbar;

class GuiCombatManeuver : public GuiElement
{
private:
    GuiSnapSlider2D* slider;
    GuiProgressbar* charge_bar;
	string combat_left_key;
	string combat_right_key;
	string combat_boost_key;
	sf::Keyboard::Key combat_left_keycode;
	sf::Keyboard::Key combat_right_keycode;
	sf::Keyboard::Key combat_boost_keycode;
public:
    GuiCombatManeuver(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    
    void setBoostValue(float value);
    void setStrafeValue(float value);
};

#endif//COMBAT_MANEUVER_H

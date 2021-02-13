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
    bool was_strafe_key_pressed;
    bool was_boost_key_pressed;

public:
    GuiCombatManeuver(GuiContainer* owner, string id);

    virtual void onUpdate() override;
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;

    void setBoostValue(float value);
    void setStrafeValue(float value);
};

#endif//COMBAT_MANEUVER_H

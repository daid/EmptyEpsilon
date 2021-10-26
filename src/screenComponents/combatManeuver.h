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
    bool hotkey_strafe_active = false;
    bool hotkey_boost_active = false;
public:
    GuiCombatManeuver(GuiContainer* owner, string id);

    virtual void onUpdate() override;
    virtual void onDraw(sp::RenderTarget& target) override;

    void setBoostValue(float value);
    void setStrafeValue(float value);
};

#endif//COMBAT_MANEUVER_H

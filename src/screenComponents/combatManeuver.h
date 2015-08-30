#ifndef GUI_COMBAT_MANEUVER_H
#define GUI_COMBAT_MANEUVER_H

#include "gui/gui2.h"
#include "snapSlider.h"

class GuiCombatManeuver : public GuiElement
{
private:
    GuiSnapSlider* boost_slider;
    GuiSnapSlider* strafe_slider;
public:
    GuiProgressbar* charge_bar;
public:
    GuiCombatManeuver(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
    void setBoostValue(float value) { boost_slider->setValue(value); }
    void setStrafeValue(float value) { strafe_slider->setValue(value); }
};

#endif//GUI_COMBAT_MANEUVER_H

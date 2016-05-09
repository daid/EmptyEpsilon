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
    charge_bar->setColor(sf::Color(192, 192, 192));
    charge_bar->setPosition(0, 0, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(charge_bar, "CHARGE_LABEL", "Combat maneuver", 20))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    strafe_slider = new GuiSnapSlider(this, id + "_STRAFE", -1.0, 1.0, 0.0, [](float value) {
        if (my_spaceship)
            my_spaceship->commandCombatManeuverStrafe(value);
    });
    strafe_slider->setPosition(0, -50, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);

    boost_slider = new GuiSnapSlider(this, id + "_BOOST", 1.0, 0.0, 0.0, [](float value) {
        if (my_spaceship)
            my_spaceship->commandCombatManeuverBoost(value);
    });
    boost_slider->setPosition(0, -100, ABottomCenter)->setSize(50, 165);
    
    (new GuiPowerDamageIndicator(strafe_slider, id + "_STRAFE_INDICATOR", SYS_Maneuver, ACenterLeft))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiPowerDamageIndicator(boost_slider, id + "_BOOST_INDICATOR", SYS_Impulse, ABottomLeft))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiCombatManeuver::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->combat_maneuver_boost_speed <= 0.0 && my_spaceship->combat_maneuver_strafe_speed <= 0.0)
        {
            charge_bar->hide();
            strafe_slider->hide();
            boost_slider->hide();
        }else{
            charge_bar->setValue(my_spaceship->combat_maneuver_charge)->show();
            strafe_slider->setVisible(my_spaceship->combat_maneuver_strafe_speed > 0.0f);
            boost_slider->setVisible(my_spaceship->combat_maneuver_boost_speed > 0.0f);
        }
    }
}

void GuiCombatManeuver::setBoostValue(float value)
{
    boost_slider->setValue(value);
}

void GuiCombatManeuver::setStrafeValue(float value)
{
    strafe_slider->setValue(value);
}

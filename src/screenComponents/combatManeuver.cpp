#include "playerInfo.h"
#include "combatManeuver.h"
#include "snapSlider.h"
#include "powerDamageIndicator.h"

GuiCombatManeuver::GuiCombatManeuver(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 1.0, 0.0);
    charge_bar->setPosition(0, 0, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(charge_bar, "CHARGE_LABEL", "Combat maneuver", 20))->setTextColor(sf::Color::Black)->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiSnapSlider(this, id + "_STRAFE", -1.0, 1.0, 0.0, [](float value) {
        if (my_spaceship)
            my_spaceship->commandCombatManeuverStrafe(value);
    }))->setPosition(0, -50, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);

    (new GuiSnapSlider(this, id + "_BOOST", 1.0, 0.0, 0.0, [](float value) {
        if (my_spaceship)
            my_spaceship->commandCombatManeuverBoost(value);
    }))->setPosition(0, -100, ABottomCenter)->setSize(50, 165);
    
    (new GuiPowerDamageIndicator(this, id + "_STRAFE_INDICATOR", SYS_Maneuver))->setPosition(0, -50, ABottomCenter)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiPowerDamageIndicator(this, id + "_BOOST_INDICATOR", SYS_Impulse))->setPosition(0, -100, ABottomCenter)->setSize(50, 165);
}

void GuiCombatManeuver::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        charge_bar->setValue(my_spaceship->combat_maneuver_charge);
}

#include "playerInfo.h"
#include "shieldsEnableButton.h"
#include "powerDamageIndicator.h"

GuiShieldsEnableButton::GuiShieldsEnableButton(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    button = new GuiButton(this, id + "_BUTTON", "Shields: ON", []() {
        if (my_spaceship)
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
    });
    button->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    bar = new GuiProgressbar(this, id + "_BAR", 0.0, PlayerSpaceship::shield_calibration_time, 0);
    bar->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(bar, id + "_CALIBRATING_LABEL", "Calibrating", 30))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_PDI", SYS_FrontShield))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiShieldsEnableButton::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->shield_calibration_delay > 0.0)
        {
            button->hide();
            bar->show();
            bar->setValue(my_spaceship->shield_calibration_delay);
        }
        else
        {
            button->show();
            bar->hide();
            button->setText(my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF");
        }
    }
}

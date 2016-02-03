#include <libintl.h>

#include "playerInfo.h"
#include "jumpControls.h"
#include "powerDamageIndicator.h"

GuiJumpControls::GuiJumpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", SpaceShip::jump_drive_max_distance, SpaceShip::jump_drive_min_distance, 10.0, nullptr);
    slider->setPosition(0, -50, ABottomLeft)->setSize(50, GuiElement::GuiSizeMax);

    charge_bar = new GuiProgressbar(this, id + "_CHARGE", SpaceShip::jump_drive_min_distance, SpaceShip::jump_drive_max_distance, SpaceShip::jump_drive_min_distance);
    charge_bar->setPosition(0, -50, ABottomLeft)->setSize(50, GuiElement::GuiSizeMax);
    charge_bar->hide();

    label = new GuiLabel(this, id + "_LABEL", gettext("Distance: 10.0"), 30);
    label->setVertical()->setPosition(50, -50, ABottomLeft)->setSize(40, GuiElement::GuiSizeMax);

    button = new GuiButton(this, id + "_BUTTON", gettext("Jump"), [this]() {
        my_spaceship->commandJump(slider->getValue());
    });
    button->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);

    (new GuiBox(this, id + "_BOX"))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_JumpDrive))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiJumpControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->jump_delay > 0.0)
        {
            label->setText(gettext("Jump in: ") + string(int(ceilf(my_spaceship->jump_delay))));
            slider->disable();
            button->disable();
            charge_bar->hide();
        }else if (my_spaceship->jump_drive_charge < SpaceShip::jump_drive_max_distance)
        {
            label->setText(gettext("Charging..."));
            slider->hide();
            button->disable();
            charge_bar->setValue(my_spaceship->jump_drive_charge)->show();
        }else{
            label->setText(gettext("Distance: ") + string(slider->getValue(), 1) + "km");
            slider->enable()->show();
            button->enable();
            charge_bar->hide();
        }
    }
}

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "jumpControls.h"
#include "powerDamageIndicator.h"

#include "gui/gui2_slider.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_button.h"

GuiJumpControls::GuiJumpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 5000.0, 50000.0, 10000.0, nullptr);
    slider->setPosition(0, -50, ABottomLeft)->setSize(50, GuiElement::GuiSizeMax);
    
    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 50000.0, 0.0);
    charge_bar->setPosition(0, -50, ABottomLeft)->setSize(50, GuiElement::GuiSizeMax);
    charge_bar->hide();
    
    label = new GuiKeyValueDisplay(this, id + "_LABEL", 0.5, "Distance", "10.0");
    label->setTextSize(30)->setPosition(50, -50, ABottomLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    button = new GuiButton(this, id + "_BUTTON", "Jump", [this]() {
        my_spaceship->commandJump(slider->getValue());
    });
    button->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    
    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_JumpDrive, ATopCenter))->setPosition(0, -50, ABottomLeft)->setSize(50, GuiElement::GuiSizeMax);
}

void GuiJumpControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->jump_delay > 0.0)
        {
            label->setKey("Jump in");
            label->setValue(string(int(ceilf(my_spaceship->jump_delay))));
            slider->disable();
            button->disable();
            charge_bar->hide();
        }else if (my_spaceship->jump_drive_charge < my_spaceship->jump_drive_max_distance)
        {
            label->setKey("Charging");
            label->setValue("...");
            slider->hide();
            button->disable();
            charge_bar->setRange(0.0, my_spaceship->jump_drive_max_distance);
            charge_bar->setValue(my_spaceship->jump_drive_charge)->show();
        }else{
            label->setKey("Distance");
            label->setValue(string(slider->getValue() / 1000.0, 1) + DISTANCE_UNIT_1K);
            slider->enable()->show();
            slider->setRange(my_spaceship->jump_drive_max_distance, my_spaceship->jump_drive_min_distance);
            button->enable();
            charge_bar->hide();
        }
    }
}

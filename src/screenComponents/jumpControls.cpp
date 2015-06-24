#include "playerInfo.h"
#include "jumpControls.h"
#include "powerDamageIndicator.h"

GuiJumpControls::GuiJumpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 40.0, 5.0, 10.0, nullptr);
    slider->setPosition(0, -50, ABottomLeft)->setSize(50, GuiElement::GuiSizeMax);
    
    label = new GuiLabel(this, id + "_LABEL", "Distance: 10.0", 30);
    label->setVertical()->setPosition(50, -50, ABottomLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    button = new GuiButton(this, id + "_BUTTON", "Jump", [this]() {
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
            label->setText("Jump in: " + string(int(ceilf(my_spaceship->jump_delay))));
            slider->disable();
            button->disable();
        }else{
            label->setText("Distance: " + string(slider->getValue(), 1) + "km");
            slider->enable();
            button->enable();
        }
    }
}

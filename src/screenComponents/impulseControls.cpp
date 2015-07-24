#include "playerInfo.h"
#include "impulseControls.h"
#include "powerDamageIndicator.h"

GuiImpulseControls::GuiImpulseControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 1.0, -1.0, 0.0, [](float value) {
        if (my_spaceship)
            my_spaceship->commandImpulse(value);
    });
    slider->setSnapValue(0.0, 0.1)->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);
    
    label = new GuiLabel(this, id + "_LABEL", "Impulse: 0%", 30);
    label->setVertical()->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    (new GuiBox(this, id + "_BOX"))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Impulse))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiImpulseControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        label->setText("Impulse: " + string(int(my_spaceship->current_impulse * 100)) + "%");
        slider->setValue(my_spaceship->impulse_request);
    }
}

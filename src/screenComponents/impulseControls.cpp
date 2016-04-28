#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "impulseControls.h"
#include "powerDamageIndicator.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_slider.h"

GuiImpulseControls::GuiImpulseControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 1.0, -1.0, 0.0, [](float value) {
        if (my_spaceship)
            my_spaceship->commandImpulse(value);
    });
    slider->addSnapValue(0.0, 0.1)->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);
    
    label = new GuiKeyValueDisplay(this, id, 0.5, "Impulse", "0%");
    label->setTextSize(30)->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Impulse, ATopCenter))->setSize(50, GuiElement::GuiSizeMax);
}

void GuiImpulseControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        label->setValue(string(int(my_spaceship->current_impulse * 100)) + "%");
        slider->setValue(my_spaceship->impulse_request);
    }
}

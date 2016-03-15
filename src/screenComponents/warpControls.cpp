#include "playerInfo.h"
#include "warpControls.h"
#include "powerDamageIndicator.h"

GuiWarpControls::GuiWarpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 4.0, 0.0, 0.0, [this](float value) {
        int warp_level = value;
        if (my_spaceship)
            my_spaceship->commandWarp(warp_level);
        slider->setValue(warp_level);
    });
    slider->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);
    slider->addSnapValue(0.0, 0.5);
    slider->addSnapValue(1.0, 0.5);
    slider->addSnapValue(2.0, 0.5);
    slider->addSnapValue(3.0, 0.5);
    slider->addSnapValue(4.0, 0.5);
    
    label = new GuiKeyValueDisplay(this, id + "_LABEL", 0.5, "Warp", "0.0");
    label->setTextSize(30)->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Warp))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiWarpControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        label->setValue(string(my_spaceship->current_warp, 1));
}

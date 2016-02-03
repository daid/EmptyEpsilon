#include <libintl.h>

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

    label = new GuiLabel(this, id + "_LABEL", gettext("Warp: 0.0"), 30);
    label->setVertical()->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);

    (new GuiBox(this, id + "_BOX"))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Warp))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiWarpControls::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        label->setText(gettext("Warp: ") + string(my_spaceship->current_warp, 1));
}

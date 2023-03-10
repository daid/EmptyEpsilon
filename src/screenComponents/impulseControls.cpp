#include <i18n.h>
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
    slider->addSnapValue(0.0f, 0.1f)->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(50, GuiElement::GuiSizeMax);

    label = new GuiKeyValueDisplay(this, id, 0.5, tr("slider", "Impulse"), "0%");
    label->setTextSize(30)->setPosition(50, 0, sp::Alignment::TopLeft)->setSize(40, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Impulse, sp::Alignment::TopCenter))->setSize(50, GuiElement::GuiSizeMax);
}

void GuiImpulseControls::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        label->setValue(string(int(my_spaceship->current_impulse * 100)) + "%");
        slider->setValue(my_spaceship->impulse_request);
    }
}

void GuiImpulseControls::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        float change = keys.helms_increase_impulse.getValue() - keys.helms_decrease_impulse.getValue();
        if (change != 0.0f)
            my_spaceship->commandImpulse(std::min(1.0f, slider->getValue() + change * 0.1f));
        if (keys.helms_zero_impulse.getDown())
            my_spaceship->commandImpulse(0.0f);
        if (keys.helms_max_impulse.getDown())
            my_spaceship->commandImpulse(1.0f);
        if (keys.helms_min_impulse.getDown())
            my_spaceship->commandImpulse(-1.0f);
        
        float set_value = keys.helms_set_impulse.getValue();
        if (set_value != my_spaceship->impulse_request && (set_value != 0.0f || set_active))
        {
            my_spaceship->commandImpulse(set_value);
            set_active = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
        }
    }
}

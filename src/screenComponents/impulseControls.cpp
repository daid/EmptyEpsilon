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
    slider->addSnapValue(0.0, 0.1)->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);

    label = new GuiKeyValueDisplay(this, id, 0.5, tr("slider", "Impulse"), "0%");
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

void GuiImpulseControls::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && my_spaceship)
    {
        if (key.hotkey == "INC_IMPULSE")
            my_spaceship->commandImpulse(std::min(1.0f, slider->getValue() + 0.1f));
        else if (key.hotkey == "DEC_IMPULSE")
            my_spaceship->commandImpulse(std::max(-1.0f, slider->getValue() - 0.1f));
        else if (key.hotkey == "ZERO_IMPULSE")
            my_spaceship->commandImpulse(0.0f);
        else if (key.hotkey == "MAX_IMPULSE")
            my_spaceship->commandImpulse(1.0f);
        else if (key.hotkey == "MIN_IMPULSE")
            my_spaceship->commandImpulse(-1.0f);
    }
}

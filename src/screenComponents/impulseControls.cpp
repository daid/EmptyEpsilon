#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "impulseControls.h"
#include "powerDamageIndicator.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_slider.h"

GuiImpulseControls::GuiImpulseControls(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship)
: GuiElement(owner, id), target_spaceship(targetSpaceship)
{
    slider = new GuiSlider(this, id + "_SLIDER", 1.0, -1.0, 0.0, [this](float value) {
        if (target_spaceship)
            target_spaceship->commandImpulse(value);
    });
    slider->addSnapValue(0.0, 0.1)->setPosition(0, 0, ATopLeft)->setSize(50, GuiElement::GuiSizeMax);
    
    label = new GuiKeyValueDisplay(this, id, 0.5, "Impulse", "0%");
    label->setTextSize(30)->setPosition(50, 0, ATopLeft)->setSize(40, GuiElement::GuiSizeMax);
    
    pdi = new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Impulse, ATopCenter, target_spaceship);
    pdi->setSize(50, GuiElement::GuiSizeMax);
}

void GuiImpulseControls::setTargetSpaceship(P<PlayerSpaceship> targetSpaceship){
    target_spaceship = targetSpaceship;
    pdi->setTargetSpaceship(target_spaceship);
}

void GuiImpulseControls::onDraw(sf::RenderTarget& window)
{
    if (target_spaceship)
    {
        label->setValue(string(int(target_spaceship->current_impulse * 100)) + "%");
        slider->setValue(target_spaceship->impulse_request);
    }
}

void GuiImpulseControls::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && target_spaceship)
    {
        if (key.hotkey == "INC_IMPULSE")
            target_spaceship->commandImpulse(std::min(1.0f, slider->getValue() + 0.1f));
        else if (key.hotkey == "DEC_IMPULSE")
            target_spaceship->commandImpulse(std::max(-1.0f, slider->getValue() - 0.1f));
        else if (key.hotkey == "ZERO_IMPULSE")
            target_spaceship->commandImpulse(0.0f);
        else if (key.hotkey == "MAX_IMPULSE")
            target_spaceship->commandImpulse(1.0f);
        else if (key.hotkey == "MIN_IMPULSE")
            target_spaceship->commandImpulse(-1.0f);
    }
}

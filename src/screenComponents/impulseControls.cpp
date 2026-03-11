#include <i18n.h>
#include "playerInfo.h"
#include "impulseControls.h"
#include "powerDamageIndicator.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_slider.h"

#include "components/docking.h"
#include "components/impulse.h"

GuiImpulseControls::GuiImpulseControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 1.0, -1.0, 0.0, [](float value) {
        if (my_spaceship)
            my_player_info->commandImpulse(value);
    });
    slider->addSnapValue(0.0, 0.1)->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(50, GuiElement::GuiSizeMax);

    label = new GuiKeyValueDisplay(this, id, 0.5, tr("slider", "Impulse"), "0%");
    label->setTextSize(30)->setPosition(50, 0, sp::Alignment::TopLeft)->setSize(40, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_DPI", ShipSystem::Type::Impulse, sp::Alignment::TopCenter))->setSize(50, GuiElement::GuiSizeMax);
}

void GuiImpulseControls::onDraw(sp::RenderTarget& target)
{
    if (!my_spaceship) return;

    if (auto engine = my_spaceship.getComponent<ImpulseEngine>())
    {
        label->setValue(string(int(std::round(engine->actual * 100.0f))) + "%");
        slider->setValue(engine->request);
    }
}

void GuiImpulseControls::onUpdate()
{
    if (!my_spaceship) return;

    auto engine = my_spaceship.getComponent<ImpulseEngine>();
    setVisible(engine != nullptr);
    if (!isVisible()) return;

    auto docking_port = my_spaceship.getComponent<DockingPort>();
    slider->setEnable(!docking_port || docking_port->state == DockingPort::State::NotDocking);
    if (!slider->isEnabled()) return;

    // Change impulse value by keybind.
    float change = keys.helms_increase_impulse.getValue() - keys.helms_decrease_impulse.getValue();
    if (change != 0.0f)
        my_player_info->commandImpulse(std::clamp(slider->getValue() + change * 0.01f, -1.0f, 1.0f));
    if (keys.helms_increase_impulse_1.getDown())
        my_player_info->commandImpulse(std::min(1.0f, slider->getValue() + 0.01f));
    if (keys.helms_decrease_impulse_1.getDown())
        my_player_info->commandImpulse(std::max(-1.0f, slider->getValue() - 0.01f));
    if (keys.helms_increase_impulse_10.getDown())
        my_player_info->commandImpulse(std::min(1.0f, slider->getValue() + 0.1f));
    if (keys.helms_decrease_impulse_10.getDown())
        my_player_info->commandImpulse(std::max(-1.0f, slider->getValue() - 0.1f));
    if (keys.helms_zero_impulse.getDown())
        my_player_info->commandImpulse(0.0f);
    if (keys.helms_max_impulse.getDown())
        my_player_info->commandImpulse(1.0f);
    if (keys.helms_min_impulse.getDown())
        my_player_info->commandImpulse(-1.0f);

    // Change impulse value by axis.
    float set_value = keys.helms_set_impulse.getValue();
    if (set_value != engine->request && (set_value != 0.0f || set_active))
    {
        my_player_info->commandImpulse(set_value);
        // Ensure the next update is sent, even if it is back to zero.
        set_active = set_value != 0.0f;
    }
}

#include <i18n.h>
#include "warpControls.h"
#include "playerInfo.h"
#include "powerDamageIndicator.h"
#include "components/warpdrive.h"

#include "gui/gui2_slider.h"
#include "gui/gui2_keyvaluedisplay.h"

GuiWarpControls::GuiWarpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    // Build warp request slider.
    slider = new GuiSlider(this, id + "_SLIDER", 1.0, 0.0, 0.0, [this](float value) {
        // Round the slider value to an int.
        int warp_level = value;

        // Send a warp request command to our ship.
        if (my_spaceship)
            my_player_info->commandWarp(warp_level);

        // Set the slider value to the warp level.
        slider->setValue(warp_level);
    });
    slider->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(50, GuiElement::GuiSizeMax);
    slider->addSnapValue(0.0, 0.5);
    slider->addSnapValue(1.0, 0.5);

    if (my_spaceship)
    {
        auto warp = my_spaceship.getComponent<WarpDrive>();
        // Set the slider's value to the current warp request.
        if (warp)
            slider->setValue(warp->request);
    }

    // Label the warp slider.
    label = new GuiKeyValueDisplay(this, id + "_LABEL", 0.5, tr("slider", "Warp"), "0.0");
    label->setTextSize(30)->setPosition(50, 0, sp::Alignment::TopLeft)->setSize(40, GuiElement::GuiSizeMax);

    // Prep the alert overlay.
    (new GuiPowerDamageIndicator(this, id + "_DPI", ShipSystem::Type::Warp, sp::Alignment::TopCenter))->setSize(50, GuiElement::GuiSizeMax);
}

void GuiWarpControls::onDraw(sp::RenderTarget& target)
{
    if (!my_spaceship) return;

    // Update the label with the current warp factor.
    if (auto warp = my_spaceship.getComponent<WarpDrive>())
    {
        label->setValue(string(warp->current, 1));
        slider->setValue(warp->request);

        if (slider->getRangeMin() != warp->max_level)
        {
            slider->setRange(warp->max_level, 0.0f);
            for (int n = 0; n <= warp->max_level; n++)
                slider->addSnapValue(n, 0.5f);
        }
    }
}

void GuiWarpControls::onUpdate()
{
    // Handle hotkey input. Warp is a HELMS-category shortcut.
    if (!my_spaceship) return;

    auto warp = my_spaceship.getComponent<WarpDrive>();
    setVisible(warp != nullptr);
    if (!warp || !slider->isEnabled()) return;

    // Read current state of the warp drive and controls.
    const int current_request_value = warp->request;
    int command_value = current_request_value;

    // Change warp request by keybind.
    if (keys.helms_increase_warp.getDown())
    {
        if (current_request_value < warp->max_level)
            command_value = current_request_value + 1;
    }
    else if (keys.helms_decrease_warp.getDown())
    {
        if (current_request_value > 0)
            command_value = current_request_value - 1;
    }
    if (keys.helms_warp0.getDown())
        command_value = 0;
    if (keys.helms_warp1.getDown())
        command_value = 1;
    if (keys.helms_warp2.getDown())
        command_value = 2;
    if (keys.helms_warp3.getDown())
        command_value = 3;
    if (keys.helms_warp4.getDown())
        command_value = 4;

    // The max warp keybind is redundant on default warp ships, but warp drives
    // can be set to have factors beyond 4, and there aren't keybinds for them.
    if (keys.helms_warp_max.getDown())
        command_value = warp->max_level;

    // Set warp request by axis.
    // Get joystick axis map value (-1.0 to 1.0).
    float axis_value = keys.helms_set_warp.getValue();
    // The warp slider's min/max range values are inverted because the
    // gui2_slider is coded for max to be on the bottom.
    // getRangeMin returns the warp range's max value, and vice versa.
    const float slider_range = slider->getRangeMin() - slider->getRangeMax();
    // Translate the slider's value on its min/max range to a value between
    // -1.0 and 1.0.
    float slider_axis_pos = ((slider->getValue() - slider->getRangeMax()) / slider_range) * 2.0f - 1.0f;

    // Translate the axis position between -1.0 and 1.0 to a value in the
    // slider's min/max range, with rounding to simulate detents.
    if (axis_value != slider_axis_pos && (axis_value != 0.0f || set_active))
    {
        // Round to nearest warp level to create detent behavior and clamp to
        // valid range.
        command_value = static_cast<int>(
            std::clamp(
                std::round((((axis_value + 1.0f) / 2.0f) * slider_range) + slider->getRangeMax()),
                slider->getRangeMax(),
                slider->getRangeMin()
            )
        );
        // Ensure the next update is sent, even if it's back to zero.
        set_active = axis_value != 0.0f;
    }

    // If the control request has diverged from the warp drive, send the warp
    // drive command and update the slider. This should also update the slider
    // if the request is changed by means other than the controls.
    if (command_value != current_request_value)
        my_player_info->commandWarp(command_value);

    slider->setValue(static_cast<float>(command_value));
}

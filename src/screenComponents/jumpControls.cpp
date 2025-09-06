#include <i18n.h>
#include "playerInfo.h"
#include "jumpControls.h"
#include "powerDamageIndicator.h"
#include "components/jumpdrive.h"
#include "featureDefs.h"

#include "gui/gui2_slider.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_button.h"

GuiJumpControls::GuiJumpControls(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    slider = new GuiSlider(this, id + "_SLIDER", 5000.0, 50000.0, 10000.0, nullptr);
    slider->setPosition(0, -50, sp::Alignment::BottomLeft)->setSize(50, GuiElement::GuiSizeMax);

    charge_bar = new GuiProgressbar(this, id + "_CHARGE", 0.0, 50000.0, 0.0);
    charge_bar->setPosition(0, -50, sp::Alignment::BottomLeft)->setSize(50, GuiElement::GuiSizeMax);
    charge_bar->hide();

    label = new GuiKeyValueDisplay(this, id + "_LABEL", 0.5, tr("jumpcontrol", "Distance"), "10.0");
    label->setTextSize(30)->setPosition(50, -50, sp::Alignment::BottomLeft)->setSize(40, GuiElement::GuiSizeMax);

    button = new GuiButton(this, id + "_BUTTON", tr("jumpcontrol", "Jump"), [this]() {
        auto jump = my_spaceship.getComponent<JumpDrive>();
        if (!jump)
            return;
        else if (jump->delay <= 0.0f)
            my_player_info->commandJump(slider->getValue());
        else
            my_player_info->commandAbortJump();
    });
    button->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(GuiElement::GuiSizeMax, 50);

    (new GuiPowerDamageIndicator(this, id + "_DPI", ShipSystem::Type::JumpDrive, sp::Alignment::TopCenter))->setPosition(0, -50, sp::Alignment::BottomLeft)->setSize(50, GuiElement::GuiSizeMax);
}

void GuiJumpControls::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        auto jump = my_spaceship.getComponent<JumpDrive>();
        if (!jump) {
            label->setKey("");
            label->setValue("");
            slider->disable();
            button->setText(tr("jumpcontrol", "Jump"))->setStyle("button")->disable();
            charge_bar->hide();
        }else if (jump->delay > 0.0f)
        {
            label->setKey(tr("jumpcontrol", "Jump in"));
            if (jump->get_seconds_to_jump() == std::numeric_limits<int>::max()) {
                // TRANSLATORS: Treat "Jump delayed" in jump control as one phrase.
                label->setKey(tr("jumpcontrol", "Jump"));
                label->setValue(tr("jumpcontrol", "delayed"));
            }else
                label->setValue(tr("jumpcontrol", "{delay} sec.").format({{"delay", string(jump->get_seconds_to_jump())}}));

            slider->disable();
            button->setText(tr("jumpcontrol", "Abort"))->setStyle("button.jump_abort")->enable();
            charge_bar->hide();
        }else if (jump->charge < jump->max_distance)
        {
            label->setKey(tr("jumpcontrol", "Charging"));
            label->setValue("...");
            slider->hide();
            button->setText(tr("jumpcontrol", "Jump"))->setStyle("button")->disable();
            charge_bar->setRange(0.0, jump->max_distance);
            charge_bar->setValue(jump->charge)->show();
        }else{
            label->setKey(tr("jumpcontrol", "Distance"));
            label->setValue(string(slider->getValue() / 1000.0f, 1) + DISTANCE_UNIT_1K);
            slider->enable()->show();
            slider->setRange(jump->max_distance, jump->min_distance);
            button->setText(tr("jumpcontrol", "Jump"))->setStyle("button")->enable();
            charge_bar->hide();
        }
    }
}

void GuiJumpControls::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        auto engine = my_spaceship.getComponent<JumpDrive>();
        setVisible(engine != nullptr);

        if (my_spaceship && engine)
        {
            float value = slider->getValue();
            float key_change = keys.helms_increase_jump_distance.getValue() - keys.helms_decrease_jump_distance.getValue();
            // Get joystick axis map value (-1.0 to 1.0)
            float axis_value = keys.helms_set_jump.getValue();
            // The jump slider's min/max range values seem to be inverted.
            // getRangeMin returns the jump range's max value, and vice versa.
            const float slider_range = slider->getRangeMin() - slider->getRangeMax();
            // Translate the slider's value on its min/max range to a value
            // between -1.0 to 1.0.
            float slider_axis_pos = ((slider->getValue() - slider->getRangeMax()) / slider_range) * 2.0f - 1.0f;

            if (key_change != 0.0f)
                value = std::clamp(value + 1000.0f * key_change, slider->getRangeMin(), slider->getRangeMax());
            if (keys.helms_increase_jump_100.getDown())
                value = std::min(value + 100.0f, slider->getRangeMax());
            if (keys.helms_decrease_jump_100.getDown())
                value = std::max(value - 100.0f, slider->getRangeMin());
            if (keys.helms_increase_jump_1k.getDown())
                value = std::min(value + 1000.0f, slider->getRangeMax());
            if (keys.helms_decrease_jump_1k.getDown())
                value = std::max(value - 1000.0f, slider->getRangeMin());
            if (keys.helms_min_jump.getDown())
                value = slider->getRangeMin();
            if (keys.helms_max_jump.getDown())
                value = slider->getRangeMax();

            if (axis_value != slider_axis_pos && (axis_value != 0.0f || set_active))
            {
                // Translate the axis position between -1.0 to 1.0 to a value in the slider's min/max range
                value = (((axis_value + 1.0f) / 2.0f) * slider_range) + slider->getRangeMax();
                set_active = axis_value != 0.0f; // Make sure the next update is sent, even if it is back to zero.
            }

            slider->setValue(value);

            if (keys.helms_execute_jump.getDown())
                my_player_info->commandJump(slider->getValue());
        }
    }
}

#include <i18n.h>
#include "shieldsEnableButton.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"
#include "gameGlobalInfo.h"
#include "components/shields.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_label.h"
#include <string>

GuiShieldsEnableButton::GuiShieldsEnableButton(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    button = new GuiToggleButton(this, id + "_BUTTON", "Shields: ON", [](bool value) {
        if (my_spaceship)
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
    });
    button->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    bar = new GuiProgressbar(this, id + "_BAR", 0.0, PlayerSpaceship::shield_calibration_time, 0);
    bar->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(bar, id + "_CALIBRATING_LABEL", tr("shields","Calibrating"), 30))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_PDI", ShipSystem::Type::FrontShield, sp::Alignment::CenterLeft))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiShieldsEnableButton::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        auto shields = my_spaceship->entity.getComponent<Shields>();
        if (!shields) {
            button->hide();
            bar->hide();
        }
        else if (my_spaceship->shield_calibration_delay > 0.0f)
        {
            button->hide();
            bar->show();
            bar->setValue(my_spaceship->shield_calibration_delay);
        }
        else
        {
            button->show();
            button->setValue(shields->active);
            bar->hide();
            string shield_status=shields->active ? tr("shields","ON") : tr("shields","OFF");
            if (gameGlobalInfo->use_beam_shield_frequencies && shields->frequency != -1)
                button->setText(tr("{frequency} Shields: {status}").format({{"frequency", frequencyToString(shields->frequency)}, {"status", shield_status}}));
            else
                button->setText(tr("Shields: {status}").format({{"status", shield_status}}));
        }
    }
}

void GuiShieldsEnableButton::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        if (keys.weapons_toggle_shields.getDown())
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
        if (keys.weapons_enable_shields.getDown())
            my_spaceship->commandSetShields(true);
        if (keys.weapons_disable_shields.getDown())
            my_spaceship->commandSetShields(false);
    }
}

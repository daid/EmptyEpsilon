#include "shieldsEnableButton.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_label.h"

GuiShieldsEnableButton::GuiShieldsEnableButton(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship)
: GuiElement(owner, id), target_spaceship(targetSpaceship)
{
    button = new GuiToggleButton(this, id + "_BUTTON", "Shields: ON", [this](bool value) {
        if (target_spaceship)
            target_spaceship->commandSetShields(!target_spaceship->shields_active);
    });
    button->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    bar = new GuiProgressbar(this, id + "_BAR", 0.0, PlayerSpaceship::shield_calibration_time, 0);
    bar->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(bar, id + "_CALIBRATING_LABEL", "Calibrating", 30))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    pdi = new GuiPowerDamageIndicator(this, id + "_PDI", SYS_FrontShield, ACenterLeft, target_spaceship);
    pdi->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiShieldsEnableButton::setTargetSpaceship(P<PlayerSpaceship> targetSpaceship){
    target_spaceship = targetSpaceship;
    pdi->setTargetSpaceship(target_spaceship);
}

void GuiShieldsEnableButton::onDraw(sf::RenderTarget& window)
{
    if (target_spaceship)
    {
        if (target_spaceship->shield_calibration_delay > 0.0)
        {
            button->hide();
            bar->show();
            bar->setValue(target_spaceship->shield_calibration_delay);
        }
        else
        {
            button->show();
            button->setValue(target_spaceship->shields_active);
            bar->hide();
            if (gameGlobalInfo->use_beam_shield_frequencies)
                button->setText(frequencyToString(target_spaceship->shield_frequency) + (target_spaceship->shields_active ? " Shields: ON" : " Shields: OFF"));
            else
                button->setText(target_spaceship->shields_active ? " Shields: ON" : " Shields: OFF");
        }
    }
}

void GuiShieldsEnableButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "WEAPONS" && target_spaceship)
    {
        if (key.hotkey == "TOGGLE_SHIELDS")
            target_spaceship->commandSetShields(!target_spaceship->shields_active);
        if (key.hotkey == "ENABLE_SHIELDS")
            target_spaceship->commandSetShields(true);
        if (key.hotkey == "DISABLE_SHIELDS")
            target_spaceship->commandSetShields(false);
    }
}

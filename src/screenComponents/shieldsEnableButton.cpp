#include "shieldsEnableButton.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_label.h"

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
    (new GuiLabel(bar, id + "_CALIBRATING_LABEL", "Calibrating", 30))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_PDI", SYS_FrontShield, ACenterLeft))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiShieldsEnableButton::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->shield_calibration_delay > 0.0)
        {
            button->hide();
            bar->show();
            bar->setValue(my_spaceship->shield_calibration_delay);
        }
        else
        {
            button->show();
            button->setValue(my_spaceship->shields_active);
            bar->hide();
            if (gameGlobalInfo->use_beam_shield_frequencies)
                button->setText(frequencyToString(my_spaceship->shield_frequency) + (my_spaceship->shields_active ? " Shields: ON" : " Shields: OFF"));
            else
                button->setText(my_spaceship->shields_active ? " Shields: ON" : " Shields: OFF");
        }
    }
}

void GuiShieldsEnableButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "WEAPONS" && my_spaceship)
    {
        if (key.hotkey == "TOGGLE_SHIELDS")
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
        if (key.hotkey == "ENABLE_SHIELDS")
            my_spaceship->commandSetShields(true);
        if (key.hotkey == "DISABLE_SHIELDS")
            my_spaceship->commandSetShields(false);
    }
}

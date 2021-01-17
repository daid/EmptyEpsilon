#include <i18n.h>
#include "shieldsEnableButton.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_label.h"
#include <string>

GuiShieldsEnableButton::GuiShieldsEnableButton(GuiContainer* owner, string id)
: GuiElement(owner, id),
  icon_only(false)
{
    // Recommended minimum button size with default text size: 130, 40

    // Shield toggle button.
    button = new GuiToggleButton(this, id + "_BUTTON", "Shields: ON", [](bool value) {
        if (my_spaceship)
        {
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
        }
    });
    button->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Progress bar during calibration.
    bar = new GuiProgressbar(this, id + "_BAR", 0.0, PlayerSpaceship::shield_calibration_time, 0);
    bar->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(bar, id + "_CALIBRATING_LABEL", tr("shields", "Calibrating"), 30))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Show power/damage indicator overlay.
    (new GuiPowerDamageIndicator(this, id + "_PDI", SYS_FrontShield, ACenterLeft))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiShieldsEnableButton::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->shield_calibration_delay > 0.0)
        {
            // If the shields are calibrating, show a progress bar.
            button->hide();
            bar->show();
            bar->setValue(my_spaceship->shield_calibration_delay);
        }
        else
        {
            // Show the button, hide the bar, set button state to shield activation state.
            button->show();
            button->setValue(my_spaceship->shields_active);
            bar->hide();

            // Format strings based on settings and shield activation state.
            string shield_frequency = icon_only ? frequencyToString(my_spaceship->shield_frequency) : tr("{frequency} Shields: ").format({{"frequency", frequencyToString(my_spaceship->shield_frequency)}});
            string shield_status = my_spaceship->shields_active ? tr("shields", "ON") : tr("shields", "OFF");

            // If the game's using beam frequencies, show the shield's current frequency setting.
            // If the button's only showing the icon, don't bother with long, formatted strings.
            if (gameGlobalInfo->use_beam_shield_frequencies)
            {
                if (icon_only)
                {
                    button->setText(shield_frequency);
                }
                else
                {
                    button->setText(string("{frequency} {status}").format({{"frequency", shield_frequency}, {"status", shield_status}}));
                }
            }
            else
            {
                if (icon_only)
                {
                    button->setText(shield_status);
                }
                else
                {
                    button->setText(tr("Shields: {status}").format({{"status", shield_status}}));
                }
            }
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

GuiShieldsEnableButton* GuiShieldsEnableButton::showIconOnly(bool icon_only)
{
    if (icon_only && button->getIcon() == "")
    {
        // If the button should have an icon instead of long strings, and it
        // doesn't already have an icon, then add an icon to the button.
        button->setIcon("gui/icons/shields");
    }
    else
    {
        button->setIcon("");
    }

    this->icon_only = icon_only;
    return this;
}
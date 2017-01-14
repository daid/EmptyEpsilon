#include "shieldFreqencySelect.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "screenComponents/shieldsEnableButton.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_progressbar.h"

GuiShieldFrequencySelect::GuiShieldFrequencySelect(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    calibrate_button = new GuiButton(this, "", "Calibrate", [this]() {
        if (my_spaceship)
            my_spaceship->commandSetShieldFrequency(new_frequency->getSelectionIndex());
    });
    calibrate_button->setPosition(0, 50, ATopLeft)->setSize(280 * 0.55, 50);
    new_frequency = new GuiSelector(this, "", nullptr);
    new_frequency->setPosition(280 * 0.55, 50, ATopLeft)->setSize(280 * 0.45, 50);
    for(int n=0; n<=SpaceShip::max_frequency; n++)
    {
        new_frequency->addEntry(frequencyToString(n), string(n));
    }
    new_frequency->setSelectionIndex(0);
}

void GuiShieldFrequencySelect::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        calibrate_button->setEnable(my_spaceship->shield_calibration_delay <= 0.0);
        new_frequency->setEnable(my_spaceship->shield_calibration_delay <= 0.0);
    }
    GuiElement::onDraw(window);
}

void GuiShieldFrequencySelect::onHotkey(const HotkeyResult& key)
{
    if ((key.category == "ENGINEERING" || key.category == "WEAPONS") && my_spaceship)
    {
        if (key.hotkey == "SHIELD_CAL_INC")
        {
            if (new_frequency->getSelectionIndex() >= new_frequency->entryCount() - 1)
                new_frequency->setSelectionIndex(0);
            else
                new_frequency->setSelectionIndex(new_frequency->getSelectionIndex() + 1);
        }
        if (key.hotkey == "SHIELD_CAL_DEC")
        {
            if (new_frequency->getSelectionIndex() <= 0)
                new_frequency->setSelectionIndex(new_frequency->entryCount() - 1);
            else
                new_frequency->setSelectionIndex(new_frequency->getSelectionIndex() - 1);
        }
        if (key.hotkey == "SHIELD_CAL_START")
        {
            my_spaceship->commandSetShieldFrequency(new_frequency->getSelectionIndex());
        }
    }
}

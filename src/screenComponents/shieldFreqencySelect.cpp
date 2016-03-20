#include "playerInfo.h"
#include "shieldFreqencySelect.h"

GuiShieldFrequencySelect::GuiShieldFrequencySelect(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    current_frequency = new GuiKeyValueDisplay(this, "", 0.65, "Shield Frequency", "400Thz");
    current_frequency->setTextSize(30)->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    calibrate_button = new GuiButton(this, "", "Calibrate", [this]() {
        if (my_spaceship)
            my_spaceship->commandSetShieldFrequency(new_frequency->getSelectionIndex());
    });
    calibrate_button->setPosition(0, 50, ATopLeft)->setSize(320 * 0.60, 50);
    new_frequency = new GuiSelector(this, "", nullptr);
    new_frequency->setPosition(320 * 0.65, 50, ATopLeft)->setSize(320 * 0.40, 50);
    for(int n=0; n<=SpaceShip::max_frequency; n++)
    {
        new_frequency->addEntry(frequencyToString(n), string(n));
    }
    new_frequency->setSelectionIndex(0);
    
    calibrate_progressbar = new GuiProgressbar(this, id + "_CAL_PROGRESS", PlayerSpaceship::shield_calibration_time, 0.0, 0.0);
    calibrate_progressbar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    calibrate_progressbar->setText("Calibrating...");
}

void GuiShieldFrequencySelect::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        current_frequency->setValue(frequencyToString(my_spaceship->shield_frequency));
        calibrate_progressbar->setVisible(my_spaceship->shield_calibration_delay > 0.0);
        calibrate_progressbar->setValue(my_spaceship->shield_calibration_delay);
        current_frequency->setVisible(!calibrate_progressbar->isVisible());
        calibrate_button->setEnable(!calibrate_progressbar->isVisible());
        new_frequency->setEnable(!calibrate_progressbar->isVisible());
    }
    GuiElement::onDraw(window);
}

#include "playerInfo.h"
#include "shieldFreqencySelect.h"

GuiShieldFrequencySelect::GuiShieldFrequencySelect(GuiContainer* owner, string id)
: GuiBox(owner, id)
{
    (new GuiLabel(this, id + "_CURRENT_LABEL", "Active Shield Freq.", 30))->setPosition(0, 20, ATopLeft)->setSize(GuiElement::GuiSizeMax, 30);
    current_frequency = new GuiLabel(this, id + "_CURRENT", "xxxThz", 30);
    current_frequency->addBackground()->setPosition(0, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(this, id + "_CHANGE_LABEL", "Change Shield Freq.", 30))->setPosition(0, 120, ATopLeft)->setSize(GuiElement::GuiSizeMax, 30);
    new_frequency = new GuiSelector(this, id + "_CHANGE_SELECT", nullptr);
    for(int n=0; n<=SpaceShip::max_frequency; n++)
    {
        new_frequency->addEntry(frequencyToString(n), string(n));
    }
    new_frequency->setSelectionIndex(0);
    new_frequency->setPosition(0, 150, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    calibrate_button = new GuiButton(this, id + "_CHANGE_BUTTON", "Calibrate", [this]() {
        if (my_spaceship)
            my_spaceship->commandSetShieldFrequency(new_frequency->getSelectionIndex());
    });
    calibrate_button->setPosition(0, 200, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    
    calibrate_progressbar = new GuiProgressbar(this, id + "_CAL_PROGRESS", PlayerSpaceship::shield_calibration_time, 0.0, 0.0);
    calibrate_progressbar->setPosition(0, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiShieldFrequencySelect::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        current_frequency->setText(frequencyToString(my_spaceship->shield_frequency));
        calibrate_progressbar->setVisible(my_spaceship->shield_calibration_delay > 0.0);
        calibrate_progressbar->setValue(my_spaceship->shield_calibration_delay);
        current_frequency->setVisible(!calibrate_progressbar->isVisible());
        calibrate_button->setEnable(!calibrate_progressbar->isVisible());
        new_frequency->setEnable(!calibrate_progressbar->isVisible());
    }
    GuiBox::onDraw(window);
}

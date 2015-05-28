#include "crewEngineeringUI_adv.h"
#include "gameGlobalInfo.h"

CrewEngineeringUIAdvanced::CrewEngineeringUIAdvanced()
{
}

void CrewEngineeringUIAdvanced::onCrewUI()
{
    if (!my_spaceship->ship_template) return;

    CrewEngineeringUI::onCrewUI();

    float x = getWindowSize().x - 330;
    if (my_spaceship->front_shield_max > 0 || my_spaceship->rear_shield_max > 0)
    {
        if (my_spaceship->shield_calibration_delay > 0.0)
            drawDisabledButton(sf::FloatRect(x, 770, 300, 50), "Calibrating", 30);
        else if (drawToggleButton(sf::FloatRect(x, 770, 300, 50), my_spaceship->shields_active, my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF", 30))
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
        drawDamagePowerDisplay(sf::FloatRect(x, 770, 300, 50), SYS_FrontShield, 20);
    }
    //TODO: Beam weapon frequency
}

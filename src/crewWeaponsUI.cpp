#include "crewWeaponsUI.h"
#include "gameGlobalInfo.h"

CrewWeaponsUI::CrewWeaponsUI()
{
    tube_load_type = MW_None;
}

void CrewWeaponsUI::onCrewUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    float radarDistance = 5000;
    sf::Vector2f radar_center = getWindowSize() / 2.0f;

    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
        {
            P<SpaceObject> target;
            sf::Vector2f mousePosition = my_spaceship->getPosition() + diff / 400.0f * radarDistance;
            PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(50, 50), mousePosition + sf::Vector2f(50, 50));
            foreach(Collisionable, obj, list)
            {
                P<SpaceObject> spaceObject = obj;
                if (spaceObject && spaceObject->canBeTargetedByPlayer() && spaceObject != my_spaceship)
                {
                    if (!target || sf::length(mousePosition - spaceObject->getPosition()) < sf::length(mousePosition - target->getPosition()))
                        target = spaceObject;
                }
            }
            my_spaceship->commandSetTarget(target);
        }
    }
    drawRadar(radar_center, 400, radarDistance, false, my_spaceship->getTarget());

    keyValueDisplay(sf::FloatRect(20, 100, 250, 40), 0.5, "Energy", string(int(my_spaceship->energy_level)), 25);
    keyValueDisplay(sf::FloatRect(20, 140, 250, 40), 0.5, "Shields", string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), 25);

    if (my_spaceship->weapon_tubes > 0)
    {
        float y = 900 - 10;
        for(int n=0; n<my_spaceship->weapon_tubes; n++)
        {
            y -= 50;
            weaponTube(tube_load_type, n, sf::FloatRect(20, y, 150, 50), sf::FloatRect(170, y, 350, 50), 35);
        }

        for(int n=0; n<MW_Count; n++)
        {
            if (my_spaceship->weapon_storage_max[n] > 0)
            {
                y -= 30;
                if (toggleButton(sf::FloatRect(20, y, 200, 30), tube_load_type == n, getMissileWeaponName(EMissileWeapons(n)) + " x" + string(my_spaceship->weapon_storage[n]), 25))
                {
                    if (tube_load_type == n)
                        tube_load_type = MW_None;
                    else
                        tube_load_type = EMissileWeapons(n);
                }
            }
        }
    }

    float x = getWindowSize().x - 290;
    if (my_spaceship->front_shield_max > 0 || my_spaceship->rear_shield_max > 0)
    {
        if (my_spaceship->shield_calibration_delay > 0.0)
            disabledButton(sf::FloatRect(x, 840, 270, 50), "Calibrating", 30);
        else if (toggleButton(sf::FloatRect(x, 840, 270, 50), my_spaceship->shields_active, my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF", 30))
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
        damagePowerDisplay(sf::FloatRect(x, 840, 270 / 2.0, 50), SYS_FrontShield, 20);
        damagePowerDisplay(sf::FloatRect(x + 270 / 2.0, 840, 270 / 2.0, 50), SYS_RearShield, 20);
    }
    
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        box(sf::FloatRect(x, 740, 270, 100));
        text(sf::FloatRect(x, 740, 270, 50), "Beam Freq.", AlignCenter, 30);
        int frequency = my_spaceship->beam_frequency + selector(sf::FloatRect(x, 790, 270, 50), frequencyToString(my_spaceship->beam_frequency), 30);
        if (frequency != my_spaceship->beam_frequency)
            my_spaceship->commandSetBeamFrequency(frequency);
        damagePowerDisplay(sf::FloatRect(x, 740, 270, 100), SYS_BeamWeapons, 20);
    }else{
        damagePowerDisplay(sf::FloatRect(radar_center.x - 140, radar_center.y + 150, 280, 50), SYS_BeamWeapons, 20);
    }
}

void CrewWeaponsUI::onPauseHelpGui()
{
    float x = getWindowSize().x - 300;
    float y = 50;
    float line_x = x - 200;

    if (my_spaceship->weapon_tubes > 0)
    {
        textboxWithBackground(sf::FloatRect(x, y, 300, 60), "1) Load your weapons", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(210, 870 - my_spaceship->weapon_tubes * 50), sf::Vector2f(x, y + 25), line_x);
        line_x += 10;
        y += 60;
        textboxWithBackground(sf::FloatRect(x, y, 300, 60), "2) Set a target", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(getWindowSize().x / 2.0f, 300), sf::Vector2f(x, y + 25), line_x);
        line_x += 10;
        y += 60;
        textboxWithBackground(sf::FloatRect(x, y, 300, 60), "3) Fire the missile!", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(500, 920 - my_spaceship->weapon_tubes * 50), sf::Vector2f(x, y + 25), line_x);
        line_x += 40;
        y += 60;
    }
    textboxWithBackground(sf::FloatRect(x, y, 300, 100), "During combat, activate the shields to prevent hull damage. Drains energy.", AlignTopLeft, 20);
    drawUILine(sf::Vector2f(x + 10, 860), sf::Vector2f(x, y + 25), line_x);
    line_x += 40;
    y += 100;
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        textboxWithBackground(sf::FloatRect(x, y, 300, 80), "Set beam frequency for optimal beam damage.", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(x + 10, 760), sf::Vector2f(x, y + 25), line_x);
        line_x += 40;
        y += 80;
    }

    textboxWithBackground(sf::FloatRect(x, y, 300, 80), "And always, listen to your captain!", AlignTopLeft, 20);


    x = 20;
    y = 200;
    textboxWithBackground(sf::FloatRect(x, y, 300, 100), "Tip: The set target is also used for beam weapon targeting.", AlignTopLeft, 20);
    y += 100;
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        textboxWithBackground(sf::FloatRect(x, y, 300, 100), "Tip: Communicate with science about beam frequencies.", AlignTopLeft, 20);
        y += 100;
    }
}

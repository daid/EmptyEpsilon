#include "crewWeaponsUI.h"
#include "gameGlobalInfo.h"

CrewWeaponsUI::CrewWeaponsUI()
{
    tube_load_type = MW_None;
    missile_target_angle = 0.0;
    missile_targeting = false;
    
    if (my_spaceship)
        missile_target_angle = my_spaceship->getRotation();
}

void CrewWeaponsUI::onCrewUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    float radarDistance = 5000;
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    sf::Vector2f diff = mouse - radar_center;
    sf::Vector2f mousePosition = my_spaceship->getPosition() + diff / 400.0f * radarDistance;

    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
    {
        if (sf::length(diff) < 400 && (mouse.x > 520 || mouse.y < 890 - 50 * my_spaceship->weapon_tubes))
        {
            P<SpaceObject> target;
            PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(50, 50), mousePosition + sf::Vector2f(50, 50));
            foreach(Collisionable, obj, list)
            {
                P<SpaceObject> spaceObject = obj;
                if (spaceObject && spaceObject->canBeTargeted() && spaceObject != my_spaceship)
                {
                    if (!target || sf::length(mousePosition - spaceObject->getPosition()) < sf::length(mousePosition - target->getPosition()))
                        target = spaceObject;
                }
            }
            if (target)
            {
                my_spaceship->commandSetTarget(target);
            }else{
                missile_targeting = true;
            }
        }
    }
    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        missile_targeting = false;
    }
    if (missile_targeting)
    {
        float angle = calculateFiringSolution(my_spaceship->getPosition() + diff / 400.0f * radarDistance);
        if (angle != std::numeric_limits<float>::infinity())
            missile_target_angle = angle;
    }

    drawMissileTrajectory(radar_center, 400.0f, radarDistance, missile_target_angle);
    drawTargetTrajectory(radar_center, 400.0f, radarDistance, my_spaceship->getTarget());

    drawRadar(radar_center, 400, radarDistance, false, my_spaceship->getTarget());

    drawKeyValueDisplay(sf::FloatRect(20, 100, 250, 40), 0.5, "Energy", string(int(my_spaceship->energy_level)), 25);
    drawKeyValueDisplay(sf::FloatRect(20, 140, 250, 40), 0.5, "Shields", string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + ":" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), 25);

    if (my_spaceship->weapon_tubes > 0)
    {
        float y = 900 - 10;
        for(int n=0; n<my_spaceship->weapon_tubes; n++)
        {
            y -= 50;
            drawWeaponTube(tube_load_type, n, missile_target_angle, sf::FloatRect(20, y, 150, 50), sf::FloatRect(170, y, 350, 50), 35);
        }

        for(int n=0; n<MW_Count; n++)
        {
            if (my_spaceship->weapon_storage_max[n] > 0)
            {
                y -= 30;
                if (drawToggleButton(sf::FloatRect(20, y, 200, 30), tube_load_type == n, getMissileWeaponName(EMissileWeapons(n)) + " x" + string(my_spaceship->weapon_storage[n]), 25))
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
            drawDisabledButton(sf::FloatRect(x, 840, 270, 50), "Calibrating", 30);
        else if (drawToggleButton(sf::FloatRect(x, 840, 270, 50), my_spaceship->shields_active, my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF", 30))
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
        drawDamagePowerDisplay(sf::FloatRect(x, 840, 270, 50), SYS_FrontShield, 20);
    }

    float y = 690;
    float h = 150;
    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        if (!gameGlobalInfo->use_beam_shield_frequencies || !gameGlobalInfo->use_system_damage)
        {
            h = 100;
            y += 50;
        }
        drawBox(sf::FloatRect(x, y, 270, h));
        drawText(sf::FloatRect(x, y, 270, 50), "Beam Info", AlignCenter, 28);
        if (gameGlobalInfo->use_beam_shield_frequencies)
        {
            int frequency = my_spaceship->beam_frequency + drawSelector(sf::FloatRect(x, y + 50, 270, 50), frequencyToString(my_spaceship->beam_frequency), 28);
            if (frequency != my_spaceship->beam_frequency)
                my_spaceship->commandSetBeamFrequency(frequency);
        }
        if (gameGlobalInfo->use_system_damage)
        {
            string system_name = getSystemName(my_spaceship->beam_system_target);
            if (my_spaceship->beam_system_target == SYS_None)
                system_name = "Hull";
            ESystem new_system = ESystem(int(my_spaceship->beam_system_target) + drawSelector(sf::FloatRect(x, y + h - 50, 270, 50), system_name, 28));
            if (new_system < SYS_None)
                new_system = SYS_None;
            if (new_system > ESystem(int(SYS_COUNT) - 1))
                new_system = ESystem(int(SYS_COUNT) - 1);
            if (new_system != my_spaceship->beam_system_target)
                my_spaceship->commandSetBeamSystemTarget(new_system);
        }
        drawDamagePowerDisplay(sf::FloatRect(x, y, 270, h), SYS_BeamWeapons, 20);
    }else{
        drawDamagePowerDisplay(sf::FloatRect(radar_center.x - 140, radar_center.y + 150, 280, 50), SYS_BeamWeapons, 20);
    }
}

void CrewWeaponsUI::onPauseHelpGui()
{
    float x = getWindowSize().x - 300;
    float y = 50;
    float line_x = x - 200;

    if (my_spaceship->weapon_tubes > 0)
    {
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 60), "1) Load your weapons", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(210, 870 - my_spaceship->weapon_tubes * 50), sf::Vector2f(x, y + 25), line_x);
        line_x += 10;
        y += 60;
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 60), "2) Set a target", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(getWindowSize().x / 2.0f, 300), sf::Vector2f(x, y + 25), line_x);
        line_x += 10;
        y += 60;
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 60), "3) Fire the missile!", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(500, 920 - my_spaceship->weapon_tubes * 50), sf::Vector2f(x, y + 25), line_x);
        line_x += 40;
        y += 60;
    }
    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 100), "During combat, activate the shields to prevent hull damage. Drains energy.", AlignTopLeft, 20);
    drawUILine(sf::Vector2f(x + 10, 860), sf::Vector2f(x, y + 25), line_x);
    line_x += 40;
    y += 100;
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "Set beam frequency for optimal beam damage.", AlignTopLeft, 20);
        drawUILine(sf::Vector2f(x + 10, 760), sf::Vector2f(x, y + 25), line_x);
        line_x += 40;
        y += 80;
    }

    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 80), "And always, listen to your captain!", AlignTopLeft, 20);


    x = 20;
    y = 200;
    drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 100), "Tip: The set target is also used for beam weapon targeting.", AlignTopLeft, 20);
    y += 100;
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        drawTextBoxWithBackground(sf::FloatRect(x, y, 300, 100), "Tip: Communicate with science about beam frequencies.", AlignTopLeft, 20);
        y += 100;
    }
}

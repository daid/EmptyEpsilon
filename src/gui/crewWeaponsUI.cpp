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
    sf::Vector2f diff = mouse - radar_center;
    sf::Vector2f mousePosition = my_spaceship->getPosition() + diff / 400.0f * radarDistance;

    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
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
                my_spaceship->commandSetTarget(target);
            else
                missile_target_angle = sf::vector2ToAngle(diff);
        }
    }

    {
        float angle_diff = sf::angleDifference(missile_target_angle, my_spaceship->getRotation());
        float turn_rate = 10.0f;
        float speed = 200.0f;
        float turn_radius = ((360.0f / turn_rate) * speed) / (2.0f * M_PI);

        float left_or_right = 90;
        if (angle_diff > 0)
            left_or_right = -90;

        sf::Vector2f turn_center = sf::vector2FromAngle(my_spaceship->getRotation() + left_or_right) * turn_radius;
        sf::Vector2f turn_exit = turn_center + sf::vector2FromAngle(missile_target_angle - left_or_right) * turn_radius;

        sf::VertexArray a(sf::LinesStrip, 13);
        a[0].position = radar_center;
        for(int cnt=0; cnt<10; cnt++)
            a[cnt + 1].position = radar_center + (turn_center + sf::vector2FromAngle(my_spaceship->getRotation() - angle_diff / 10.0f * cnt - left_or_right) * turn_radius) / radarDistance * 400.0f;
        a[11].position = radar_center + turn_exit / radarDistance * 400.0f;
        a[12].position = radar_center + (turn_exit + sf::vector2FromAngle(missile_target_angle) * radarDistance) / radarDistance * 400.0f;
        for(int cnt=0; cnt<13; cnt++)
            a[cnt].color = sf::Color(255, 255, 255, 128);
        getRenderTarget()->draw(a);

        float offset = 10.0 * speed;
        float turn_distance = fabs(angle_diff) / 360.0 * (turn_radius * 2.0f * M_PI);
        for(int cnt=0; cnt<5; cnt++)
        {
            sf::Vector2f p;
            sf::Vector2f n;
            if (offset < turn_distance)
            {
                n = sf::vector2FromAngle(my_spaceship->getRotation() - (angle_diff * offset / turn_distance) - left_or_right);
                p = (turn_center + n * turn_radius) / radarDistance * 400.0f;
            }else{
                p = (turn_exit + sf::vector2FromAngle(missile_target_angle) * (offset - turn_distance)) / radarDistance * 400.0f;
                n = sf::vector2FromAngle(missile_target_angle + 90.0f);
            }
            sf::VertexArray a(sf::Lines, 2);
            a[0].position = radar_center + p - n * 10.0f;
            a[1].position = radar_center + p + n * 10.0f;
            getRenderTarget()->draw(a);

            offset += 10.0 * speed;
        }
    }

    P<SpaceObject> target = my_spaceship->getTarget();
    if (target && target->getVelocity() > 1.0f)
    {
        sf::VertexArray a(sf::Lines, 12);
        a[0].position = radar_center + (target->getPosition() - my_spaceship->getPosition()) / radarDistance * 400.0f;
        a[0].color = sf::Color(255, 255, 255, 128);
        a[1].position = a[0].position + (target->getVelocity() * 60.0f) / radarDistance * 400.0f;
        a[1].color = sf::Color(255, 255, 255, 0);
        sf::Vector2f n = sf::normalize(sf::Vector2f(-target->getVelocity().y, target->getVelocity().x));
        for(int cnt=0; cnt<5; cnt++)
        {
            sf::Vector2f p = (target->getVelocity() * (10.0f + 10.0f * cnt)) / radarDistance * 400.0f;
            a[2 + cnt * 2].position = a[0].position + p + n * 10.0f;
            a[3 + cnt * 2].position = a[0].position + p - n * 10.0f;
            a[2 + cnt * 2].color = a[3 + cnt * 2].color = sf::Color(255, 255, 255, 128 - cnt * 20);
        }
        getRenderTarget()->draw(a);
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
            drawWeaponTube(tube_load_type, n, missile_target_angle, sf::FloatRect(20, y, 150, 50), sf::FloatRect(170, y, 350, 50), 35);
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
        box(sf::FloatRect(x, y, 270, h));
        text(sf::FloatRect(x, y, 270, 50), "Beam Info", AlignCenter, 28);
        if (gameGlobalInfo->use_beam_shield_frequencies)
        {
            int frequency = my_spaceship->beam_frequency + selector(sf::FloatRect(x, y + 50, 270, 50), frequencyToString(my_spaceship->beam_frequency), 28);
            if (frequency != my_spaceship->beam_frequency)
                my_spaceship->commandSetBeamFrequency(frequency);
        }
        if (gameGlobalInfo->use_system_damage)
        {
            string system_name = getSystemName(my_spaceship->beam_system_target);
            if (my_spaceship->beam_system_target == SYS_None)
                system_name = "Hull";
            ESystem new_system = ESystem(int(my_spaceship->beam_system_target) + selector(sf::FloatRect(x, y + h - 50, 270, 50), system_name, 28));
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

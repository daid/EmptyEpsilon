#include "crewSinglePilotUI.h"
#include "gameGlobalInfo.h"
#include "main.h"

CrewSinglePilotUI::CrewSinglePilotUI()
{
    tube_load_type = MW_None;
    jump_distance = 10.0;
}

void CrewSinglePilotUI::onCrewUI()
{
    float radarDistance = 5000;
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    radar_center.x /= 2.0f;
    float radar_size = radar_center.x - 20;

    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < radar_size)
        {
            P<SpaceObject> target;
            sf::Vector2f mousePosition = my_spaceship->getPosition() + diff / radar_size * radarDistance;
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
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(diff));
        }
    }

    drawRadar(radar_center, radar_size, radarDistance, false, my_spaceship->getTarget(), sf::FloatRect(0, 0, getWindowSize().x / 2.0f, 900));

    keyValueDisplay(sf::FloatRect(10, 30, 200, 20), 0.5, "Energy", string(int(my_spaceship->energy_level)), 20);
    keyValueDisplay(sf::FloatRect(10, 50, 200, 20), 0.5, "Hull", string(int(my_spaceship->hull_strength * 100 / my_spaceship->hull_max)), 20);
    keyValueDisplay(sf::FloatRect(10, 70, 200, 20), 0.5, "Shields", string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), 20);
    if (my_spaceship->front_shield_max > 0 || my_spaceship->rear_shield_max > 0)
    {
        if (toggleButton(sf::FloatRect(10, 90, 170, 25), my_spaceship->shields_active, my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF", 20))
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
    }
    dockingButton(sf::FloatRect(10, 115, 170, 25), 20);

    impulseSlider(sf::FloatRect(10, 650, 40, 200), 15);
    float x = 60;
    if (my_spaceship->hasWarpdrive)
    {
        warpSlider(sf::FloatRect(x, 650, 40, 200), 15);
        x += 50;
    }
    if (my_spaceship->hasJumpdrive)
    {
        jumpSlider(jump_distance, sf::FloatRect(x, 650, 40, 200), 15);
        jumpButton(jump_distance, sf::FloatRect(x, 865, 80, 30), 20);
        x += 50;
    }

    if (my_spaceship->weapon_tubes > 0)
    {
        float y = 900 - 5;
        for(int n=0; n<my_spaceship->weapon_tubes; n++)
        {
            y -= 30;
            weaponTube(tube_load_type, n, 0.0, sf::FloatRect(getWindowSize().x / 2.0 - 100, y, 100, 30), sf::FloatRect(getWindowSize().x / 2.0 - 300, y, 200, 30), 20);
        }

        for(int n=0; n<MW_Count; n++)
        {
            if (my_spaceship->weapon_storage_max[n] > 0)
            {
                y -= 25;
                if (toggleButton(sf::FloatRect(getWindowSize().x / 2.0 - 150, y, 150, 25), tube_load_type == n, getMissileWeaponName(EMissileWeapons(n)) + " x" + string(my_spaceship->weapon_storage[n]), 20))
                {
                    if (tube_load_type == n)
                        tube_load_type = MW_None;
                    else
                        tube_load_type = EMissileWeapons(n);
                }
            }
        }
    }

    if (my_spaceship->getTarget())
    {
        P<SpaceObject> target = my_spaceship->getTarget();
        float distance = sf::length(target->getPosition() - my_spaceship->getPosition());
        float heading = sf::vector2ToAngle(target->getPosition() - my_spaceship->getPosition());
        if (heading < 0) heading += 360;
        text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 50, 100, 20), target->getCallSign(), AlignRight, 20);
        text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 70, 100, 20), "Distance: " + string(distance / 1000.0, 1) + "km", AlignRight, 20);
        text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 90, 100, 20), "Heading: " + string(int(heading)), AlignRight, 20);

        P<SpaceShip> ship = target;
        if (ship && (ship->scanned_by_player == SS_NotScanned || ship->scanned_by_player == SS_FriendOrFoeIdentified))
        {
            if (my_spaceship->scanning_delay > 0.0)
            {
                progressBar(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 20), my_spaceship->scanning_delay, 6.0, 0.0);
            }else{
                if (button(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 30), "Scan", 20))
                    my_spaceship->commandScan(target);
            }
        }else{
            text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 20), factionInfo[target->getFactionId()]->getName(), AlignRight, 20);
            if (ship && ship->ship_template)
            {
                text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 130, 100, 20), ship->ship_type_name, AlignRight, 20);
                text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 150, 100, 20), "Shields: " + string(int(ship->front_shield)) + "/" + string(int(ship->rear_shield)), AlignRight, 20);
                if (ship->scanned_by_player == SS_SimpleScan)
                {
                    if (my_spaceship->scanning_delay > 0.0)
                    {
                        progressBar(sf::FloatRect(getWindowSize().x / 2.0 - 100, 170, 100, 20), my_spaceship->scanning_delay, 6.0, 0.0);
                    }else{
                        if (button(sf::FloatRect(getWindowSize().x / 2.0 - 100, 170, 100, 30), "Scan", 20))
                            my_spaceship->commandScan(target);
                    }
                }
            }
        }
        P<SpaceStation> station = target;
        if (station)
        {
            text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 150, 100, 20), "Shields: " + string(int(station->shields)), AlignRight, 20);
        }
    }

    if (my_spaceship->comms_state == CS_ChannelOpenPlayer)
    {
        std::vector<string> lines = my_spaceship->comms_incomming_message.split("\n");
        float y = 100;
        static const unsigned int max_lines = 20;
        for(unsigned int n=lines.size() > max_lines ? lines.size() - max_lines : 0; n<lines.size(); n++)
        {
            text(sf::FloatRect(getWindowSize().x / 2.0 + 20, y, 600, 30), lines[n]);
            y += 30;
        }
        y += 30;
        comms_player_message = textEntry(sf::FloatRect(820, y, 450, 50), comms_player_message);
        if (button(sf::FloatRect(getWindowSize().x - 330, y, 110, 50), "Send") || InputHandler::keyboardIsPressed(sf::Keyboard::Return))
        {
            my_spaceship->commandSendCommPlayer(comms_player_message);
            comms_player_message = "";
        }

        if (button(sf::FloatRect(getWindowSize().x / 2.0 + 20, 800, 300, 50), "Close channel"))
            my_spaceship->commandCloseTextComm();
    }else{
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_LongRange:
            drawRadar(sf::Vector2f(getWindowSize().x / 4 * 3, 450), radar_size, gameGlobalInfo->long_range_radar_range, true, NULL, sf::FloatRect(getWindowSize().x / 2.0f, 0, getWindowSize().x / 2.0f, 900));
            break;
        case MSS_Tactical:
            drawRadar(sf::Vector2f(getWindowSize().x / 4 * 3, 450), radar_size, 5000, false, NULL, sf::FloatRect(getWindowSize().x / 2.0f, 0, getWindowSize().x / 2.0f, 900));
            break;
        default:
            float target_camera_yaw = my_spaceship->getRotation();
    #ifdef DEBUG
            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left))
                target_camera_yaw -= 45;
            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right))
                target_camera_yaw += 45;
    #endif
            switch(my_spaceship->main_screen_setting)
            {
            case MSS_Back: target_camera_yaw += 180; break;
            case MSS_Left: target_camera_yaw -= 90; break;
            case MSS_Right: target_camera_yaw += 90; break;
            default: break;
            }
            camera_pitch = 30.0f;

            const float camera_ship_distance = 420.0f;
            const float camera_ship_height = 420.0f;
            sf::Vector2f cameraPosition2D = my_spaceship->getPosition() + sf::vector2FromAngle(target_camera_yaw) * -camera_ship_distance;
            sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);
    #ifdef DEBUG
            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
            {
                targetCameraPosition.x = my_spaceship->getPosition().x;
                targetCameraPosition.y = my_spaceship->getPosition().y;
                targetCameraPosition.z = 6000.0;
                camera_pitch = 90.0f;
            }
    #endif
            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw = camera_yaw * 0.9f + target_camera_yaw * 0.1f;
            draw3Dworld(sf::FloatRect(getWindowSize().x / 2.0f, 0, getWindowSize().x / 2.0f, 900));
            break;
        }
    }
}

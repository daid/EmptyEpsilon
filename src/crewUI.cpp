#include "crewUI.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "repairCrew.h"
#include "spaceStation.h"

CrewUI::CrewUI()
{
}

void CrewUI::onGui()
{
    if (my_spaceship)
    {
        switch(my_player_info->crew_active_position)
        {
        case singlePilot:
            singlePilotUI();
            break;
        default:
            onCrewUI();
            break;
        }
        if (my_player_info->main_screen_control)
            mainScreenSelectGUI();
    }else{
        drawStatic();
    }
        
    int cnt = 0;
    for(int n=0; n<max_crew_positions; n++)
        if (my_player_info->crew_position[n])
            cnt++;
    
    if (cnt > 1)
    {
        int offset = 0;
        for(int n=0; n<max_crew_positions; n++)
        {
            if (my_player_info->crew_position[n])
            {
                if (toggleButton(sf::FloatRect(200 * offset, 0, 200, 25), my_player_info->crew_active_position == ECrewPosition(n), getCrewPositionName(ECrewPosition(n)), 20))
                {
                    if (my_player_info->crew_active_position != ECrewPosition(n))
                    {
                        my_player_info->crew_active_position = ECrewPosition(n);
                        destroy();
                        my_player_info->spawnUI();
                    }
                }
                offset++;
            }
        }
    }

    MainUIBase::onGui();
}

void CrewUI::onCrewUI()
{
    drawStatic();
    text(sf::FloatRect(0, 500, 1600, 100), "???", AlignCenter, 100);
}

void CrewUI::singlePilotUI()
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
                if (spaceObject && spaceObject->canBeTargetedByPlayer() && spaceObject != my_spaceship)
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
        //TODO: jumpSlider(jump_distance, sf::FloatRect(x, 650, 40, 200), 15);
        //TODO: jumpButton(jump_distance, sf::FloatRect(x, 865, 80, 30), 20);
        x += 50;
    }

    if (my_spaceship->weaponTubes > 0)
    {
        float y = 900 - 5;
        for(int n=0; n<my_spaceship->weaponTubes; n++)
        {
            y -= 30;
            //TODO: weaponTube(n, sf::FloatRect(getWindowSize().x / 2.0 - 100, y, 100, 30), sf::FloatRect(getWindowSize().x / 2.0 - 300, y, 200, 30), 20);
        }

        for(int n=0; n<MW_Count; n++)
        {
            if (my_spaceship->weapon_storage_max[n] > 0)
            {
                y -= 25;
                /*TODO:
                if (toggleButton(sf::FloatRect(getWindowSize().x / 2.0 - 150, y, 150, 25), tube_load_type == n, getMissileWeaponName(EMissileWeapons(n)) + " x" + string(my_spaceship->weapon_storage[n]), 20))
                {
                    if (tube_load_type == n)
                        tube_load_type = MW_None;
                    else
                        tube_load_type = EMissileWeapons(n);
                }
                */
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
        if (ship && ship->scanned_by_player == SS_NotScanned)
        {
            if (my_spaceship->scanning_delay > 0.0)
            {
                progressBar(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 20), my_spaceship->scanning_delay, 8.0, 0.0);
            }else{
                if (button(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 30), "Scan", 20))
                    my_spaceship->commandScan(target);
            }
        }else{
            text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 20), factionInfo[target->faction_id]->name, AlignRight, 20);
            if (ship && ship->ship_template)
            {
                text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 130, 100, 20), ship->ship_template->name, AlignRight, 20);
                text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 150, 100, 20), "Shields: " + string(int(ship->front_shield)) + "/" + string(int(ship->rear_shield)), AlignRight, 20);
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
        /*TODO:
        comms_player_message = textEntry(sf::FloatRect(820, y, 450, 50), comms_player_message);
        if (button(sf::FloatRect(getWindowSize().x - 330, y, 110, 50), "Send") || InputHandler::keyboardIsPressed(sf::Keyboard::Return))
        {
            my_spaceship->commandSendCommPlayer(comms_player_message);
            comms_player_message = "";
        }*/

        if (button(sf::FloatRect(getWindowSize().x / 2.0 + 20, 800, 300, 50), "Close channel"))
            my_spaceship->commandCloseTextComm();
    }else{
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_LongRange:
            drawRadar(sf::Vector2f(getWindowSize().x / 4 * 3, 450), radar_size, 50000, true, NULL, sf::FloatRect(getWindowSize().x / 2.0f, 0, getWindowSize().x / 2.0f, 900));
            break;
        case MSS_Tactical:
            drawRadar(sf::Vector2f(getWindowSize().x / 4 * 3, 450), radar_size, 5000, false, NULL, sf::FloatRect(getWindowSize().x / 2.0f, 0, getWindowSize().x / 2.0f, 900));
            break;
        default:
            draw3Dworld(sf::FloatRect(getWindowSize().x / 2.0f, 0, getWindowSize().x / 2.0f, 900));
            break;
        }
    }
}

void CrewUI::impulseSlider(sf::FloatRect rect, float text_size)
{
    float res = vslider(rect, my_spaceship->impulseRequest, 1.0, -1.0);
    if (res > -0.15 && res < 0.15)
        res = 0.0;
    if (res != my_spaceship->impulseRequest)
        my_spaceship->commandImpulse(res);
    text(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(int(my_spaceship->impulseRequest * 100)) + "%", AlignLeft, text_size);
    text(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(my_spaceship->currentImpulse * 100)) + "%", AlignLeft, text_size);
}

void CrewUI::warpSlider(sf::FloatRect rect, float text_size)
{
    float res = vslider(rect, my_spaceship->warpRequest, 4.0, 0.0);
    if (res != my_spaceship->warpRequest)
        my_spaceship->commandWarp(res);
    text(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(int(my_spaceship->warpRequest)), AlignLeft, text_size);
    text(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(my_spaceship->currentWarp * 100)) + "%", AlignLeft, text_size);
}

void CrewUI::jumpSlider(float& jump_distance, sf::FloatRect rect, float text_size)
{
    jump_distance = vslider(rect, jump_distance, 40.0, 1.0, 1.0);
    jump_distance = roundf(jump_distance * 10.0f) / 10.0f;
    text(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(jump_distance, 1) + "km", AlignLeft, text_size);
}

void CrewUI::jumpButton(float jump_distance, sf::FloatRect rect, float text_size)
{
    if (my_spaceship->jumpDelay > 0.0)
    {
        if (rect.width < text_size * 5)
            textbox(rect, string(int(ceilf(my_spaceship->jumpDelay))), AlignCenter, text_size);
        else
            keyValueDisplay(rect, 0.5, "Jump in", string(int(ceilf(my_spaceship->jumpDelay))), text_size);
    }else{
        if (button(rect, "Jump", text_size))
            my_spaceship->commandJump(jump_distance);
    }
}

void CrewUI::dockingButton(sf::FloatRect rect, float text_size)
{
    switch(my_spaceship->docking_state)
    {
    case DS_NotDocking:
        {
            PVector<Collisionable> obj_list = CollisionManager::queryArea(my_spaceship->getPosition() - sf::Vector2f(1000, 1000), my_spaceship->getPosition() + sf::Vector2f(1000, 1000));
            P<SpaceObject> dock_object;
            foreach(Collisionable, obj, obj_list)
            {
                dock_object = obj;
                if (dock_object && dock_object->canBeDockedBy(my_spaceship) && sf::length(dock_object->getPosition() - my_spaceship->getPosition()) < 1000.0)
                    break;
                dock_object = NULL;
            }
            
            if (dock_object)
            {
                if (button(rect, "Request Dock", text_size))
                    my_spaceship->commandDock(dock_object);
            }else{
                disabledButton(rect, "Request Dock", text_size);
            }
        }
        break;
    case DS_Docking:
        disabledButton(rect, "Docking...", text_size);
        break;
    case DS_Docked:
        if (button(rect, "Undock", text_size))
            my_spaceship->commandUndock();
        break;
    }
}

void CrewUI::weaponTube(EMissileWeapons load_type, int n, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size)
{
    switch(my_spaceship->weaponTube[n].state)
    {
    case WTS_Empty:
        if (toggleButton(load_rect, load_type != MW_None && my_spaceship->weapon_storage[load_type] > 0, "Load", text_size) && load_type != MW_None)
            my_spaceship->commandLoadTube(n, load_type);
        disabledButton(fire_rect, "Empty", text_size);
        break;
    case WTS_Loaded:
        if (button(load_rect, "Unload", text_size))
            my_spaceship->commandUnloadTube(n);
        if (button(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), text_size))
            my_spaceship->commandFireTube(n);
        break;
    case WTS_Loading:
        progressBar(fire_rect, my_spaceship->weaponTube[n].delay, my_spaceship->tubeLoadTime, 0.0);
        text(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), AlignCenter, text_size, sf::Color(128, 128, 128));
        disabledButton(load_rect, "Loading", text_size);
        break;
    case WTS_Unloading:
        progressBar(fire_rect, my_spaceship->weaponTube[n].delay, 0.0, my_spaceship->tubeLoadTime);
        text(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), AlignCenter, text_size, sf::Color(128, 128, 128));
        disabledButton(load_rect, "Unloading", text_size * 0.8);
        break;
    }
}

int CrewUI::frequencyCurve(sf::FloatRect rect, bool frequency_is_beam, bool more_damage_is_positive, int frequency)
{
    sf::RenderTarget& window = *getRenderTarget();
    
    float w = rect.width / (SpaceShip::max_frequency + 1);
    for(int n=0; n<=SpaceShip::max_frequency; n++)
    {
        float x = rect.left + w * n;
        float f;
        if (frequency_is_beam)
            f = frequencyVsFrequencyDamageFactor(frequency, n);
        else
            f = frequencyVsFrequencyDamageFactor(n, frequency);
        f = Tween<float>::linear(f, 0.5, 1.5, 0.1, 1.0);
        float h = rect.height * f;
        sf::RectangleShape bar(sf::Vector2f(w * 0.8, h));
        bar.setPosition(x, rect.top + rect.height - h);
        if (more_damage_is_positive)
            bar.setFillColor(sf::Color(255 * (1.0 - f), 255 * f, 0));
        else
            bar.setFillColor(sf::Color(255 * f, 255 * (1.0 - f), 0));
        window.draw(bar);
    }
    
    if (rect.contains(InputHandler::getMousePos()))
    {
        return int((InputHandler::getMousePos().x - rect.left) / w);
    }
    return -1;
}

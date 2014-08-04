#include "crewUI.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "repairCrew.h"
#include "spaceStation.h"

CrewUI::CrewUI()
{
    jump_distance = 1.0;
    tube_load_type = MW_None;
    science_radar_distance = 50000;
    comms_open_channel_type = OCT_None;

    for(int n=0; n<max_crew_positions; n++)
    {
        if (my_player_info->crew_position[n])
        {
            show_position = ECrewPosition(n);
            break;
        }
    }
}

void CrewUI::onGui()
{
    if (my_spaceship)
    {
        switch(show_position)
        {
        case helmsOfficer:
            helmsUI();
            break;
        case weaponsOfficer:
            weaponsUI();
            break;
        case engineering:
            engineeringUI();
            break;
        case scienceOfficer:
            scienceUI();
            break;
        case commsOfficer:
            commsUI();
            break;
        case singlePilot:
            singlePilotUI();
            break;
        default:
            drawStatic();
            text(sf::FloatRect(0, 500, 1600, 100), "???", AlignCenter, 100);
            break;
        }
        if (my_player_info->main_screen_control)
            mainScreenSelectGUI();
    }else{
        drawStatic();
    }

    int offset = 0;
    for(int n=0; n<max_crew_positions; n++)
    {
        if (my_player_info->crew_position[n])
        {
            if (toggleButton(sf::FloatRect(200 * offset, 0, 200, 25), show_position == ECrewPosition(n), getCrewPositionName(ECrewPosition(n)), 20))
            {
                show_position = ECrewPosition(n);
            }
            offset++;
        }
    }

    MainUIBase::onGui();
}

void CrewUI::helmsUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
            my_spaceship->commandTargetRotation(sf::vector2ToAngle(diff));
    }

    drawRadar(radar_center, 400, 5000, false, my_spaceship->getTarget());

    text(sf::FloatRect(10, 100, 200, 20), "Energy: " + string(int(my_spaceship->energy_level)), AlignLeft, 20);

    impulseSlider(sf::FloatRect(20, 500, 50, 300), 20);

    float x = 100;
    if (my_spaceship->hasWarpdrive)
    {
        warpSlider(sf::FloatRect(x, 500, 50, 300), 20);
        x += 80;
    }
    if (my_spaceship->hasJumpdrive)
    {
        jumpSlider(sf::FloatRect(x, 500, 50, 300), 20);
        x += 80;
    }

    dockingButton(sf::FloatRect(x, 800, 280, 50), 30);
}

void CrewUI::weaponsUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    float radarDistance = 5000;

    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);
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
    drawRadar(sf::Vector2f(800, 450), 400, radarDistance, false, my_spaceship->getTarget());

    text(sf::FloatRect(20, 100, 200, 20), "Energy: " + string(int(my_spaceship->energy_level)), AlignLeft, 20);
    text(sf::FloatRect(20, 120, 200, 20), "Shields: " + string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), AlignLeft, 20);
    if (my_spaceship->front_shield_max > 0 || my_spaceship->rear_shield_max > 0)
    {
        if (toggleButton(sf::FloatRect(20, 140, 200, 30), my_spaceship->shields_active, my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF", 25))
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
    }

    if (my_spaceship->weaponTubes > 0)
    {
        float y = 900 - 10;
        for(int n=0; n<my_spaceship->weaponTubes; n++)
        {
            y -= 50;
            weaponTube(n, sf::FloatRect(20, y, 150, 50), sf::FloatRect(170, y, 350, 50), 35);
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
}

void CrewUI::engineeringUI()
{
    if (!my_spaceship->ship_template) return;
    sf::RenderTarget& window = *getRenderTarget();
    sf::Vector2f mouse = InputHandler::getMousePos();

    float net_power = 0.0;
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (!my_spaceship->hasSystem(ESystem(n))) continue;
        if (my_spaceship->systems[n].power_user_factor < 0)
            net_power -= my_spaceship->systems[n].power_user_factor * my_spaceship->systems[n].health * my_spaceship->systems[n].power_level;
        else
            net_power -= my_spaceship->systems[n].power_user_factor * my_spaceship->systems[n].power_level;
    }
    text(sf::FloatRect(50, 100, 200, 20), "Energy: " + string(int(my_spaceship->energy_level)) + " (" + string(net_power) + ")", AlignLeft, 20);
    text(sf::FloatRect(50, 120, 200, 20), "Hull: " + string(int(my_spaceship->hull_strength * 100 / my_spaceship->hull_max)), AlignLeft, 20);
    text(sf::FloatRect(50, 140, 200, 20), "Shields: " + string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), AlignLeft, 20);
    if (toggleButton(sf::FloatRect(50, 200, 250, 50), my_spaceship->auto_repair_enabled, "Auto-Repair", 30))
    {
        my_spaceship->commandSetAutoRepair(!my_spaceship->auto_repair_enabled);
    }

    ESystem highlight_system = SYS_None;
    int x = 20;
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (!my_spaceship->hasSystem(ESystem(n))) continue;
        if (sf::FloatRect(x + 20, 530, 140, 320).contains(mouse))
            highlight_system = ESystem(n);

        vtext(sf::FloatRect(x + 20, 550, 30, 300), "Dmg:" + string(int(100 - my_spaceship->systems[n].health * 100)) + "%", AlignRight, 15);
        vtext(sf::FloatRect(x, 550, 50, 300), getSystemName(ESystem(n)), AlignLeft);
        text(sf::FloatRect(x + 50, 530, 50, 20), string(int(my_spaceship->systems[n].power_level * 100)) + "%", AlignCenter, 20);
        float ret = vslider(sf::FloatRect(x + 50, 550, 50, 300), my_spaceship->systems[n].power_level, 3.0, 0.0, 1.0);
        if (ret < 1.25 && ret > 0.75)
            ret = 1.0;
        if (my_spaceship->systems[n].power_level != ret)
            my_spaceship->commandSetSystemPower(ESystem(n), ret);
        vprogressBar(sf::FloatRect(x + 110, 500, 50, 50), my_spaceship->systems[n].heat_level, 0.0, 1.0, sf::Color(255, 255 * (1.0 - my_spaceship->systems[n].heat_level), 0));
        float heating_diff = powf(1.7, my_spaceship->systems[n].power_level - 1.0) - (1.0 + my_spaceship->systems[n].coolant_level * 0.1);
        if (my_spaceship->systems[n].heat_level > 0.0 && fabs(heating_diff) > 0.0)
        {
            sf::Sprite arrow;
            textureManager.setTexture(arrow, "gui_arrow.png");
            arrow.setPosition(x + 135, 525);
            float f = 50 / float(arrow.getTextureRect().height);
            arrow.setScale(f, f);
            if (heating_diff < 0)
                arrow.setRotation(-90);
            else
                arrow.setRotation(90);
            arrow.setColor(sf::Color(255, 255, 255, std::min(255, int(255 * fabs(heating_diff)))));
            getRenderTarget()->draw(arrow);
        }
        ret = vslider(sf::FloatRect(x + 110, 550, 50, 300), my_spaceship->systems[n].coolant_level, 10.0, 0.0);
        if (my_spaceship->systems[n].coolant_level != ret)
            my_spaceship->commandSetSystemCoolant(ESystem(n), ret);
        x += 160;
    }

    sf::Vector2i interior_size = my_spaceship->ship_template->interiorSize();
    sf::Vector2f interial_position = sf::Vector2f(getWindowSize().x / 2.0, 250) - sf::Vector2f(interior_size) * 48.0f / 2.0f;
    drawShipInternals(interial_position, my_spaceship, highlight_system);

    PVector<RepairCrew> rc_list = getRepairCrewFor(my_spaceship);
    foreach(RepairCrew, rc, rc_list)
    {
        sf::Vector2f position = interial_position + sf::Vector2f(rc->position) * 48.0f + sf::Vector2f(1.0, 1.0) * 48.0f / 2.0f + sf::Vector2f(2.0, 2.0);
        sf::Sprite sprite;
        textureManager.setTexture(sprite, "RadarBlip.png");
        sprite.setPosition(position);
        window.draw(sprite);

        if (InputHandler::mouseIsPressed(sf::Mouse::Left) && sf::length(mouse - position) < 48.0f/2.0)
        {
            selected_crew = rc;
        }

        if (selected_crew == rc)
        {
            sf::Sprite select_sprite;
            textureManager.setTexture(select_sprite, "redicule.png");
            select_sprite.setPosition(position);
            window.draw(select_sprite);
        }
    }

    if (InputHandler::mouseIsPressed(sf::Mouse::Right) && selected_crew)
    {
        sf::Vector2i target_pos = sf::Vector2i((mouse - interial_position) / 48.0f);
        if (target_pos.x >= 0 && target_pos.x < interior_size.x && target_pos.y >= 0 && target_pos.y < interior_size.y)
        {
            selected_crew->commandSetTargetPosition(target_pos);
        }
    }
}

void CrewUI::scienceUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;

    float radarDistance = science_radar_distance;
    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
        {
            P<SpaceObject> target;
            sf::Vector2f mousePosition = my_spaceship->getPosition() + diff / 400.0f * radarDistance;
            PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(radarDistance / 100, radarDistance / 100), mousePosition + sf::Vector2f(radarDistance / 100, radarDistance / 100));
            foreach(Collisionable, obj, list)
            {
                P<SpaceObject> spaceObject = obj;
                if (spaceObject && spaceObject->canBeTargeted() && spaceObject != my_spaceship)
                {
                    if (!target || sf::length(mousePosition - spaceObject->getPosition()) < sf::length(mousePosition - target->getPosition()))
                        target = spaceObject;
                }
            }
            scienceTarget = target;
        }
    }

    drawRadar(radar_center, 400, radarDistance, true, scienceTarget);

    if (scienceTarget)
    {
        float distance = sf::length(scienceTarget->getPosition() - my_spaceship->getPosition());
        float heading = sf::vector2ToAngle(scienceTarget->getPosition() - my_spaceship->getPosition());
        if (heading < 0) heading += 360;
        text(sf::FloatRect(20, 100, 100, 20), scienceTarget->getCallSign(), AlignLeft, 20);
        text(sf::FloatRect(20, 120, 100, 20), "Distance: " + string(distance / 1000.0, 1) + "km", AlignLeft, 20);
        text(sf::FloatRect(20, 140, 100, 20), "Heading: " + string(int(heading)), AlignLeft, 20);

        P<SpaceShip> ship = scienceTarget;
        if (ship && !ship->scanned_by_player)
        {
            if (my_spaceship->scanning_delay > 0.0)
            {
                progressBar(sf::FloatRect(20, 160, 150, 30), my_spaceship->scanning_delay, 8.0, 0.0);
            }else{
                if (button(sf::FloatRect(20, 160, 150, 30), "Scan", 25))
                    my_spaceship->commandScan(scienceTarget);
            }
        }else{
            text(sf::FloatRect(20, 160, 100, 20), factionInfo[scienceTarget->faction_id].name, AlignLeft, 20);
            if (ship && ship->ship_template)
            {
                text(sf::FloatRect(20, 180, 100, 20), ship->ship_template->name, AlignLeft, 20);
                text(sf::FloatRect(20, 200, 200, 20), "Shields: " + string(int(ship->front_shield)) + "/" + string(int(ship->rear_shield)), AlignLeft, 20);
            }
        }
        P<SpaceStation> station = scienceTarget;
        if (station)
        {
            text(sf::FloatRect(20, 200, 200, 20), "Shields: " + string(int(station->shields)), AlignLeft, 20);
        }
    }

    if (science_radar_distance == 50000 && button(sf::FloatRect(20, 850, 150, 30), "Zoom: 1x", 25))
        science_radar_distance = 25000;
    else if (science_radar_distance == 25000 && button(sf::FloatRect(20, 850, 150, 30), "Zoom: 2x", 25))
        science_radar_distance = 12500;
    else if (science_radar_distance == 12500 && button(sf::FloatRect(20, 850, 150, 30), "Zoom: 4x", 25))
        science_radar_distance = 5000;
    else if (science_radar_distance == 5000 && button(sf::FloatRect(20, 850, 150, 30), "Zoom: 10x", 25))
        science_radar_distance = 50000;
}

void CrewUI::commsUI()
{
    switch(my_spaceship->comms_state)
    {
    case CS_Inactive: //Standard state; not doing anything in particular.
        {
            PVector<SpaceObject> station_list;
            PVector<SpaceObject> friendly_list;
            PVector<SpaceObject> neutral_list;
            PVector<SpaceObject> enemy_list;
            PVector<SpaceObject> unknown_list;
            PVector<SpaceObject> player_list;
            foreach(SpaceObject, obj, space_object_list) //Loop through all objects in space.
            {
                if (sf::length(obj->getPosition() - my_spaceship->getPosition()) < PlayerSpaceship::max_comm_range)
                { //Object is within range
                    P<SpaceStation> station = obj;
                    P<SpaceShip> ship = obj;
                    if (station)
                        station_list.push_back(obj);
                    if (ship)
                    {
                        P<PlayerSpaceship> playership = ship;
                        if (playership)
                        {
                            if (playership != my_spaceship)
                                player_list.push_back(obj);
                            continue;
                        }
                        if (ship->scanned_by_player)
                        {
                            switch(factionInfo[my_spaceship->faction_id].states[ship->faction_id])
                            {
                            case FVF_Friendly:
                                friendly_list.push_back(obj);
                                break;
                            case FVF_Neutral:
                                neutral_list.push_back(obj);
                                break;
                            case FVF_Enemy:
                                enemy_list.push_back(obj);
                                break;
                            }
                        }else{
                            unknown_list.push_back(obj);
                        }
                    }
                }
            }

            text(sf::FloatRect(50, 100, 600, 50), "Open comm channel to:");
            if (comms_open_channel_type == OCT_None)
            {
                float y = 150;
                if (station_list.size() > 0)
                {
                    if (button(sf::FloatRect(50, y, 300, 50), "Station (" + string(int(station_list.size())) + ")"))
                        comms_open_channel_type = OCT_Station;
                    y += 50;
                }
                if (friendly_list.size() > 0)
                {
                    if (button(sf::FloatRect(50, y, 300, 50), "Friendly ship (" + string(int(friendly_list.size())) + ")"))
                        comms_open_channel_type = OCT_FriendlyShip;
                    y += 50;
                }
                if (neutral_list.size() > 0)
                {
                    if (button(sf::FloatRect(50, y, 300, 50), "Neutral ship (" + string(int(neutral_list.size())) + ")"))
                        comms_open_channel_type = OCT_NeutralShip;
                    y += 50;
                }
                if (enemy_list.size() > 0)
                {
                    if (button(sf::FloatRect(50, y, 300, 50), "Enemy ship (" + string(int(enemy_list.size())) + ")"))
                        comms_open_channel_type = OCT_EnemyShip;
                    y += 50;
                }
                if (unknown_list.size() > 0)
                {
                    if (button(sf::FloatRect(50, y, 300, 50), "Unknown ship (" + string(int(unknown_list.size())) + ")"))
                        comms_open_channel_type = OCT_UnknownShip;
                    y += 50;
                }
                if (player_list.size() > 0)
                {
                    y += 20;
                    if (button(sf::FloatRect(50, y, 300, 50), "Player (" + string(int(player_list.size())) + ")"))
                        comms_open_channel_type = OCT_PlayerShip;
                    y += 50;
                }
            }else
            { //Target is selected (eg; subsection between station/friendly/neutral/etc).
                PVector<SpaceObject> show_list;
                switch(comms_open_channel_type)
                {
                    case OCT_Station:
                        show_list = station_list;
                        break;
                    case OCT_FriendlyShip:
                        show_list = friendly_list;
                        break;
                    case OCT_NeutralShip:
                        show_list = neutral_list;
                        break;
                    case OCT_EnemyShip:
                        show_list = enemy_list;
                        break;
                    case OCT_UnknownShip:
                        show_list = unknown_list;
                        break;
                    case OCT_PlayerShip:
                        show_list = player_list;
                    default:
                        break;
                }

                float x = 50;
                float y = 150;
                foreach(SpaceObject, obj, show_list)
                {
                    P<PlayerSpaceship> playerShip = obj;
                    if (playerShip) //Why do we make a distinction here? Seems to me a player ship also has a callsign?
                    {
                        if (button(sf::FloatRect(x, y, 300, 50), playerShip->ship_template->name))
                        {
                            my_spaceship->commandOpenTextComm(obj);
                            my_spaceship->commandOpenVoiceComm(obj);
                            comms_open_channel_type = OCT_None;
                        }
                        y += 50;
                    } else
                    {
                        if (button(sf::FloatRect(x, y, 300, 50), obj->getCallSign()))
                        {
                            my_spaceship->commandOpenTextComm(obj);
                            comms_open_channel_type = OCT_None;
                        }
                        y += 50;
                    }
                    if (y > 700)
                    {
                        y = 150;
                        x += 300;
                    }
                }
                if (button(sf::FloatRect(50, 800, 300, 50), "Back"))
                    comms_open_channel_type = OCT_None;
            }
        }
        break;
    case CS_OpeningChannel:
        text(sf::FloatRect(50, 100, 600, 50), "Opening communication channel...");
        progressBar(sf::FloatRect(50, 150, 600, 50), my_spaceship->comms_open_delay, PlayerSpaceship::comms_channel_open_time, 0.0);
        if (button(sf::FloatRect(50, 800, 300, 50), "Cancel call"))
            {
                my_spaceship->commandCloseTextComm();
                my_spaceship->commandCloseVoiceComm();
            }
        break;
    case CS_ChannelOpen:
        {
            std::vector<string> lines = my_spaceship->comms_incomming_message.split("\n");
            float y = 100;
            for(unsigned int n=0; n<lines.size(); n++)
            {
                text(sf::FloatRect(50, y, 600, 30), lines[n]);
                y += 30;
            }
            y += 30;
            for(int n=0; n<my_spaceship->comms_reply_count; n++)
            {
                if (button(sf::FloatRect(50, y, 600, 50), my_spaceship->comms_reply[n].message))
                {
                    my_spaceship->commandSendComm(n);
                }
                y += 50;
            }

            if (button(sf::FloatRect(50, 800, 300, 50), "Close channel"))
                my_spaceship->commandCloseTextComm();
        }
        break;
    case CS_ChannelOpenPlayer:
        {
            std::vector<string> lines = my_spaceship->comms_incomming_message.split("\n");
            float y = 100;
            static const unsigned int max_lines = 20;
            for(unsigned int n=lines.size() > max_lines ? lines.size() - max_lines : 0; n<lines.size(); n++)
            {
                text(sf::FloatRect(50, y, 600, 30), lines[n]);
                y += 30;
            }
            y += 30;
            comms_player_message = textEntry(sf::FloatRect(50, y, 600, 50), comms_player_message);
            if (button(sf::FloatRect(650, y, 300, 50), "Send") || InputHandler::keyboardIsPressed(sf::Keyboard::Return))
            {
                my_spaceship->commandSendCommPlayer(comms_player_message);
                comms_player_message = "";
            }

            if (button(sf::FloatRect(50, 800, 300, 50), "Close channel"))
                my_spaceship->commandCloseTextComm();
        }
        break;
    case CS_ChannelFailed:
        text(sf::FloatRect(50, 100, 600, 50), "Failed to open communication channel.");
        text(sf::FloatRect(50, 150, 600, 50), "No response.");
        if (button(sf::FloatRect(50, 800, 300, 50), "Close channel"))
            my_spaceship->commandCloseTextComm();
        break;
    case CS_ChannelBroken:
        text(sf::FloatRect(50, 100, 600, 50), "ERROR 5812 - Checksum failed.");
        if (button(sf::FloatRect(50, 800, 300, 50), "Close channel"))
            my_spaceship->commandCloseTextComm();
        break;
    }
}

void CrewUI::singlePilotUI()
{
    float radarDistance = 5000;
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    radar_center.x /= 2.0f;
    float radar_size = radar_center.x - 20;

    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
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

    text(sf::FloatRect(10, 30, 200, 20), "Energy: " + string(int(my_spaceship->energy_level)), AlignLeft, 20);
    text(sf::FloatRect(10, 50, 200, 20), "Hull: " + string(int(my_spaceship->hull_strength * 100 / my_spaceship->hull_max)), AlignLeft, 20);
    text(sf::FloatRect(10, 70, 200, 20), "Shields: " + string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), AlignLeft, 20);
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
        jumpSlider(sf::FloatRect(x, 650, 40, 200), 15);
        x += 50;
    }

    if (my_spaceship->weaponTubes > 0)
    {
        float y = 900 - 5;
        for(int n=0; n<my_spaceship->weaponTubes; n++)
        {
            y -= 30;
            weaponTube(n, sf::FloatRect(getWindowSize().x / 2.0 - 100, y, 100, 30), sf::FloatRect(getWindowSize().x / 2.0 - 300, y, 200, 30), 20);
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
        if (ship && !ship->scanned_by_player)
        {
            if (my_spaceship->scanning_delay > 0.0)
            {
                progressBar(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 20), my_spaceship->scanning_delay, 8.0, 0.0);
            }else{
                if (button(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 30), "Scan", 20))
                    my_spaceship->commandScan(target);
            }
        }else{
            text(sf::FloatRect(getWindowSize().x / 2.0 - 100, 110, 100, 20), factionInfo[target->faction_id].name, AlignRight, 20);
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

void CrewUI::jumpSlider(sf::FloatRect rect, float text_size)
{
    jump_distance = vslider(rect, jump_distance, 40.0, 1.0, 1.0);
    jump_distance = roundf(jump_distance * 10.0f) / 10.0f;
    text(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(jump_distance, 1) + "km", AlignLeft, text_size);
    if (my_spaceship->jumpDelay > 0.0)
    {
        text(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(ceilf(my_spaceship->jumpDelay))), AlignLeft, text_size);
    }else{
        if (button(sf::FloatRect(rect.left - text_size / 2, rect.top + rect.height + text_size, rect.width + text_size, text_size), "Jump", text_size))
        {
            my_spaceship->commandJump(jump_distance);
        }
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

void CrewUI::weaponTube(int n, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size)
{
    switch(my_spaceship->weaponTube[n].state)
    {
    case WTS_Empty:
        if (toggleButton(load_rect, tube_load_type != MW_None && my_spaceship->weapon_storage[tube_load_type] > 0, "Load", text_size) && tube_load_type != MW_None)
            my_spaceship->commandLoadTube(n, tube_load_type);
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
        disabledButton(load_rect, "Loading", text_size);
        text(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), AlignCenter, text_size, sf::Color::Black);
        break;
    case WTS_Unloading:
        progressBar(fire_rect, my_spaceship->weaponTube[n].delay, 0.0, my_spaceship->tubeLoadTime);
        disabledButton(load_rect, "Unloading", text_size * 0.8);
        text(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), AlignCenter, text_size, sf::Color::Black);
        break;
    }
}

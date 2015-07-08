#include "crewOperationsUI.h"
#include "scienceDatabase.h"
#include "gameGlobalInfo.h"

CrewOperationsUI::CrewOperationsUI()
{
    mode = mode_default;
    
    science_radar_zoom = 1;
    science_section = radar;
    science_database_selection = -1;
    science_sub_selection = -1;
    science_description_line_nr = 0;
    
    comms_reply_view_offset = 0;
}

void CrewOperationsUI::onCrewUI()
{
    switch(my_spaceship->comms_state)
    {
    case CS_Inactive: //Standard state; not doing anything in particular.
    case CS_BeingHailed:
    case CS_BeingHailedByGM:
        switch(science_section)
        {
        case radar:
            onRadarUI();
            break;
        case database:
            onDatabaseUI();
            break;
        }

        if (drawToggleButton(sf::FloatRect(20, 770, 200, 50), science_section == radar, "Radar", 30))
            science_section = radar;

        if (drawToggleButton(sf::FloatRect(20, 820, 200, 50), science_section == database, "Database", 30))
        {
            science_section = database;
            science_database_selection = -1;
        }
        break;
    case CS_OpeningChannel:
    case CS_ChannelOpen:
    case CS_ChannelOpenPlayer:
    case CS_ChannelOpenGM:
    case CS_ChannelFailed:
    case CS_ChannelBroken:
        drawCommsChannel();
        break;
    }
}

void CrewOperationsUI::onRadarUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    
    sf::Vector2f radar_center = sf::Vector2f((getWindowSize().x - 250) / 2.0f, getWindowSize().y / 2.0f);

    float radar_distance = gameGlobalInfo->long_range_radar_range / science_radar_zoom;
    float radar_size = 400.0f;
    if (InputHandler::mouseIsReleased(sf::Mouse::Left) && my_spaceship->scanning_delay <= 0.0)
    {
        sf::Vector2f diff = mouse - radar_center;
        if (diff < radar_size)
        {
            switch(mode)
            {
            case mode_default:
                {
                    selection_type = select_none;
                    selection_object = nullptr;
                    P<SpaceObject> target;
                    float target_pixel_distance = 0.0;
                    for(unsigned int n=0; n<scan_ghost.size(); n++)
                    {
                        P<SpaceObject> obj = scan_ghost[n].object;
                        if(!obj || !obj->canBeTargeted() || obj == my_spaceship)
                            continue;
                        sf::Vector2f position = radar_center + (scan_ghost[n].position - my_spaceship->getPosition()) / radar_distance * radar_size;
                        float pixel_distance = sf::length(position - mouse);
                        if (pixel_distance < 30)
                        {
                            if (!target || pixel_distance < target_pixel_distance)
                            {
                                target = obj;
                                target_pixel_distance = pixel_distance;
                            }
                        }
                    }
                    if (target)
                    {
                        selection_object = target;
                        selection_type = select_object;
                    }else{
                        for(unsigned int n=0; n<my_spaceship->waypoints.size(); n++)
                        {
                            sf::Vector2f screen_position = radar_center + (my_spaceship->waypoints[n] - my_spaceship->getPosition()) / radar_distance * radar_size;
                            if (sf::length(screen_position - mouse) < 30)
                            {
                                selection_type = select_waypoint;
                                selection_waypoint_index = n;
                            }
                        }
                    }
                }
                break;
            case mode_place_waypoint:
                {
                    sf::Vector2f point = my_spaceship->getPosition() + (mouse - radar_center) / radar_size * radar_distance;
                    my_spaceship->commandAddWaypoint(point);
                    mode = mode_default;
                }
                break;
            case mode_launch_probe:
                {
                    sf::Vector2f point = my_spaceship->getPosition() + (mouse - radar_center) / radar_size * radar_distance;
                    my_spaceship->commandLaunchProbe(point);
                    mode = mode_default;
                }
                break;
            }
        }
    }

    drawRadar(radar_center, radar_size, radar_distance, true, selection_object);
    sf::Vector2f target_position;
    if (selection_type == select_object && selection_object)
    {
        target_position = selection_object->getPosition();
        for(unsigned int n = 0; n < scan_ghost.size(); n++)
            if (scan_ghost[n].object == selection_object)
                target_position = scan_ghost[n].position;
        drawUILine(radar_center + (target_position - my_spaceship->getPosition()) / radar_distance * radar_size + sf::Vector2f(16.0f, 0), sf::Vector2f(getWindowSize().x - 270, 215), getWindowSize().x - 320);
    }

    if (my_spaceship->scanning_delay > 0.0)
    {
        float x = getWindowSize().x - 270;
        float y = 200;
        drawTextBox(sf::FloatRect(x, y, 250, 30), "Scanning", AlignCenter, 20); y += 30;
        drawProgressBar(sf::FloatRect(x, y, 250, 50), my_spaceship->scanning_delay, PlayerSpaceship::max_scanning_delay, 0.0); y += 50;
    } else {
        float x = getWindowSize().x - 270;
        float y = 200;
        switch(selection_type)
        {
        case select_none:
            break;
        case select_object:
            if (selection_object)
            {
                sf::Vector2f position_diff = target_position - my_spaceship->getPosition();
                float distance = sf::length(position_diff);
                float heading = sf::vector2ToAngle(position_diff) - 270;
                while(heading < 0) heading += 360;
                float rel_velocity = dot(selection_object->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);
                if (fabs(rel_velocity) < 0.01)
                    rel_velocity = 0.0;

                P<SpaceStation> station = selection_object;
                P<SpaceShip> ship = selection_object;
                if (station || ship)
                {
                    if (drawButton(sf::FloatRect(x, y - 50, 250, 50), "Open comms"))
                    {
                        my_spaceship->commandOpenTextComm(selection_object);
                    }
                }

                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Callsign", selection_object->getCallSign(), 20); y += 30;
                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Distance", string(distance / 1000.0, 1) + "km", 20); y += 30;
                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Heading", string(int(heading)), 20); y += 30;
                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Rel.Speed", string(rel_velocity / 1000 * 60, 1) + "km/min", 20); y += 30;

                if (ship && (ship->scanned_by_player == SS_NotScanned || ship->scanned_by_player == SS_FriendOrFoeIdentified))
                {
                    if (drawButton(sf::FloatRect(x, y, 250, 50), "Scan", 30))
                        my_spaceship->commandScan(selection_object);
                    y += 50;
                }else{
                    drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Faction", factionInfo[selection_object->getFactionId()]->getName(), 20); y += 30;
                    if (ship)
                    {
                        drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Type", ship->ship_type_name, 20); y += 30;
                        drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(ship->front_shield)) + ":" + string(int(ship->rear_shield)), 20); y += 30;

                        if (ship->scanned_by_player == SS_FullScan)
                        {
                            if (gameGlobalInfo->use_beam_shield_frequencies)
                            {
                                drawBox(sf::FloatRect(x, y, 250, 100));
                                int freq = drawFrequencyCurve(sf::FloatRect(x + 20, y + 30, 210, 60), false, true, ship->shield_frequency);
                                if (freq > -1)
                                {
                                    drawText(sf::FloatRect(x + 20, y, 210, 30), frequencyToString(freq) + " " + string(int(frequencyVsFrequencyDamageFactor(freq, ship->shield_frequency) * 100)) + "% dmg", AlignCenter, 20);
                                }else{
                                    drawText(sf::FloatRect(x + 20, y, 210, 30), "Your damage on", AlignCenter, 20);
                                }
                                y += 100;

                                drawBox(sf::FloatRect(x, y, 250, 100));
                                freq = drawFrequencyCurve(sf::FloatRect(x + 20, y + 30, 210, 60), true, false, ship->beam_frequency);
                                if (freq > -1)
                                {
                                    drawText(sf::FloatRect(x + 20, y, 210, 30), frequencyToString(freq) + " " + string(int(frequencyVsFrequencyDamageFactor(ship->beam_frequency, freq) * 100)) + "% dmg", AlignCenter, 20);
                                }else{
                                    drawText(sf::FloatRect(x + 20, y, 210, 30), "Damage recieved from", AlignCenter, 20);
                                }
                                y += 100;
                            }

                            for(int n=0; n<SYS_COUNT; n++)
                            {
                                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.75, getSystemName(ESystem(n)), string(int(ship->systems[n].health * 100.0f)) + "%", 20); y += 30;
                            }
                        }else{
                            if (drawButton(sf::FloatRect(x, y, 250, 50), "Scan", 30))
                                my_spaceship->commandScan(selection_object);
                        }
                    }
                }
                if (station)
                {
                    drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(station->shields)), 20); y += 30;
                }
            }
            break;
        case select_waypoint:
            if (drawButton(sf::FloatRect(x, y, 250, 50), "Delete Waypoint"))
            {
                my_spaceship->commandRemoveWaypoint(selection_waypoint_index);
                selection_type = select_none;
            }
            break;
        }
    }

    if (science_radar_zoom == 1 && drawButton(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 1x", 30))
        science_radar_zoom = 2;
    else if (science_radar_zoom == 2 && drawButton(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 2x", 30))
        science_radar_zoom = 4;
    else if (science_radar_zoom == 4 && drawButton(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 4x", 30))
        science_radar_zoom = 10;
    else if (science_radar_zoom == 10 && drawButton(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 10x", 30))
        science_radar_zoom = 1;

    float x = 20;
    float y = 100;
    switch(mode)
    {
    case mode_default:
        if (drawButton(sf::FloatRect(x, y, 250, 50), "Add waypoint"))
        {
            mode = mode_place_waypoint;
            selection_type = select_none;
        }
        y += 50;
        /*
        if (drawButton(sf::FloatRect(x, y, 250, 50), "Probe [" + string(my_spaceship->scan_probe_stock) + "/" + string(PlayerSpaceship::max_scan_probes) + "]"))
        {
            mode = mode_launch_probe;
            selection_type = select_none;
        }
        y += 50;
        */
        break;
    case mode_place_waypoint:
        if (drawButton(sf::FloatRect(x, y, 250, 50), "Cancel"))
        {
            mode = mode_default;
        }
        y += 50;

        drawText(sf::FloatRect(radar_center.x, 100, 0, 50), "Place new waypoint", AlignCenter);
        break;
    case mode_launch_probe:
        if (drawButton(sf::FloatRect(x, y, 250, 50), "Cancel"))
        {
            mode = mode_default;
        }
        y += 50;

        drawText(sf::FloatRect(radar_center.x, 100, 0, 50), "Select probe target", AlignCenter);
        break;
    }
}

void CrewOperationsUI::onDatabaseUI()
{
    float y = 100;
    int idx = 0;
    foreach(ScienceDatabase, sd, ScienceDatabase::scienceDatabaseList)
    {
        if (drawToggleButton(sf::FloatRect(20, y, 200, 50), science_database_selection == idx, sd->getName(), 30))
        {
            science_database_selection = idx;
            science_sub_selection = -1;
        }
        idx++;
        y += 50;
    }
    if (science_database_selection > -1 && science_database_selection < int(ScienceDatabase::scienceDatabaseList.size()))
    {
        P<ScienceDatabase> database = ScienceDatabase::scienceDatabaseList[science_database_selection];
        y = 100;
        idx = 0;
        foreach(ScienceDatabaseEntry, entry, database->items)
        {
            if (drawToggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == idx, entry->name, 30))
            {
                science_sub_selection = idx;
                science_description_line_nr = 0;
            }
            idx++;
            y += 50;
        }
        if (science_sub_selection > -1 && science_sub_selection < int(database->items.size()))
        {
            P<ScienceDatabaseEntry> entry = database->items[science_sub_selection];
            y = 100;
            for(unsigned int n=0; n<entry->keyValuePairs.size(); n++)
            {
                drawKeyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, entry->keyValuePairs[n].key, entry->keyValuePairs[n].value, 20);
                y += 40;
            }
            if (entry->model_template)
            {
                float width = getWindowSize().x - 500 - 400;
                if (width > 400)
                    width = 400;
                float height = width;
                float margin_3d = 5;
                if (height + 100 > y)
                    y = height + 100;
                drawSpinningModel(sf::FloatRect(500 + 400 + margin_3d, 100 + margin_3d, width - margin_3d * 2, height - margin_3d * 2), entry->model_template->model_data);
                drawBox(sf::FloatRect(500 + 400, 100, width, height));
            }
            if (entry->longDescription.length() > 0)
            {
                science_description_line_nr = drawScrollableTextBox(sf::FloatRect(500, y, 600, 800 - y), entry->longDescription, science_description_line_nr, AlignTopLeft, 20);
            }
        }
    }
}

void CrewOperationsUI::drawCommsChannel()
{
    switch(my_spaceship->comms_state)
    {
    case CS_Inactive: //Standard state; not doing anything in particular.
    case CS_BeingHailed:
    case CS_BeingHailedByGM:
        //This is never reached, as drawCommsChannel should not be called with these stats.
        break;
    case CS_OpeningChannel:
        drawText(sf::FloatRect(50, 100, 600, 50), "Opening communication channel...");
        drawProgressBar(sf::FloatRect(50, 150, 600, 50), my_spaceship->comms_open_delay, PlayerSpaceship::comms_channel_open_time, 0.0);
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Cancel call"))
        {
            my_spaceship->commandCloseTextComm();
        }
        break;
    case CS_ChannelOpen:
        {
            std::vector<string> lines = my_spaceship->comms_incomming_message.split("\n");
            float y = 100;
            drawKeyValueDisplay(sf::FloatRect(50, y, 300, 30), 0.5, "Rep: ", int(my_spaceship->getReputationPoints()), 20.0f);
            y += 50;
            for(unsigned int n=0; n<lines.size(); n++)
            {
                drawText(sf::FloatRect(50, y, 600, 30), lines[n]);
                y += 30;
            }
            y += 30;

            if (my_spaceship->comms_reply_message.size() <= comms_reply_view_offset)
                comms_reply_view_offset = 0;
            const int comm_reply_per_page = 8;
            unsigned int cnt = std::min(comm_reply_per_page, int(my_spaceship->comms_reply_message.size() - comms_reply_view_offset));
            for(unsigned int n=0; n<cnt; n++)
            {
                if (n + comms_reply_view_offset < my_spaceship->comms_reply_message.size()) //Extra check, as the my_spaceship->commandSendComm can modify the comms_reply_message list when the relay station is ran on the server.
                {
                    if (drawButton(sf::FloatRect(50, y, 600, 50), my_spaceship->comms_reply_message[n + comms_reply_view_offset]))
                    {
                        my_spaceship->commandSendComm(n + comms_reply_view_offset);
                        comms_reply_view_offset = 0;
                    }
                }
                y += 50;
            }
            if (comms_reply_view_offset > 0)
            {
                if (drawButton(sf::FloatRect(50, y, 200, 50), "<-"))
                    comms_reply_view_offset -= comm_reply_per_page;
            }
            if (comms_reply_view_offset + comm_reply_per_page < my_spaceship->comms_reply_message.size())
            {
                if (drawButton(sf::FloatRect(450, y, 200, 50), "->"))
                    comms_reply_view_offset += comm_reply_per_page;
            }

            if (drawButton(sf::FloatRect(50, 800, 300, 50), "Close channel"))
                my_spaceship->commandCloseTextComm();
        }
        break;
    case CS_ChannelOpenPlayer:
    case CS_ChannelOpenGM:
        {
            std::vector<string> lines = my_spaceship->comms_incomming_message.split("\n");
            float y = 100;
            unsigned int max_lines = 20;

            if (!engine->getObject("mouseRenderer"))
            {
                string keyboard_entry = drawOnScreenKeyboard();
                if (keyboard_entry == "\n")
                {
                    my_spaceship->commandSendCommPlayer(comms_player_message);
                    comms_player_message = "";
                }else if (keyboard_entry == "\b")
                {
                    if (comms_player_message.length() > 0)
                        comms_player_message = comms_player_message.substr(0, -1);;
                }else{
                    comms_player_message += keyboard_entry;
                }
                max_lines = 10;
            }

            for(unsigned int n=lines.size() > max_lines ? lines.size() - max_lines : 0; n<lines.size(); n++)
            {
                drawText(sf::FloatRect(50, y, 600, 30), lines[n]);
                y += 30;
            }
            y += 30;
            comms_player_message = drawTextEntry(sf::FloatRect(50, y, 600, 50), comms_player_message);
            if (drawButton(sf::FloatRect(650, y, 300, 50), "Send") || InputHandler::keyboardIsPressed(sf::Keyboard::Return))
            {
                my_spaceship->commandSendCommPlayer(comms_player_message);
                comms_player_message = "";
            }

            if (drawButton(sf::FloatRect(50, 800, 300, 50), "Close channel"))
                my_spaceship->commandCloseTextComm();
        }
        break;
    case CS_ChannelFailed:
        drawText(sf::FloatRect(50, 100, 600, 50), "Failed to open communication channel.");
        drawText(sf::FloatRect(50, 150, 600, 50), "No response.");
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Close channel"))
            my_spaceship->commandCloseTextComm();
        break;
    case CS_ChannelBroken:
        drawText(sf::FloatRect(50, 100, 600, 50), "ERROR 5812 - Checksum failed.");
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Close channel"))
            my_spaceship->commandCloseTextComm();
        break;
    }
}

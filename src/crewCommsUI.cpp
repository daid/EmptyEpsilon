#include "crewCommsUI.h"

CrewCommsUI::CrewCommsUI()
{
    comms_open_channel_type = OCT_None;
}

void CrewCommsUI::onCrewUI()
{
    sf::RenderTarget& window = *getRenderTarget();

    PVector<SpaceObject> friendly_objects;
    foreach(SpaceObject, obj, space_object_list)
    {
        if (obj->faction_id == my_spaceship->faction_id)
        {
            P<SpaceShip> ship = obj;
            if (ship)
            {
                friendly_objects.push_back(obj);
            }else{
                P<SpaceStation> station = obj;
                if (station)
                    friendly_objects.push_back(obj);
            }
        }
    }

    sf::RectangleShape background(getWindowSize());
    background.setFillColor(sf::Color::Black);
    window.draw(background);
    
    sf::Vector2f radar_center = sf::Vector2f(getWindowSize().x - 450, 450);
    float scale = (400.0 / 50000.0);
    sf::CircleShape circle(5000.0 * scale, 32);
    circle.setFillColor(sf::Color(20, 20, 20));
    circle.setOrigin(5000.0 * scale, 5000.0 * scale);
    foreach(SpaceObject, obj, friendly_objects)
    {
        circle.setPosition(radar_center + (obj->getPosition() - my_spaceship->getPosition()) * scale);
        window.draw(circle);
    }
    drawRaderBackground(my_spaceship->getPosition(), radar_center, 400, 50000.0);
    foreach(SpaceObject, obj, friendly_objects)
    {
        sf::Vector2f screen_position = radar_center + (obj->getPosition() - my_spaceship->getPosition()) * scale;
        obj->drawRadar(window, screen_position, scale, true);
    }
    drawWaypoints(radar_center, 900, 50000.0);
    
    sf::RectangleShape left_cover(sf::Vector2f(getWindowSize().x - 900, 900));
    left_cover.setFillColor(sf::Color::Black);
    window.draw(left_cover);
    //drawRadarCuttoff(sf::Vector2f(getWindowSize().x - 450, 450), 400);
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
                        if (ship->scanned_by_player != SS_NotScanned)
                        {
                            switch(factionInfo[my_spaceship->faction_id]->states[ship->faction_id])
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

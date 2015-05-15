#include <set>

#include "gui/crewCommsUI.h"
#include "spaceObjects/mine.h"
#include "spaceObjects/scanProbe.h"

CrewCommsUI::CrewCommsUI()
{
    mode = mode_default;
    selection_type = select_none;
    radar_distance = 50000.0f;
    comms_reply_view_offset = 0;
}

void CrewCommsUI::onCrewUI()
{
    switch(my_spaceship->comms_state)
    {
    case CS_Inactive: //Standard state; not doing anything in particular.
    case CS_BeingHailed:
    case CS_BeingHailedByGM:
        drawCommsRadar();
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

void CrewCommsUI::drawCommsRadar()
{
    sf::RenderTarget& window = *getRenderTarget();

    PVector<SpaceObject> friendly_objects;
    std::set<SpaceObject*> visible_objects;
    foreach(SpaceObject, obj, space_object_list)
    {
        if (obj->isFriendly(my_spaceship))
        {
            P<SpaceShip> ship = obj;
            if (ship)
            {
                friendly_objects.push_back(obj);
            }else{
                P<ScanProbe> probe = obj;
                if (probe)
                {
                    if (probe->owner_id == my_spaceship->getMultiplayerId())
                        friendly_objects.push_back(obj);  
                }else{
                    P<SpaceStation> station = obj;
                    if (station)
                        friendly_objects.push_back(obj);
                }
            }
        }
    }
    foreach(SpaceObject, friendly, friendly_objects)
    {
        sf::Vector2f position = friendly->getPosition();
        PVector<Collisionable> obj_list = CollisionManager::queryArea(position - sf::Vector2f(5000, 5000), position + sf::Vector2f(5000, 5000));
        foreach(Collisionable, c_obj, obj_list)
        {
            P<SpaceObject> obj = c_obj;
            if (obj && (friendly->getPosition() - obj->getPosition()) < 5000.0f + obj->getRadius())
            {
                visible_objects.insert(*obj);
            }
        }
    }

    if (!selection_object && selection_type == select_object)
        selection_type = select_none;
    if (selection_type == select_waypoint && selection_waypoint_index >= my_spaceship->waypoints.size())
        selection_type = select_none;

    float x = 300;
    float w = getWindowSize().x - x;
    float radar_size = w / 2.0f;
    sf::Vector2f radar_center = sf::Vector2f(x + w / 2.0f, 450);
    sf::Vector2f mouse = InputHandler::getMousePos();
    if (InputHandler::mouseIsDown(sf::Mouse::Left))
    {
        if (mouse.x > x && previous_mouse.x > x)
        {
            radar_view_position += (previous_mouse - mouse) / radar_size * radar_distance;
        }
    }
    previous_mouse = mouse;

    sf::RectangleShape background(getWindowSize());
    background.setFillColor(sf::Color::Black);
    window.draw(background);

    float scale = (radar_size / radar_distance);
    sf::CircleShape circle(5000.0 * scale, 32);
    circle.setFillColor(sf::Color(20, 20, 20));
    circle.setOrigin(5000.0 * scale, 5000.0 * scale);
    foreach(SpaceObject, obj, friendly_objects)
    {
        circle.setPosition(radar_center + (obj->getPosition() - radar_view_position) * scale);
        window.draw(circle);
    }
    drawRaderBackground(radar_view_position, radar_center, radar_size, radar_distance);
    for(SpaceObject* obj : visible_objects)
    {
        sf::Vector2f screen_position = radar_center + (obj->getPosition() - radar_view_position) * scale;
        obj->drawOnRadar(window, screen_position, scale, true);
    }
    drawWaypoints(radar_view_position, radar_center, radar_size, radar_distance);
    if(selection_type != select_none)
    {
        sf::Vector2f position;
        if (selection_type == select_object)
            position = selection_object->getPosition();
        if (selection_type == select_waypoint)
            position = my_spaceship->waypoints[selection_waypoint_index];
        position = radar_center + (position - radar_view_position) * scale;
        if (selection_type == select_waypoint)
            position.y -= 10;

        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(position);
        window.draw(objectSprite);
    }

    sf::RectangleShape left_cover(sf::Vector2f(x, 900));
    left_cover.setFillColor(sf::Color::Black);
    window.draw(left_cover);

    float y = 100;
    switch(mode)
    {
    case mode_default:
        drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.5, "Rep: ", int(my_spaceship->getReputationPoints()), 20.0);
        y += 30;
        if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Add waypoint"))
        {
            mode = mode_place_waypoint;
            selection_type = select_none;
        }
        y += 50;
        if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Probe [" + string(my_spaceship->scan_probe_stock) + "/" + string(PlayerSpaceship::max_scan_probes) + "]"))
        {
            mode = mode_launch_probe;
            selection_type = select_none;
        }
        y += 50;
        if (InputHandler::mouseIsReleased(sf::Mouse::Left) && mouse.x > x)
        {
            P<SpaceObject> target;
            float target_pixel_distance = 0.0;
            for(SpaceObject* obj : visible_objects)
            {
                if(obj == *my_spaceship)
                    continue;
                sf::Vector2f screen_position = radar_center + (obj->getPosition() - radar_view_position) * scale;
                float pixel_distance = sf::length(screen_position - mouse);
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
                selection_type = select_object;
                selection_object = target;
            }else{
                for(unsigned int n=0; n<my_spaceship->waypoints.size(); n++)
                {
                    sf::Vector2f screen_position = radar_center + (my_spaceship->waypoints[n] - radar_view_position) * scale;
                    if (sf::length(screen_position - mouse) < 30)
                    {
                        selection_type = select_waypoint;
                        selection_waypoint_index = n;
                    }
                }
            }
        }

        switch(selection_type)
        {
        case select_none:
            break;
        case select_object:
            {
                P<SpaceStation> station = selection_object;
                P<SpaceShip> ship = selection_object;
                P<Mine> mine = selection_object;
                if (station || ship)
                {
                    if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Open comms"))
                    {
                        my_spaceship->commandOpenTextComm(selection_object);
                    }
                    y += 50;
                }
                if (mine && mine->isFriendly(my_spaceship))
                {
                    if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Detonate"))
                    {
                        mine->explode();
                    }
                    y += 50;
                }
                
                sf::Vector2f position_diff = selection_object->getPosition() - my_spaceship->getPosition();
                float distance = sf::length(position_diff);
                float heading = sf::vector2ToAngle(position_diff) - 270;
                while(heading < 0) heading += 360;
                float rel_velocity = dot(selection_object->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);
                if (fabs(rel_velocity) < 0.01)
                    rel_velocity = 0.0;

                drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Callsign", selection_object->getCallSign(), 20); y += 30;
                drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Distance", string(distance / 1000.0, 1) + "km", 20); y += 30;
                drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Heading", string(int(heading)), 20); y += 30;
                drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Rel.Speed", string(rel_velocity / 1000 * 60, 1) + "km/min", 20); y += 30;

                if ((ship && ship->scanned_by_player != SS_NotScanned) || station)
                {
                    drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Faction", factionInfo[selection_object->getFactionId()]->getName(), 20); y += 30;
                    if (ship && ship->scanned_by_player != SS_FriendOrFoeIdentified)
                    {
                        drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Type", ship->ship_type_name, 20); y += 30;
                        drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Shields", string(int(ship->front_shield)) + ":" + string(int(ship->rear_shield)), 20); y += 30;
                    }
                    if (station && my_spaceship->isFriendly(station))
                    {
                        drawKeyValueDisplay(sf::FloatRect(x - 270, y, 250, 30), 0.4, "Shields", string(int(station->shields)), 20); y += 30;
                    }
                }
            }
            break;
        case select_waypoint:
            if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Delete Waypoint"))
            {
                my_spaceship->commandRemoveWaypoint(selection_waypoint_index);
                selection_type = select_none;
            }
            break;
        }
        break;
    case mode_place_waypoint:
        if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Cancel"))
        {
            mode = mode_default;
        }
        y += 50;

        drawText(sf::FloatRect(x + 450, 100, 0, 50), "Place new waypoint", AlignCenter);
        if (InputHandler::mouseIsReleased(sf::Mouse::Left) && mouse.x > x)
        {
            sf::Vector2f point = radar_view_position + (mouse - radar_center) / radar_size * radar_distance;
            my_spaceship->commandAddWaypoint(point);
            mode = mode_default;
        }
        break;
    case mode_launch_probe:
        if (drawButton(sf::FloatRect(x - 270, y, 250, 50), "Cancel"))
        {
            mode = mode_default;
        }
        y += 50;

        drawText(sf::FloatRect(x + 450, 100, 0, 50), "Select probe target", AlignCenter);
        if (InputHandler::mouseIsReleased(sf::Mouse::Left) && mouse.x > x)
        {
            sf::Vector2f point = radar_view_position + (mouse - radar_center) / radar_size * radar_distance;
            my_spaceship->commandLaunchProbe(point);
            mode = mode_default;
        }
        break;
    }

    if (my_spaceship->comms_state == CS_BeingHailed || my_spaceship->comms_state == CS_BeingHailedByGM)
    {
        drawBox(sf::FloatRect(0, 450, 300, 170));
        drawText(sf::FloatRect(20, 470, 260, 30), my_spaceship->comms_incomming_message, AlignCenter, 20);
        if (drawButton(sf::FloatRect(20, 500, 260, 50), "Answer"))
            my_spaceship->commandAnswerCommHail(true);
        if (drawButton(sf::FloatRect(20, 550, 260, 50), "Ignore"))
            my_spaceship->commandAnswerCommHail(false);
    }

    int zoom_level = round(50000.0f / radar_distance);
    zoom_level += drawSelector(sf::FloatRect(x - 270, 820, 250, 50), "Zoom: " + string(zoom_level) + "x", 30);
    zoom_level = std::min(std::max(zoom_level, 1), 10);
    radar_distance = 50000.0 / zoom_level;
}

void CrewCommsUI::drawCommsChannel()
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

#include "crewScienceUI.h"
#include "scienceDatabase.h"
#include "gameGlobalInfo.h"

CrewScienceUI::CrewScienceUI()
{
    science_radar_zoom = 1;
    science_section = radar;
    science_database_selection = -1;
    science_sub_selection = -1;
    science_description_line_nr = 0;
}

void CrewScienceUI::onCrewUI()
{
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
}

void CrewScienceUI::onRadarUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    
    sf::Vector2f radar_center = sf::Vector2f((getWindowSize().x - 250) / 2.0f, getWindowSize().y / 2.0f);

    float radarDistance = gameGlobalInfo->long_range_radar_range / science_radar_zoom;
    if (InputHandler::mouseIsReleased(sf::Mouse::Left) && my_spaceship->scanning_delay <= 0.0)
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
        {
            P<SpaceObject> target;
            float target_pixel_distance = 0.0;
            for(unsigned int n=0; n<scan_ghost.size(); n++)
            {
                P<SpaceObject> obj = scan_ghost[n].object;
                if(!obj || !obj->canBeTargeted() || obj == my_spaceship)
                    continue;
                sf::Vector2f position = radar_center + (scan_ghost[n].position - my_spaceship->getPosition()) / radarDistance * 400.0f;
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
            scienceTarget = target;
        }
    }

    drawRadar(radar_center, 400, radarDistance, true, scienceTarget);
    sf::Vector2f target_position;
    if (scienceTarget)
    {
        target_position = scienceTarget->getPosition();
        for(unsigned int n = 0; n < scan_ghost.size(); n++)
            if (scan_ghost[n].object == scienceTarget)
                target_position = scan_ghost[n].position;
        drawUILine(radar_center + (target_position - my_spaceship->getPosition()) / radarDistance * 400.0f + sf::Vector2f(16.0f, 0), sf::Vector2f(getWindowSize().x - 270, 215), getWindowSize().x - 320);
    }

    if (my_spaceship->scanning_delay > 0.0)
    {
        float x = getWindowSize().x - 270;
        float y = 200;
        drawTextBox(sf::FloatRect(x, y, 250, 30), "Scanning", AlignCenter, 20); y += 30;
        drawProgressBar(sf::FloatRect(x, y, 250, 50), my_spaceship->scanning_delay, 6.0, 0.0); y += 50;
    } else {
        if (scienceTarget)
        {
            float x = getWindowSize().x - 270;
            float y = 200;
            sf::Vector2f position_diff = target_position - my_spaceship->getPosition();
            float distance = sf::length(position_diff);
            float heading = sf::vector2ToAngle(position_diff) - 270;
            while(heading < 0) heading += 360;
            float rel_velocity = dot(scienceTarget->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);
            if (fabs(rel_velocity) < 0.01)
                rel_velocity = 0.0;

            drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Callsign", scienceTarget->getCallSign(), 20); y += 30;
            drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Distance", string(distance / 1000.0, 1) + "km", 20); y += 30;
            drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Heading", string(int(heading)), 20); y += 30;
            drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Rel.Speed", string(rel_velocity / 1000 * 60, 1) + "km/min", 20); y += 30;

            P<SpaceShip> ship = scienceTarget;
            if (ship && (ship->scanned_by_player == SS_NotScanned || ship->scanned_by_player == SS_FriendOrFoeIdentified))
            {
                if (drawButton(sf::FloatRect(x, y, 250, 50), "Scan", 30))
                    my_spaceship->commandScan(scienceTarget);
                y += 50;
            }else{
                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Faction", factionInfo[scienceTarget->getFactionId()]->getName(), 20); y += 30;
                if (ship)
                {
                    drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Type", ship->ship_type_name, 20); y += 30;
                    drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(ship->front_shield)) + "/" + string(int(ship->rear_shield)), 20); y += 30;

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
                            my_spaceship->commandScan(scienceTarget);
                    }
                }
            }
            P<SpaceStation> station = scienceTarget;
            if (station)
            {
                drawKeyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(station->shields)), 20); y += 30;
            }
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
}

void CrewScienceUI::onDatabaseUI()
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
                drawSpinningModel(sf::FloatRect(500 + 400 + margin_3d, 100 + margin_3d, width - margin_3d * 2, height - margin_3d * 2), entry->model_template);
                drawBox(sf::FloatRect(500 + 400, 100, width, height));
            }
            if (entry->longDescription.length() > 0)
            {
                science_description_line_nr = drawScrollableTextBox(sf::FloatRect(500, y, 600, 800 - y), entry->longDescription, science_description_line_nr, AlignTopLeft, 20);
            }
        }
    }
}

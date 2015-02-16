#include "crewScienceUI.h"
#include "gameGlobalInfo.h"

CrewScienceUI::CrewScienceUI()
{
    science_radar_zoom = 1;
    science_show_radar = true;
    science_database_type = SDT_None;
    science_sub_selection = -1;
    science_description_line_nr = 0;
}

void CrewScienceUI::onCrewUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();

    if (science_show_radar)
    {
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
            /*
            sf::Vector2f end_point_1(getWindowSize().x - 300, 215);
            sf::Vector2f end_point_2(getWindowSize().x - 270, 215);
            sf::Vector2f start_point = radar_center + (target_position - my_spaceship->getPosition()) / radarDistance * 400.0f;
            start_point.x += 16;

            if (end_point_1.x - fabs(start_point.y - end_point_1.y) > start_point.x + 16)
            {
                sf::VertexArray target_line(sf::LinesStrip, 4);
                target_line[0].position = start_point;
                target_line[1].position = sf::Vector2f(end_point_1.x - fabs(start_point.y - end_point_1.y), start_point.y);
                target_line[2].position = end_point_1;
                target_line[3].position = end_point_2;
                target_line[0].color = target_line[1].color = target_line[2].color = target_line[3].color = sf::Color(255, 255, 255, 128);
                getRenderTarget()->draw(target_line);
            }else{
                sf::VertexArray target_line(sf::LinesStrip, 6);
                target_line[0].position = start_point;
                target_line[1].position = start_point + sf::Vector2f(16, 0);
                target_line[2].position = sf::Vector2f(end_point_1.x - 16, start_point.y - (end_point_1.x - 16 - start_point.x - 16));
                target_line[3].position = end_point_1 + sf::Vector2f(-16, 16);
                target_line[4].position = end_point_1;
                target_line[5].position = end_point_2;
                target_line[0].color = target_line[1].color = target_line[2].color = target_line[3].color = target_line[4].color = target_line[5].color = sf::Color(255, 255, 255, 128);
                getRenderTarget()->draw(target_line);
            }
            */
        }

        if (my_spaceship->scanning_delay > 0.0)
        {
            float x = getWindowSize().x - 270;
            float y = 200;
            textbox(sf::FloatRect(x, y, 250, 30), "Scanning", AlignCenter, 20); y += 30;
            progressBar(sf::FloatRect(x, y, 250, 50), my_spaceship->scanning_delay, 6.0, 0.0); y += 50;
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

                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Callsign", scienceTarget->getCallSign(), 20); y += 30;
                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Distance", string(distance / 1000.0, 1) + "km", 20); y += 30;
                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Heading", string(int(heading)), 20); y += 30;
                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Rel.Speed", string(rel_velocity / 1000 * 60, 1) + "km/min", 20); y += 30;

                P<SpaceShip> ship = scienceTarget;
                if (ship && (ship->scanned_by_player == SS_NotScanned || ship->scanned_by_player == SS_FriendOrFoeIdentified))
                {
                    if (button(sf::FloatRect(x, y, 250, 50), "Scan", 30))
                        my_spaceship->commandScan(scienceTarget);
                    y += 50;
                }else{
                    keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Faction", factionInfo[scienceTarget->faction_id]->name, 20); y += 30;
                    if (ship)
                    {
                        keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Type", ship->ship_type_name, 20); y += 30;
                        keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(ship->front_shield)) + "/" + string(int(ship->rear_shield)), 20); y += 30;

                        if (ship->scanned_by_player == SS_FullScan)
                        {
                            if (gameGlobalInfo->use_beam_shield_frequencies)
                            {
                                box(sf::FloatRect(x, y, 250, 100));
                                int freq = frequencyCurve(sf::FloatRect(x + 20, y + 30, 210, 60), false, true, ship->shield_frequency);
                                if (freq > -1)
                                {
                                    text(sf::FloatRect(x + 20, y, 210, 30), frequencyToString(freq) + " " + string(int(frequencyVsFrequencyDamageFactor(freq, ship->shield_frequency) * 100)) + "% dmg", AlignCenter, 20);
                                }else{
                                    text(sf::FloatRect(x + 20, y, 210, 30), "Your damage on", AlignCenter, 20);
                                }
                                y += 100;

                                box(sf::FloatRect(x, y, 250, 100));
                                freq = frequencyCurve(sf::FloatRect(x + 20, y + 30, 210, 60), true, false, ship->beam_frequency);
                                if (freq > -1)
                                {
                                    text(sf::FloatRect(x + 20, y, 210, 30), frequencyToString(freq) + " " + string(int(frequencyVsFrequencyDamageFactor(ship->beam_frequency, freq) * 100)) + "% dmg", AlignCenter, 20);
                                }else{
                                    text(sf::FloatRect(x + 20, y, 210, 30), "Damage recieved from", AlignCenter, 20);
                                }
                                y += 100;
                            }
                            
                            for(int n=0; n<SYS_COUNT; n++)
                            {
                                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.75, getSystemName(ESystem(n)), string(int(ship->systems[n].health * 100.0f)) + "%", 20); y += 30;
                            }
                        }else{
                            if (button(sf::FloatRect(x, y, 250, 50), "Scan", 30))
                                my_spaceship->commandScan(scienceTarget);
                        }
                    }
                }
                P<SpaceStation> station = scienceTarget;
                if (station)
                {
                    keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(station->shields)), 20); y += 30;
                }
            }
        }

        if (science_radar_zoom == 1 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 1x", 30))
            science_radar_zoom = 2;
        else if (science_radar_zoom == 2 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 2x", 30))
            science_radar_zoom = 4;
        else if (science_radar_zoom == 4 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 4x", 30))
            science_radar_zoom = 10;
        else if (science_radar_zoom == 10 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 10x", 30))
            science_radar_zoom = 1;
    } else {
        if (toggleButton(sf::FloatRect(20, 100, 200, 50), science_database_type == SDT_Factions, "Factions", 30))
        {
            science_database_type = SDT_Factions;
            science_sub_selection = -1;
        }
        if (toggleButton(sf::FloatRect(20, 150, 200, 50), science_database_type == SDT_Ships, "Ship types", 30))
        {
            science_database_type = SDT_Ships;
            science_sub_selection = -1;
        }
        if (toggleButton(sf::FloatRect(20, 200, 200, 50), science_database_type == SDT_Weapons, "Weapons", 30))
        {
            science_database_type = SDT_Weapons;
            science_sub_selection = -1;
        }
        switch(science_database_type)
        {
        case SDT_None:
            break;
        case SDT_Factions:
            for(unsigned int n = 0; n < factionInfo.size(); n++)
            {
                if (toggleButton(sf::FloatRect(240, 100 + n * 50, 250, 50), science_sub_selection == int(n), factionInfo[n]->name, 30))
                {
                    science_sub_selection = n;
                    science_description_line_nr = 0;
                }
            }
            if (science_sub_selection > -1)
            {
                float y = 100;
                for(unsigned int n=0; n < factionInfo.size(); n++)
                {
                    if (int(n) == science_sub_selection) continue;

                    string stance = "Neutral";
                    switch(factionInfo[science_sub_selection]->states[n])
                    {
                        case FVF_Neutral: stance = "Neutral"; break;
                        case FVF_Enemy: stance = "Enemy"; break;
                        case FVF_Friendly: stance = "Friendly"; break;
                    }
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, factionInfo[n]->name, stance, 20);
                    y += 40;
                }

                science_description_line_nr = scrolltextbox(sf::FloatRect(500, y, 600, 550), factionInfo[science_sub_selection]->description, science_description_line_nr, AlignTopLeft, 20);
            }
            break;
        case SDT_Ships:
            {
                float y = 100;
                P<ShipTemplate> ship_template;
                std::vector<string> template_names = ShipTemplate::getPlayerTemplateNameList();
                std::sort(template_names.begin(), template_names.end());
                int nr = 0;
                for(unsigned int n=0; n<template_names.size(); n++)
                {
                    if (toggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == nr, template_names[n], 30))
                        science_sub_selection = nr;
                    if (science_sub_selection == nr)
                        ship_template = ShipTemplate::getTemplate(template_names[n]);
                    y += 50;
                    nr ++;
                }
                template_names = ShipTemplate::getTemplateNameList();
                std::sort(template_names.begin(), template_names.end());
                for(unsigned int n=0; n<template_names.size(); n++)
                {
                    if (toggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == nr, template_names[n], 30))
                        science_sub_selection = nr;
                    if (science_sub_selection == nr)
                        ship_template = ShipTemplate::getTemplate(template_names[n]);
                    y += 50;
                    nr ++;
                }
                if (ship_template)
                {
                    y = 100;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Size", string(int(ship_template->radius)), 20); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Shield", string(int(ship_template->frontShields)) + "/" + string(int(ship_template->rearShields)), 20); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Hull", string(int(ship_template->hull)), 20); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Move speed", string(int(ship_template->impulseSpeed)), 20); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Turn speed", string(int(ship_template->turnSpeed)), 20); y += 40;
                    if (ship_template->warpSpeed > 0.0)
                    {
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Has warp drive", "True", 20); y += 40;
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Warp speed", string(int(ship_template->warpSpeed)), 20); y += 40;
                    }
                    if (ship_template->jumpDrive)
                    {
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Has jump drive", "True", 20); y += 40;
                    }
                    for(int n=0; n<maxBeamWeapons; n++)
                    {
                        if (ship_template->beams[n].range > 0)
                        {
                            string name = "?";
                            if (ship_template->beams[n].direction < 45 || ship_template->beams[n].direction > 315)
                                name = "Front";
                            else if (ship_template->beams[n].direction > 45 && ship_template->beams[n].direction < 135)
                                name = "Right";
                            else if (ship_template->beams[n].direction > 135 && ship_template->beams[n].direction < 225)
                                name = "Rear";
                            else if (ship_template->beams[n].direction > 225 && ship_template->beams[n].direction < 315)
                                name = "Left";
                            keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, name + " beam weapon", string(ship_template->beams[n].damage / ship_template->beams[n].cycle_time, 2) + " DPS", 20); y += 40;
                        }
                    }
                    if (ship_template->weapon_tubes > 0)
                    {
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Missile tubes", string(ship_template->weapon_tubes), 20); y += 40;
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Missile load time", string(int(ship_template->tube_load_time)), 20); y += 40;
                    }
                    for(int n=0; n < MW_Count; n++)
                    {
                        if (ship_template->weapon_storage[n] > 0)
                        {
                            keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Storage " + getMissileWeaponName(EMissileWeapons(n)), string(ship_template->weapon_storage[n]), 20); y += 40;
                        }
                    }
                }
            }
            break;
        case SDT_Weapons:
            {
                float y = 100;
                int nr = 0;
                if (toggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == nr, "Homing missile", 30))
                    science_sub_selection = nr;
                y += 50; nr ++;

                if (toggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == nr, "Nuke", 30))
                    science_sub_selection = nr;
                y += 50; nr ++;

                if (toggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == nr, "Mine", 30))
                    science_sub_selection = nr;
                y += 50; nr ++;

                if (toggleButton(sf::FloatRect(240, y, 250, 50), science_sub_selection == nr, "EMP", 30))
                    science_sub_selection = nr;
                y += 50; nr ++;

                y = 100;
                switch(science_sub_selection)
                {
                case 0://Homing missile
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Range", "6km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Damage", "30", 20.0f); y += 40;
                    textbox(sf::FloatRect(500, y, 400, 400), "The standard homing missile is the\ndefault weapon of choice for many ships", AlignTopLeft, 20);
                    break;
                case 1://Nuke
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Range", "4.8km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Blast radius", "1km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Maximal Damage", "160", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Minimal Damage", "30", 20.0f); y += 40;
                    textbox(sf::FloatRect(500, y, 400, 400), "The heavy nuke is a fearsome weapon\nwhich is known to take out multiple\nships in a single shot.\n\nSome captains question the use of these\nweapons, due to the ease of friendly-fire\nincidents. And unknown prolonged\neffect on the crew of using these\nweapons in space.", AlignTopLeft, 20);
                    break;
                case 2://Mine
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Drop distance", "1.2km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Trigger distance", "0.6km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Blast radius", "1km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Maximal Damage", "160", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Minimal Damage", "30", 20.0f); y += 40;
                    textbox(sf::FloatRect(500, y, 400, 400), "Mines are often placed in a defensive\nperimeter around stations\n\nThere are also old mine fields scattered\naround the universe from older wars.\n\nSome fearless captains have used mines\nas offensive weapons.\nBut this is with great risk.", AlignTopLeft, 20);
                    break;
                case 3://EMP
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Range", "4.8km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Blast radius", "1km", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Maximal Damage", "160", 20.0f); y += 40;
                    keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Minimal Damage", "30", 20.0f); y += 40;
                    textbox(sf::FloatRect(500, y, 400, 400), "The EMP is a shield-only damaging\nweapon It matches the heavy nuke in\ndamage but does no hull damage.\n\nThe EMP missile is smaller and easier\nto storage then the heavy nuke.\nAnd thus many captains preferer it's use\nover nukes.", AlignTopLeft, 20);
                    break;
                }
            }
            break;
        }
    }

    if (toggleButton(sf::FloatRect(20, 770, 200, 50), science_show_radar, "Radar", 30))
        science_show_radar = true;

    if (toggleButton(sf::FloatRect(20, 820, 200, 50), !science_show_radar, "Database", 30))
    {
        science_show_radar = false;
        science_database_type = SDT_None;
    }
}

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
    science_show_radar = true;
    science_database_type = SDT_None;
    science_sub_selection = -1;
    
    comms_open_channel_type = OCT_None;
    engineering_selected_system = SYS_None;
    engineering_shield_new_frequency = SpaceShip::max_frequency / 2;

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
                if (toggleButton(sf::FloatRect(200 * offset, 0, 200, 25), show_position == ECrewPosition(n), getCrewPositionName(ECrewPosition(n)), 20))
                    show_position = ECrewPosition(n);
                offset++;
            }
        }
    }

    MainUIBase::onGui();
}

void CrewUI::helmsUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    if (InputHandler::mouseIsPressed(sf::Mouse::Left) || InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_center;
        if (sf::length(diff) < 400)
            my_spaceship->commandTargetRotation(sf::vector2ToAngle(diff));
    }

    drawRadar(radar_center, 400, 5000, false, my_spaceship->getTarget());

    keyValueDisplay(sf::FloatRect(20, 100, 200, 40), 0.5, "Energy", string(int(my_spaceship->energy_level)), 25);

    impulseSlider(sf::FloatRect(20, 400, 50, 300), 20);

    float x = 100;
    if (my_spaceship->hasWarpdrive)
    {
        warpSlider(sf::FloatRect(x, 400, 50, 300), 20);
        x += 80;
    }
    if (my_spaceship->hasJumpdrive)
    {
        jumpSlider(sf::FloatRect(x, 400, 50, 300), 20);
        x += 80;
        jumpButton(sf::FloatRect(20, 750, 280, 50), 30);
    }

    dockingButton(sf::FloatRect(20, 800, 280, 50), 30);
}

void CrewUI::weaponsUI()
{
    sf::Vector2f mouse = InputHandler::getMousePos();
    float radarDistance = 5000;
    sf::Vector2f radar_position = getWindowSize() / 2.0f;

    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - radar_position;
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
    drawRadar(radar_position, 400, radarDistance, false, my_spaceship->getTarget());

    keyValueDisplay(sf::FloatRect(20, 100, 250, 40), 0.5, "Energy", string(int(my_spaceship->energy_level)), 25);
    keyValueDisplay(sf::FloatRect(20, 140, 250, 40), 0.5, "Shields", string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), 25);

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

    float x = getWindowSize().x - 290;
    if (my_spaceship->front_shield_max > 0 || my_spaceship->rear_shield_max > 0)
    {
        if (toggleButton(sf::FloatRect(x, 840, 270, 50), my_spaceship->shields_active, my_spaceship->shields_active ? "Shields:ON" : "Shields:OFF", 30))
            my_spaceship->commandSetShields(!my_spaceship->shields_active);
    }
    box(sf::FloatRect(x, 740, 270, 100));
    text(sf::FloatRect(x, 740, 270, 50), "Beam Freq.", AlignCenter, 30);
    int frequency = my_spaceship->beam_frequency + selector(sf::FloatRect(x, 790, 270, 50), frequencyToString(my_spaceship->beam_frequency), 30);
    if (frequency != my_spaceship->beam_frequency)
        my_spaceship->commandSetBeamFrequency(frequency);
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
    keyValueDisplay(sf::FloatRect(20, 100, 300, 40), 0.5, "Energy", string(int(my_spaceship->energy_level)) + " (" + string(net_power) + ")", 25);
    keyValueDisplay(sf::FloatRect(20, 140, 300, 40), 0.5, "Hull", string(int(my_spaceship->hull_strength * 100 / my_spaceship->hull_max)), 25);
    keyValueDisplay(sf::FloatRect(20, 180, 300, 40), 0.5, "Shields", string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), 25);
    /*
    if (toggleButton(sf::FloatRect(20, 250, 300, 50), my_spaceship->auto_repair_enabled, "Auto-Repair", 30))
    {
        my_spaceship->commandSetAutoRepair(!my_spaceship->auto_repair_enabled);
    }
    */

    int y = 470;
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (!my_spaceship->hasSystem(ESystem(n))) continue;
        if (toggleButton(sf::FloatRect(50, y, 300, 50), ESystem(n) == engineering_selected_system, getSystemName(ESystem(n)), 30))
            engineering_selected_system = ESystem(n);
        
        float health = my_spaceship->systems[n].health;
        progressBar(sf::FloatRect(350, y, 100, 50), health, 0.0, 1.0, sf::Color(64, 128 * health, 64 * health));
        text(sf::FloatRect(350, y, 100, 50), string(int(health * 100)) + "%", AlignCenter, 20);
        
        float heat = my_spaceship->systems[n].heat_level;
        progressBar(sf::FloatRect(450, y, 50, 50), heat, 0.0, 1.0, sf::Color(128, 128 * (1.0 - heat), 0));
        float heating_diff = powf(1.7, my_spaceship->systems[n].power_level - 1.0) - (1.0 + my_spaceship->systems[n].coolant_level * 0.1);
        if (my_spaceship->systems[n].heat_level > 0.0 && fabs(heating_diff) > 0.0)
        {
            sf::Sprite arrow;
            textureManager.setTexture(arrow, "gui_arrow.png");
            arrow.setPosition(450 + 25, y + 25);
            float f = 50 / float(arrow.getTextureRect().height);
            arrow.setScale(f, f);
            if (heating_diff < 0)
                arrow.setRotation(-90);
            else
                arrow.setRotation(90);
            arrow.setColor(sf::Color(255, 255, 255, std::min(255, int(255 * fabs(heating_diff)))));
            getRenderTarget()->draw(arrow);
        }
        float power = my_spaceship->systems[n].power_level;
        progressBar(sf::FloatRect(500, y, 50, 50), power, 0.0, 3.0, sf::Color(192, 192, 0));
        float coolant = my_spaceship->systems[n].coolant_level;
        progressBar(sf::FloatRect(550, y, 50, 50), coolant, 0.0, 10.0, sf::Color(0, 128, 128));
        
        y += 50;
    }
    
    box(sf::FloatRect(600, 470, 270, 400));
    if (my_spaceship->hasSystem(engineering_selected_system))
    {
        vtext(sf::FloatRect(630, 490, 30, 360), "Power", AlignLeft);
        float ret = vslider(sf::FloatRect(660, 490, 60, 360), my_spaceship->systems[engineering_selected_system].power_level, 3.0, 0.0, 1.0);
        if (ret < 1.25 && ret > 0.75)
            ret = 1.0;
        if (my_spaceship->systems[engineering_selected_system].power_level != ret)
            my_spaceship->commandSetSystemPower(engineering_selected_system, ret);

        vtext(sf::FloatRect(730, 490, 30, 360), "Coolant", AlignLeft);
        ret = vslider(sf::FloatRect(760, 490, 60, 360), my_spaceship->systems[engineering_selected_system].coolant_level, 10.0, 0.0);
        if (my_spaceship->systems[engineering_selected_system].coolant_level != ret)
            my_spaceship->commandSetSystemCoolant(engineering_selected_system, ret);
    }

    ///Shield frequency configuration
    float x = getWindowSize().x - 320;
    //box(sf::FloatRect(x, 470, 300, 400));
    text(sf::FloatRect(x, 470, 300, 50), "Shield Freq.", AlignCenter, 30);
    textbox(sf::FloatRect(x, 520, 300, 50), frequencyToString(my_spaceship->shield_frequency), AlignCenter, 30);
    
    text(sf::FloatRect(x, 570, 300, 50), "Change Freq.", AlignCenter, 30);
    if (my_spaceship->shield_calibration_delay > 0.0)
    {
        textbox(sf::FloatRect(x, 620, 300, 50), "Calibrating", AlignCenter, 30);
        progressBar(sf::FloatRect(x, 670, 300, 50), my_spaceship->shield_calibration_delay, PlayerSpaceship::shield_calibration_time, 0);
    }else{
        engineering_shield_new_frequency += selector(sf::FloatRect(x, 620, 300, 50), frequencyToString(engineering_shield_new_frequency), 30);
        if (engineering_shield_new_frequency < 0)
            engineering_shield_new_frequency = 0;
        if (engineering_shield_new_frequency > SpaceShip::max_frequency)
            engineering_shield_new_frequency = SpaceShip::max_frequency;
        if (button(sf::FloatRect(x, 670, 300, 50), "Calibrate", 30))
            my_spaceship->commandSetShieldFrequency(engineering_shield_new_frequency);
    }

    ///Draw the ship interior
    sf::Vector2i interior_size = my_spaceship->ship_template->interiorSize();
    sf::Vector2f interial_position = sf::Vector2f(getWindowSize().x / 2.0, 250) - sf::Vector2f(interior_size) * 48.0f / 2.0f;
    drawShipInternals(interial_position, my_spaceship, engineering_selected_system);

    PVector<RepairCrew> rc_list = getRepairCrewFor(my_spaceship);
    foreach(RepairCrew, rc, rc_list)
    {
        sf::Vector2f position = interial_position + sf::Vector2f(rc->position) * 48.0f + sf::Vector2f(1.0, 1.0) * 48.0f / 2.0f + sf::Vector2f(2.0, 2.0);
        sf::Sprite sprite;
        textureManager.setTexture(sprite, "RadarBlip.png");
        sprite.setPosition(position);
        window.draw(sprite);

        if (InputHandler::mouseIsReleased(sf::Mouse::Left) && sf::length(mouse - position) < 48.0f/2.0)
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

    if (InputHandler::mouseIsReleased(sf::Mouse::Left) && selected_crew)
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
    //TODO: Unions to give speed/time estimate
    sf::Vector2f mouse = InputHandler::getMousePos();
    
    if (science_show_radar)
    {
        sf::Vector2f radar_center = sf::Vector2f((getWindowSize().x - 250) / 2.0f, getWindowSize().y / 2.0f);

        float radarDistance = science_radar_distance;
        if (InputHandler::mouseIsReleased(sf::Mouse::Left))
        {
            sf::Vector2f diff = mouse - radar_center;
            if (sf::length(diff) < 400)
            {
                P<SpaceObject> target;
                sf::Vector2f mousePosition = my_spaceship->getPosition() + diff / 400.0f * radarDistance;
                PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(radarDistance / 30, radarDistance / 30), mousePosition + sf::Vector2f(radarDistance / 30, radarDistance / 30));
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
            float x = getWindowSize().x - 270;
            float y = 400;
            sf::Vector2f position_diff = scienceTarget->getPosition() - my_spaceship->getPosition();
            float distance = sf::length(position_diff);
            float heading = sf::vector2ToAngle(position_diff);
            if (heading < 0) heading += 360;
            float rel_velocity = dot(scienceTarget->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);
            if (fabs(rel_velocity) < 0.01)
                rel_velocity = 0.0;
            
            keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Callsign", scienceTarget->getCallSign(), 20); y += 30;
            keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Distance", string(distance / 1000.0, 1) + "km", 20); y += 30;
            keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Heading", string(int(heading)), 20); y += 30;
            keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Rel.Speed", string(rel_velocity / 1000 * 60, 1) + "km/min", 20); y += 30;

            P<SpaceShip> ship = scienceTarget;
            if (ship && !ship->scanned_by_player)
            {
                if (my_spaceship->scanning_delay > 0.0)
                {
                    progressBar(sf::FloatRect(x, y, 250, 50), my_spaceship->scanning_delay, 8.0, 0.0);
                    y += 50;
                }else{
                    if (button(sf::FloatRect(x, y, 250, 50), "Scan", 30))
                        my_spaceship->commandScan(scienceTarget);
                    y += 50;
                }
            }else{
                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Faction", factionInfo[scienceTarget->faction_id]->name, 20); y += 30;
                if (ship && ship->ship_template)
                {
                    keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Type", ship->ship_template->name, 20); y += 30;
                    keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(ship->front_shield)) + "/" + string(int(ship->rear_shield)), 20); y += 30;
                }
            }
            P<SpaceStation> station = scienceTarget;
            if (station)
            {
                keyValueDisplay(sf::FloatRect(x, y, 250, 30), 0.4, "Shields", string(int(station->shields)), 20); y += 30;
            }
        }

        if (science_radar_distance == 50000 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 1x", 30))
            science_radar_distance = 25000;
        else if (science_radar_distance == 25000 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 2x", 30))
            science_radar_distance = 12500;
        else if (science_radar_distance == 12500 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 4x", 30))
            science_radar_distance = 5000;
        else if (science_radar_distance == 5000 && button(sf::FloatRect(getWindowSize().x - 490, 820, 200, 50), "Zoom: 10x", 30))
            science_radar_distance = 50000;
    }else{
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
            for(unsigned int n=0; n<factionInfo.size(); n++)
            {
                if (toggleButton(sf::FloatRect(240, 100 + n * 50, 250, 50), science_sub_selection == int(n), factionInfo[n]->name, 30))
                    science_sub_selection = n;
            }
            if (science_sub_selection > -1)
            {
                float y = 100;
                for(unsigned int n=0; n<factionInfo.size(); n++)
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
                textbox(sf::FloatRect(500, y, 400, 400), factionInfo[science_sub_selection]->description, AlignTopLeft, 20);
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
                    if (ship_template->weaponTubes > 0)
                    {
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Missile tubes", string(ship_template->weaponTubes), 20); y += 40;
                        keyValueDisplay(sf::FloatRect(500, y, 400, 40), 0.7, "Missile load time", string(int(ship_template->tube_load_time)), 20); y += 40;
                    }
                    for(int n=0; n<MW_Count; n++)
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
        jumpSlider(sf::FloatRect(x, 650, 40, 200), 15);
        jumpButton(sf::FloatRect(x, 865, 80, 30), 20);
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
}

void CrewUI::jumpButton(sf::FloatRect rect, float text_size)
{
    if (my_spaceship->jumpDelay > 0.0)
    {
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

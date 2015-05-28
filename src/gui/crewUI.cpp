#include "crewUI.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "spaceObjects/spaceStation.h"
#include "spaceObjects/warpJammer.h"
#include "shipSelectionScreen.h"

CrewUI::CrewUI()
{
    return_to_ship_selection_time = 0.0;
}

void CrewUI::onGui()
{
    if (my_spaceship)
    {
        onCrewUI();
        if (my_spaceship->activate_self_destruct)
        {
            selfDestructGUI();
        }else{
            if (my_player_info->main_screen_control)
                mainScreenSelectGUI();
        }
    }else{
        drawStatic();
        if (return_to_ship_selection_time == 0.0)
        {
            return_to_ship_selection_time = engine->getElapsedTime() + 20.0;
        }
        if (engine->getElapsedTime() > return_to_ship_selection_time)
        {
            destroy();
            new ShipSelectionScreen();
        }
        if (engine->getElapsedTime() > return_to_ship_selection_time - 10.0)
        {
            drawProgressBar(sf::FloatRect(getWindowSize().x / 2 - 300, 600, 600, 100), return_to_ship_selection_time - engine->getElapsedTime(), 0, 10);
        }
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
                if (drawToggleButton(sf::FloatRect(200 * offset, 0, 200, 35), my_player_info->crew_active_position == ECrewPosition(n), getCrewPositionName(ECrewPosition(n)), 20))
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
    drawText(sf::FloatRect(0, 500, 1600, 100), "???", AlignCenter, 100);
}

void CrewUI::drawImpulseSlider(sf::FloatRect rect, float text_size)
{
    float res = drawVerticalSlider(rect, my_spaceship->impulse_request, 1.0, -1.0);
    if (res > -0.15 && res < 0.15)
        res = 0.0;
    if (res != my_spaceship->impulse_request)
    {
        my_spaceship->commandImpulse(res);
        my_spaceship->impulse_request = res; //Set the impulse_request directly, so it looks smooth on the client.
    }
    drawText(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(int(my_spaceship->impulse_request * 100)) + "%", AlignLeft, text_size);
    drawText(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(my_spaceship->current_impulse * 100)) + "%", AlignLeft, text_size);
    drawDamagePowerDisplay(rect, SYS_Impulse, text_size);
}

void CrewUI::drawWarpSlider(sf::FloatRect rect, float text_size)
{
    float res = drawVerticalSlider(rect, my_spaceship->warp_request, 4.0, 0.0);
    if (res != my_spaceship->warp_request)
        my_spaceship->commandWarp(res);
    drawText(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(int(my_spaceship->warp_request)), AlignLeft, text_size);
    drawText(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(my_spaceship->current_warp * 100)) + "%", AlignLeft, text_size);
    drawDamagePowerDisplay(rect, SYS_Warp, text_size);
}

void CrewUI::drawJumpSlider(float& jump_distance, sf::FloatRect rect, float text_size)
{
    if (my_spaceship->jump_delay > 0.0)
    {
        drawVerticalSlider(rect, jump_distance, 40.0, 5.0, 10.0);
    }else{
        jump_distance = drawVerticalSlider(rect, jump_distance, 40.0, 5.0, 10.0);
    }
    jump_distance = roundf(jump_distance * 10.0f) / 10.0f;
    drawText(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(jump_distance, 1) + "km", AlignLeft, text_size);
}

void CrewUI::drawJumpButton(float jump_distance, sf::FloatRect rect, float text_size)
{
    if (my_spaceship->jump_delay > 0.0)
    {
        if (rect.width < text_size * 5)
            drawTextBox(rect, string(int(ceilf(my_spaceship->jump_delay))), AlignCenter, text_size);
        else
            drawKeyValueDisplay(rect, 0.5, "Jump in", string(int(ceilf(my_spaceship->jump_delay))), text_size);
    }else{
        if (drawButton(rect, "Jump", text_size))
            my_spaceship->commandJump(jump_distance);
    }
    drawDamagePowerDisplay(rect, SYS_JumpDrive, text_size);
}

void CrewUI::drawDockingButton(sf::FloatRect rect, float text_size)
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
                if (dock_object && dock_object->canBeDockedBy(my_spaceship) && (dock_object->getPosition() - my_spaceship->getPosition()) < 1000.0f + dock_object->getRadius())
                    break;
                dock_object = NULL;
            }

            if (dock_object)
            {
                if (drawButton(rect, "Request Dock", text_size))
                    my_spaceship->commandDock(dock_object);
            }else{
                drawDisabledButton(rect, "Request Dock", text_size);
            }
        }
        break;
    case DS_Docking:
        drawDisabledButton(rect, "Docking...", text_size);
        break;
    case DS_Docked:
        if (drawButton(rect, "Undock", text_size))
            my_spaceship->commandUndock();
        break;
    }
}

void CrewUI::drawWeaponTube(EMissileWeapons load_type, int n, float missile_target_angle, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size)
{
    switch(my_spaceship->weaponTube[n].state)
    {
    case WTS_Empty:
        if (drawToggleButton(load_rect, load_type != MW_None && my_spaceship->weapon_storage[load_type] > 0, "Load", text_size) && load_type != MW_None)
            my_spaceship->commandLoadTube(n, load_type);
        drawDisabledButton(fire_rect, "Empty", text_size);
        break;
    case WTS_Loaded:
        if (drawButton(load_rect, "Unload", text_size))
            my_spaceship->commandUnloadTube(n);
        if (drawButton(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), text_size))
            my_spaceship->commandFireTube(n, missile_target_angle);
        break;
    case WTS_Loading:
        drawProgressBar(fire_rect, my_spaceship->weaponTube[n].delay, my_spaceship->tube_load_time, 0.0);
        drawText(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), AlignCenter, text_size, sf::Color(128, 128, 128));
        drawDisabledButton(load_rect, "Loading", text_size);
        break;
    case WTS_Unloading:
        drawProgressBar(fire_rect, my_spaceship->weaponTube[n].delay, 0.0, my_spaceship->tube_load_time);
        drawText(fire_rect, getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded), AlignCenter, text_size, sf::Color(128, 128, 128));
        drawDisabledButton(load_rect, "Unloading", text_size * 0.8);
        break;
    }
    drawDamagePowerDisplay(fire_rect, SYS_MissileSystem, text_size);
}

int CrewUI::drawFrequencyCurve(sf::FloatRect rect, bool frequency_is_beam, bool more_damage_is_positive, int frequency)
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

void CrewUI::drawDamagePowerDisplay(sf::FloatRect rect, ESystem system, float text_size)
{
    if (!my_spaceship->hasSystem(system))
        return;
    sf::Color color;
    string display_text;

    float power = my_spaceship->systems[system].power_level;
    float health = my_spaceship->systems[system].health;
    float heat = my_spaceship->systems[system].heat_level;
    int alpha = 128;
    if (system == SYS_FrontShield)
    {
        power = std::max(power, my_spaceship->systems[SYS_RearShield].power_level);
        health = std::max(health, my_spaceship->systems[SYS_RearShield].health);
        heat = std::max(heat, my_spaceship->systems[SYS_RearShield].heat_level);
    }
    if (health <= 0.0)
    {
        color = sf::Color::Red;
        display_text = "DAMAGED";
    }else if ((system == SYS_Warp || system == SYS_JumpDrive) && WarpJammer::isWarpJammed(my_spaceship->getPosition()))
    {
        color = sf::Color::Red;
        display_text = "JAMMED";
    }else if (power == 0.0)
    {
        color = sf::Color::Red;
        display_text = "NO POWER";
    }else if (power < 0.3)
    {
        color = sf::Color(255, 128, 0);
        alpha = 64;
        display_text = "LOW POWER";
    }else if (heat > 0.90)
    {
        color = sf::Color(255, 128, 0);
        alpha = 64;
        display_text = "OVERHEATING";
    }else{
        return;
    }
    drawBoxWithBackground(rect, color, sf::Color(0, 0, 0, alpha));
    if (rect.height > rect.width)
        drawVerticalText(rect, display_text, AlignCenter, text_size, color);
    else
        drawText(rect, display_text, AlignCenter, text_size, color);
}

string CrewUI::drawOnScreenKeyboard()
{
    string ret = "";
    float size = 60;
    float text_size = 40;
    float x = getWindowSize().x / 2.0 - size * 7.5;
    float y = 790;

    string line = "1234567890-=";
    for(unsigned int n=0; n<line.size(); n++)
        if (drawButton(sf::FloatRect(x + n * size, y - size * 5, size, size), line[n], text_size))
            ret += line[n];
    if (drawButton(sf::FloatRect(x + 12 * size, y - size * 5, size * 2, size), "<-", text_size))
        ret += "\b";
    line = "QWERTYUIOP()";
    for(unsigned int n=0; n<line.size(); n++)
        if (drawButton(sf::FloatRect(x + size * 0.5 + n * size, y - size * 4, size, size), line[n], text_size))
            ret += line[n];
    line = "ASDFGHJKL;'";
    for(unsigned int n=0; n<line.size(); n++)
        if (drawButton(sf::FloatRect(x + size * 1.0 + n * size, y - size * 3, size, size), line[n], text_size))
            ret += line[n];
    if (drawButton(sf::FloatRect(x + 12 * size, y - size * 3, size * 2, size), "Send", text_size))
        ret += "\n";
    line = "ZXCVBNM,./";
    for(unsigned int n=0; n<line.size(); n++)
        if (drawButton(sf::FloatRect(x + size * 1.5 + n * size, y - size * 2, size, size), line[n], text_size))
            ret += line[n];
    if (drawButton(sf::FloatRect(x + size * 2.0, y - size, size * 9, size), "", text_size))
        ret += " ";

    return ret;
}

float CrewUI::calculateFiringSolution(sf::Vector2f target_position)
{
    float missile_angle = sf::vector2ToAngle(target_position - my_spaceship->getPosition());
    float missile_speed = 200.0f;
    float missile_turn_rate = 10.0f;
    float turn_radius = ((360.0f / missile_turn_rate) * missile_speed) / (2.0f * M_PI);

    for(int iterations=0; iterations<10; iterations++)
    {
        float angle_diff = sf::angleDifference(missile_angle, my_spaceship->getRotation());

        float left_or_right = 90;
        if (angle_diff > 0)
            left_or_right = -90;

        sf::Vector2f turn_center = my_spaceship->getPosition() + sf::vector2FromAngle(my_spaceship->getRotation() + left_or_right) * turn_radius;
        sf::Vector2f turn_exit = turn_center + sf::vector2FromAngle(missile_angle - left_or_right) * turn_radius;

        float time_missile = sf::length(turn_exit - target_position) / missile_speed;
        sf::Vector2f interception = turn_exit + sf::vector2FromAngle(missile_angle) * missile_speed * time_missile;
        if ((interception - target_position) < 100.0f)
            return missile_angle;
        missile_angle = sf::vector2ToAngle(target_position - turn_exit);
    }
    return std::numeric_limits<float>::infinity();
}

void CrewUI::drawMissileTrajectory(sf::Vector2f radar_center, float radar_size, float radar_distance, float missile_target_angle)
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
        a[cnt + 1].position = radar_center + (turn_center + sf::vector2FromAngle(my_spaceship->getRotation() - angle_diff / 10.0f * cnt - left_or_right) * turn_radius) / radar_distance * radar_size;
    a[11].position = radar_center + turn_exit / radar_distance * radar_size;
    a[12].position = radar_center + (turn_exit + sf::vector2FromAngle(missile_target_angle) * radar_distance) / radar_distance * radar_size;
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
            p = (turn_center + n * turn_radius) / radar_distance * radar_size;
        }else{
            p = (turn_exit + sf::vector2FromAngle(missile_target_angle) * (offset - turn_distance)) / radar_distance * radar_size;
            n = sf::vector2FromAngle(missile_target_angle + 90.0f);
        }
        sf::VertexArray a(sf::Lines, 2);
        a[0].position = radar_center + p - n * 10.0f;
        a[1].position = radar_center + p + n * 10.0f;
        getRenderTarget()->draw(a);

        offset += 10.0 * speed;
    }
}

void CrewUI::drawTargetTrajectory(sf::Vector2f radar_center, float radar_size, float radar_distance, P<SpaceObject> target)
{
    if (!target || target->getVelocity() < 1.0f)
        return;
        
    sf::VertexArray a(sf::Lines, 12);
    a[0].position = radar_center + (target->getPosition() - my_spaceship->getPosition()) / radar_distance * radar_size;
    a[0].color = sf::Color(255, 255, 255, 128);
    a[1].position = a[0].position + (target->getVelocity() * 60.0f) / radar_distance * radar_size;
    a[1].color = sf::Color(255, 255, 255, 0);
    sf::Vector2f n = sf::normalize(sf::Vector2f(-target->getVelocity().y, target->getVelocity().x));
    for(int cnt=0; cnt<5; cnt++)
    {
        sf::Vector2f p = (target->getVelocity() * (10.0f + 10.0f * cnt)) / radar_distance * radar_size;
        a[2 + cnt * 2].position = a[0].position + p + n * 10.0f;
        a[3 + cnt * 2].position = a[0].position + p - n * 10.0f;
        a[2 + cnt * 2].color = a[3 + cnt * 2].color = sf::Color(255, 255, 255, 128 - cnt * 20);
    }
    getRenderTarget()->draw(a);
}

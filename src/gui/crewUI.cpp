#include "crewUI.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "spaceObjects/spaceStation.h"
#include "spaceObjects/warpJammer.h"

CrewUI::CrewUI()
{
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
    float res = drawVerticalSlider(rect, my_spaceship->impulseRequest, 1.0, -1.0);
    if (res > -0.15 && res < 0.15)
        res = 0.0;
    if (res != my_spaceship->impulseRequest)
    {
        my_spaceship->commandImpulse(res);
        my_spaceship->impulseRequest = res; //Set the impulseRequest directly, so it looks smooth on the client.
    }
    drawText(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(int(my_spaceship->impulseRequest * 100)) + "%", AlignLeft, text_size);
    drawText(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(my_spaceship->currentImpulse * 100)) + "%", AlignLeft, text_size);
    drawDamagePowerDisplay(rect, SYS_Impulse, text_size);
}

void CrewUI::drawWarpSlider(sf::FloatRect rect, float text_size)
{
    float res = drawVerticalSlider(rect, my_spaceship->warpRequest, 4.0, 0.0);
    if (res != my_spaceship->warpRequest)
        my_spaceship->commandWarp(res);
    drawText(sf::FloatRect(rect.left, rect.top + rect.height, rect.width, text_size), string(int(my_spaceship->warpRequest)), AlignLeft, text_size);
    drawText(sf::FloatRect(rect.left, rect.top + rect.height + text_size, rect.width, text_size), string(int(my_spaceship->currentWarp * 100)) + "%", AlignLeft, text_size);
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
    int alpha = 128;
    if (system == SYS_FrontShield)
    {
        power = std::max(power, my_spaceship->systems[SYS_RearShield].power_level);
        health = std::max(health, my_spaceship->systems[SYS_RearShield].health);
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

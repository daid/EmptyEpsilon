#include "crewEngineeringUI.h"
#include "gameGlobalInfo.h"

CrewEngineeringUI::CrewEngineeringUI()
{
    self_destruct_open = false;
    selected_system = SYS_None;
    shield_new_frequency = SpaceShip::max_frequency / 2;
}

void CrewEngineeringUI::onCrewUI()
{
    if (!my_spaceship->ship_template) return;
    
    sf::RenderTarget& window = *getRenderTarget();
    sf::Vector2f mouse = InputHandler::getMousePos();

    float net_power = my_spaceship->getNetPowerUsage();
    keyValueDisplay(sf::FloatRect(20, 100, 300, 40), 0.5, "Energy", string(int(my_spaceship->energy_level)) + " (" + string(net_power) + ")", 25);
    keyValueDisplay(sf::FloatRect(20, 140, 300, 40), 0.5, "Hull", string(int(my_spaceship->hull_strength * 100 / my_spaceship->hull_max)), 25);
    keyValueDisplay(sf::FloatRect(20, 180, 300, 40), 0.5, "Shields", string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "/" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)), 25);
    /*
    if (toggleButton(sf::FloatRect(20, 250, 300, 50), my_spaceship->auto_repair_enabled, "Auto-Repair", 30))
    {
        my_spaceship->commandSetAutoRepair(!my_spaceship->auto_repair_enabled);
    }
    */
    
    if (my_spaceship->activate_self_destruct)
    {
        box(sf::FloatRect(20, 220, 300, 140));
        box(sf::FloatRect(20, 270, 300, 90));
        text(sf::FloatRect(20, 220, 300, 50), "Self destruct", AlignCenter, 30);
        if (button(sf::FloatRect(40, 290, 260, 50), "Cancel", 30))
            my_spaceship->commandCancelSelfDestruct();
    }else{
        if (!self_destruct_open)
        {
            if (button(sf::FloatRect(20, 220, 300, 50), "Self destruct", 30))
                self_destruct_open = true;
        }else{
            box(sf::FloatRect(20, 220, 300, 140));
            box(sf::FloatRect(20, 270, 300, 90));
            text(sf::FloatRect(20, 220, 300, 50), "Self destruct", AlignCenter, 30);
            if (button(sf::FloatRect(40, 290, 260, 50), "Confirm", 30))
                my_spaceship->commandActivateSelfDestruct();
            if (InputHandler::mouseIsReleased(sf::Mouse::Left))
                self_destruct_open = false;
        }
    }

    int y = 470;
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (!my_spaceship->hasSystem(ESystem(n))) continue;
        if (toggleButton(sf::FloatRect(20, y, 300, 50), ESystem(n) == selected_system, getSystemName(ESystem(n)), 30))
            selected_system = ESystem(n);
        
        float health = my_spaceship->systems[n].health;
        progressBar(sf::FloatRect(320, y, 100, 50), health, 0.0, 1.0, sf::Color(64, 128 * health, 64 * health));
        text(sf::FloatRect(320, y, 100, 50), string(int(health * 100)) + "%", AlignCenter, 20);
        
        float heat = my_spaceship->systems[n].heat_level;
        progressBar(sf::FloatRect(420, y, 50, 50), heat, 0.0, 1.0, sf::Color(128, 128 * (1.0 - heat), 0));
        float heating_diff = powf(1.7, my_spaceship->systems[n].power_level - 1.0) - (1.0 + my_spaceship->systems[n].coolant_level * 0.1);
        if (my_spaceship->systems[n].heat_level > 0.0 && fabs(heating_diff) > 0.0)
        {
            sf::Sprite arrow;
            textureManager.setTexture(arrow, "gui_arrow.png");
            arrow.setPosition(420 + 25, y + 25);
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
        progressBar(sf::FloatRect(470, y, 50, 50), power, 0.0, 3.0, sf::Color(192, 192, 0));
        float coolant = my_spaceship->systems[n].coolant_level;
        progressBar(sf::FloatRect(520, y, 50, 50), coolant, 0.0, 10.0, sf::Color(0, 128, 128));
        
        y += 50;
    }
    
    box(sf::FloatRect(570, 470, 270, 400));
    if (my_spaceship->hasSystem(selected_system))
    {
        vtext(sf::FloatRect(600, 490, 30, 360), "Power", AlignLeft);
        float ret = vslider(sf::FloatRect(630, 490, 60, 360), my_spaceship->systems[selected_system].power_level, 3.0, 0.0, 1.0);
        if (ret < 1.25 && ret > 0.75)
            ret = 1.0;
        if (my_spaceship->systems[selected_system].power_level != ret)
            my_spaceship->commandSetSystemPower(selected_system, ret);

        vtext(sf::FloatRect(700, 490, 30, 360), "Coolant", AlignLeft);
        ret = vslider(sf::FloatRect(730, 490, 60, 360), my_spaceship->systems[selected_system].coolant_level, 10.0, 0.0);
        if (my_spaceship->systems[selected_system].coolant_level != ret)
            my_spaceship->commandSetSystemCoolant(selected_system, ret);
    }

    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        ///Shield frequency configuration
        float x = getWindowSize().x - 330;
        box(sf::FloatRect(x - 20, 470, 340, 400));
        text(sf::FloatRect(x, 470, 300, 50), "Shield Freq.", AlignCenter, 30);
        textbox(sf::FloatRect(x, 520, 300, 50), frequencyToString(my_spaceship->shield_frequency), AlignCenter, 30);
        
        text(sf::FloatRect(x, 570, 300, 50), "Change Freq.", AlignCenter, 30);
        if (my_spaceship->shield_calibration_delay > 0.0)
        {
            textbox(sf::FloatRect(x, 620, 300, 50), "Calibrating", AlignCenter, 30);
            progressBar(sf::FloatRect(x, 670, 300, 50), my_spaceship->shield_calibration_delay, PlayerSpaceship::shield_calibration_time, 0);
        }else{
            shield_new_frequency += selector(sf::FloatRect(x, 620, 300, 50), frequencyToString(shield_new_frequency), 30);
            if (shield_new_frequency < 0)
                shield_new_frequency = 0;
            if (shield_new_frequency > SpaceShip::max_frequency)
                shield_new_frequency = SpaceShip::max_frequency;
            if (button(sf::FloatRect(x, 670, 300, 50), "Calibrate", 30))
                my_spaceship->commandSetShieldFrequency(shield_new_frequency);
        }
    }

    ///Draw the ship interior
    sf::Vector2i interior_size = my_spaceship->ship_template->interiorSize();
    sf::Vector2f interial_position = sf::Vector2f(getWindowSize().x / 2.0, 250) - sf::Vector2f(interior_size) * 48.0f / 2.0f;
    drawShipInternals(interial_position, my_spaceship, selected_system);

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

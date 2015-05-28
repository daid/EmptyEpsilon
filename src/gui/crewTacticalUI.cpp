#include "crewTacticalUI.h"

CrewTacticalUI::CrewTacticalUI()
{
    jump_distance = 10.0;
    ghost_delay = 0.0;

    tube_load_type = MW_None;
    missile_target_angle = 0.0;
    missile_targeting = false;
    
    if (my_spaceship)
        missile_target_angle = my_spaceship->getRotation();
}

void CrewTacticalUI::update(float delta)
{
    if (!my_spaceship)
        return;

    ///Ghost dots are the dots drawn on screen to indicate previous positions of the ship.
    if (ghost_delay > 0)
    {
        ghost_delay -= delta;
    } else {
        ghost_delay = 5.0;

        foreach(SpaceObject, obj, space_object_list)
        {
            P<SpaceShip> ship = obj;
            if (ship && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000.0)
            {
                ghost_dot.push_back(HelmsGhostDot(obj->getPosition()));
            }
        }
    }

    for(unsigned int n=0; n < ghost_dot.size(); n++)
    {
        HelmsGhostDot& ghost = ghost_dot[n];
        ghost.lifetime -= delta;
        if (ghost.lifetime <= 0.0)
        {
            ghost_dot.erase(ghost_dot.begin() + n);
            n--;
        }
    }

    CrewUI::update(delta);
}

void CrewTacticalUI::onCrewUI()
{
    float radarDistance = 5000.0f;
    sf::Vector2f mousePosition = InputHandler::getMousePos();
    sf::Vector2f radar_center = getWindowSize() / 2.0f;
    sf::Vector2f diff = mousePosition - radar_center;
    
    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
    {
        if (sf::length(diff) < 400 && (mousePosition.x < getWindowSize().x - 170 - 350 || mousePosition.y < 890 - 50 * my_spaceship->weapon_tubes))
        {
            P<SpaceObject> target;
            PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(50, 50), mousePosition + sf::Vector2f(50, 50));
            foreach(Collisionable, obj, list)
            {
                P<SpaceObject> spaceObject = obj;
                if (spaceObject && spaceObject->canBeTargeted() && spaceObject != my_spaceship)
                {
                    if (!target || sf::length(mousePosition - spaceObject->getPosition()) < sf::length(mousePosition - target->getPosition()))
                        target = spaceObject;
                }
            }
            if (target)
            {
                my_spaceship->commandSetTarget(target);
            }else{
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(diff));
                missile_targeting = true;
            }
        }
    }
    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        missile_targeting = false;
    }
    if (missile_targeting)
    {
        float angle = calculateFiringSolution(my_spaceship->getPosition() + diff / 400.0f * radarDistance);
        if (angle != std::numeric_limits<float>::infinity())
            missile_target_angle = angle;
    }
    
    drawMissileTrajectory(radar_center, 400.0f, radarDistance, missile_target_angle);

    sf::VertexArray ghost_dots(sf::Points, ghost_dot.size());
    for(unsigned int n=0; n<ghost_dot.size(); n++)
    {
        ghost_dots[n].position = radar_center + (ghost_dot[n].position - my_spaceship->getPosition()) / radarDistance * 400.0f;
        ghost_dots[n].color = sf::Color(255, 255, 255, 255 * (ghost_dot[n].lifetime / HelmsGhostDot::total_lifetime));
    }
    getRenderTarget()->draw(ghost_dots);

    drawRadar(radar_center, 400, radarDistance, false, my_spaceship->getTarget());
    if (InputHandler::mouseIsDown(sf::Mouse::Left))
    {
        sf::Vector2f diff = mousePosition - radar_center;
        if (sf::length(diff) < 400)
        {
            sf::Vector2f text_pos = mousePosition;
            if (engine->getObject("mouseRenderer"))
                text_pos.y -= 10.0;
            else
                text_pos.y -= 30.0;
            drawText(sf::FloatRect(text_pos.x, text_pos.y, 0, 0), string(fmodf(sf::vector2ToAngle(diff) + 360.0 + 360.0 - 270.0, 360.0), 1), AlignCenter, 20);
        }
    }
    drawDamagePowerDisplay(sf::FloatRect(radar_center.x - 140, radar_center.y + 150, 280, 50), SYS_Maneuver, 20);

    drawKeyValueDisplay(sf::FloatRect(20, 100, 240, 40), 0.45, "Energy", string(int(my_spaceship->energy_level)), 20);
    drawKeyValueDisplay(sf::FloatRect(20, 140, 240, 40), 0.45, "Heading", string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1), 20);
    float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
    string velocity_text = string(velocity, 1);
    drawKeyValueDisplay(sf::FloatRect(20, 180, 240, 40), 0.45, "Speed", velocity_text + "km/min", 20);

    drawImpulseSlider(sf::FloatRect(20, 400, 50, 300), 20);

    float x = 100;
    if (my_spaceship->has_warp_drive)
    {
        drawWarpSlider(sf::FloatRect(x, 400, 50, 300), 20);
        x += 80;
    }
    if (my_spaceship->has_jump_drive)
    {
        drawJumpSlider(jump_distance, sf::FloatRect(x, 400, 50, 300), 20);
        x += 80;
        drawJumpButton(jump_distance, sf::FloatRect(20, 750, 280, 50), 30);
    }

    drawDockingButton(sf::FloatRect(20, 800, 280, 50), 30);

    x = getWindowSize().x - 300;

    /*
    //TODO: Combat boost/strafe for tactical UI.
    
    //TODO: Here a trick is used to draw the same control twice to get a "snap back to default" type of control.
    float combat_boost_request = drawVerticalSlider(sf::FloatRect(x + 140 - 25, 750 - 165, 50, 165), 0.0, 1.0, 0.0, 0.0);
    drawVerticalSlider(sf::FloatRect(x + 140 - 25, 750 - 165, 50, 165), combat_boost_request, 1.0, 0.0, 0.0);
    if (combat_boost_request != my_spaceship->combat_maneuver_boost_request)
        my_spaceship->commandCombatManeuverBoost(combat_boost_request);
    float combat_strafe_request = drawHorizontalSlider(sf::FloatRect(x, 750, 280, 50), 0.0, -1.0, 1.0, 0.0);
    drawHorizontalSlider(sf::FloatRect(x, 750, 280, 50), combat_strafe_request, -1.0, 1.0, 0.0);
    if (combat_strafe_request != my_spaceship->combat_maneuver_strafe_request)
        my_spaceship->commandCombatManeuverStrafe(combat_strafe_request);
    
    drawDamagePowerDisplay(sf::FloatRect(x + 140 - 25, 750 - 165, 50, 165), SYS_Impulse, 20);
    drawDamagePowerDisplay(sf::FloatRect(x, 750, 280, 50), SYS_Maneuver, 20);
    
    drawProgressBar(sf::FloatRect(x, 800, 280, 50), my_spaceship->combat_maneuver_charge, 0.0, 1.0);
    drawText(sf::FloatRect(x, 800, 280, 50), "Combat maneuver", AlignCenter, 20, sf::Color::Black);
    */

    if (my_spaceship->weapon_tubes > 0)
    {
        float x = getWindowSize().x;
        float y = 900 - 10;
        for(int n=0; n<my_spaceship->weapon_tubes; n++)
        {
            y -= 50;
            drawWeaponTube(tube_load_type, n, missile_target_angle, sf::FloatRect(x - 170, y, 150, 50), sf::FloatRect(x - 170 - 350, y, 350, 50), 35);
        }

        for(int n=0; n<MW_Count; n++)
        {
            if (my_spaceship->weapon_storage_max[n] > 0)
            {
                y -= 30;
                if (drawToggleButton(sf::FloatRect(x - 220, y, 200, 30), tube_load_type == n, getMissileWeaponName(EMissileWeapons(n)) + " x" + string(my_spaceship->weapon_storage[n]), 25))
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

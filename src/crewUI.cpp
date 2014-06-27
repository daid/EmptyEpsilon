#include "crewUI.h"
#include "playerInfo.h"

CrewUI::CrewUI()
{
    jump_distance = 1.0;
    tube_load_type = MW_None;

    for(int n=0; n<max_crew_positions; n++)
    {
        if (my_player_info->crewPosition[n])
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
        case tacticalOfficer:
            tacticalUI();
            break;
        default:
            text(sf::FloatRect(0, 500, 1600, 100), "???", AlignCenter, 100);
            break;
        }
    }else{
        drawStatic();
    }

    int offset = 0;
    for(int n = 0; n < max_crew_positions; n++)
    {
        if (my_player_info->crewPosition[n])
        {
            if (button(sf::FloatRect(200 * offset, 0, 200, 20), getCrewPositionName(ECrewPosition(n)), 20))
            {
                show_position = ECrewPosition(n);
            }
            offset++;
        }
    }

    MainUI::onGui();
}

void CrewUI::helmsUI()
{
    sf::RenderTarget* window = getRenderTarget();
    P<InputHandler> input_handler = engine->getObject("inputHandler");
    sf::Vector2f mouse = input_handler->getMousePos();
    if (input_handler->mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);
        if (sf::length(diff) < 400)
            my_spaceship->commandTargetRotation(sf::vector2ToAngle(diff));
    }

    //Radar
    float radar_distance = 5000; //TODO: HARDCODED
    drawHeadingCircle(sf::Vector2f(800, 450), 400);

    foreach(SpaceObject, obj, space_object_list)
    {
        if (obj != my_spaceship && sf::length(obj->getPosition() - my_spaceship->getPosition()) < radar_distance)
            obj->drawRadar(*window, sf::Vector2f(800, 450) + (obj->getPosition() - my_spaceship->getPosition()) / radar_distance * 400.0f, 400.0f / radar_distance);
    }

    P<SpaceObject> target = my_spaceship->getTarget();
    if (target)
    {
        sf::Sprite object_sprite;
        texture_manager.setTexture(object_sprite, "redicule.png"); //Hihi redicule.
        object_sprite.setPosition(sf::Vector2f(800, 450) + (target->getPosition() - my_spaceship->getPosition()) / radar_distance * 400.0f);
        window->draw(object_sprite);
    }
    my_spaceship->drawRadar(*window, sf::Vector2f(800, 450), 400.0f / radar_distance);
    //!Radar

    float res = vslider(sf::FloatRect(20, 500, 50, 300), my_spaceship->impulse_request, 1.0, -1.0);
    if (res > -0.15 && res < 0.15)
        res = 0.0;
    if (res != my_spaceship->impulse_request)
        my_spaceship->commandImpulse(res);
    text(sf::FloatRect(20, 800, 50, 20), string(int(my_spaceship->impulse_request * 100)) + "%", AlignLeft, 20);
    text(sf::FloatRect(20, 820, 50, 20), string(int(my_spaceship->current_impulse * 100)) + "%", AlignLeft, 20);

    if (my_spaceship->has_warp_drive)
    {
        res = vslider(sf::FloatRect(100, 500, 50, 300), my_spaceship->warp_request, 4.0, 0.0);
        if (res != my_spaceship->warp_request)
            my_spaceship->commandWarp(res);
        text(sf::FloatRect(100, 800, 50, 20), string(int(my_spaceship->warp_request)), AlignLeft, 20);
        text(sf::FloatRect(100, 820, 50, 20), string(int(my_spaceship->current_warp * 100)) + "%", AlignLeft, 20);
    }
    if (my_spaceship->has_jump_drive)
    {
        float x = my_spaceship->has_warp_drive ? 180 : 100;
        jump_distance = vslider(sf::FloatRect(x, 500, 50, 300), jump_distance, 20.0, 1.0);
        text(sf::FloatRect(x, 800, 50, 20), string(jump_distance) + "km", AlignLeft, 20);
        if (my_spaceship->jump_delay > 0.0)
        {
            text(sf::FloatRect(x, 820, 50, 20), string(int(my_spaceship->jump_delay) + 1), AlignLeft, 20);
        }else{
            if (button(sf::FloatRect(x, 820, 70, 30), "Jump", 20))
            {
                my_spaceship->commandJump(jump_distance);
            }
        }
    }
}
#include <typeinfo>
void CrewUI::tacticalUI()
{
    sf::RenderTarget* window = getRenderTarget();
    P<InputHandler> input_handler = engine->getObject("inputHandler");
    sf::Vector2f mouse = input_handler->getMousePos();
    float radar_distance = 5000; //TODO: Hardcoded. Also, why is it declared again here? It's also declared in helms UI. This should be a ship option.

    //Radar
    if (input_handler->mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);
        if (sf::length(diff) < 400)
        {
            P<SpaceObject> target;
            sf::Vector2f mouse_position = my_spaceship->getPosition() + diff / 400.0f * radar_distance;
            PVector<Collisionable> list = CollisionManager::queryArea(mouse_position - sf::Vector2f(50, 50), mouse_position + sf::Vector2f(50, 50));
            foreach(Collisionable, obj, list)
            {
                P<SpaceObject> space_object = obj;
                if (space_object && space_object != my_spaceship)
                    target = space_object;
            }
            my_spaceship->commandSetTarget(target);
        }
    }

    drawHeadingCircle(sf::Vector2f(800, 450), 400);

    foreach(SpaceObject, obj, space_object_list)
    {
        if (obj != my_spaceship && sf::length(obj->getPosition() - my_spaceship->getPosition()) < radar_distance)
            obj->drawRadar(*window, sf::Vector2f(800, 450) + (obj->getPosition() - my_spaceship->getPosition()) / radar_distance * 400.0f, 400.0f / radar_distance);
    }

    P<SpaceObject> target = my_spaceship->getTarget();
    if (target)
    {
        sf::Sprite object_sprite;
        texture_manager.setTexture(object_sprite, "redicule.png");
        object_sprite.setPosition(sf::Vector2f(800, 450) + (target->getPosition() - my_spaceship->getPosition()) / radar_distance * 400.0f);
        window->draw(object_sprite);
    }
    my_spaceship->drawRadar(*window, sf::Vector2f(800, 450), 400.0f / radar_distance);
    //!Radar

    for(int n = 0; n < MW_Count; n++)
    {
        if (toggleButton(sf::FloatRect(10, 440 + n * 30, 200, 30), tube_load_type == n, getMissileWeaponName(EMissileWeapons(n)), 25))
        {
            if (tube_load_type == n)
                tube_load_type = MW_None;
            else
                tube_load_type = EMissileWeapons(n);
        }
    }

    for(int n = 0; n < my_spaceship->weapon_tubes; n++)
    {
        if (my_spaceship->weapon_tube[n].type_loaded == MW_None)
        {
            if (toggleButton(sf::FloatRect(20, 840 - 50 * n, 150, 50), tube_load_type != MW_None, "Load", 35) && tube_load_type != MW_None)
            {
                my_spaceship->commandLoadTube(n, tube_load_type);
            }
            toggleButton(sf::FloatRect(170, 840 - 50 * n, 350, 50), false, "Empty", 35);
        }else{
            if (button(sf::FloatRect(20, 840 - 50 * n, 150, 50), "Unload", 35))
            {
                my_spaceship->commandUnloadTube(n);
            }
            if (button(sf::FloatRect(170, 840 - 50 * n, 350, 50), getMissileWeaponName(my_spaceship->weapon_tube[n].type_loaded), 35))
            {
                my_spaceship->commandFireTube(n);
            }
        }
    }
}

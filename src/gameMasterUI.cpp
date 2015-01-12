#include <limits>

#include "gameMasterUI.h"
#include "factionInfo.h"
#include "cpuShip.h"
#include "spaceStation.h"
#include "blackHole.h"
#include "nebula.h"
#include "warpJammer.h"
#include "gameGlobalInfo.h"

GameMasterUI::GameMasterUI()
{
    view_distance = 50000;
    mouse_mode = MM_None;
    if (engine->getGameSpeed() == 0.0)
        mouse_mode = MM_Drag;
    click_and_drag_state = CD_None;
}

void GameMasterUI::onGui()
{
    sf::RenderTarget& window = *getRenderTarget();
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f mouse_world_position = view_position + (mouse - sf::Vector2f(800, 450)) / 400.0f * view_distance;

    if (isActive())
    {
        if (InputHandler::mouseIsPressed(sf::Mouse::Left) && mouse.x > 300)
        {
            mouse_down_pos = mouse;
            click_and_drag_state = CD_BoxSelect;
            if (mouse_mode == MM_Drag)
            {
                foreach(SpaceObject, obj, selection)
                {
                    if (sf::length(mouse_world_position - obj->getPosition()) < 0.1 * view_distance)
                        click_and_drag_state = CD_DragObjects;
                }
            }
        }
        if (InputHandler::mouseIsReleased(sf::Mouse::Left) && mouse.x > 300)
        {
            switch(mouse_mode)
            {
            case MM_None:
            case MM_Drag:
                if (click_and_drag_state == CD_BoxSelect)
                {
                    selection.clear();
                    
                    if (mouse_down_pos == mouse)
                    {
                        P<SpaceObject> target;
                        PVector<Collisionable> list = CollisionManager::queryArea(mouse_world_position - sf::Vector2f(0.1 * view_distance, 0.1 * view_distance), mouse_world_position + sf::Vector2f(0.1 * view_distance, 0.1 * view_distance));
                        foreach(Collisionable, obj, list)
                        {
                            P<SpaceObject> spaceObject = obj;
                            if (spaceObject)
                            {
                                if (!target || sf::length(mouse_world_position - spaceObject->getPosition()) < sf::length(mouse_world_position - target->getPosition()))
                                    target = spaceObject;
                            }
                        }
                        selection.clear();
                        if (target)
                            selection.push_back(target);
                    }else{
                        sf::Vector2f mouse_down_world_position = view_position + (mouse_down_pos - sf::Vector2f(800, 450)) / 400.0f * view_distance;
                        PVector<Collisionable> list = CollisionManager::queryArea(mouse_world_position, mouse_down_world_position);
                        foreach(Collisionable, obj, list)
                        {
                            P<SpaceObject> spaceObject = obj;
                            if (spaceObject)
                                selection.push_back(spaceObject);
                        }
                    }
                }
                break;
            case MM_Create:
                new GameMasterCreateObjectWindow(mouse_world_position);
                break;
            }
            click_and_drag_state = CD_None;
        }
        if (mouse_mode == MM_Drag && click_and_drag_state == CD_DragObjects && InputHandler::mouseIsDown(sf::Mouse::Left) && mouse.x > 300)
        {
            if (sf::length(mouse - mouse_down_pos) > 5.0f)
            {
                foreach(SpaceObject, obj, selection)
                    obj->setPosition(obj->getPosition() + (mouse - prev_mouse_pos) / 400.0f * view_distance);
            }
        }
        if (InputHandler::mouseIsReleased(sf::Mouse::Right) && mouse.x > 300)
        {
            sf::Vector2f upper_bound(-std::numeric_limits<float>::max(), -std::numeric_limits<float>::max());
            sf::Vector2f lower_bound(std::numeric_limits<float>::max(), std::numeric_limits<float>::max());
            foreach(SpaceObject, obj, selection)
            {
                lower_bound.x = std::min(lower_bound.x, obj->getPosition().x);
                lower_bound.y = std::min(lower_bound.y, obj->getPosition().y);
                upper_bound.x = std::max(upper_bound.x, obj->getPosition().x);
                upper_bound.y = std::max(upper_bound.y, obj->getPosition().y);
            }
            sf::Vector2f objects_center = (upper_bound + lower_bound) / 2.0f;
            foreach(SpaceObject, obj, selection)
            {
                P<CpuShip> cpuShip = obj;
                if (cpuShip)
                {
                    P<SpaceObject> target;
                    PVector<Collisionable> list = CollisionManager::queryArea(mouse_world_position - sf::Vector2f(0.1 * view_distance, 0.1 * view_distance), mouse_world_position + sf::Vector2f(0.1 * view_distance, 0.1 * view_distance));
                    foreach(Collisionable, collisionable, list)
                    {
                        P<SpaceObject> spaceObject = collisionable;
                        if (spaceObject)
                        {
                            if (!target || sf::length(mouse_world_position - spaceObject->getPosition()) < sf::length(mouse_world_position - target->getPosition()))
                                target = spaceObject;
                        }
                    }
                    if (target && target != obj && target->canBeTargeted())
                    {
                        if (obj->isEnemy(target))
                        {
                            cpuShip->orderAttack(target);
                        }else{
                            cpuShip->orderDefendTarget(target);
                        }
                    }else{
                        cpuShip->orderFlyTowardsBlind(mouse_world_position + (obj->getPosition() - objects_center));
                    }
                }
            }
        }

        view_distance *= 1.0 - (InputHandler::getMouseWheelDelta() * 0.1f);
        if (view_distance > 100000)
            view_distance = 100000;
        if (view_distance < 5000)
            view_distance = 5000;
        if (InputHandler::mouseIsDown(sf::Mouse::Middle))
        {
            view_position += (prev_mouse_pos - mouse) / 400.0f * view_distance;
        }
    }

    drawRaderBackground(view_position, sf::Vector2f(800, 450), 400.0, view_distance);
    if (click_and_drag_state == CD_BoxSelect)
    {
        sf::RectangleShape rect;
        rect.setPosition(mouse);
        rect.setSize(mouse_down_pos - mouse);
        rect.setFillColor(sf::Color(255, 255, 255, 8));
        rect.setOutlineColor(sf::Color(255, 255, 255, 32));
        rect.setOutlineThickness(2.0);
        window.draw(rect);
    }

    foreach(SpaceObject, obj, space_object_list)
    {
        obj->drawOnRadar(window, sf::Vector2f(800, 450) + (obj->getPosition() - view_position) / view_distance * 400.0f, 400.0f / view_distance, view_distance > 10000);
        P<CpuShip> cpuShip = obj;
        if (cpuShip)
        {
            P<SpaceObject> target = cpuShip->getTarget();
            if (target)
            {
                sf::VertexArray a(sf::Lines, 2);
                a[0].position = sf::Vector2f(800, 450) + (cpuShip->getPosition() - view_position) / view_distance * 400.0f;
                a[1].position = sf::Vector2f(800, 450) + (target->getPosition() - view_position) / view_distance * 400.0f;
                a[0].color = a[1].color = sf::Color(255, 255, 255, 32);
                window.draw(a);
            }
            sf::VertexArray a(sf::LinesStrip, cpuShip->pathPlanner.route.size() + 1);
            a[0].position = sf::Vector2f(800, 450) + (cpuShip->getPosition() - view_position) / view_distance * 400.0f;
            a[0].color = sf::Color(255, 255, 255, 32);
            for(unsigned int n=0; n<cpuShip->pathPlanner.route.size(); n++)
            {
                a[n+1].position = sf::Vector2f(800, 450) + (cpuShip->pathPlanner.route[n] - view_position) / view_distance * 400.0f;
                a[n+1].color = sf::Color(255, 255, 255, 32);
            }
            window.draw(a);
        }
    }
    sf::RectangleShape sidebackBackground(sf::Vector2f(300, 900));
    sidebackBackground.setFillColor(sf::Color(0, 0, 0, 128));
    window.draw(sidebackBackground);

    foreach(SpaceObject, obj, selection)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(sf::Vector2f(800, 450) + (obj->getPosition() - view_position) / view_distance * 400.0f);
        window.draw(objectSprite);
    }

    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Delete))
    {
        foreach(SpaceObject, obj, selection)
            obj->destroy();
        selection.clear();
    }

    if (selection.size() == 1)
    {
        P<SpaceObject> obj = selection[0];
        float y = 20;
        P<SpaceShip> ship = obj;
        if (ship && ship->ship_template)
        {
            text(sf::FloatRect(20, y, 100, 20), factionInfo[ship->faction_id]->name + " " + ship->ship_type_name, AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Hull: " + string(ship->hull_strength), AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Shields: " + string(ship->front_shield) + ", " + string(ship->rear_shield), AlignLeft, 20);
            y += 20;
        }
        P<SpaceStation> station = obj;
        if (station)
        {
            text(sf::FloatRect(20, y, 100, 20), factionInfo[station->faction_id]->name, AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Hull: " + string(station->hull_strength), AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Shields: " + string(station->shields), AlignLeft, 20);
            y += 20;
        }
        P<CpuShip> cpuShip = obj;
        if (cpuShip)
        {
            text(sf::FloatRect(20, y, 100, 20), "Orders: " + getAIOrderString(cpuShip->getOrder()), AlignLeft, 20);
            y += 20;

            if (toggleButton(sf::FloatRect(20, y, 250, 30), cpuShip->getOrder() == AI_Idle, "Idle", 20))
                cpuShip->orderIdle();
            y += 30;
            if (toggleButton(sf::FloatRect(20, y, 250, 30), cpuShip->getOrder() == AI_Roaming, "Roaming", 20))
                cpuShip->orderRoaming();
            y += 30;
            if (toggleButton(sf::FloatRect(20, y, 250, 30), cpuShip->getOrder() == AI_StandGround, "Stand Ground", 18))
                cpuShip->orderStandGround();
            y += 30;
            if (toggleButton(sf::FloatRect(20, y, 250, 30), cpuShip->getOrder() == AI_DefendLocation, "Defend location", 18))
                cpuShip->orderDefendLocation(cpuShip->getPosition());
            y += 30;
        }
        if (ship)
        {
            for(int n=0; n<MW_Count; n++)
            {
                if (ship->weapon_storage_max[n] < 1)
                    continue;
                text(sf::FloatRect(20, y, 130, 30), getMissileWeaponName(EMissileWeapons(n)) + ": " + string(ship->weapon_storage[n]) + "/" + string(ship->weapon_storage_max[n]), AlignLeft, 20);
                if (button(sf::FloatRect(170, y, 100, 30), "Refill", 15))
                    ship->weapon_storage[n] = ship->weapon_storage_max[n];
                y += 30;
            }
            y += 10;
            if (button(sf::FloatRect(20, y, 250, 30), "Retrofit ship", 20))
            {
                new GameMasterShipRetrofit(ship);
            }
            y += 30;
        }
        P<PlayerSpaceship> player = obj;
        if (player)
        {
            if (button(sf::FloatRect(20, y, 250, 30), "Hail ship", 20))
            {
                new GameMasterHailUI(player);
            }
            y += 30;
        }

        text(sf::FloatRect(20, 480, 250, 20), "Change faction:", AlignCenter, 20);
        unsigned int new_id = selection[0]->getFactionId() + selector(sf::FloatRect(20, 500, 250, 50), factionInfo[selection[0]->getFactionId()]->name);
        if (new_id != selection[0]->getFactionId() && new_id < factionInfo.size())
            foreach(SpaceObject, obj, selection)
                obj->setFactionId(new_id);
    }

    if (button(sf::FloatRect(20, 720, 250, 50), "Global Message", 25))
        new GameMasterGlobalMessageEntry();
    
    if (toggleButton(sf::FloatRect(20, 770, 250, 50), mouse_mode == MM_Create, "Create...", 30))
    {
        if (mouse_mode == MM_Create)
            mouse_mode = MM_None;
        else
            mouse_mode = MM_Create;
    }

    if (toggleButton(sf::FloatRect(20, 820, 250, 50), mouse_mode == MM_Drag, "Drag Objects"))
    {
        if (mouse_mode == MM_Drag)
            mouse_mode = MM_None;
        else
            mouse_mode = MM_Drag;
    }

    if (gameGlobalInfo->global_message_timeout > 0.0)
    {
        boxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 300, 100, 600, 80));
        text(sf::FloatRect(getWindowSize().x / 2 - 300, 100, 600, 80), gameGlobalInfo->global_message, AlignCenter, 30);
    }

    MainUIBase::onGui();
    prev_mouse_pos = mouse;
}

GameMasterShipRetrofit::GameMasterShipRetrofit(P<SpaceShip> ship)
: ship(ship)
{
}

void GameMasterShipRetrofit::onGui()
{
    if (!ship)
    {
        destroy();
        return;
    }
    float x = getWindowSize().x / 2 - 325;
    float y = 200;
    boxWithBackground(sf::FloatRect(x - 30, y - 30, 710, 460));

    ship->ship_type_name = textEntry(sf::FloatRect(x, y, 300, 30), ship->ship_type_name, 20);
    y += 30;
    int diff = selector(sf::FloatRect(x, y, 300, 30), string("WarpDrive: ") + (ship->hasWarpdrive ? "Yes" : "No"), 20);
    y += 30;
    if (diff)
    {
        ship->hasWarpdrive = !ship->hasWarpdrive;
        if (ship->warpSpeedPerWarpLevel < 100)
            ship->warpSpeedPerWarpLevel = 1000;
    }
    if (selector(sf::FloatRect(x, y, 300, 30), string("JumpDrive: ") + (ship->hasJumpdrive ? "Yes" : "No"), 20))
        ship->hasJumpdrive = !ship->hasJumpdrive;
    y += 30;
    ship->impulseMaxSpeed += selector(sf::FloatRect(x, y, 300, 30), "Max speed: " + string(ship->impulseMaxSpeed), 20);
    y += 30;
    ship->rotationSpeed += selector(sf::FloatRect(x, y, 300, 30), "Rotation speed: " + string(ship->rotationSpeed), 20);
    y += 30;
    diff = selector(sf::FloatRect(x, y, 300, 30), "Hull: " + string(ship->hull_strength) + "/" + string(ship->hull_max), 20);
    ship->hull_strength = std::max(0.0f, ship->hull_strength + diff * 5);
    ship->hull_max = std::max(0.0f, ship->hull_max + diff * 5);
    y += 30;
    diff = selector(sf::FloatRect(x, y, 300, 30), "Front shield: " + string(ship->front_shield) + "/" + string(ship->front_shield_max), 20);
    ship->front_shield = std::max(0.0f, ship->front_shield + diff * 15);
    ship->front_shield_max = std::max(0.0f, ship->front_shield_max + diff * 15);
    y += 30;
    diff = selector(sf::FloatRect(x, y, 300, 30), "Front shield: " + string(ship->rear_shield) + "/" + string(ship->rear_shield_max), 20);
    ship->rear_shield = std::max(0.0f, ship->rear_shield + diff * 15);
    ship->rear_shield_max = std::max(0.0f, ship->rear_shield_max + diff * 15);
    y += 30;

    x += 350;
    y = 200;

    ship->weapon_tubes += selector(sf::FloatRect(x, y, 300, 30), "Missile tubes: " + string(ship->weapon_tubes), 20);
    if (ship->weapon_tubes < 0)
        ship->weapon_tubes = maxWeaponTubes;
    if (ship->weapon_tubes > maxWeaponTubes)
        ship->weapon_tubes = 0;
    y += 30;
    for(int n=0; n<MW_Count; n++)
    {
        int diff = selector(sf::FloatRect(x, y, 300, 30), getMissileWeaponName(EMissileWeapons(n)) + ": " + string(ship->weapon_storage[n]) + "/" + string(ship->weapon_storage_max[n]), 20);
        y += 30;
        ship->weapon_storage[n] += diff;
        ship->weapon_storage_max[n] += diff;
        if (ship->weapon_storage_max[n] < 0)
            ship->weapon_storage_max[n] = 0;
        if (ship->weapon_storage[n] < 0)
            ship->weapon_storage[n] = 0;
    }
    
    y += 10;
    if (button(sf::FloatRect(x, y, 300, 50), "Ok"))
        destroy();
}

void GameMasterGlobalMessageEntry::onGui()
{
    float x = getWindowSize().x / 2 - 325;
    float y = 200;
    boxWithBackground(sf::FloatRect(x - 30, y - 30, 710, 460));

    message = textEntry(sf::FloatRect(x, y, 650, 30), message, 20);
    
    y += 50;
    if (button(sf::FloatRect(x, y, 300, 50), "Send"))
    {
        gameGlobalInfo->global_message = message;
        gameGlobalInfo->global_message_timeout = 5.0;
        destroy();
    }

    x += 350;
    if (button(sf::FloatRect(x, y, 300, 50), "Cancel"))
        destroy();
}

unsigned int GameMasterCreateObjectWindow::current_faction = 2;

GameMasterCreateObjectWindow::GameMasterCreateObjectWindow(sf::Vector2f position)
: position(position)
{
}

void GameMasterCreateObjectWindow::onGui()
{
    float x = getWindowSize().x / 2 - 325;
    float y = 200;
    boxWithBackground(sf::FloatRect(x - 30, y - 30, 710, 460));

    for(unsigned int f=0; f<factionInfo.size(); f++)
    {
        if (toggleButton(sf::FloatRect(x, y, 250, 30), current_faction == f, factionInfo[f]->name, 20))
            current_faction = f;
        y += 30;
    }
    y += 30;

    if (button(sf::FloatRect(x, y, 300, 30), "Station", 20))
    {
        P<SpaceObject> obj = new SpaceStation();
        obj->setFactionId(current_faction);
        obj->setRotation(random(0, 360));
        obj->setPosition(position);
        destroy();
    }
    y += 30;
    if (button(sf::FloatRect(x, y, 300, 30), "WarpJammer", 20))
    {
        P<SpaceObject> obj = new WarpJammer();
        obj->setFactionId(current_faction);
        obj->setRotation(random(0, 360));
        obj->setPosition(position);
        destroy();
    }
    y += 30;
    if (button(sf::FloatRect(x, y, 300, 30), "BlackHole", 20))
    {
        P<SpaceObject> obj = new BlackHole();
        obj->setPosition(position);
        destroy();
    }
    y += 30;
    if (button(sf::FloatRect(x, y, 300, 30), "Nebula", 20))
    {
        P<SpaceObject> obj = new Nebula();
        obj->setPosition(position);
        destroy();
    }
    y += 30;

    x += 350;
    y = 200;

    std::vector<string> template_names = ShipTemplate::getTemplateNameList();
    std::sort(template_names.begin(), template_names.end());
    for(unsigned int n=0; n<template_names.size(); n++)
    {
        if (button(sf::FloatRect(x, y, 300, 30), template_names[n] + "(" + string(ShipTemplate::getTemplate(template_names[n])->frontShields) + ")", 20))
        {
            P<CpuShip> s = new CpuShip();
            s->setFactionId(current_faction);
            s->setShipTemplate(template_names[n]);
            s->setPosition(position);
            s->orderRoaming();
            
            destroy();
        }
        y += 30;
    }
    
    y += 10;
    if (button(sf::FloatRect(x, y, 300, 50), "Cancel"))
        destroy();
}

GameMasterHailUI::GameMasterHailUI(P<PlayerSpaceship> player)
: player(player)
{
    hail_name = "Main Command";
}

void GameMasterHailUI::onGui()
{
    if (!player)
    {
        destroy();
        return;
    }

    float x = getWindowSize().x / 2 - 425;
    float y = 100;
    boxWithBackground(sf::FloatRect(x - 30, y - 30, 960, 840));
    
    switch(player->comms_state)
    {
    case CS_Inactive:
    case CS_ChannelFailed:
    case CS_ChannelBroken:
        text(sf::FloatRect(x, y, 300, 50), "Use name:", AlignRight);
        hail_name = textEntry(sf::FloatRect(x + 300, y, 300, 50), hail_name, 25);
        y += 50;
        if (button(sf::FloatRect(x, y, 300, 50), "Call"))
        {
            player->comms_state = CS_BeingHailedByGM;
            player->comms_incomming_message = "Hailed by " + hail_name;
        }
        break;
    case CS_OpeningChannel:
    case CS_BeingHailed:
    case CS_ChannelOpen:
    case CS_ChannelOpenPlayer:
        text(sf::FloatRect(x + 300, y, 300, 50), "Target still communicating with someone.");
        y += 50;
        if (button(sf::FloatRect(x, y, 300, 50), "Abort his call"))
        {
            player->commandCloseTextComm();
        }
        break;
    case CS_BeingHailedByGM:
        text(sf::FloatRect(x + 300, y, 300, 50), "Waiting for response.");
        break;
    case CS_ChannelOpenGM:
        std::vector<string> lines = player->comms_incomming_message.split("\n");
        static const unsigned int max_lines = 20;
        for(unsigned int n=lines.size() > max_lines ? lines.size() - max_lines : 0; n<lines.size(); n++)
        {
            text(sf::FloatRect(x, y, 600, 30), lines[n]);
            y += 30;
        }
        y += 30;
        comms_message = textEntry(sf::FloatRect(x, y, 600, 50), comms_message);
        if (button(sf::FloatRect(x + 600, y, 300, 50), "Send") || InputHandler::keyboardIsPressed(sf::Keyboard::Return))
        {
            player->comms_incomming_message = player->comms_incomming_message + "\n>" + comms_message;
            comms_message = "";
        }
        break;
    }

    if (button(sf::FloatRect(x, 825, 300, 50), "Cancel"))
    {
        if (player->comms_state == CS_BeingHailedByGM)
            player->comms_state = CS_Inactive;
        if (player->comms_state == CS_ChannelOpenGM)
            player->comms_state = CS_Inactive;
        destroy();
    }
}

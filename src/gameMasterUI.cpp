#include "gameMasterUI.h"
#include "factionInfo.h"
#include "cpuShip.h"
#include "spaceStation.h"
#include "blackHole.h"

GameMasterUI::GameMasterUI()
{
    view_distance = 50000;
    current_faction = 2;
    allow_object_drag = engine->getGameSpeed() == 0.0;
}

void GameMasterUI::onGui()
{
    sf::RenderTarget& window = *getRenderTarget();
    sf::Vector2f mouse = InputHandler::getMousePos();
    sf::Vector2f mouse_world_position = view_position + (mouse - sf::Vector2f(800, 450)) / 400.0f * view_distance;

    if (InputHandler::mouseIsPressed(sf::Mouse::Left) && mouse.x > 300)
    {
        mouse_down_pos = mouse;

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
        selection = target;
    }
    if (selection && allow_object_drag && InputHandler::mouseIsDown(sf::Mouse::Left) && mouse.x > 300)
    {
        if (sf::length(mouse - mouse_down_pos) > 5.0f)
        {
            selection->setPosition(mouse_world_position);
        }
    }
    if (selection && InputHandler::mouseIsReleased(sf::Mouse::Right) && mouse.x > 300)
    {
        P<CpuShip> cpuShip = selection;
        if (selection)
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
            if (target && target->canBeTargeted())
            {
                if (selection->isEnemy(target))
                {
                    cpuShip->orderAttack(target);
                }else{
                    cpuShip->orderDefendTarget(target);
                }
            }else{
                cpuShip->orderFlyTowardsBlind(mouse_world_position);
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

    drawRaderBackground(view_position, sf::Vector2f(800, 450), 400.0, view_distance);

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

    if (selection)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(sf::Vector2f(800, 450) + (selection->getPosition() - view_position) / view_distance * 400.0f);
        window.draw(objectSprite);

        float y = 20;
        P<SpaceShip> ship = selection;
        if (ship && ship->ship_template)
        {
            text(sf::FloatRect(20, y, 100, 20), factionInfo[ship->faction_id]->name + " " + ship->ship_type_name, AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Hull: " + string(ship->hull_strength), AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Shields: " + string(ship->front_shield) + ", " + string(ship->rear_shield), AlignLeft, 20);
            y += 20;
        }
        P<SpaceStation> station = selection;
        if (station)
        {
            text(sf::FloatRect(20, y, 100, 20), factionInfo[station->faction_id]->name, AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Hull: " + string(station->hull_strength), AlignLeft, 20);
            y += 20;
            text(sf::FloatRect(20, y, 100, 20), "Shields: " + string(station->shields), AlignLeft, 20);
            y += 20;
        }
        P<CpuShip> cpuShip = selection;
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
                if (button(sf::FloatRect(200, y, 100, 30), "Refill", 15))
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

        text(sf::FloatRect(20, 480, 250, 20), "Change faction:", AlignCenter, 20);
        for(unsigned int f=0; f<factionInfo.size(); f++)
        {
            if (toggleButton(sf::FloatRect(20, 500 + 30 * f, 250, 30), selection->getFactionId() == f, factionInfo[f]->name, 20))
            {
                selection->setFactionId(f);
            }
        }

        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Delete))
        {
            selection->destroy();
        }
    }else{
        text(sf::FloatRect(20, 20, 100, 20), "Create new:", AlignLeft, 20);
        for(unsigned int f=0; f<factionInfo.size(); f++)
        {
            if (toggleButton(sf::FloatRect(20, 500 + 30 * f, 250, 30), current_faction == f, factionInfo[f]->name, 20))
            {
                current_faction = f;
            }
        }

        if (button(sf::FloatRect(20, 100, 250, 30), "Station", 20))
        {
            selection = new SpaceStation();
            selection->setFactionId(current_faction);
            selection->setRotation(random(0, 360));
            selection->setPosition(view_position + sf::vector2FromAngle(random(0, 360)) * random(0, view_distance * 0.1));
        }
        if (button(sf::FloatRect(20, 130, 250, 30), "BlackHole", 20))
        {
            selection = new BlackHole();
            selection->setPosition(view_position + sf::vector2FromAngle(random(0, 360)) * random(0, view_distance * 0.1));
        }
        
        std::vector<string> template_names = ShipTemplate::getTemplateNameList();
        std::sort(template_names.begin(), template_names.end());
        for(unsigned int n=0; n<template_names.size(); n++)
        {
            if (button(sf::FloatRect(20, 170 + n * 30, 250, 30), template_names[n] + "(" + string(ShipTemplate::getTemplate(template_names[n])->frontShields) + ")", 20))
            {
                P<CpuShip> s = new CpuShip();
                s->faction_id = current_faction;
                s->setShipTemplate(template_names[n]);
                s->setPosition(view_position + sf::vector2FromAngle(random(0, 360)) * random(0, view_distance * 0.1));
                s->orderRoaming();

                selection = s;
            }
        }
    }

    if (toggleButton(sf::FloatRect(20, 820, 250, 50), allow_object_drag, "Drag Objects"))
        allow_object_drag = !allow_object_drag;

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
    float x = getWindowSize().x / 2 - 400;
    float y = 200;
    boxWithBackground(sf::FloatRect(x - 30, y - 30, 860, 460));

    ship->ship_type_name = textEntry(sf::FloatRect(x, y, 300, 30), ship->ship_type_name, 20);
    y += 30;
    ship->weaponTubes += selector(sf::FloatRect(x, y, 300, 30), "Missile tubes: " + string(ship->weaponTubes), 20);
    if (ship->weaponTubes < 0)
        ship->weaponTubes = maxWeaponTubes;
    if (ship->weaponTubes > maxWeaponTubes)
        ship->weaponTubes = 0;
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
    diff = selector(sf::FloatRect(x, y, 300, 30), "Front shield: " + string(ship->front_shield) + "/" + string(ship->front_shield_max), 20);
    ship->front_shield += diff * 15;
    ship->front_shield_max += diff * 15;
    y += 30;
    diff = selector(sf::FloatRect(x, y, 300, 30), "Front shield: " + string(ship->rear_shield) + "/" + string(ship->rear_shield_max), 20);
    ship->rear_shield += diff * 15;
    ship->rear_shield_max += diff * 15;
    y += 30;
    
    y += 10;
    if (button(sf::FloatRect(x, y, 300, 50), "Ok"))
        destroy();
}

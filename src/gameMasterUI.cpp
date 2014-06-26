#include "gameMasterUI.h"
#include "factionInfo.h"
#include "cpuShip.h"
#include "spaceStation.h"

GameMasterUI::GameMasterUI()
{
    view_distance = 50000;
    current_faction = 2;
}

void GameMasterUI::onGui()
{
    sf::RenderTarget& window = *getRenderTarget();
    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    sf::Vector2f mouse = inputHandler->getMousePos();

    if (inputHandler->mouseIsPressed(sf::Mouse::Left) && mouse.x > 300)
    {
        mouse_down_pos = mouse;
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);

        P<SpaceObject> target;
        sf::Vector2f mousePosition = view_position + diff / 400.0f * view_distance;
        PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(0.1 * view_distance, 0.1 * view_distance), mousePosition + sf::Vector2f(0.1 * view_distance, 0.1 * view_distance));
        foreach(Collisionable, obj, list)
        {
            P<SpaceObject> spaceObject = obj;
            if (spaceObject && spaceObject->canBeTargeted())
            {
                if (!target || sf::length(mousePosition - spaceObject->getPosition()) < sf::length(mousePosition - target->getPosition()))
                    target = spaceObject;
            }
        }
        selection = target;
    }
    if (selection && inputHandler->mouseIsDown(sf::Mouse::Left) && mouse.x > 300)
    {
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);
        sf::Vector2f mousePosition = view_position + diff / 400.0f * view_distance;
        if (sf::length(mouse - mouse_down_pos) > 2.0f)
        {
            selection->setPosition(mousePosition);
        }
    }
    
    view_distance *= 1.0 - (inputHandler->getMouseWheelDelta() * 0.1f);
    if (view_distance > 100000)
        view_distance = 100000;
    if (view_distance < 5000)
        view_distance = 5000;
    if (inputHandler->mouseIsDown(sf::Mouse::Middle))
    {
        view_position += (prev_mouse_pos - mouse) / 400.0f * view_distance;
    }
    
    drawRaderBackground(view_position, sf::Vector2f(800, 450), 800, 400.0f / view_distance);

    foreach(SpaceObject, obj, spaceObjectList)
    {
        obj->drawRadar(window, sf::Vector2f(800, 450) + (obj->getPosition() - view_position) / view_distance * 400.0f, 400.0f / view_distance, view_distance > 10000);
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
        
        P<SpaceShip> ship = selection;
        if (ship && ship->shipTemplate)
        {
            text(sf::FloatRect(20, 20, 100, 20), factionInfo[ship->factionId].name + " " + ship->shipTemplate->name, AlignLeft, 20);
            text(sf::FloatRect(20, 40, 100, 20), "Hull: " + string(ship->hull_strength), AlignLeft, 20);
            text(sf::FloatRect(20, 60, 100, 20), "Shields: " + string(ship->front_shield) + ", " + string(ship->rear_shield), AlignLeft, 20);
        }
        P<CpuShip> cpuShip = selection;
        if (cpuShip)
        {
            text(sf::FloatRect(20, 80, 100, 20), "Orders: " + getAIOrderString(cpuShip->getOrder()), AlignLeft, 20);
            
            P<SpaceObject> target = cpuShip->getTarget();
            if (target)
            {
                sf::VertexArray a(sf::Lines, 2);
                a[0].position = sf::Vector2f(800, 450) + (cpuShip->getPosition() - view_position) / view_distance * 400.0f;
                a[1].position = sf::Vector2f(800, 450) + (target->getPosition() - view_position) / view_distance * 400.0f;
                a[0].color = a[1].color = sf::Color(255, 255, 255, 32);
                window.draw(a);
            }
            
            float y = 100;
            if (toggleButton(sf::FloatRect(20, y, 150, 30), cpuShip->getOrder() == AI_Idle, "Idle", 20))
                cpuShip->orderIdle();
            y += 30;
            if (toggleButton(sf::FloatRect(20, y, 150, 30), cpuShip->getOrder() == AI_Roaming, "Roaming", 20))
                cpuShip->orderRoaming();
            y += 30;
            
            for(int n=0; n<MW_Count; n++)
            {
                if (cpuShip->weaponStorageMax[n] < 1)
                    continue;
                text(sf::FloatRect(20, y, 130, 30), getMissileWeaponName(EMissileWeapons(n)) + ": " + string(cpuShip->weaponStorage[n]) + "/" + string(cpuShip->weaponStorageMax[n]), AlignLeft, 20);
                if (button(sf::FloatRect(200, y, 100, 30), "Refill", 15))
                {
                    cpuShip->weaponStorage[n] = cpuShip->weaponStorageMax[n];
                }
                y += 30;
            }
        }
        
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Delete))
        {
            selection->destroy();
        }
    }else{
        text(sf::FloatRect(20, 20, 100, 20), "Create new:", AlignLeft, 20);
        for(int f=0; f<maxFactions; f++)
        {
            if (toggleButton(sf::FloatRect(20, 500 + 30 * f, 150, 30), current_faction == f, factionInfo[f].name, 20))
            {
                current_faction = f;
            }
        }
        
        if (button(sf::FloatRect(20, 100, 150, 30), "Station", 20))
        {
            selection = new SpaceStation();
            selection->factionId = current_faction;
        }
        std::vector<string> template_names = ShipTemplate::getTemplateNameList();
        for(unsigned int n=0; n<template_names.size(); n++)
        {
            if (button(sf::FloatRect(20, 150 + n * 30, 150, 30), template_names[n], 20))
            {
                P<CpuShip> s = new CpuShip();
                s->factionId = current_faction;
                s->setShipTemplate(template_names[n]);
                s->setPosition(view_position + sf::vector2FromAngle(random(0, 360)) * random(0, view_distance * 0.1));
                
                selection = s;
            }
        }
    }

    MainUI::onGui();
    prev_mouse_pos = mouse;
}

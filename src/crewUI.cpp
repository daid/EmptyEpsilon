#include "crewUI.h"
#include "playerInfo.h"

CrewUI::CrewUI()
{
    jumpDistance = 1.0;
    tubeLoadType = MW_None;
    
    for(int n=0; n<maxCrewPositions; n++)
    {
        if (myPlayerInfo->crewPosition[n])
        {
            showPosition = ECrewPosition(n);
            break;
        }
    }
}

void CrewUI::onGui()
{
    if (mySpaceship)
    {
        switch(showPosition)
        {
        case helmsOfficer:
            helmsUI();
            break;
        case tacticalOfficer:
            tacticalUI();
            break;
        default:
            drawStatic();
            text(sf::FloatRect(0, 500, 1600, 100), "???", AlignCenter, 100);
            break;
        }
    }else{
        drawStatic();
    }

    int offset = 0;
    for(int n=0; n<maxCrewPositions; n++)
    {
        if (myPlayerInfo->crewPosition[n])
        {
            if (toggleButton(sf::FloatRect(200 * offset, 0, 200, 20), showPosition == ECrewPosition(n), getCrewPositionName(ECrewPosition(n)), 20))
            {
                showPosition = ECrewPosition(n);
            }
            offset++;
        }
    }
    
    MainUI::onGui();
}

void CrewUI::helmsUI()
{
    sf::RenderTarget* window = getRenderTarget();
    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    sf::Vector2f mouse = inputHandler->getMousePos();
    if (inputHandler->mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);
        if (sf::length(diff) < 400)
            mySpaceship->commandTargetRotation(sf::vector2ToAngle(diff));
    }
    
    //Radar
    float radarDistance = 5000;
    drawHeadingCircle(sf::Vector2f(800, 450), 400);
    
    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < radarDistance)
            obj->drawRadar(*window, sf::Vector2f(800, 450) + (obj->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f, 400.0f / radarDistance);
    }

    P<SpaceObject> target = mySpaceship->getTarget();
    if (target)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(sf::Vector2f(800, 450) + (target->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f);
        window->draw(objectSprite);
    }
    mySpaceship->drawRadar(*window, sf::Vector2f(800, 450), 400.0f / radarDistance);
    //!Radar
    
    float res = vslider(sf::FloatRect(20, 500, 50, 300), mySpaceship->impulseRequest, 1.0, -1.0);
    if (res > -0.15 && res < 0.15)
        res = 0.0;
    if (res != mySpaceship->impulseRequest)
        mySpaceship->commandImpulse(res);
    text(sf::FloatRect(20, 800, 50, 20), string(int(mySpaceship->impulseRequest * 100)) + "%", AlignLeft, 20);
    text(sf::FloatRect(20, 820, 50, 20), string(int(mySpaceship->currentImpulse * 100)) + "%", AlignLeft, 20);

    if (mySpaceship->hasWarpdrive)
    {
        res = vslider(sf::FloatRect(100, 500, 50, 300), mySpaceship->warpRequest, 4.0, 0.0);
        if (res != mySpaceship->warpRequest)
            mySpaceship->commandWarp(res);
        text(sf::FloatRect(100, 800, 50, 20), string(int(mySpaceship->warpRequest)), AlignLeft, 20);
        text(sf::FloatRect(100, 820, 50, 20), string(int(mySpaceship->currentWarp * 100)) + "%", AlignLeft, 20);
    }
    if (mySpaceship->hasJumpdrive)
    {
        float x = mySpaceship->hasWarpdrive ? 180 : 100;
        jumpDistance = vslider(sf::FloatRect(x, 500, 50, 300), jumpDistance, 20.0, 1.0);
        text(sf::FloatRect(x, 800, 50, 20), string(jumpDistance) + "km", AlignLeft, 20);
        if (mySpaceship->jumpDelay > 0.0)
        {
            text(sf::FloatRect(x, 820, 50, 20), string(int(mySpaceship->jumpDelay) + 1), AlignLeft, 20);
        }else{
            if (button(sf::FloatRect(x, 820, 70, 30), "Jump", 20))
            {
                mySpaceship->commandJump(jumpDistance);
            }
        }
    }
}
#include <typeinfo> 
void CrewUI::tacticalUI()
{
    sf::RenderTarget* window = getRenderTarget();
    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    sf::Vector2f mouse = inputHandler->getMousePos();
    float radarDistance = 5000;

    //Radar
    if (inputHandler->mouseIsPressed(sf::Mouse::Left))
    {
        sf::Vector2f diff = mouse - sf::Vector2f(800, 450);
        if (sf::length(diff) < 400)
        {
            P<SpaceObject> target;
            sf::Vector2f mousePosition = mySpaceship->getPosition() + diff / 400.0f * radarDistance;
            PVector<Collisionable> list = CollisionManager::queryArea(mousePosition - sf::Vector2f(50, 50), mousePosition + sf::Vector2f(50, 50));
            foreach(Collisionable, obj, list)
            {
                P<SpaceObject> spaceObject = obj;
                if (spaceObject && spaceObject != mySpaceship)
                    target = spaceObject;
            }
            mySpaceship->commandSetTarget(target);
        }
    }

    drawHeadingCircle(sf::Vector2f(800, 450), 400);
    
    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < radarDistance)
            obj->drawRadar(*window, sf::Vector2f(800, 450) + (obj->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f, 400.0f / radarDistance);
    }
    
    P<SpaceObject> target = mySpaceship->getTarget();
    if (target)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(sf::Vector2f(800, 450) + (target->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f);
        window->draw(objectSprite);
    }
    mySpaceship->drawRadar(*window, sf::Vector2f(800, 450), 400.0f / radarDistance);
    //!Radar

    for(int n=0; n<MW_Count; n++)
    {
        if (toggleButton(sf::FloatRect(10, 440 + n * 30, 200, 30), tubeLoadType == n, getMissileWeaponName(EMissileWeapons(n)) + " x" + string(mySpaceship->weaponStorage[n]), 25))
        {
            if (tubeLoadType == n)
                tubeLoadType = MW_None;
            else
                tubeLoadType = EMissileWeapons(n);
        }
    }
    
    for(int n=0; n<mySpaceship->weaponTubes; n++)
    {
        switch(mySpaceship->weaponTube[n].state)
        {
        case WTS_Empty:
            if (toggleButton(sf::FloatRect(20, 840 - 50 * n, 150, 50), tubeLoadType != MW_None && mySpaceship->weaponStorage[tubeLoadType] > 0, "Load", 35) && tubeLoadType != MW_None)
                mySpaceship->commandLoadTube(n, tubeLoadType);
            toggleButton(sf::FloatRect(170, 840 - 50 * n, 350, 50), false, "Empty", 35);
            break;
        case WTS_Loaded:
            if (button(sf::FloatRect(20, 840 - 50 * n, 150, 50), "Unload", 35))
                mySpaceship->commandUnloadTube(n);
            if (button(sf::FloatRect(170, 840 - 50 * n, 350, 50), getMissileWeaponName(mySpaceship->weaponTube[n].typeLoaded), 35))
                mySpaceship->commandFireTube(n);
            break;
        case WTS_Loading:
            toggleButton(sf::FloatRect(20, 840 - 50 * n, 150, 50), false, "Loading", 35);
            text(sf::FloatRect(170, 840 - 50 * n, 350, 50), getMissileWeaponName(mySpaceship->weaponTube[n].typeLoaded), AlignCenter, 35);
            toggleButton(sf::FloatRect(170, 840 - 50 * n, 350 * (1.0 - (mySpaceship->weaponTube[n].delay / mySpaceship->tubeLoadTime)), 50), false, "");
            break;
        case WTS_Unloading:
            toggleButton(sf::FloatRect(20, 840 - 50 * n, 150, 50), false, "Unloading", 25);
            text(sf::FloatRect(170, 840 - 50 * n, 350, 50), getMissileWeaponName(mySpaceship->weaponTube[n].typeLoaded), AlignCenter, 35);
            toggleButton(sf::FloatRect(170, 840 - 50 * n, 350 * (mySpaceship->weaponTube[n].delay / mySpaceship->tubeLoadTime), 50), false, "");
            break;
        }
    }
}

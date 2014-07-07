#include "mainScreen.h"
#include "shipSelectionScreen.h"
#include "main.h"

MainScreenUI::MainScreenUI()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    mouseRenderer->visible = false;
}

void MainScreenUI::onGui()
{
    if (mySpaceship)
    {
        switch(mySpaceship->mainScreenSetting)
        {
        case MSS_Front:
        case MSS_Back:
        case MSS_Left:
        case MSS_Right:
            draw3Dworld();
            break;
        case MSS_Tactical:
            renderTactical(*getRenderTarget());
            break;
        case MSS_LongRange:
            renderLongRange(*getRenderTarget());
            break;
        }
    }else{
        draw3Dworld();
    }
    
    MainUIBase::onGui();
}

void MainScreenUI::destroy()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    mouseRenderer->visible = true;
    MainUIBase::destroy();
}

void MainScreenUI::renderTactical(sf::RenderTarget& window)
{
    float radarDistance = 5000;
    drawRaderBackground(mySpaceship->getPosition(), sf::Vector2f(800, 450), 400, 400.0f / radarDistance);

    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < radarDistance)
            obj->drawRadar(window, sf::Vector2f(800, 450) + (obj->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f, 400.0f / radarDistance, false);
    }
    
    mySpaceship->drawRadar(window, sf::Vector2f(800, 450), 400.0f / radarDistance, false);
    drawHeadingCircle(sf::Vector2f(800, 450), 400);
}

void MainScreenUI::renderLongRange(sf::RenderTarget& window)
{
    float radarDistance = 50000;
    drawRaderBackground(mySpaceship->getPosition(), sf::Vector2f(800, 450), 800, 400.0f / radarDistance);

    foreach(SpaceObject, obj, spaceObjectList)
    {
        if (obj != mySpaceship && sf::length(obj->getPosition() - mySpaceship->getPosition()) < radarDistance)
            obj->drawRadar(window, sf::Vector2f(800, 450) + (obj->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f, 400.0f / radarDistance, true);
    }
    
    P<SpaceObject> target = mySpaceship->getTarget();
    if (target)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "redicule.png");
        objectSprite.setPosition(sf::Vector2f(800, 450) + (target->getPosition() - mySpaceship->getPosition()) / radarDistance * 400.0f);
        window.draw(objectSprite);
    }
    mySpaceship->drawRadar(window, sf::Vector2f(800, 450), 400.0f / radarDistance, true);
    drawHeadingCircle(sf::Vector2f(800, 450), 400);
}

#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "topDownScreen.h"
#include "main.h"
#include "menus/shipSelectionScreen.h"

#include "screenComponents/indicatorOverlays.h"

TopDownScreen::TopDownScreen()
{
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns();
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    new GuiIndicatorOverlays(this);
}

void TopDownScreen::update(float delta)
{
    camera_yaw = -90.0f;
    camera_pitch = 90.0f;

    camera_position.z = 7000.0;
    
    if (!target)
    {
        for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
        {
            target = gameGlobalInfo->getPlayerShip(n);
            if (target)
                break;
        }
    }
    
    if (target)
    {
        sf::Vector2f position = target->getPosition();

        camera_position.x = position.x;
        camera_position.y = position.y;
    }
}

void TopDownScreen::onKey(sf::Keyboard::Key key, int unicode)
{
    switch(key)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        new ShipSelectionScreen();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}

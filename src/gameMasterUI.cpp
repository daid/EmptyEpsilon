#include "gameMasterUI.h"

GameMasterUI::GameMasterUI()
{
    view_distance = 50000;
}

void GameMasterUI::onGui()
{
    sf::RenderTarget& window = *getRenderTarget();
    P<InputHandler> inputHandler = engine->getObject("inputHandler");
    sf::Vector2f mouse = inputHandler->getMousePos();
    
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

    MainUI::onGui();
    prev_mouse_pos = mouse;
}

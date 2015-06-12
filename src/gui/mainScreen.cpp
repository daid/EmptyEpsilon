#include "mainScreen.h"
#include "menus/shipSelectionScreen.h"
#include "main.h"
#include "mouseRenderer.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"

MainScreenBaseUI::MainScreenBaseUI()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    if (mouseRenderer) mouseRenderer->visible = false;
    return_to_ship_selection_time = 0.0;
}

void MainScreenBaseUI::destroy()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    if (mouseRenderer) mouseRenderer->visible = true;
    MainUIBase::destroy();
}

void MainScreenBaseUI::onGui()
{
    if (!my_spaceship)
    {
        if (return_to_ship_selection_time == 0.0)
        {
            return_to_ship_selection_time = engine->getElapsedTime() + 20.0;
        }
        if (engine->getElapsedTime() > return_to_ship_selection_time)
        {
            destroy();
            new ShipSelectionScreen();
        }
        if (engine->getElapsedTime() > return_to_ship_selection_time - 10.0)
        {
            drawProgressBar(sf::FloatRect(getWindowSize().x / 2 - 300, 600, 600, 100), return_to_ship_selection_time - engine->getElapsedTime(), 0, 10);
        }
    }
    MainUIBase::onGui();
}

void TopDownUI::onGui()
{
    if (my_spaceship)
    {
        camera_yaw = -90.0f;
        camera_pitch = 90.0f;

        sf::Vector2f position = my_spaceship->getPosition();

        camera_position.x = position.x;
        camera_position.y = position.y;
        camera_position.z = 7000.0;
    }
    draw3Dworld(sf::FloatRect(0, 0, getWindowSize().x, getWindowSize().y), true);

    MainUIBase::onGui();
}

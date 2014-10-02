#include "mainScreen.h"
#include "shipSelectionScreen.h"
#include "main.h"

MainScreenBaseUI::MainScreenBaseUI()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    if (mouseRenderer) mouseRenderer->visible = false;
}

void MainScreenBaseUI::destroy()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    if (mouseRenderer) mouseRenderer->visible = true;
    MainUIBase::destroy();
}

void MainScreenUI::onGui()
{
    if (my_spaceship)
    {
        camera_yaw = my_spaceship->getRotation();
#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left))
            camera_yaw -= 45;
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right))
            camera_yaw += 45;
#endif
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Back: camera_yaw += 180; break;
        case MSS_Left: camera_yaw -= 90; break;
        case MSS_Right: camera_yaw += 90; break;
        default: break;
        }
        camera_pitch = 30.0f;

        const float camera_ship_distance = 420.0f;
        const float camera_ship_height = 420.0f;
        sf::Vector2f cameraPosition2D = my_spaceship->getPosition() + sf::vector2FromAngle(camera_yaw) * -camera_ship_distance;
        sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);
#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
        {
            targetCameraPosition.x = my_spaceship->getPosition().x;
            targetCameraPosition.y = my_spaceship->getPosition().y;
            targetCameraPosition.z = 3000.0;
            camera_pitch = 90.0f;
        }
#endif
        camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;

        switch(my_spaceship->main_screen_setting)
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

    MainScreenBaseUI::onGui();
}

void MainScreenUI::renderTactical(sf::RenderTarget& window)
{
    drawRadar(sf::Vector2f(800, 450), 400, 5000, false, my_spaceship->getTarget());
}

void MainScreenUI::renderLongRange(sf::RenderTarget& window)
{
    drawRadar(sf::Vector2f(800, 450), 400, 50000, true, NULL);
}

ShipWindowUI::ShipWindowUI()
{
    window_angle = 0;
}

void ShipWindowUI::onGui()
{
    if (my_spaceship)
    {
        if (InputHandler::keyboardIsPressed(sf::Keyboard::Left))
            window_angle -= 5;
        if (InputHandler::keyboardIsPressed(sf::Keyboard::Right))
            window_angle += 5;
        
        camera_yaw = my_spaceship->getRotation() + window_angle;
        camera_pitch = 0.0f;
        
        sf::Vector2f position = my_spaceship->getPosition() + sf::rotateVector(sf::Vector2f(my_spaceship->getRadius(), 0), camera_yaw);

        camera_position.x = position.x;
        camera_position.y = position.y;
        camera_position.z = 0.0;

#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
        {
            camera_position.z = 3000.0;
            camera_pitch = 90.0f;
        }
#endif
    }
    draw3Dworld();

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
    draw3Dworld();

    MainUIBase::onGui();
}

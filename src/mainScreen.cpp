#include "mainScreen.h"
#include "shipSelectionScreen.h"
#include "main.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"

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
        if (InputHandler::mouseIsReleased(sf::Mouse::Left))
        {
            switch(my_spaceship->main_screen_setting)
            {
            case MSS_Front: my_spaceship->commandMainScreenSetting(MSS_Left); break;
            case MSS_Left: my_spaceship->commandMainScreenSetting(MSS_Back); break;
            case MSS_Back: my_spaceship->commandMainScreenSetting(MSS_Right); break;
            case MSS_Right: my_spaceship->commandMainScreenSetting(MSS_Front); break;
            default: my_spaceship->commandMainScreenSetting(MSS_Front); break;
            }
        }
        if (InputHandler::mouseIsReleased(sf::Mouse::Right))
        {
            switch(my_spaceship->main_screen_setting)
            {
            case MSS_Front: my_spaceship->commandMainScreenSetting(MSS_Right); break;
            case MSS_Right: my_spaceship->commandMainScreenSetting(MSS_Back); break;
            case MSS_Back: my_spaceship->commandMainScreenSetting(MSS_Left); break;
            case MSS_Left: my_spaceship->commandMainScreenSetting(MSS_Front); break;
            default: my_spaceship->commandMainScreenSetting(MSS_Front); break;
            }
        }
        if (InputHandler::mouseIsReleased(sf::Mouse::Middle))
        {
            switch(my_spaceship->main_screen_setting)
            {
            default:
                if (gameGlobalInfo->allow_main_screen_tactical_radar)
                    my_spaceship->commandMainScreenSetting(MSS_Tactical);
                else if (gameGlobalInfo->allow_main_screen_long_range_radar)
                    my_spaceship->commandMainScreenSetting(MSS_LongRange);
                break;
            case MSS_Tactical:
                if (gameGlobalInfo->allow_main_screen_long_range_radar)
                    my_spaceship->commandMainScreenSetting(MSS_LongRange);
                break;
            case MSS_LongRange:
                if (gameGlobalInfo->allow_main_screen_tactical_radar)
                    my_spaceship->commandMainScreenSetting(MSS_Tactical);
                break;
            }
        }
        if (InputHandler::keyboardIsReleased(sf::Keyboard::Up))
            my_spaceship->commandMainScreenSetting(MSS_Front);
        if (InputHandler::keyboardIsReleased(sf::Keyboard::Left))
            my_spaceship->commandMainScreenSetting(MSS_Left);
        if (InputHandler::keyboardIsReleased(sf::Keyboard::Right))
            my_spaceship->commandMainScreenSetting(MSS_Right);
        if (InputHandler::keyboardIsReleased(sf::Keyboard::Down))
            my_spaceship->commandMainScreenSetting(MSS_Back);
        if (InputHandler::keyboardIsReleased(sf::Keyboard::Tab) && gameGlobalInfo->allow_main_screen_tactical_radar)
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        if (InputHandler::keyboardIsReleased(sf::Keyboard::Q) && gameGlobalInfo->allow_main_screen_long_range_radar)
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
        
        camera_yaw = my_spaceship->getRotation();
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
        if (my_spaceship->activate_self_destruct)
        {
            boxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 150));
            textbox(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 100), "SELF DESTRUCT ACTIVATED", AlignCenter, 50);
            int todo = 0;
            for(int n=0; n<PlayerSpaceship::max_self_destruct_codes; n++)
                if (!my_spaceship->self_destruct_code_confirmed[n])
                    todo++;
            text(sf::FloatRect(getWindowSize().x / 2 - 400, 295, 800, 50), "Waiting for autorization input: "+string(todo)+" left", AlignCenter, 30);
        }
        if (my_spaceship->jumpDelay > 0.0)
        {
            boxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 100));
            text(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 100), "Jump in: " + string(int(ceilf(my_spaceship->jumpDelay))), AlignCenter, 50);
        }
        if (gameGlobalInfo->global_message_timeout > 0.0)
        {
            boxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 400, 300, 800, 100));
            text(sf::FloatRect(getWindowSize().x / 2 - 400, 300, 800, 100), gameGlobalInfo->global_message, AlignCenter, 50);
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
    drawRadar(sf::Vector2f(800, 450), 400, 10000, true, NULL);
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

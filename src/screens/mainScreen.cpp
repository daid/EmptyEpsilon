#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "mainScreen.h"
#include "main.h"

#include "screenComponents/indicatorOverlays.h"

ScreenMainScreen::ScreenMainScreen()
{
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns()->showHeadings()->showSpacedust();
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    new GuiIndicatorOverlays(this);
        /*
        if (my_spaceship->activate_self_destruct)
        {
            drawBoxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 150));
            drawTextBox(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 100), "SELF DESTRUCT ACTIVATED", AlignCenter, 50);
            int todo = 0;
            for(int n=0; n<PlayerSpaceship::max_self_destruct_codes; n++)
                if (!my_spaceship->self_destruct_code_confirmed[n])
                    todo++;
            drawText(sf::FloatRect(getWindowSize().x / 2 - 400, 295, 800, 50), "Waiting for autorization input: "+string(todo)+" left", AlignCenter, 30);
        }
        if (my_spaceship->jump_delay > 0.0)
        {
            drawBoxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 100));
            drawText(sf::FloatRect(getWindowSize().x / 2 - 400, 200, 800, 100), "Jump in: " + string(int(ceilf(my_spaceship->jump_delay))), AlignCenter, 50);
        }
        if (gameGlobalInfo->global_message_timeout > 0.0)
        {
            drawBoxWithBackground(sf::FloatRect(getWindowSize().x / 2 - 400, 300, 800, 100));
            drawText(sf::FloatRect(getWindowSize().x / 2 - 400, 300, 800, 100), gameGlobalInfo->global_message, AlignCenter, 50);
        }

    if (game_client && !game_client->isConnected())
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

    if (game_server)
    {
        if (InputHandler::keyboardIsPressed(sf::Keyboard::P))
            engine->setGameSpeed(0.0);
    }

    if (isActive())
    {
        if (InputHandler::keyboardIsPressed(sf::Keyboard::Escape) || InputHandler::keyboardIsPressed(sf::Keyboard::Home))
        {
            destroy();
            new ShipSelectionScreen();
        }
    }
    */
}

void ScreenMainScreen::update(float delta)
{
    if (my_spaceship)
    {
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

        float target_camera_yaw = my_spaceship->getRotation();
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Back: target_camera_yaw += 180; break;
        case MSS_Left: target_camera_yaw -= 90; break;
        case MSS_Right: target_camera_yaw += 90; break;
        default: break;
        }
        camera_pitch = 30.0f;

        const float camera_ship_distance = 420.0f;
        const float camera_ship_height = 420.0f;
        sf::Vector2f cameraPosition2D = my_spaceship->getPosition() + sf::vector2FromAngle(target_camera_yaw) * -camera_ship_distance;
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
        camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;

        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Front:
        case MSS_Back:
        case MSS_Left:
        case MSS_Right:
            viewport->show();
            break;
        case MSS_Tactical:
            //renderTactical(*getRenderTarget());
            viewport->hide();
            break;
        case MSS_LongRange:
            //renderLongRange(*getRenderTarget());
            viewport->hide();
            break;
        }
    }
}

void ScreenMainScreen::onClick(sf::Vector2f mouse_position)
{
    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
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
    if (InputHandler::mouseIsPressed(sf::Mouse::Right))
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
    if (InputHandler::mouseIsPressed(sf::Mouse::Middle))
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
}

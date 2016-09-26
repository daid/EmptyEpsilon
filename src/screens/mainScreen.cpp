#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "mainScreen.h"
#include "main.h"
#include "epsilonServer.h"
#include "preferenceManager.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/selfDestructIndicator.h"
#include "screenComponents/globalMessage.h"
#include "screenComponents/jumpIndicator.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"
#include "screenComponents/shipDestroyedPopup.h"

#include "screens/extra/damcon.h"

#include "gui/gui2_overlay.h"

ScreenMainScreen::ScreenMainScreen()
{
    new GuiOverlay(this, "", sf::Color::Black);

    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns()->showHeadings()->showSpacedust();
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    (new GuiRadarView(viewport, "VIEWPORT_RADAR", 5000.0f, nullptr))->setStyle(GuiRadarView::CircularMasked)->setSize(200, 200)->setPosition(-20, 20, ATopRight);
    
    tactical_radar = new GuiRadarView(this, "TACTICAL", 5000.0f, nullptr);
    tactical_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    tactical_radar->setRangeIndicatorStepSize(1000.0f)->shortRange()->enableCallsigns()->hide();
    long_range_radar = new GuiRadarView(this, "TACTICAL", gameGlobalInfo->long_range_radar_range, nullptr);
    long_range_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    long_range_radar->setRangeIndicatorStepSize(5000.0f)->longRange()->enableCallsigns()->hide();
    long_range_radar->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);

    global_range_radar = new GuiRadarView(this, "GLOBAL", 80000.0f, nullptr);
    global_range_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    global_range_radar->setAutoCentering(true);
    global_range_radar->longRange()->enableWaypoints()->enableCallsigns()->setStyle(GuiRadarView::Rectangular)->setFogOfWarStyle(GuiRadarView::FriendlysShortRangeFogOfWar);
    global_range_radar->hide();
        
    onscreen_comms = new GuiCommsOverlay(this);
    onscreen_comms->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setVisible(false);
    
    ship_state = new DamageControlScreen(this);
    ship_state->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    ship_state->hide();
    
    new GuiShipDestroyedPopup(this);
    
    new GuiJumpIndicator(this);
    new GuiSelfDestructIndicator(this);
    new GuiGlobalMessage(this);
    new GuiIndicatorOverlays(this);

    if (PreferencesManager::get("music_enabled") != "0")
    {
        threat_estimate = new ThreatLevelEstimate();
        threat_estimate->setCallbacks([](){
            LOG(INFO) << "Switching to ambient music";
            soundManager->playMusicSet(findResources("music/ambient/*.ogg"));
        }, []() {
            LOG(INFO) << "Switching to combat music";
            soundManager->playMusicSet(findResources("music/combat/*.ogg"));
        });
    }

    first_person = false;
}

void ScreenMainScreen::update(float delta)
{
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        soundManager->stopMusic();
        soundManager->stopSound(impulse_sound);
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

    if (my_spaceship)
    {
        P<SpaceObject> target_ship = my_spaceship->getTarget();
        float target_camera_yaw = my_spaceship->getRotation();
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Back: target_camera_yaw += 180; break;
        case MSS_Left: target_camera_yaw -= 90; break;
        case MSS_Right: target_camera_yaw += 90; break;
        case MSS_Target:
            if (target_ship)
            {
                sf::Vector2f target_camera_diff = my_spaceship->getPosition() - target_ship->getPosition();
                target_camera_yaw = sf::vector2ToAngle(target_camera_diff) + 180;
            }
            break;
        default: break;
        }
        camera_pitch = 30.0f;

        float camera_ship_distance = 420.0f;
        float camera_ship_height = 420.0f;
        if (first_person)
        {
            camera_ship_distance = -my_spaceship->getRadius();
            camera_ship_height = my_spaceship->getRadius() / 10.f;
            camera_pitch = 0;
        }
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
        if (first_person)
        {
            camera_position = targetCameraPosition;
            camera_yaw = target_camera_yaw;
        }
        else
        {
            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
        }

        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Front:
        case MSS_Back:
        case MSS_Left:
        case MSS_Right:
        case MSS_Target:
            viewport->show();
            tactical_radar->hide();
            long_range_radar->hide();
            global_range_radar->hide();
            ship_state->hide();
            break;
        case MSS_Tactical:
            viewport->hide();
            tactical_radar->show();
            long_range_radar->hide();
            global_range_radar->hide();
            ship_state->hide();
            break;
        case MSS_LongRange:
            viewport->hide();
            tactical_radar->hide();
            long_range_radar->show();
            global_range_radar->hide();
            ship_state->hide();
            break;
        case MSS_GlobalRange:
            viewport->hide();
            tactical_radar->hide();
            long_range_radar->hide();
            global_range_radar->show();
            ship_state->hide();
            break;
        case MSS_ShipState:
            viewport->hide();
            tactical_radar->hide();
            long_range_radar->hide();
            global_range_radar->hide();
            ship_state->show();
            break;
        }

        switch(my_spaceship->main_screen_overlay)
        {
        case MSO_ShowComms:
            onscreen_comms->clearElements();
            onscreen_comms->show();
            break;
        case MSO_HideComms:
            onscreen_comms->clearElements();
            onscreen_comms->hide();
            break;
        }

        // If we have an impulse power, loop the engine sound.
        float impulse_ability = std::max(0.0f, std::min(my_spaceship->getSystemEffectiveness(SYS_Impulse), my_spaceship->getSystemPower(SYS_Impulse)));
        string impulse_sound_file = my_spaceship->impulse_sound_file;
        if (impulse_ability > 0 && impulse_sound_file.length() > 0)
        {
            if (impulse_sound > -1)
            {
                soundManager->setSoundVolume(impulse_sound, std::max(10.0f * impulse_ability, fabsf(my_spaceship->current_impulse) * 10.0f * std::max(0.1f, impulse_ability)));
                soundManager->setSoundPitch(impulse_sound, std::max(0.7f * impulse_ability, fabsf(my_spaceship->current_impulse) + 0.2f * std::max(0.1f, impulse_ability)));
            }
            else
            {
                impulse_sound = soundManager->playSound(impulse_sound_file, std::max(0.7f * impulse_ability, fabsf(my_spaceship->current_impulse) + 0.2f * impulse_ability), std::max(30.0f, fabsf(my_spaceship->current_impulse) * 10.0f * impulse_ability), true);
            }
        }
        // If we don't have impulse available, stop the engine sound.
        else if (impulse_sound > -1)
        {
            soundManager->stopSound(impulse_sound);
            // TODO: Play an engine failure sound.
            impulse_sound = -1;
        }

    }
}

void ScreenMainScreen::onClick(sf::Vector2f mouse_position)
{
    if (!my_spaceship)
        return;
    
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
            else if (gameGlobalInfo->allow_main_screen_global_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_GlobalRange);
            else if (gameGlobalInfo->allow_main_screen_ship_state)
                my_spaceship->commandMainScreenSetting(MSS_ShipState);
            break;
        case MSS_Tactical:
            if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_LongRange);
            else if (gameGlobalInfo->allow_main_screen_global_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_GlobalRange);
            else if (gameGlobalInfo->allow_main_screen_ship_state)
                my_spaceship->commandMainScreenSetting(MSS_ShipState);
            break;
        case MSS_LongRange:
            if (gameGlobalInfo->allow_main_screen_global_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_GlobalRange);
            else if (gameGlobalInfo->allow_main_screen_ship_state)
                my_spaceship->commandMainScreenSetting(MSS_ShipState);
            else if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_spaceship->commandMainScreenSetting(MSS_Tactical);
            break;
        case MSS_GlobalRange:
            if (gameGlobalInfo->allow_main_screen_ship_state)
                my_spaceship->commandMainScreenSetting(MSS_ShipState);
            else if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_spaceship->commandMainScreenSetting(MSS_Tactical);
            else if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_LongRange);
            break;
        case MSS_ShipState:
            if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_spaceship->commandMainScreenSetting(MSS_Tactical);
            else if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_LongRange);
            else if (gameGlobalInfo->allow_main_screen_global_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_GlobalRange);
            break;
        }
    }
}

void ScreenMainScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    case sf::Keyboard::Up:
        if (my_spaceship)
            my_spaceship->commandMainScreenSetting(MSS_Front);
        break;
    case sf::Keyboard::Left:
        if (my_spaceship)
            my_spaceship->commandMainScreenSetting(MSS_Left);
        break;
    case sf::Keyboard::Right:
        if (my_spaceship)
            my_spaceship->commandMainScreenSetting(MSS_Right);
        break;
    case sf::Keyboard::Down:
        if (my_spaceship)
            my_spaceship->commandMainScreenSetting(MSS_Back);
        break;
    case sf::Keyboard::T:
        if (my_spaceship)
            my_spaceship->commandMainScreenSetting(MSS_Target);
        break;
    case sf::Keyboard::Tab:
        if (my_spaceship && gameGlobalInfo->allow_main_screen_tactical_radar)
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        break;
    case sf::Keyboard::Q:
        if (my_spaceship && gameGlobalInfo->allow_main_screen_long_range_radar)
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
        break;
    case sf::Keyboard::F:
        first_person = !first_person;
        break;
    
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        soundManager->stopMusic();
        soundManager->stopSound(impulse_sound);
        destroy();
        returnToShipSelection();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}

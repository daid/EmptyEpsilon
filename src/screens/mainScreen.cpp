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

#include "gui/gui2_panel.h"
#include "gui/gui2_overlay.h"

ScreenMainScreen::ScreenMainScreen()
{
    // Initialize a black background.
    new GuiOverlay(this, "", sf::Color::Black);

    // Build the 3D viewport.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns()->showHeadings()->showSpacedust();
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Build, style, size, and position the mini short-range radar view.
    (new GuiRadarView(viewport, "VIEWPORT_RADAR", nullptr))->setStyle(GuiRadarView::CircularMasked)->setSize(200, 200)->setPosition(-20, 20, ATopRight);

    // Build radar views for full-screen short- and long-range radars.
    tactical_radar = new GuiRadarView(this, "TACTICAL", nullptr);
    tactical_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    tactical_radar->setRangeIndicatorStepSize(1000.0f)->shortRange()->enableCallsigns()->hide();
    long_range_radar = new GuiRadarView(this, "TACTICAL", nullptr);
    long_range_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    long_range_radar->setRangeIndicatorStepSize(5000.0f)->longRange()->enableCallsigns()->hide();
    long_range_radar->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);

    // Initialize and hide the onscreen comms overlay.
    onscreen_comms = new GuiCommsOverlay(this);
    onscreen_comms->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setVisible(false);

    // Initialize indicator and message overlays.
    new GuiShipDestroyedPopup(this);    
    new GuiJumpIndicator(this);
    new GuiSelfDestructIndicator(this);
    new GuiGlobalMessage(this);
    new GuiIndicatorOverlays(this);

    // Add general keyboard shortcut help.
    keyboard_help = new GuiHelpOverlay(this, "Keyboard Shortcuts");
    keyboard_general = "";

    for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory("Main Screen"))
        keyboard_general += shortcut.second + ":\t" + shortcut.first + "\n";

    keyboard_help->setText(keyboard_general);

    // If music is not disabled in preferences, play it based on our ship's
    // current threat level.
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

    // Determine whether to start in first-person view from user preferences.
    first_person = PreferencesManager::get("first_person", "0") == "1";
}

void ScreenMainScreen::update(float delta)
{
    // If we disconnected, stop audio, destroy the screen, and return to main.
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
        // Remember our ship's current weapons target.
        P<SpaceObject> target_ship = my_spaceship->getTarget();

        float camera_ship_distance = 0.0f;
        float camera_ship_height = 0.0f;

        // Set the initial camera yaw (direction) to our ship's current facing.
        float target_camera_yaw = my_spaceship->getRotation();

        // Turn the camera based on the current main screen setting.
        // Each direction is relative to our ship's current facing.
        // Negative values turn the camera to the left, positive to the right.
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Back: target_camera_yaw += 180; break;
        case MSS_Left: target_camera_yaw -= 90; break;
        case MSS_Right: target_camera_yaw += 90; break;
        case MSS_Target:
            // If our ship has a weapons target, calculate the angle required
            // to turn the camera toward it.
            if (target_ship)
            {
                sf::Vector2f target_camera_diff = my_spaceship->getPosition() - target_ship->getPosition();
                target_camera_yaw = sf::vector2ToAngle(target_camera_diff) + 180;
            }
            break;
        default: break;
        }

        // Bound mods
        camera_ship_distance_modifier = std::min(200.0f, std::max(-100.0f, camera_ship_distance_modifier));
        camera_ship_height_modifier = std::min(200.0f, std::max(-100.0f, camera_ship_height_modifier));
        camera_pitch_modifier = std::min(20.0f, std::max(-20.0f, camera_pitch_modifier));

        if (first_person)
        {
            // Set first-person camera position by moving it to the front of
            // its radius (-getRadius) and proportionally slightly elevated.
            // The proportion is based on a naive assumption that ships tend to
            // be about 1/10 as tall as their 2D (length/width) radius.
            camera_ship_distance = camera_ship_distance_modifier - my_spaceship->getRadius();
            camera_ship_height = camera_ship_height_modifier + (my_spaceship->getRadius() / 10.f);
            camera_pitch = camera_pitch_modifier + 0;
        } else {
            // By default, place the camera 420m behind and above the ship and
            // point it downward 30 degrees.
            camera_ship_distance = camera_ship_distance_modifier + 420.0f;
            camera_ship_height = camera_ship_height_modifier + 420.0f;
            camera_pitch = camera_pitch_modifier + 30.0f;
        }

        // 2D position is used to calculate the camera's target position based
        // on its coordinates on the 2D playing field and its height.
        sf::Vector2f cameraPosition2D = my_spaceship->getPosition() + sf::vector2FromAngle(target_camera_yaw) * -camera_ship_distance;
        sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);

#ifdef DEBUG
        // Debug mode view turns the camera into a top-dow view over our ship's
        // position for as long as main screen holds down the Z key.
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
            // Reposition and redirect the first-person camera and direction to
            // point at the calculated target position.
            camera_position = targetCameraPosition;
            camera_yaw = target_camera_yaw;
        } else {
            // By default, reposition the camera to facter in the target
            // position, and rotate the camera horizontally to follow it.
            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
        }

        // Determine main screen state. Only one state should be active at a
        // time.
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
            break;
        case MSS_Tactical:
            viewport->hide();
            tactical_radar->show();
            long_range_radar->hide();
            break;
        case MSS_LongRange:
            viewport->hide();
            tactical_radar->hide();
            long_range_radar->show();
            break;
        default:
            viewport->show();
            tactical_radar->hide();
            long_range_radar->hide();
            break;
        }

        // Determine whether to show any overlays on the main screen.
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
        default:
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
    
    // Rotate the view to the left on left click, and to the right on right
    // click. Default to forward view.
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

    // Cycle main screen states on middle click.
    if (InputHandler::mouseIsPressed(sf::Mouse::Middle))
    {
        switch(my_spaceship->main_screen_setting)
        {
        // Default to tactical first unless it's prohibited by server settings.
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

void ScreenMainScreen::onHotkey(const HotkeyResult& key)
{
    // Set configurable hotkey behaviors.
    if (key.category == "MAIN_SCREEN" && my_spaceship)
    {
        if (key.hotkey == "VIEW_FORWARD")
            my_spaceship->commandMainScreenSetting(MSS_Front);
        else if (key.hotkey == "VIEW_LEFT")
            my_spaceship->commandMainScreenSetting(MSS_Left);
        else if (key.hotkey == "VIEW_RIGHT")
            my_spaceship->commandMainScreenSetting(MSS_Right);
        else if (key.hotkey == "VIEW_BACK")
            my_spaceship->commandMainScreenSetting(MSS_Back);
        else if (key.hotkey == "VIEW_TARGET")
            my_spaceship->commandMainScreenSetting(MSS_Target);
        else if (key.hotkey == "TACTICAL_RADAR")
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        else if (key.hotkey == "LONG_RANGE_RADAR")
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
        else if (key.hotkey == "FIRST_PERSON")
            first_person = !first_person;
    }
}

void ScreenMainScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    // Set non-configurable hotkey behavior.
    switch (key.code)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        // Exit the view and return to ship selection.
        soundManager->stopMusic();
        soundManager->stopSound(impulse_sound);
        destroy();
        returnToShipSelection();
        break;
    case sf::Keyboard::E:
        camera_ship_height_modifier += 10.0f;
        break;
    case sf::Keyboard::D:
        camera_ship_height_modifier -= 10.0f;
        break;
    case sf::Keyboard::W:
        camera_pitch_modifier -= 5.0f;
        break;
    case sf::Keyboard::S:
        camera_pitch_modifier += 5.0f;
        break;
    case sf::Keyboard::Slash:
    case sf::Keyboard::F1:
        // Toggle keyboard help.
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());
        break;
    case sf::Keyboard::P:
        // Pause the game
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}

#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "cinematicViewScreen.h"
#include "epsilonServer.h"
#include "main.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/scrollingBanner.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

CinematicViewScreen::CinematicViewScreen()
{
    // Create a full-screen viewport.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    viewport->showCallsigns();

    // Initialize the camera's vertical position.
    camera_position.z = 200.0;
    // Initialize an angled top-down view with the top of the screen pointing
    // toward heading 0.
    camera_yaw = -90.0f;
    camera_pitch = 45.0f;

    // Lock onto player ship 0 to start.
    if (gameGlobalInfo->getPlayerShip(0))
        target = gameGlobalInfo->getPlayerShip(0);

    // Let the screen operator select a player ship to lock the camera onto.
    camera_lock_selector = new GuiSelector(this, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship)
            target = ship;
    });
    camera_lock_selector->setSelectionIndex(0)->setPosition(20, -80, ABottomLeft)->setSize(300, 50)->hide();

    // Toggle whether to lock the camera onto a ship.
    camera_lock_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOGGLE", "Lock camera on ship", [this](bool value) {});
    camera_lock_toggle->setValue(true)->setPosition(20, -20, ABottomLeft)->setSize(300, 50)->hide();

    camera_lock_tot_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOT_TOGGLE", "Lock camera on ship's target", [this](bool value) {});
    camera_lock_tot_toggle->setValue(true)->setPosition(320, -20, ABottomLeft)->setSize(350, 50)->hide();

    new GuiIndicatorOverlays(this);

    (new GuiScrollingBanner(this))->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, 100);
}

void CinematicViewScreen::update(float delta)
{
    // If this is a client and it is disconnected, exit.
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

    // TODO: Add mouselook.
    if (InputHandler::keyboardIsDown(sf::Keyboard::W))
    {
        sf::Vector2f xy_vector = sf::vector2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x += xy_vector.x;
        camera_position.y += xy_vector.y;
    }
    if (InputHandler::keyboardIsDown(sf::Keyboard::S))
    {
        sf::Vector2f xy_vector = sf::vector2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x -= xy_vector.x;
        camera_position.y -= xy_vector.y;
    }
    if (InputHandler::keyboardIsDown(sf::Keyboard::A))
    {
        sf::Vector2f xy_vector = sf::vector2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x += xy_vector.y;
        camera_position.y -= xy_vector.x;
    }
    if (InputHandler::keyboardIsDown(sf::Keyboard::D))
    {
        sf::Vector2f xy_vector = sf::vector2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x -= xy_vector.y;
        camera_position.y += xy_vector.x;
    }
    if (InputHandler::keyboardIsDown(sf::Keyboard::R))
        camera_position.z += delta * 100.0f;
    if (InputHandler::keyboardIsDown(sf::Keyboard::F))
        camera_position.z -= delta * 100.0f;
    if (InputHandler::keyboardIsDown(sf::Keyboard::Left))
        camera_yaw -= delta * 50.0f;
    if (InputHandler::keyboardIsDown(sf::Keyboard::Right))
        camera_yaw += delta * 50.0f;
    if (InputHandler::keyboardIsDown(sf::Keyboard::Up))
        camera_pitch -= delta * 50.0f;
    if (InputHandler::keyboardIsDown(sf::Keyboard::Down))
        camera_pitch += delta * 50.0f;

    // Add and remove entries from the player ship list.
    // TODO: Allow any ship or station to be the camera target.
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (camera_lock_selector->indexByValue(string(n)) == -1)
                camera_lock_selector->addEntry(ship->getTypeName() + " " + ship->getCallSign(), string(n));
        }else{
            if (camera_lock_selector->indexByValue(string(n)) != -1)
                camera_lock_selector->removeEntry(camera_lock_selector->indexByValue(string(n)));
        }
    }

    // Plot headings from the camera to the locked player ship.
    // Set camera_yaw and camera_pitch to those values.

    // If lock is enabled and a ship is selected...
    if (camera_lock_toggle->getValue() && target)
    {
        // Show the target-of-target lock button.
        if (camera_lock_toggle->isVisible())
            camera_lock_tot_toggle->show();

        // Get the selected ship's current position.
        target_position_2D = target->getPosition();
        // Copy the selected ship's position into a Vector3 for camera angle
        // calculations.
        target_position_3D.x = target_position_2D.x;
        target_position_3D.y = target_position_2D.y;
        target_position_3D.z = 0;

        // Copy the camera position into a Vector2 for camera angle
        // calculations.
        camera_position_2D.x = camera_position.x;
        camera_position_2D.y = camera_position.y;

        // Calculate the distance from the camera to the selected ship.
        diff_2D = target_position_2D - camera_position_2D;
        diff_3D = target_position_3D - camera_position;

        distance_2D = sf::length(diff_2D);
        distance_3D = sf::length(diff_3D);

        // Get the ship's current heading and velocity.
        target_rotation = target->getRotation();
        // float target_velocity = sf::length(target->getVelocity());

        // We want the camera to always be less than 1U from the selected ship.
        max_camera_distance = 1000.0f + target->getRadius() + sf::length(target->getVelocity());
        min_camera_distance = target->getRadius() * 2.0f;

        // Check if our selected ship has a weapons target.
        target_of_target = target->getTarget();
        if (target_of_target && sf::length(target_of_target->getPosition() - target_position_2D) > 10000.0)
            target_of_target = nullptr;

        // If it does, lock the camera onto that target.
        if (camera_lock_tot_toggle->getValue() && target_of_target)
        {
            // Get the position of the selected ship's target.
            tot_position_2D = target_of_target->getPosition();
            // Convert it to a 3D vector.
            tot_position_3D.x = tot_position_2D.x;
            tot_position_3D.y = tot_position_3D.y;
            tot_position_3D.z = 0;
            
            // Get the diff, distance, and angle between the ToT and camera.
            tot_diff_2D = tot_position_2D - camera_position_2D;
            tot_diff_3D = tot_position_3D - camera_position;
            tot_angle = sf::vector2ToAngle(tot_diff_2D);
            tot_distance_2D = sf::length(tot_diff_2D);
            tot_distance_3D = sf::length(tot_diff_3D);

            //Point the camera aiming between the target ship and the target of the target.
            angle_yaw = tot_angle + sf::angleDifference(tot_angle, sf::vector2ToAngle(diff_2D)) / 2.0f;
            if (std::abs(sf::angleDifference(angle_yaw, tot_angle)) > 40.0f)
            {
                //The target of target is not really in view, so re-position the camera.
                camera_position_2D = target_position_2D - sf::vector2FromAngle(sf::vector2ToAngle(tot_position_2D - target_position_2D) + 20) * target->getRadius() * 2.0f;
                camera_position.x = camera_position_2D.x;
                camera_position.y = camera_position_2D.y;
            }

            angle_pitch = (atan(camera_position.z / tot_distance_3D)) * (180 / pi);
        } 
        
        if (distance_2D > max_camera_distance)
        // If the selected ship moves more than 1U from the camera ...
        {
            // Set a vector 10 degrees to the right of the selected ship's
            // rotation.
            camera_rotation_vector = sf::vector2FromAngle(target_rotation + 10);

            // Plot a destination on that vector at a distance of 1U.
            camera_destination = target_position_2D + camera_rotation_vector * max_camera_distance;

            // Move the camera's X and Y coordinates to this destination.
            camera_position.x = camera_destination.x;
            camera_position.y = camera_destination.y;
        } else {
            //If we are too close to the ship, move away from it.
            if (distance_3D < min_camera_distance && distance_2D > 0.0f)
            {
                camera_position.x -= diff_2D.x / distance_2D * (min_camera_distance - distance_3D);
                camera_position.y -= diff_2D.y / distance_2D * (min_camera_distance - distance_3D);
            }
            
            if (!camera_lock_tot_toggle->getValue() || !target_of_target)
            {
                // Calculate the angles between the camera and the ship.
                angle_yaw = sf::vector2ToAngle(diff_2D);
                angle_pitch = (atan(camera_position.z / distance_3D)) * (180 / pi);
            }
        }
        // TODO: Park the camera at a photogenic angle at high speeds.

        // Point the camera.
        camera_yaw = angle_yaw;
        camera_pitch = angle_pitch;
    } else {
        // Hide the target-of-target camera lock button.
        camera_lock_tot_toggle->hide();
    }
}

void CinematicViewScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    // Toggle UI visibility with the H key.
    case sf::Keyboard::H:
        if (camera_lock_toggle->isVisible() || camera_lock_selector->isVisible() || camera_lock_tot_toggle->isVisible())
        {
            camera_lock_toggle->hide();
            camera_lock_selector->hide();
            camera_lock_tot_toggle->hide();
        }else{
            camera_lock_toggle->show();
            camera_lock_selector->show();
        }
        break;
    // Toggle camera lock with the L key.
    case sf::Keyboard::L:
        camera_lock_toggle->setValue(!camera_lock_toggle->getValue());
        break;
    // Cycle through player ships with the J and K keys.
    case sf::Keyboard::J:
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() - 1);
        if (camera_lock_selector->getSelectionIndex() < 0)
            camera_lock_selector->setSelectionIndex(camera_lock_selector->entryCount() - 1);
        target = gameGlobalInfo->getPlayerShip(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()).toInt());
        break;
    case sf::Keyboard::K:
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
        if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
            camera_lock_selector->setSelectionIndex(0);
        target = gameGlobalInfo->getPlayerShip(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()).toInt());
        break;
    // TODO: X resets the camera to a default relative position and heading.
    // TODO: This is more generic code and is duplicated.
    // Exit the screen with the escape or home keys.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        returnToShipSelection();
        break;
    // If this is the server, pause the game with the P key.
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}

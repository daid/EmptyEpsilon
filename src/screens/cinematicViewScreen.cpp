#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "cinematicViewScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "menus/shipSelectionScreen.h"

#include "screenComponents/indicatorOverlays.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

CinematicViewScreen::CinematicViewScreen()
{
    // Create a full-screen viewport.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Initialize the camera's vertical position.
    camera_position.z = 100.0;
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
    camera_lock_tot_toggle->setValue(false)->setPosition(320, -20, ABottomLeft)->setSize(350, 50)->hide();

    new GuiIndicatorOverlays(this);
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
        camera_distance = 1000.0f;

        // Check if our selected ship has a weapons target.
        target_of_target = target->getTarget();

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

            // Position the camera over the selected ship.
            camera_position.x = target_position_2D.x - (100.0f * sf::normalize(tot_diff_2D).x);
            camera_position.y = target_position_2D.y - (100.0f * sf::normalize(tot_diff_2D).y);
            camera_position.z = 100.0f;

            // Set the camera angle to point at the selected ship's target.
            angle_yaw = tot_angle;
            angle_pitch = (atan(camera_position.z / tot_distance_3D)) * (180 / pi);
        } else if (distance_2D > camera_distance)
        // If the selected ship moves more than 1U from the camera ...
        {
            // Set a vector 5 degrees to the right of the selected ship's
            // rotation.
            camera_rotation_vector = sf::vector2FromAngle(target_rotation + 5);

            // Plot a destination on that vector at a distance of 1U.
            camera_destination = target_position_2D + camera_rotation_vector * camera_distance;

            // Move the camera's X and Y coordinates to this destination.
            camera_position.x = camera_destination.x;
            camera_position.y = camera_destination.y;
        } else {
            // Calculate the angles between the camera and the ship.
            angle_yaw = sf::vector2ToAngle(diff_2D);
            angle_pitch = (atan(camera_position.z / distance_3D)) * (180 / pi);
        }
        /* else{
            // Park the camera at a photogenic angle at high speeds.
            camera_position.x = target_position_2D.x;
            camera_position.y = target_position_2D.y;
        } */

        // Point the camera.
        camera_yaw = angle_yaw;
        camera_pitch = angle_pitch;
    } else {
        // Hide the target-of-target camera lock button.
        camera_lock_tot_toggle->hide();
    }

#ifdef DEBUG
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
    {
        camera_position.x = target->getPosition().x;
        camera_position.y = target->getPosition().y;
        camera_position.z = 3000.0;
        camera_pitch = 90.0f;
    }
#endif
}

void CinematicViewScreen::onKey(sf::Keyboard::Key key, int unicode)
{
    switch(key)
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
    // WASD controls for the camera.
    // TODO: If unlocked, W moves the camera forward on its current heading.
    //       If locked, W moves the camera toward the target.
    case sf::Keyboard::W:
        if (!camera_lock_toggle->getValue())
            camera_position.y = camera_position.y - (50 * (camera_position.z / 1000));
        break;
    // TODO: If unlocked, A moves the camera laterally to the left of its
    //         current heading.
    //       If locked, A moves the camera counterclockwise around the
    //         target.
    case sf::Keyboard::A:
        if (!camera_lock_toggle->getValue())
            camera_position.x = camera_position.x - (50 * (camera_position.z / 1000));
        break;
    // TODO: If unlocked, S moves the camera laterally to the right of its
    //         current heading.
    //       If locked, S moves the camera clockwise around the target.
    case sf::Keyboard::S:
        if (!camera_lock_toggle->getValue())
            camera_position.y = camera_position.y + (50 * (camera_position.z / 1000));
        break;
    // TODO: If unlocked, D moves the camera backward from its current heading.
    //       If locked, D moves the camera away from the target.
    case sf::Keyboard::D:
        if (!camera_lock_toggle->getValue())
            camera_position.x = camera_position.x + (50 * (camera_position.z / 1000));
        break;
    // TODO: If unlocked, R moves the camera vertically upward from its current
    //         heading, and F moves it downward.
    //       If locked, R moves the camera vertically upward around the target,
    //         and F moves it downward.
    case sf::Keyboard::R:
        if (camera_position.z > 200.0)
            camera_position.z = camera_position.z - 100;
        else
            camera_position.z = 1000.0;
        break;
    case sf::Keyboard::F:
        if (camera_position.z < 10000.0)
            camera_position.z = camera_position.z + 100;
        else
            camera_position.z = 10000.0;
        break;
    // TODO: If unlocked, the arrow keys turn the camera.
    // TODO: X resets the camera to a default relative position and heading.
    // TODO: This is more generic code and is duplicated.
    // Exit the screen with the escape or home keys.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        new ShipSelectionScreen();
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

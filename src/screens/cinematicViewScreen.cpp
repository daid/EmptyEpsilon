#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "cinematicViewScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "multiplayer_client.h"
#include "ecs/query.h"
#include "i18n.h"
#include "components/collision.h"
#include "components/target.h"
#include "components/player.h"
#include "components/name.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/scrollingBanner.h"
#include "screenComponents/helpOverlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

CinematicViewScreen::CinematicViewScreen(RenderLayer* render_layer)
: GuiCanvas(render_layer)
{
    // Create a full-screen viewport.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    viewport->showCallsigns();

    // Initialize the camera's vertical position.
    camera_position.z = 200.0;
    // Initialize an angled top-down view with the top of the screen pointing
    // toward heading 0.
    camera_yaw = -90.0f;
    camera_pitch = 45.0f;

    // Lock onto player ship to start.
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>()) {
        target = entity;
        break;
    }

    // Let the screen operator select a player ship to lock the camera onto.
    camera_lock_selector = new GuiSelector(this, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        auto ship = sp::ecs::Entity::fromString(value);
        if (ship)
            target = ship;
    });
    camera_lock_selector->setSelectionIndex(0)->setPosition(20, -80, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();

    // Toggle whether to lock the camera onto a ship.
    camera_lock_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOGGLE", tr("button", "Lock camera on ship"), [](bool value) {});
    camera_lock_toggle->setValue(true)->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();

    camera_lock_tot_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOT_TOGGLE", tr("button", "Lock camera on ship's target"), [this](bool value) {});
    camera_lock_tot_toggle->setValue(true)->setPosition(320, -20, sp::Alignment::BottomLeft)->setSize(350, 50)->hide();

    camera_lock_cycle_toggle = new GuiToggleButton(this, "CAMERA_LOCK_CYCLE_TOGGLE", tr("button", "Cycle through ships"), [this](bool value) {});
    camera_lock_cycle_toggle->setValue(false)->setPosition(670, -20, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();
    cycle_time = 0.0f;

    new GuiIndicatorOverlays(this);

    (new GuiScrollingBanner(this))->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, 100);

    keyboard_help = new GuiHelpOverlay(viewport, tr("hotkey_F1", "Keyboard Shortcuts"));
    string keyboard_cinematic = "";

    for (auto binding : sp::io::Keybinding::listAllByCategory("Cinematic View"))
        keyboard_cinematic += tr("hotkey_F1", "{label}: {button}\n").format({{"label", binding->getLabel()}, {"button", binding->getHumanReadableKeyName(0)}});

    keyboard_help->setText(keyboard_cinematic);
    keyboard_help->moveToFront();
}

void CinematicViewScreen::update(float delta)
{
    // If this is a client and it is disconnected, exit.
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
        return;
    }

    if (keys.help.getDown())
    {
        // Toggle keyboard help.
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());
    }

    if (keys.cinematic.toggle_ui.getDown())
    {
        if (camera_lock_toggle->isVisible() || camera_lock_selector->isVisible() || camera_lock_tot_toggle->isVisible())
        {
            camera_lock_toggle->hide();
            camera_lock_selector->hide();
            camera_lock_tot_toggle->hide();
            camera_lock_cycle_toggle->hide();
        }
        else {
            camera_lock_toggle->show();
            camera_lock_selector->show();
            camera_lock_tot_toggle->show();
        }
    }

    if (keys.cinematic.lock_camera.getDown())
    {
        camera_lock_toggle->setValue(!camera_lock_toggle->getValue());
    }

    if (keys.cinematic.cycle_camera.getDown())
    {
        camera_lock_cycle_toggle->setValue(!camera_lock_cycle_toggle->getValue());
    }

    if (keys.cinematic.previous_player_ship.getDown())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() - 1);
        if (camera_lock_selector->getSelectionIndex() < 0)
            camera_lock_selector->setSelectionIndex(camera_lock_selector->entryCount() - 1);
        target = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()));
    }

    if (keys.cinematic.next_player_ship.getDown())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
        if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
            camera_lock_selector->setSelectionIndex(0);
        target = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()));
    }
    // TODO: X resets the camera to a default relative position and heading.
    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection(getRenderLayer());
    }
    if (keys.pause.getDown())
    {
        if (game_server)
            engine->setGameSpeed(0.0);
    }

    if (keys.cinematic.move_forward.get())
    {
        glm::vec2 xy_vector = vec2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x += xy_vector.x;
        camera_position.y += xy_vector.y;
    }

    if (keys.cinematic.move_backward.get())
    {
        glm::vec2 xy_vector = vec2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x -= xy_vector.x;
        camera_position.y -= xy_vector.y;
    }

    if (keys.cinematic.strafe_left.get())
    {
        glm::vec2 xy_vector = vec2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x += xy_vector.y;
        camera_position.y -= xy_vector.x;
    }

    if (keys.cinematic.strafe_right.get())
    {
        glm::vec2 xy_vector = vec2FromAngle(camera_yaw) * delta * 100.0f;
        camera_position.x -= xy_vector.y;
        camera_position.y += xy_vector.x;
    }

    if (keys.cinematic.move_up.get())
    {
        camera_position.z += delta * 100.0f;
    }

    if (keys.cinematic.move_down.get())
    {
        camera_position.z -= delta * 100.0f;
    }

    if (keys.cinematic.rotate_left.get())
    {
        camera_yaw -= delta * 50.0f;
    }

    if (keys.cinematic.rotate_right.get())
    {
        camera_yaw += delta * 50.0f;
    }

    if (keys.cinematic.tilt_up.get())
    {
        camera_pitch -= delta * 50.0f;
    }

    if (keys.cinematic.tilt_down.get())
    {
        camera_pitch += delta * 50.0f;
    }

    // TODO: Add mouselook.

    // Add and remove entries from the player ship list.
    // TODO: Allow any ship or station to be the camera target.
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
    {
        if (camera_lock_selector->indexByValue(entity.toString()) == -1) {
            string label;
            if (auto tn = entity.getComponent<TypeName>())
                label = tn->type_name;
            if (auto cs = entity.getComponent<CallSign>())
                label += " " + cs->callsign;
            camera_lock_selector->addEntry(label, entity.toString());
        }
    }
    for(int n=0; n<camera_lock_selector->entryCount(); n++) {
        if (!sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(n)))
            camera_lock_selector->removeEntry(n);
    }

    // If cycle is enabled switch target every 30 sec.
    if (camera_lock_cycle_toggle->getValue())
    {
        cycle_time -= delta;
        if (cycle_time < 0.0f)
        {
            cycle_time = 30.0f;
            camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
            if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
                camera_lock_selector->setSelectionIndex(0);
            target = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()));
        }
    }

    // Plot headings from the camera to the locked player ship.
    // Set camera_yaw and camera_pitch to those values.

    // If lock is enabled and a ship is selected...
    if (camera_lock_toggle->getValue() && target)
    {
        // Show the target-of-target lock button.
        if (camera_lock_toggle->isVisible())
        {
            camera_lock_tot_toggle->show();
            camera_lock_cycle_toggle->show();
        }

        auto transform = target.getComponent<sp::Transform>();
        // Get the selected ship's current position.
        if (transform)
            target_position_2D = transform->getPosition();
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

        distance_2D = glm::length(diff_2D);
        distance_3D = glm::length(diff_3D);

        // Get the ship's current heading and velocity.
        if (transform)
            target_rotation = transform->getRotation();
        // float target_velocity = glm::length(target->getVelocity());

        // We want the camera to always be less than 1U from the selected ship.
        auto physics = target.getComponent<sp::Physics>();
        auto radius = 300.0f;
        if (physics)
            radius = physics->getSize().x;
        max_camera_distance = 1000.0f + radius + glm::length(physics->getVelocity());
        min_camera_distance = radius * 2.0f;

        // Check if our selected ship has a weapons target.
        auto target_of_target = target.getComponent<Target>() ? target.getComponent<Target>()->entity : sp::ecs::Entity{};
        auto target_of_target_transform = target_of_target.getComponent<sp::Transform>();
        if (target_of_target && glm::length(target_of_target_transform->getPosition() - target_position_2D) > 10000.0f)
            target_of_target_transform = nullptr;

        // If it does, lock the camera onto that target.
        if (camera_lock_tot_toggle->getValue() && target_of_target_transform)
        {
            // Get the position of the selected ship's target.
            tot_position_2D = target_of_target_transform->getPosition();
            // Convert it to a 3D vector.
            tot_position_3D.x = tot_position_2D.x;
            tot_position_3D.y = tot_position_3D.y;
            tot_position_3D.z = 0;

            // Get the diff, distance, and angle between the ToT and camera.
            tot_diff_2D = tot_position_2D - camera_position_2D;
            tot_diff_3D = tot_position_3D - camera_position;
            tot_angle = vec2ToAngle(tot_diff_2D);
            tot_distance_2D = glm::length(tot_diff_2D);
            tot_distance_3D = glm::length(tot_diff_3D);

            //Point the camera aiming between the target ship and the target of the target.
            angle_yaw = tot_angle + angleDifference(tot_angle, vec2ToAngle(diff_2D)) / 2.0f;
            if (std::abs(angleDifference(angle_yaw, tot_angle)) > 40.0f)
            {
                //The target of target is not really in view, so re-position the camera.
                camera_position_2D = target_position_2D - vec2FromAngle(vec2ToAngle(tot_position_2D - target_position_2D) + 20) * radius * 2.0f;
                camera_position.x = camera_position_2D.x;
                camera_position.y = camera_position_2D.y;
            }

            angle_pitch = glm::degrees(atan(camera_position.z / tot_distance_3D));
        }

        if (distance_2D > max_camera_distance)
        // If the selected ship moves more than 1U from the camera ...
        {
            // Set a vector 10 degrees to the right of the selected ship's
            // rotation.
            camera_rotation_vector = vec2FromAngle(target_rotation + 10);

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
                angle_yaw = vec2ToAngle(diff_2D);
                angle_pitch = glm::degrees(atan(camera_position.z / distance_3D));
            }
        }
        // TODO: Park the camera at a photogenic angle at high speeds.

        // Point the camera.
        camera_yaw = angle_yaw;
        camera_pitch = angle_pitch;
    } else {
        // Hide the target-of-target camera lock button.
        camera_lock_tot_toggle->hide();
        camera_lock_cycle_toggle->hide();
    }
}

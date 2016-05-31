#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "topDownScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "menus/shipSelectionScreen.h"

#include "screenComponents/indicatorOverlays.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

TopDownScreen::TopDownScreen()
{
    // Create a full-screen viewport and draw callsigns on ships.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns();
    viewport->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Set the camera's vertical position/zoom.
    camera_position.z = 7000.0;

    // Let the screen operator select a player ship to lock the camera onto.
    // This selector is visible only if the lock toggle is on and at least one
    // player ship exists.
    camera_lock_selector = new GuiSelector(this, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        if (gameGlobalInfo->getPlayerShip(index))
            target = gameGlobalInfo->getPlayerShip(index);
    });
    camera_lock_selector->setPosition(20, -80, ABottomLeft)->setSize(300, 50);

    // Toggle whether to lock onto a player ship.
    // This button is visible only if at least one player ship exists.
    camera_lock_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOGGLE", "Lock camera on ship", [this](bool value) {
        if (value)
            camera_lock_selector->show();
        else
            camera_lock_selector->hide();
    });
    camera_lock_toggle->setPosition(20, -20, ABottomLeft)->setSize(300, 50);

    new GuiIndicatorOverlays(this);
}

void TopDownScreen::update(float delta)
{
    // If this is a client and it is disconnected, exit.
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

    // Enable mouse wheel zoom.
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0)
    {
        camera_position.z = camera_position.z * (1.0 - (mouse_wheel_delta) * 0.1f);
        if (camera_position.z > 10000)
            camera_position.z = 10000;
        if (camera_position.z < 1000)
            camera_position.z = 1000;
    }

    // Add and remove entries from the player ship list.
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

    // Determine whether the camera lock button or selector are visible.
    if (camera_lock_selector->entryCount() > 0 || camera_lock_toggle->getValue())
    {
        camera_lock_toggle->show();
	if (camera_lock_toggle->getValue())
            camera_lock_selector->show();
        else
            camera_lock_selector->hide();
    }else{
        camera_lock_selector->hide();
        camera_lock_toggle->hide();
    }

    // Enforce a top-down view with up pointing toward heading 0.
    camera_yaw = -90.0f;
    camera_pitch = 90.0f;

    // If locked onto a player ship, move the camera along with it.
    if (camera_lock_toggle->getValue() && target)
    {
        sf::Vector2f target_position = target->getPosition();

        camera_position.x = target_position.x;
        camera_position.y = target_position.y;
    }
}

void TopDownScreen::onKey(sf::Keyboard::Key key, int unicode)
{
    switch(key)
    {
    // WASD controls for the unlocked camera.
    case sf::Keyboard::W:
        if (!camera_lock_toggle->getValue())
            camera_position.y = camera_position.y - (50 * (camera_position.z / 1000));
        break;
    case sf::Keyboard::A:
        if (!camera_lock_toggle->getValue())
            camera_position.x = camera_position.x - (50 * (camera_position.z / 1000));
        break;
    case sf::Keyboard::S:
        if (!camera_lock_toggle->getValue())
            camera_position.y = camera_position.y + (50 * (camera_position.z / 1000));
        break;
    case sf::Keyboard::D:
        if (!camera_lock_toggle->getValue())
            camera_position.x = camera_position.x + (50 * (camera_position.z / 1000));
        break;
    // Zoom the camera in and out with the R and F keys.
    case sf::Keyboard::R:
        if (camera_position.z > 1000.0)
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

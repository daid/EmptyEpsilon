#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "topDownScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "multiplayer_client.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/scrollingBanner.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

TopDownScreen::TopDownScreen(RenderLayer* render_layer)
: GuiCanvas(render_layer)
{
    // Create a full-screen viewport and draw callsigns on ships.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns();
    viewport->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Set the camera's vertical position/zoom.
    camera_position.z = 7000.0f;

    // Let the screen operator select a player ship to lock the camera onto.
    camera_lock_selector = new GuiSelector(this, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship)
            target = ship;
    });
    camera_lock_selector->setSelectionIndex(0)->setPosition(20, -80, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();

    // Toggle whether to lock onto a player ship.
    camera_lock_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOGGLE", tr("button", "Lock camera on ship"), [this](bool value) {});
    camera_lock_toggle->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();

    new GuiIndicatorOverlays(this);

    (new GuiScrollingBanner(this))->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, 100);

    // Lock onto the first player ship to start.
    for(int n = 0; n < GameGlobalInfo::max_player_ships; n++)
    {
        if (gameGlobalInfo->getPlayerShip(n))
        {
            target = gameGlobalInfo->getPlayerShip(n);
            camera_lock_toggle->setValue(true);
            break;
        }
    }
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
    float mouse_wheel_delta = keys.zoom_in.getValue() - keys.zoom_out.getValue();
    if (mouse_wheel_delta != 0.0f)
    {
        camera_position.z = camera_position.z * (1.0f - (mouse_wheel_delta) * 0.1f);
        if (camera_position.z > 10000)
            camera_position.z = 10000;
        if (camera_position.z < 1000)
            camera_position.z = 1000;
    }

    /* TODO hotkeys
    switch(key.keysym.sym)
    {
    // Toggle UI visibility with the H key.
    case SDLK_h:
        if (camera_lock_toggle->isVisible() || camera_lock_selector->isVisible())
        {
            camera_lock_toggle->hide();
            camera_lock_selector->hide();
        }else{
            camera_lock_toggle->show();
            camera_lock_selector->show();
        }
        break;
    // Toggle camera lock with the L key.
    case SDLK_l:
        camera_lock_toggle->setValue(!camera_lock_toggle->getValue());
        break;
    // Cycle through player ships with the J and K keys.
    case SDLK_j:
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() - 1);
        if (camera_lock_selector->getSelectionIndex() < 0)
            camera_lock_selector->setSelectionIndex(camera_lock_selector->entryCount() - 1);
        target = gameGlobalInfo->getPlayerShip(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()).toInt());
        break;
    case SDLK_k:
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
        if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
            camera_lock_selector->setSelectionIndex(0);
        target = gameGlobalInfo->getPlayerShip(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()).toInt());
        break;
    // WASD controls for the unlocked camera.
    case SDLK_w:
        if (!camera_lock_toggle->getValue())
            camera_position.y = camera_position.y - (50 * (camera_position.z / 1000));
        break;
    case SDLK_a:
        if (!camera_lock_toggle->getValue())
            camera_position.x = camera_position.x - (50 * (camera_position.z / 1000));
        break;
    case SDLK_s:
        if (!camera_lock_toggle->getValue())
            camera_position.y = camera_position.y + (50 * (camera_position.z / 1000));
        break;
    case SDLK_d:
        if (!camera_lock_toggle->getValue())
            camera_position.x = camera_position.x + (50 * (camera_position.z / 1000));
        break;
    */
    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection();
    }
    if (keys.pause.getDown())
    {
        if (game_server)
            engine->setGameSpeed(0.0);
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

    // Enforce a top-down view with up pointing toward heading 0.
    camera_yaw = -90.0f;
    camera_pitch = 90.0f;

    // If locked onto a player ship, move the camera along with it.
    if (camera_lock_toggle->getValue() && target)
    {
        auto target_position = target->getPosition();

        camera_position.x = target_position.x;
        camera_position.y = target_position.y;
    }
}

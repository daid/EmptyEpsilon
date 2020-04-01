#include "spectatorScreen.h"
#include "main.h"
#include "gameGlobalInfo.h"

#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/radarView.h"

SpectatorScreen::SpectatorScreen()
{
    main_radar = new GuiRadarView(this, "MAIN_RADAR", 50000.0f, nullptr);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster()->enableTargetProjections(nullptr)->setAutoCentering(false)->enableCallsigns();
    main_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    main_radar->setCallbacks(
        [this](sf::Vector2f position) { this->onMouseDown(position); },
        [this](sf::Vector2f position) { this->onMouseDrag(position); },
        [this](sf::Vector2f position) { this->onMouseUp(position); }
    );

    // Let the screen operator select a player ship to lock the camera onto.
    camera_lock_selector = new GuiSelector(this, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship)
            main_radar->setViewPosition(ship->getPosition());
    });
    camera_lock_selector->setSelectionIndex(0)->setPosition(20, -80, ABottomLeft)->setSize(300, 50)->show();

    // Toggle whether to lock onto a player ship.
    camera_lock_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOGGLE", "Lock camera on ship", [this](bool value) {});
    camera_lock_toggle->setPosition(20, -20, ABottomLeft)->setSize(300, 50)->show();

    new GuiIndicatorOverlays(this);
}

SpectatorScreen::~SpectatorScreen()
{
}

void SpectatorScreen::update(float delta)
{
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0)
    {
        float view_distance = main_radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        if (view_distance > 100000)
            view_distance = 100000;
        if (view_distance < 5000)
            view_distance = 5000;
        main_radar->setDistance(view_distance);
        if (view_distance < 10000)
            main_radar->shortRange();
        else
            main_radar->longRange();
    }

    // Add and remove entries from the player ship list.
    for(int n = 0; n < GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);

        if (ship)
        {
            if (camera_lock_selector->indexByValue(string(n)) == -1)
                camera_lock_selector->addEntry(ship->getTypeName() + " " + ship->getCallSign(), string(n));
        } else {
            if (camera_lock_selector->indexByValue(string(n)) != -1)
                camera_lock_selector->removeEntry(camera_lock_selector->indexByValue(string(n)));
        }
    }

    // If locked onto a player ship, move the camera along with it.
    if (camera_lock_toggle->getValue() && camera_lock_selector->getSelectionIndex() > -1)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(camera_lock_selector->getSelectionIndex());
        if (ship)
            main_radar->setViewPosition(ship->getPosition());
    }
}

void SpectatorScreen::onMouseDown(sf::Vector2f position)
{
    drag_start_position = position;
    drag_previous_position = position;
}

void SpectatorScreen::onMouseDrag(sf::Vector2f position)
{
    main_radar->setViewPosition(main_radar->getViewPosition() - (position - drag_previous_position));
    position -= (position - drag_previous_position);
    drag_previous_position = position;
}

void SpectatorScreen::onMouseUp(sf::Vector2f position)
{
}

void SpectatorScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        returnToShipSelection();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    case sf::Keyboard::C:
        // Toggle callsigns.
        main_radar->showCallsigns(!main_radar->getCallsigns());
    default:
        break;
    }
}

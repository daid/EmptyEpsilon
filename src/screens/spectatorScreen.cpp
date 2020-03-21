#include "main.h"
#include "gameGlobalInfo.h"
#include "spectatorScreen.h"

#include "screenComponents/radarView.h"


SpectatorScreen::SpectatorScreen()
{
    main_radar = new GuiRadarView(this, "MAIN_RADAR", 50000.0f, &targets);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster()->enableTargetProjections(nullptr)->setAutoCentering(false);
    main_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    main_radar->setCallbacks(
        [this](sf::Vector2f position) { this->onMouseDown(position); },
        [this](sf::Vector2f position) { this->onMouseDrag(position); },
        [this](sf::Vector2f position) { this->onMouseUp(position); }
    );
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
    default:
        break;
    }
}

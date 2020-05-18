#include "playerInfo.h"
#include "navigationScreen.h"
#include "spaceObjects/playerSpaceship.h"
#include "spaceObjects/scanProbe.h"
#include "scriptInterface.h"
#include "gameGlobalInfo.h"
#include "screenComponents/globalMessage.h"

#include "screenComponents/navigationView.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_textentry.h"

NavigationScreen::NavigationScreen(GuiContainer *owner)
    : GuiOverlay(owner, "NAVIGATION_SCREEN", colorConfig.background), mode(TargetSelection)
{

    targets.setAllowWaypointSelection();
    radar = new NavigationView(this, "NAVIGATION_RADAR", min_distance, &targets);
    radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    radar->setCallbacks(
        [this](sf::Vector2f position) { //down
            if (!placeWayPoints && mode == TargetSelection && targets.getWaypointIndex() > -1 && my_spaceship)
            {
                if (my_spaceship->routes[route_index][targets.getWaypointIndex()] < empty_waypoint 
                    && sf::length(my_spaceship->routes[route_index][targets.getWaypointIndex()] - position) < 25.0 / radar->getScale())
                {
                    mode = MoveWaypoint;
                    drag_waypoint_index = targets.getWaypointIndex();
                }
            }
            mouse_down_position = position;
        },
        [this](sf::Vector2f position) { //drag
            if (!placeWayPoints && mode == TargetSelection)
            {
                position_text_custom = false;
                sf::Vector2f newPosition = radar->getViewPosition() - (position - mouse_down_position);
                radar->setViewPosition(newPosition);
                if (!position_text_custom)
                    position_text->setText(getStringFromPosition(newPosition));
            } else if (!placeWayPoints && mode == MoveWaypoint && my_spaceship){
                if (my_spaceship->routes[route_index][drag_waypoint_index] < empty_waypoint){
                    my_spaceship->commandMoveRouteWaypoint(route_index, drag_waypoint_index, position);
                } 
            }
        },
        [this](sf::Vector2f position) { //up
            if (placeWayPoints){
                placeWaypoint(position);
            } else {
                switch (mode)
                {
                case TargetSelection:
                    targets.setToClosestTo(position, 25.0 / radar->getScale(), TargetsContainer::Targetable);
                    break;
                case MoveWaypoint:
                    mode = TargetSelection;
                    targets.setWaypointIndex(drag_waypoint_index);
                    break;
                }
            }
        });

    if (my_spaceship)
        radar->setViewPosition(my_spaceship->getPosition());

    placeWayPoints = false;
    // Controls for the radar view
    GuiAutoLayout* view_controls = new GuiAutoLayout(this, "VIEW_CONTROLS", GuiAutoLayout::LayoutVerticalBottomToTop);
    view_controls->setPosition(20, -70, ABottomLeft)->setSize(250, GuiElement::GuiSizeMax);
    zoom_slider = new GuiSlider(view_controls, "ZOOM_SLIDER", max_distance, min_distance, radar->getDistance(), [this](float value) {
        zoom_label->setText("Zoom: " + string(max_distance / value, 1.0f) + "x");
        radar->setDistance(value);
    });
    zoom_slider->setPosition(20, -70, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    zoom_slider->setVisible(false);
    zoom_label = new GuiLabel(zoom_slider, "", "Zoom: " + string(max_distance / radar->getDistance(), 1.0f) + "x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    position_text_custom = false;
    position_text = new GuiTextEntry(view_controls, "SECTOR_NAME_TEXT", "");
    position_text->setSize(GuiElement::GuiSizeMax, 50);
    position_text->callback([this](string text) {
        position_text_custom = true;
    });
    position_text->validator(isValidPositionString);
    position_text->enterCallback([this](string text) {
        position_text_custom = false;
        if (position_text->isValid())
        {
            sf::Vector2f pos = getPositionFromSring(text);
            radar->setViewPosition(pos);
        }
    });
    position_text->setText(getStringFromPosition(radar->getViewPosition()));


    GuiAutoLayout* route_controls = new GuiAutoLayout(this, "ROUTE_CONTROLS", GuiAutoLayout::LayoutVerticalTopToBottom);
    route_controls->setPosition(20, 50, ATopLeft)->setSize(250, GuiElement::GuiSizeMax);
    
    GuiAutoLayout* waypoint_controls = new GuiAutoLayout(this, "WAYPOINT_CONTROLS", GuiAutoLayout::LayoutVerticalColumns);
    waypoint_controls->setMargins(300, 0)->setPosition(0,20,ATopCenter)->setSize(GuiElement::GuiSizeMax, 40);

    //manage routes
    for(int r = 0; r < PlayerSpaceship::max_routes; r++){
        routeButtons[r] = new GuiButton(route_controls, "ROUTE_TOGGLE_" + string(r, 0),"Route "+ string(r+1, 0),  [this, r]() {
            setRouteIndex(r);
        });
        routeButtons[r]->setSize(GuiElement::GuiSizeMax, 50);
    }

    // Manage waypoints.
    waypoint_place_button = new GuiButton(waypoint_controls, "WAYPOINT_PLACE_BUTTON", "Place Waypoints", [this]() {
        placeWayPoints = !placeWayPoints;
    });
    waypoint_place_button->setTextSize(20);

    (new GuiButton(waypoint_controls, "WAYPOINT_PLACE_AT_CENTER_BUTTON", "Waypoint At View Center",  [this]() {
       placeWaypoint(radar->getViewPosition());
    }))->setTextSize(20);

    delete_waypoint_button = new GuiButton(waypoint_controls, "WAYPOINT_DELETE_BUTTON", "Delete Waypoint", [this]() {
        if (my_spaceship && targets.getWaypointIndex() >= 0) {
            my_spaceship->commandRemoveRouteWaypoint(route_index, targets.getWaypointIndex());
        }
    });
    delete_waypoint_button->setTextSize(20);
    setRouteIndex(0);

    (new GuiCustomShipFunctions(this, navigation, ""))->setPosition(-20, 240, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
    
    new GuiGlobalMessage(this);
}

void NavigationScreen::placeWaypoint(sf::Vector2f position)
{
    if (my_spaceship){
        my_spaceship->commandAddRouteWaypoint(route_index, position);
    }
}

void NavigationScreen::setRouteIndex(int index){
    if (index < PlayerSpaceship::max_routes && index >= -1){
        route_index = index;
    }
    targets.setRouteIndex(route_index);
}

void NavigationScreen::onDraw(sf::RenderTarget &window)
{
    for(int r = 0; r < PlayerSpaceship::max_routes; r++){
        bool active = r == route_index;
        routeButtons[r]->setColorsOver(routeColors[r], active? sf::Color::Black : routeColors[r])->setActive(active);
    }
    ///Handle mouse wheel
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0)
    {
        float view_distance = radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        zoom_slider->setValue(view_distance);
        view_distance = zoom_slider->getValue();
        radar->setDistance(view_distance);
        zoom_label->setText("Zoom: " + string(max_distance / view_distance, 1.0f) + "x");
    }
    ///!

    GuiOverlay::onDraw(window);

    if (targets.getWaypointIndex() >= 0)
        delete_waypoint_button->enable();
    else
        delete_waypoint_button->disable();
    
    waypoint_place_button->setActive(placeWayPoints);
}

void NavigationScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "NAVIGATION")
    {
        if (key.hotkey == "PLACE_WAYPOINTS") {
            placeWayPoints = !placeWayPoints;
        } else if (key.hotkey == "WAYPOINT_PLACE_AT_CENTER") {
            placeWaypoint(radar->getViewPosition());
        } else if (key.hotkey == "WAYPOINT_DELETE" && my_spaceship && targets.getWaypointIndex() >= 0) {
            my_spaceship->commandRemoveWaypoint(targets.getWaypointIndex());
        }
    }
}

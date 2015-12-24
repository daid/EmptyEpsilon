#include "relayScreen.h"
#include "playerInfo.h"
#include "spaceObjects/scanProbe.h"

#include "screenComponents/radarView.h"
#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

RelayScreen::RelayScreen(GuiContainer* owner)
: GuiOverlay(owner, "RELAY_SCREEN", sf::Color::Black), mode(TargetSelection)
{   
    radar = new GuiRadarView(this, "RELAY_RADAR", 50000.0f, &targets);
    radar->longRange()->enableWaypoints()->enableCallsigns()->setStyle(GuiRadarView::Rectangular)->setFogOfWarStyle(GuiRadarView::FriendlysShortRangeFogOfWar);
    radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            mouse_down_position = position;
        },
        [this](sf::Vector2f position) {
            radar->setViewPosition(radar->getViewPosition() - (position - mouse_down_position));
        },
        [this](sf::Vector2f position) {
            switch(mode)
            {
            case TargetSelection:
                targets.setToClosestTo(position, 1000);
                break;
            case WaypointPlacement:
                if (my_spaceship)
                    my_spaceship->commandAddWaypoint(position);
                mode = TargetSelection;
                option_buttons->show();
                break;
            case WaypointDelete:
                if (my_spaceship)
                {
                    for(unsigned int n=0; n<my_spaceship->waypoints.size(); n++)
                    {
                        if ((my_spaceship->waypoints[n] - position) < 1000.0f)
                        {
                            my_spaceship->commandRemoveWaypoint(n);
                            break;
                        }
                    }
                }
                mode = TargetSelection;
                option_buttons->show();
                break;
            case LaunchProbe:
                if (my_spaceship)
                    my_spaceship->commandLaunchProbe(position);
                mode = TargetSelection;
                option_buttons->show();
                break;
            }
        }
    );
    
    if (my_spaceship)
        radar->setViewPosition(my_spaceship->getPosition());

    GuiAutoLayout* sidebar = new GuiAutoLayout(this, "SIDE_BAR", GuiAutoLayout::LayoutVerticalTopToBottom);
    sidebar->setPosition(-20, 150, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
    
    info_callsign = new GuiKeyValueDisplay(sidebar, "SCIENCE_CALLSIGN", 0.4, "Callsign", "");
    info_callsign->setSize(GuiElement::GuiSizeMax, 30);
    info_distance = new GuiKeyValueDisplay(sidebar, "SCIENCE_DISTANCE", 0.4, "Distance", "");
    info_distance->setSize(GuiElement::GuiSizeMax, 30);
    info_heading = new GuiKeyValueDisplay(sidebar, "SCIENCE_DISTANCE", 0.4, "Heading", "");
    info_heading->setSize(GuiElement::GuiSizeMax, 30);
    info_relspeed = new GuiKeyValueDisplay(sidebar, "SCIENCE_REL_SPEED", 0.4, "Rel.Speed", "");
    info_relspeed->setSize(GuiElement::GuiSizeMax, 30);
    
    info_faction = new GuiKeyValueDisplay(sidebar, "SCIENCE_FACTION", 0.4, "Faction", "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);
    info_type = new GuiKeyValueDisplay(sidebar, "SCIENCE_TYPE", 0.4, "Type", "");
    info_type->setSize(GuiElement::GuiSizeMax, 30);
    info_shields = new GuiKeyValueDisplay(sidebar, "SCIENCE_SHIELDS", 0.4, "Shields", "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);
    
    (new GuiSelector(this, "ZOOM_SELECT", [this](int index, string value) {
        float zoom_amount = powf(2.0f, index);
        radar->setDistance(50000.0f / zoom_amount);
    }))->setOptions({"Zoom: 1x", "Zoom: 2x", "Zoom: 4x", "Zoom: 8x"})->setSelectionIndex(0)->setPosition(20, -20, ABottomLeft)->setSize(250, 50);
    
    option_buttons = new GuiAutoLayout(this, "BUTTONS", GuiAutoLayout::LayoutVerticalTopToBottom);
    option_buttons->setPosition(20, 50, ATopLeft)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiOpenCommsButton(option_buttons, "OPEN_COMMS_BUTTON", &targets))->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiButton(option_buttons, "WAYPOINT_PLACE_BUTTON", "Place Waypoint", [this]() {
        mode = WaypointPlacement;
        option_buttons->hide();
    }))->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiButton(option_buttons, "WAYPOINT_DELETE_BUTTON", "Delete Waypoint", [this]() {
        mode = WaypointDelete;
        option_buttons->hide();
    }))->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiButton(option_buttons, "WAYPOINT_PLACE_BUTTON", "Launch Probe", [this]() {
        mode = LaunchProbe;
        option_buttons->hide();
    }))->setSize(GuiElement::GuiSizeMax, 50);
    
    info_reputation = new GuiKeyValueDisplay(option_buttons, "INFO_REPUTATION", 0.7, "Reputation:", "");
    info_reputation->setSize(GuiElement::GuiSizeMax, 40);
    
    GuiAutoLayout* layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutVerticalBottomToTop);
    layout->setPosition(-20, -20, ABottomRight)->setSize(300, GuiElement::GuiSizeMax);
    alert_level_button = new GuiToggleButton(layout, "", "Alert level", [this](bool value)
    {
        for(GuiButton* button : alert_level_buttons)
            button->setVisible(value);
    });
    alert_level_button->setValue(false);
    alert_level_button->setSize(GuiElement::GuiSizeMax, 50);

    for(int level=AL_Normal; level < AL_MAX; level++)
    {
        GuiButton* alert_button = new GuiButton(layout, "", alertLevelToString(EAlertLevel(level)), [this, level]()
        {
            if (my_spaceship)
                my_spaceship->commandSetAlertLevel(EAlertLevel(level));
            for(GuiButton* button : alert_level_buttons)
                button->setVisible(false);
            alert_level_button->setValue(false);
        });
        alert_button->setVisible(false);
        alert_button->setSize(GuiElement::GuiSizeMax, 50);
        alert_level_buttons.push_back(alert_button);
    }

    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void RelayScreen::onDraw(sf::RenderTarget& window)
{
    ///Handle mouse wheel
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0)
    {
        float view_distance = radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        if (view_distance > 50000.0f)
            view_distance = 50000.0f;
        if (view_distance < 5000.0f)
            view_distance = 5000.0f;
        radar->setDistance(view_distance);
    }
    ///!

    GuiOverlay::onDraw(window);

    info_faction->setValue("-");
    info_type->setValue("-");
    info_shields->setValue("-");

    if (targets.get() && my_spaceship)
    {
        P<SpaceObject> target = targets.get();
        bool near_friendly = false;
        foreach(SpaceObject, obj, space_object_list)
        {
            if ((!P<SpaceShip>(obj) && !P<SpaceStation>(obj)) || !obj->isFriendly(my_spaceship))
            {
                P<ScanProbe> sp = obj;
                if (!sp || sp->owner_id != my_spaceship->getMultiplayerId())
                {
                    continue;
                }
            }
            if (obj->getPosition() - target->getPosition() < 5000.0f)
            {
                near_friendly = true;
                break;
            }
        }
        if (!near_friendly)
            targets.clear();
    }
    
    if (targets.get())
    {
        P<SpaceObject> obj = targets.get();
        P<SpaceShip> ship = obj;
        P<SpaceStation> station = obj;
        sf::Vector2f position_diff = obj->getPosition() - my_spaceship->getPosition();
        float distance = sf::length(position_diff);
        float heading = sf::vector2ToAngle(position_diff) - 270;
        while(heading < 0) heading += 360;
        float rel_velocity = dot(obj->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);
        if (fabs(rel_velocity) < 0.01)
            rel_velocity = 0.0;
        
        info_callsign->setValue(obj->getCallSign());
        info_distance->setValue(string(distance / 1000.0f, 1) + "km");
        info_heading->setValue(string(int(heading)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + "km/min");

        if (ship)
        {
            if (ship->scanned_by_player >= SS_SimpleScan)
            {
                info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
                info_type->setValue(ship->ship_type_name);
                info_shields->setValue(string(int(ship->front_shield)) + ":" + string(int(ship->rear_shield)));
            }
        }else{
            info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
            if (station)
            {
                info_type->setValue(station->template_name);
                info_shields->setValue(string(int(station->shields)));
            }
        }
    }else{
        info_callsign->setValue("-");
        info_distance->setValue("-");
        info_heading->setValue("-");
        info_relspeed->setValue("-");
    }
    
    if (my_spaceship)
        info_reputation->setValue(string(my_spaceship->getReputationPoints(), 0));
}

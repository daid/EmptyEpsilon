#include "relayScreen.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "spaceObjects/scanProbe.h"
#include "scriptInterface.h"
#include "gameGlobalInfo.h"

#include "screenComponents/radarView.h"
#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"
#include "screenComponents/hackingDialog.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_textentry.h"

RelayScreen::RelayScreen(GuiContainer* owner, bool has_comms)
: GuiOverlay(owner, "RELAY_SCREEN", colorConfig.background),has_comms(has_comms),mode(TargetSelection)
{
    targets.setAllowWaypointSelection();
    radar = new GuiRadarView(this, "RELAY_RADAR", 50000.0f, &targets, my_spaceship);
    radar->longRange()->enableWaypoints()->enableCallsigns()->setStyle(GuiRadarView::Rectangular)->setFogOfWarStyle(GuiRadarView::FriendlysShortRangeFogOfWar);
    radar->setAutoCentering(false);
    radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    radar->setCallbacks(
        [this](sf::Vector2f position) { //down
            if (mode == TargetSelection && targets.getWaypointIndex() > -1 && my_spaceship)
            {
                if (sf::length(my_spaceship->waypoints[targets.getWaypointIndex()] - position) < 1000.0)
                {
                    mode = MoveWaypoint;
                    drag_waypoint_index = targets.getWaypointIndex();
                }
            }
            mouse_down_position = position;
        },
        [this](sf::Vector2f position) { //drag
            if (mode == TargetSelection)
            {
                sector_name_custom = false;
                sf::Vector2f newPosition = radar->getViewPosition() - (position - mouse_down_position);
                radar->setViewPosition(newPosition);
                if(!sector_name_custom)
                    sector_name_text->setText(getSectorName(newPosition));
            }
            if (mode == MoveWaypoint && my_spaceship)
                my_spaceship->commandMoveWaypoint(drag_waypoint_index, position);
        },
        [this](sf::Vector2f position) { //up
            switch(mode)
            {
            case TargetSelection:
                targets.setToClosestTo(position, 1000, TargetsContainer::Targetable);
                break;
            case WaypointPlacement:
                if (my_spaceship)
                    my_spaceship->commandAddWaypoint(position);
                mode = TargetSelection;
                option_buttons->show();
                break;
            case MoveWaypoint:
                mode = TargetSelection;
                targets.setWaypointIndex(drag_waypoint_index);
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

    info_faction = new GuiKeyValueDisplay(sidebar, "SCIENCE_FACTION", 0.4, "Faction", "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);

    // Controls for the radar view
    view_controls = new GuiAutoLayout(this, "VIEW_CONTROLS", GuiAutoLayout::LayoutVerticalBottomToTop);
    view_controls->setPosition(20, -70, ABottomLeft)->setSize(250, GuiElement::GuiSizeMax);
    zoom_slider = new GuiSlider(view_controls, "ZOOM_SLIDER", max_distance, min_distance, radar->getDistance(), [this](float value) {
        zoom_label->setText("Zoom: " + string(max_distance / value, 1.0f) + "x");
        radar->setDistance(value);
    });
    zoom_slider->setPosition(20, -70, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 50);
    zoom_slider->setVisible(false);
    zoom_label = new GuiLabel(zoom_slider, "", "Zoom: " + string(max_distance / radar->getDistance(), 1.0f) + "x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    sector_name_custom = false;
    sector_name_text = new GuiTextEntry(view_controls, "SECTOR_NAME_TEXT", "");
    sector_name_text->setSize(GuiElement::GuiSizeMax, 50);
    sector_name_text->callback([this](string text){
        sector_name_custom = true;
    });
    sector_name_text->validator(isValidSectorName);
    sector_name_text->enterCallback([this](string text){
        sector_name_custom = false;
        if (sector_name_text->isValid())
        {
            sf::Vector2f pos = getSectorPosition(text);
            radar->setViewPosition(pos);
        }
    });
    sector_name_text->setText(getSectorName(radar->getViewPosition()));
    // Option buttons for comms, waypoints, and probes.
    option_buttons = new GuiAutoLayout(this, "BUTTONS", GuiAutoLayout::LayoutVerticalTopToBottom);
    option_buttons->setPosition(20, 50, ATopLeft)->setSize(250, GuiElement::GuiSizeMax);

    // Open comms button.
    (new GuiOpenCommsButton(option_buttons, "OPEN_COMMS_BUTTON", &targets))->setSize(GuiElement::GuiSizeMax, 50);

    // Hack target
    hack_target_button = new GuiButton(option_buttons, "HACK_TARGET", "Start hacking", [this](){
        P<SpaceObject> target = targets.get();
        if (my_spaceship && target && target->canBeHackedBy(my_spaceship))
        {
            hacking_dialog->open(target);
        }
    });
    hack_target_button->setSize(GuiElement::GuiSizeMax, 50);

    // Link probe to science button.
    link_to_science_button = new GuiToggleButton(option_buttons, "LINK_TO_SCIENCE", "Link to Science", [this](bool value){
        if (value)
            my_spaceship->commandSetScienceLink(targets.get()->getMultiplayerId());
        else
            my_spaceship->commandSetScienceLink(-1);
    });
    link_to_science_button->setSize(GuiElement::GuiSizeMax, 50);
	
    // Link probe to 3D port button.
    link_to_3D_port_button = new GuiToggleButton(option_buttons, "LINK_TO_3D_PORT", "Camera Probe", [this](bool value){
        if (value)
            my_spaceship->commandSetProbe3DLink(targets.get()->getMultiplayerId());
        else
            my_spaceship->commandSetProbe3DLink(-1);
    });
    link_to_3D_port_button->setSize(GuiElement::GuiSizeMax, 50);

    // Manage waypoints.
    (new GuiButton(option_buttons, "WAYPOINT_PLACE_BUTTON", "Place Waypoint", [this]() {
        mode = WaypointPlacement;
        option_buttons->hide();
    }))->setSize(GuiElement::GuiSizeMax, 50);

    delete_waypoint_button = new GuiButton(option_buttons, "WAYPOINT_DELETE_BUTTON", "Delete Waypoint", [this]() {
        if (my_spaceship && targets.getWaypointIndex() >= 0)
        {
            my_spaceship->commandRemoveWaypoint(targets.getWaypointIndex());
        }
    });
    delete_waypoint_button->setSize(GuiElement::GuiSizeMax, 50);

    // Launch probe button.
    launch_probe_button = new GuiButton(option_buttons, "LAUNCH_PROBE_BUTTON", "Launch Probe", [this]() {
        mode = LaunchProbe;
        option_buttons->hide();
    });
    launch_probe_button->setSize(GuiElement::GuiSizeMax, 50);

    // Launch drone button.
    launch_drone_button = new GuiButton(option_buttons, "LAUNCH_DRONE_BUTTON", "Launch Drone", [this]() {
        my_spaceship->commandLaunchCargo(2); 
    });
    launch_drone_button->setSize(GuiElement::GuiSizeMax, 50);

    // Reputation display.
    info_reputation = new GuiKeyValueDisplay(option_buttons, "INFO_REPUTATION", 0.7, "Reputation:", "");
    info_reputation->setSize(GuiElement::GuiSizeMax, 40);

    // Bottom layout.
    GuiAutoLayout* layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutVerticalBottomToTop);
    layout->setPosition(-20, -70, ABottomRight)->setSize(300, GuiElement::GuiSizeMax);

    // Alert level buttons.
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

    (new GuiCustomShipFunctions(this, relayOfficer, "", my_spaceship))->setPosition(-20, 240, ATopRight)->setSize(250, GuiElement::GuiSizeMax);

    hacking_dialog = new GuiHackingDialog(this, "");

    new ShipsLog(this,"extern");
	if (has_comms)
		(new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void RelayScreen::onDraw(sf::RenderTarget& window)
{
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

    info_faction->setValue("-");

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
        P<ScanProbe> probe = obj;

        info_callsign->setValue(obj->getCallSign());

        if (ship)
        {
            if (ship->getScannedStateFor(my_spaceship) >= SS_SimpleScan)
            {
                info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
            }
        }else{
            info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
        }

        if (probe && probe->owner_id == my_spaceship->getMultiplayerId() && probe->canBeTargetedBy(my_spaceship))
        {
            link_to_science_button->setValue(my_spaceship->linked_science_probe_id == probe->getMultiplayerId());
            link_to_science_button->enable();
			
            link_to_3D_port_button->setValue(my_spaceship->linked_probe_3D_id == probe->getMultiplayerId());
            link_to_3D_port_button->enable();
        }
        else
        {
            link_to_science_button->setValue(false);
            link_to_science_button->disable();
			
            link_to_3D_port_button->setValue(false);
            link_to_3D_port_button->disable();
        }
        if (my_spaceship && obj->canBeHackedBy(my_spaceship))
        {
            hack_target_button->enable();
        }else{
            hack_target_button->disable();
        }
    }else{
        hack_target_button->disable();
        link_to_science_button->disable();
        link_to_science_button->setValue(false);
		link_to_3D_port_button->disable();
		link_to_3D_port_button->setValue(false);
        info_callsign->setValue("-");
    }
    if (my_spaceship)
    {
        info_reputation->setValue(string(my_spaceship->getReputationPoints(), 0));
        launch_probe_button->setText("Launch probe (" + string(my_spaceship->scan_probe_stock) + ")");
    }

    if (targets.getWaypointIndex() >= 0)
        delete_waypoint_button->enable();
    else
        delete_waypoint_button->disable();
}

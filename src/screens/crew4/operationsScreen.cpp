#include "operationsScreen.h"
#include "playerInfo.h"
#include "i18n.h"
#include "gameGlobalInfo.h"
#include "preferenceManager.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"

#include "components/scanning.h"
#include "components/radar.h"

#include "screens/crew6/scienceScreen.h"

#include "gui/theme.h"
#include "screenComponents/radarView.h"
#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"

OperationScreen::OperationScreen(GuiContainer* owner)
: GuiOverlay(owner, "", GuiTheme::getColor("background"))
{
    science = new ScienceScreen(this, CrewPosition::operationsOfficer);
    science->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, 0, 0, 50);
    science->science_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) { // Down
            // If not our ship, or if we're scanning, ignore clicks.
            auto science_scanner = my_spaceship.getComponent<ScienceScanner>();
            if (science_scanner && science_scanner->delay > 0.0f) return;

            // If we're in target selection mode, there's a waypoint, and this
            // is our ship...
            if (mode == TargetSelection && science->targets.getWaypointIndex() > -1 && my_spaceship)
            {
                if (auto waypoints = my_spaceship.getComponent<Waypoints>())
                {
                    // ... and we select something near a waypoint, switch to move
                    // waypoint mode.
                    if (auto waypoint_position = waypoints->get(science->targets.getWaypointIndex(), science->targets.getWaypointSetId()))
                    {
                        if (glm::length(waypoint_position.value() - position) < 1000.0f)
                        {
                            mode = MoveWaypoint;
                            drag_waypoint_index = science->targets.getWaypointIndex();
                            drag_waypoint_set = science->targets.getWaypointSetId();
                        }
                    }
                }
            }
            mouse_down_position = position;
        },
        [this](glm::vec2 position) { // Drag
            // If we're dragging a waypoint, move it.
            if (mode == MoveWaypoint && my_spaceship)
                my_player_info->commandMoveWaypoint(drag_waypoint_index, position, drag_waypoint_set);
        },
        [this](glm::vec2 position) { // Up
            switch(mode)
            {
            case TargetSelection:
                science->targets.setToClosestTo(position, 1000.0, TargetsContainer::Selectable);
                break;
            case WaypointPlacement:
                if (my_spaceship)
                    my_player_info->commandAddWaypoint(position, active_waypoint_set);
                mode = TargetSelection;
                place_waypoint_button->setValue(false);
                break;
            case MoveWaypoint:
                mode = TargetSelection;
                science->targets.setWaypointIndex(drag_waypoint_index, drag_waypoint_set);
                break;
            }
        },
        [this](float value, glm::vec2 position) { // Wheel
            float view_distance = std::clamp(
                science->science_radar->getDistance() * (1.0f - value * 0.1f),
                science->DEFAULT_MIN_ZOOM_DISTANCE,
                science->DEFAULT_MAX_ZOOM_DISTANCE
            );
            science->science_radar->setDistance(view_distance);
            // zoom_slider->setValue(view_distance);
        }
    );
    science->science_radar->setAutoRotating(PreferencesManager::get("operations_radar_lock","0")=="1");

    // Limited relay functions: comms and waypoints.
    GuiElement* relay_functions = new GuiElement(science->radar_view, "RELAY_FUNCTIONS");
    relay_functions
        ->setPosition(-270.0f, -20.0f, sp::Alignment::BottomRight)
        ->setSize(200.0f, 150.0f)
        ->setAttribute("layout", "verticalbottom");

    // Manage comms.
    (new GuiOpenCommsButton(relay_functions, "OPEN_COMMS_BUTTON", tr("Open comms"), &science->targets))
        ->setSize(200.0f, 50.0f);

    // Manage waypoints.
    place_waypoint_button = new GuiToggleButton(relay_functions, "WAYPOINT_PLACE_BUTTON", tr("Place waypoint"), [this](bool value) {
        mode = value ? WaypointPlacement : TargetSelection;
    });
    place_waypoint_button->setSize(200.0f, 50.0f);

    delete_waypoint_button = new GuiButton(relay_functions, "WAYPOINT_DELETE_BUTTON", tr("Delete waypoint"),
        [this]()
        {
            if (my_spaceship && science->targets.getWaypointIndex() >= 0)
                my_player_info->commandRemoveWaypoint(science->targets.getWaypointIndex(), science->targets.getWaypointSetId());
        }
    );
    delete_waypoint_button->setSize(200.0f, 50.0f);

    // Waypoint set selector, shown only when multiple sets are enabled.
    waypoint_set_selector = new GuiSelector(relay_functions, "WAYPOINT_SET_SELECTOR",
        [this](int index, string value)
        {
            active_waypoint_set = index + 1;
        }
    );
    waypoint_set_selector
        ->setOptions({tr("Waypoint set 1"), tr("Waypoint set 2"), tr("Waypoint set 3"), tr("Waypoint set 4")})
        ->setSelectionIndex(0)
        ->setSize(GuiElement::GuiSizeMax, 50.0f);

    // Route toggle.
    route_toggle = new GuiToggleButton(relay_functions, "WAYPOINT_ROUTE_TOGGLE", tr("Route"),
        [this](bool value)
        {
            if (my_spaceship) my_player_info->commandSetWaypointRoute(value, active_waypoint_set);
        }
    );
    route_toggle->setSize(200.0f, 50.0f);

    auto stats = new GuiElement(this, "OPERATIONS_STATS");
    stats->setPosition(20, 60, sp::Alignment::TopLeft)->setSize(240, 80)->setAttribute("layout", "vertical");

    // Reputation display.
    info_reputation = new GuiKeyValueDisplay(stats, "INFO_REPUTATION", 0.55f, tr("Reputation") + ":", "");
    info_reputation->setTextSize(20)->setSize(200, 40);

    // Scenario clock display.
    info_clock = new GuiKeyValueDisplay(stats, "INFO_CLOCK", 0.55f, tr("Clock") + ":", "");
    info_clock->setTextSize(20)->setSize(200, 40);

    mode = TargetSelection;

    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void OperationScreen::onDraw(sp::RenderTarget& target)
{
    GuiOverlay::onDraw(target);

    if (!my_spaceship) return;
    if (science->radar_view->isVisible())
    {
        info_reputation->setValue(string(Faction::getInfo(my_spaceship).reputation_points, 0))->show();

        // Update mission clock
        info_clock->setValue(gameGlobalInfo->getMissionTime())->show();
    }
    else
    {
        info_reputation->hide();
        info_clock->hide();
    }

    // Show/hide waypoint set selector and route toggle
    waypoint_set_selector->setVisible(gameGlobalInfo->enable_multiple_waypoint_sets);
    route_toggle->setVisible(gameGlobalInfo->enable_waypoint_routes);

    // Sync route toggle
    if (gameGlobalInfo->enable_waypoint_routes)
    {
        if (auto wp = my_spaceship.getComponent<Waypoints>())
            route_toggle->setValue(wp->is_route[active_waypoint_set - 1]);
    }
}

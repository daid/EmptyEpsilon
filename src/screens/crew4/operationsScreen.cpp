#include "playerInfo.h"
#include "i18n.h"
#include "gameGlobalInfo.h"
#include "operationsScreen.h"
#include "preferenceManager.h"

#include "gui/gui2_keyvaluedisplay.h"

#include "components/scanning.h"
#include "components/radar.h"

#include "screens/crew6/scienceScreen.h"

#include "screenComponents/radarView.h"
#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"


OperationScreen::OperationScreen(GuiContainer* owner)
: GuiOverlay(owner, "", colorConfig.background)
{
    science = new ScienceScreen(this, CrewPosition::operationsOfficer);
    science->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, 0, 0, 50);
    science->science_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) { // Down
            // If not our ship, or if we're scanning, ignore clicks.
            auto science_scanner = my_spaceship.getComponent<ScienceScanner>();
            if (science_scanner && science_scanner->delay > 0.0f)
                return;

            // If we're in target selection mode, there's a waypoint, and this
            // is our ship...
            if (mode == TargetSelection && science->targets.getWaypointIndex() > -1 && my_spaceship)
            {
                if (auto waypoints = my_spaceship.getComponent<Waypoints>()) {
                    // ... and we select something near a waypoint, switch to move
                    // waypoint mode.
                    if (auto waypoint_position = waypoints->get(science->targets.getWaypointIndex())) {
                        if (glm::length(waypoint_position.value() - position) < 1000.0f)
                        {
                            mode = MoveWaypoint;
                            drag_waypoint_index = science->targets.getWaypointIndex();
                        }
                    }
                }
            }
            mouse_down_position = position;
        },
        [this](glm::vec2 position) { // Drag
            // If we're dragging a waypoint, move it.
            if (mode == MoveWaypoint && my_spaceship)
                my_player_info->commandMoveWaypoint(drag_waypoint_index, position);
        },
        [this](glm::vec2 position) { // Up
            switch(mode)
            {
            case TargetSelection:
                science->targets.setToClosestTo(position, 1000.0, TargetsContainer::Selectable);
                break;
            case WaypointPlacement:
                if (my_spaceship)
                    my_player_info->commandAddWaypoint(position);
                mode = TargetSelection;
                break;
            case MoveWaypoint:
                mode = TargetSelection;
                science->targets.setWaypointIndex(drag_waypoint_index);
                break;
            }
        }
    );
    science->science_radar->setAutoRotating(PreferencesManager::get("operations_radar_lock","0")=="1");

    (new GuiOpenCommsButton(science->radar_view, "OPEN_COMMS_BUTTON", tr("Open Comms"), &science->targets))->setPosition(-270, -20, sp::Alignment::BottomRight)->setSize(200, 50);

    // Manage waypoints.
    place_waypoint_button = new GuiButton(science->radar_view, "WAYPOINT_PLACE_BUTTON", tr("Place Waypoint"), [this]() {
        mode = WaypointPlacement;
    });
    place_waypoint_button->setPosition(-270, -70, sp::Alignment::BottomRight)->setSize(200, 50);

    delete_waypoint_button = new GuiButton(science->radar_view, "WAYPOINT_DELETE_BUTTON", tr("Delete Waypoint"), [this]() {
        if (my_spaceship && science->targets.getWaypointIndex() >= 0)
        {
            my_player_info->commandRemoveWaypoint(science->targets.getWaypointIndex());
        }
    });
    delete_waypoint_button->setPosition(-270, -120, sp::Alignment::BottomRight)->setSize(200, 50);

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
}

#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "operationsScreen.h"
#include "preferenceManager.h"

#include "gui/gui2_keyvaluedisplay.h"

#include "screens/crew6/scienceScreen.h"

#include "screenComponents/radarView.h"
#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"

#include "spaceObjects/playerSpaceship.h"

OperationScreen::OperationScreen(GuiContainer* owner)
: GuiOverlay(owner, "", colorConfig.background)
{
    science = new ScienceScreen(this, operationsOfficer);
    science->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, 0, 0, 50);
    science->science_radar->setCallbacks(
        [this](glm::vec2 position) { // Down
            // If not our ship, or if we're scanning, ignore clicks.
            if (!my_spaceship || my_spaceship->scanning_delay > 0.0)
                return;

            // If we're in target selection mode, there's a waypoint, and this
            // is our ship...
            if (mode == TargetSelection && science->targets.getWaypointIndex() > -1 && my_spaceship)
            {
                // ... and we select something near a waypoint, switch to move
                // waypoint mode.
                if (glm::length(my_spaceship->waypoints[science->targets.getWaypointIndex()] - position) < 1000.0)
                {
                    mode = MoveWaypoint;
                    drag_waypoint_index = science->targets.getWaypointIndex();
                }
            }
            mouse_down_position = position;
        },
        [this](glm::vec2 position) { // Drag
            // If we're dragging a waypoint, move it.
            if (mode == MoveWaypoint && my_spaceship)
                my_spaceship->commandMoveWaypoint(drag_waypoint_index, position);
        },
        [this](glm::vec2 position) { // Up
            switch(mode)
            {
            case TargetSelection:
                science->targets.setToClosestTo(position, 1000.0, TargetsContainer::Selectable);
                break;
            case WaypointPlacement:
                if (my_spaceship)
                    my_spaceship->commandAddWaypoint(position);
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

    (new GuiOpenCommsButton(science->radar_view, "OPEN_COMMS_BUTTON", tr("Open Comms"), &science->targets))->setPosition(-270, -20, ABottomRight)->setSize(200, 50);

    // Manage waypoints.
    place_waypoint_button = new GuiButton(science->radar_view, "WAYPOINT_PLACE_BUTTON", tr("Place Waypoint"), [this]() {
        mode = WaypointPlacement;
    });
    place_waypoint_button->setPosition(-270, -70, ABottomRight)->setSize(200, 50);

    delete_waypoint_button = new GuiButton(science->radar_view, "WAYPOINT_DELETE_BUTTON", tr("Delete Waypoint"), [this]() {
        if (my_spaceship && science->targets.getWaypointIndex() >= 0)
        {
            my_spaceship->commandRemoveWaypoint(science->targets.getWaypointIndex());
        }
    });
    delete_waypoint_button->setPosition(-270, -120, ABottomRight)->setSize(200, 50);

    // Reputation display.
    info_reputation = new GuiKeyValueDisplay(this, "INFO_REPUTATION", 0.7, tr("Reputation") + ":", "");
    info_reputation->setPosition(20, 20, ATopLeft)->setSize(175, 30);

    // Scenario clock display.
    info_clock = new GuiKeyValueDisplay(this, "INFO_CLOCK", 0.7, tr("Clock") + ":", "");
    info_clock->setPosition(20, 50, ATopLeft)->setSize(175, 30);

    mode = TargetSelection;

    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void OperationScreen::onDraw(sf::RenderTarget& window)
{
    if (science->radar_view->isVisible())
    {
        info_reputation->setValue(string(my_spaceship->getReputationPoints(), 0))->show();
        info_clock->setValue(string(gameGlobalInfo->elapsed_time, 0))->show();
    }
    else
    {
        info_reputation->hide();
        info_clock->hide();
    }
}

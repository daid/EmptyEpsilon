#include "droneOperatorScreen.h"

#include "playerInfo.h"
#include "gameGlobalInfo.h"

#include "screenComponents/alertOverlay.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "screenComponents/powerDamageIndicator.h"
#include "screenComponents/tractorBeamControl.h"
#include "screenComponents/radarView.h"

const ECrewPosition crewPosition = ECrewPosition::singlePilot;
DroneOperatorScreen::DroneOperatorScreen(GuiContainer *owner)
    : GuiOverlay(owner, "DRONE_PILOT_SCREEN", colorConfig.background), mode(DroneSelection)
{
    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Draw a container for drone selection UI
    droneSelection = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutHorizontalRows);
    droneSelection->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Drone list
    drone_list = new GuiListbox(droneSelection, "PLAYER_SHIP_LIST", [this](int index, string value) {
        P<PlayerSpaceship> ship;
        if (game_server)
            ship = game_server->getObjectById(value.toInt());
        else if (game_client)
            ship = game_client->getObjectById(value.toInt());
        // If the selected item is a ship ...
        if (ship)
        // TODO :  check if occupied
        {
            mode = Piloting;
            selected_drone = ship;
            single_pilot_view->setTargetSpaceship(selected_drone);
        }
    });
    drone_list->setPosition(0, -100, ATopCenter)->setSize(500, 1000);
    
    tractor_beam_control = new GuiTractorBeamControl(this, "BEAM_CONFIG");
    tractor_beam_control->setPosition(-20, -20, ABottomRight)->setSize(580, 290);

    // single pilot UI
    single_pilot_view = new SinglePilotView(this, selected_drone);
    single_pilot_view->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    connection_label = new GuiLabel(this, "CONNECTION_LABEL", "0%", 30);
    connection_label->setPosition(0, -50, ABottomCenter)->setSize(460, 50);

    disconnect_button = new GuiButton(this, "DISCONNECT_BUTTON", "Disconnect", [this]() {disconnected();});
    disconnect_button->setPosition(0, 0, ABottomCenter)->setSize(400, 50);
    disconnect_button->moveToFront();
    // label for when there are no drones
    no_drones_label = new GuiLabel(this, "SHIP_SELECTION_NO_SHIPS_LABEL", "No active drones in range", 30);
    no_drones_label->setPosition(0, 100, ATopCenter)->setSize(460, 50);
    // Prep the alert overlay.
    (new GuiPowerDamageIndicator(this, "DOCKS_DPI", SYS_Drones, ATopCenter, my_spaceship))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void DroneOperatorScreen::disconnected()
{
    mode = drone_list->entryCount() == 0 ? NoDrones : DroneSelection;
    selected_drone = NULL;
    single_pilot_view->setTargetSpaceship(selected_drone);
}

bool DroneOperatorScreen::isConnectable(P<PlayerSpaceship> ship)
{
    return ship 
    && ship->ship_template 
    && ship->ship_template->getType() == ShipTemplate::TemplateType::Drone 
    && ship->getFactionId() == my_spaceship->getFactionId()
    && getConnectionQuality(ship) >= 0.01f; 
}
float DroneOperatorScreen::getConnectionQuality(P<PlayerSpaceship> ship)
{
    float rangeFactor = 1 - std::min(1.0f, (length(ship->getPosition() - my_spaceship->getPosition()) / my_spaceship->getDronesControlRange()));
    float droneStateFactor = std::min(1.0f, ship->getSystemEffectiveness(SYS_Drones));
    return rangeFactor * droneStateFactor;
}
void DroneOperatorScreen::onDraw(sf::RenderTarget &window)
{
    if (my_spaceship)
    {
        // Update the player ship list with all player ships.
        std::vector<string> options;
        std::vector<string> values;
        for (int n = 0; n < GameGlobalInfo::max_player_ships; n++)
        {
            P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
            if (isConnectable(ship)) {
                options.push_back(ship->getTypeName() + " " + ship->getCallSign() + "(" + string(int(getConnectionQuality(ship) * 100)) + "%)");
                values.push_back(ship->getMultiplayerId());
            }
        }
        drone_list->setOptions(options, values);
        // automatically change mode if needed
        if (!selected_drone || !isConnectable(selected_drone) || selected_drone->isDestroyed())
        {
           disconnected();
        }
        // update display according to mode
        switch (mode)
        {
        case DroneSelection:
            no_drones_label->hide();
            droneSelection->show();
            single_pilot_view->hide();
            disconnect_button->hide();
            connection_label->hide();
            tractor_beam_control->show();
            break;
        case Piloting:
            no_drones_label->hide();
            droneSelection->hide();
            single_pilot_view->show();
            disconnect_button->setText("Disconnect " + selected_drone->callsign);
            disconnect_button->show();
            connection_label->setText(string(int(getConnectionQuality(selected_drone) * 100)) + "%");
            connection_label->show();
            tractor_beam_control->hide();
            break;
        case NoDrones:
            no_drones_label->show();
            droneSelection->hide();
            single_pilot_view->hide();
            disconnect_button->hide();
            connection_label->hide();
            tractor_beam_control->show();
            break;
        }
    }
}

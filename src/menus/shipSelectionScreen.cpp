#include "shipSelectionScreen.h"
#include "serverCreationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "screens/windowScreen.h"
#include "screens/topDownScreen.h"
#include "screens/cinematicViewScreen.h"
#include "screens/spectatorScreen.h"
#include "screens/gm/gameMasterScreen.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_togglebutton.h"
#include "preferenceManager.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Easiest place to ensure that positional sound is disabled on console
    // views. As soon as a 3D view is rendered, positional sound is re-enabled.
    soundManager->disablePositionalSound();

    // Draw a container with two columns.
    container = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutVerticalColumns);
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    left_container = new GuiElement(container, "");
    right_container = new GuiElement(container, "");

    // List the station types and stations in the right column.
    GuiAutoLayout* stations_layout = new GuiAutoLayout(right_container, "CREW_POSITION_BUTTON_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    stations_layout->setPosition(0, 50, ATopCenter)->setSize(400, 600);
    (new GuiLabel(stations_layout, "CREW_POSITION_SELECT_LABEL", "Select your station", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Crew type selector
    crew_type_selector = new GuiSelector(stations_layout, "CREW_TYPE_SELECTION", [this](int index, string value) {
        updateCrewTypeOptions();
    });
    crew_type_selector->setOptions({"6/5 player crew", "4/3 player crew", "1 player crew/extras", "Alternative options"})->setSize(GuiElement::GuiSizeMax, 50);

    // Main screen button
    main_screen_button = new GuiToggleButton(stations_layout, "MAIN_SCREEN_BUTTON", "Main screen", [this](bool value) {
        my_player_info->commandSetMainScreen(value);
    });
    main_screen_button->setSize(GuiElement::GuiSizeMax, 50);

    // Crew position buttons, with icons if they have them
    for(int n = 0; n < max_crew_positions; n++)
    {
        crew_position_button[n] = new GuiToggleButton(stations_layout, "CREW_" + getCrewPositionName(ECrewPosition(n)) + "_BUTTON", getCrewPositionName(ECrewPosition(n)), [this, n](bool value){
            my_player_info->commandSetCrewPosition(ECrewPosition(n), value);
        });
        crew_position_button[n]->setSize(GuiElement::GuiSizeMax, 50);
        crew_position_button[n]->setIcon(getCrewPositionIcon(ECrewPosition(n)));
    }

    // Main screen controls button
    main_screen_controls_button = new GuiToggleButton(stations_layout, "MAIN_SCREEN_CONTROLS_ENABLE", "Main screen controls", [](bool value) {
        my_player_info->commandSetMainScreenControl(value);
    });
    main_screen_controls_button->setValue(my_player_info->main_screen_control)->setSize(GuiElement::GuiSizeMax, 50);
    
    // Game master button
    game_master_button = new GuiToggleButton(stations_layout, "GAME_MASTER_BUTTON", "Game master", [this](bool value) {
        window_button->setValue(false);
        topdown_button->setValue(false);
        cinematic_view_button->setValue(false);
        spectator_button->setValue(false);
    });
    game_master_button->setSize(GuiElement::GuiSizeMax, 50);

    // Ship window button and angle slider
    window_button_row = new GuiAutoLayout(stations_layout, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    window_button_row->setSize(GuiElement::GuiSizeMax, 50);
    window_button = new GuiToggleButton(window_button_row, "WINDOW_BUTTON", "Ship window", [this](bool value) {
        game_master_button->setValue(false);
        topdown_button->setValue(false);
        cinematic_view_button->setValue(false);
        spectator_button->setValue(false);
    });
    window_button->setSize(175, 50);

    window_angle = new GuiSlider(window_button_row, "WINDOW_ANGLE", 0.0, 359.0, 0.0, [this](float value) {
        window_angle_label->setText(string(int(window_angle->getValue())) + " degrees");
    });
    window_angle->setSize(GuiElement::GuiSizeMax, 50);
    window_angle_label = new GuiLabel(window_angle, "WINDOW_ANGLE_LABEL", "0 degrees", 30);
    window_angle_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Top-down view button
    topdown_button = new GuiToggleButton(stations_layout, "TOP_DOWN_3D_BUTTON", "Top-down 3D view", [this](bool value) {
        game_master_button->setValue(false);
        window_button->setValue(false);
        cinematic_view_button->setValue(false);
        spectator_button->setValue(false);
    });
    topdown_button->setSize(GuiElement::GuiSizeMax, 50);

    // Cinematic view button
    cinematic_view_button = new GuiToggleButton(stations_layout, "CINEMATIC_VIEW_BUTTON", "Cinematic view", [this](bool value) {
        game_master_button->setValue(false);
        window_button->setValue(false);
        topdown_button->setValue(false);
        spectator_button->setValue(false);
    });
    cinematic_view_button->setSize(GuiElement::GuiSizeMax, 50);

    // Spectator view button
    spectator_button = new GuiToggleButton(stations_layout, "SPECTATOR_BUTTON", "Spectate (view all)", [this](bool value) {
        game_master_button->setValue(false);
        window_button->setValue(false);
        topdown_button->setValue(false);
        cinematic_view_button->setValue(false);

        if (gameGlobalInfo->gm_control_code.length() > 0)
        {
            LOG(INFO) << "Player selected Spectate mode, which has a control code.";
            password_label->setText("Enter the GM control code:");
            left_container->hide();
            right_container->hide();
            password_overlay->show();
        }
    });
    spectator_button->setSize(GuiElement::GuiSizeMax, 50);

    // If this is the server, add a panel to create player ships.
    if (game_server)
    {
        (new GuiPanel(left_container, "CREATE_SHIP_BOX"))->setPosition(0, 50, ATopCenter)->setSize(550, 700);
    }

    // Player ship selection panel
    (new GuiPanel(left_container, "SHIP_SELECTION_BOX"))->setPosition(0, 50, ATopCenter)->setSize(550, 560);
    (new GuiLabel(left_container, "SHIP_SELECTION_LABEL", "Select ship", 30))->addBackground()->setPosition(0, 50, ATopCenter)->setSize(510, 50);
    no_ships_label = new GuiLabel(left_container, "SHIP_SELECTION_NO_SHIPS_LABEL", "Waiting for server to spawn a ship", 30);
    no_ships_label->setPosition(0, 100, ATopCenter)->setSize(460, 50);

    // Player ship list
    player_ship_list = new GuiListbox(left_container, "PLAYER_SHIP_LIST", [this](int index, string value) {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());

        // If the selected item is a ship ...
        if (ship)
        {
            // ... and it has a control code, ask the player for it.
            if (ship->control_code.length() > 0)
            {
                LOG(INFO) << "Player selected " << ship->getCallSign() << ", which has a control code.";
                // Hide the ship selection UI temporarily to deter sneaky ship thieves.
                left_container->hide();
                right_container->hide();
                // Show the control code entry dialog.
                password_overlay->show();
            }
            // Otherwise, select and set this ship ID in the player info.
            else
            {
                my_player_info->commandSetShipId(ship->getMultiplayerId());
            }
        // If the selected item isn't a ship, reset the ship ID in player info.
        }else{
            my_player_info->commandSetShipId(-1);
        }
    });
    player_ship_list->setPosition(0, 100, ATopCenter)->setSize(490, 500);

    // If this is the server, add buttons and a selector to create player ships.
    if (game_server)
    {
        GuiSelector* ship_template_selector = new GuiSelector(left_container, "CREATE_SHIP_SELECTOR", nullptr);
        // List only ships with templates designated for player use.
        std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::PlayerShip);
        std::sort(template_names.begin(), template_names.end());

        for(string& template_name : template_names)
        {
            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
            ship_template_selector->addEntry(template_name + " (" + ship_template->getClass() + ":" + ship_template->getSubClass() + ")", template_name);
        }
        ship_template_selector->setSelectionIndex(0);
        ship_template_selector->setPosition(0, 630, ATopCenter)->setSize(490, 50);

        // Spawn a ship of the selected template near 0,0 and give it a random
        // heading.
        (new GuiButton(left_container, "CREATE_SHIP_BUTTON", "Spawn player ship", [this, ship_template_selector]() {
            P<PlayerSpaceship> ship = new PlayerSpaceship();

            if (ship)
            {
                ship->setTemplate(ship_template_selector->getSelectionValue());
                ship->setRotation(random(0, 360));
                ship->target_rotation = ship->getRotation();
                ship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
                my_player_info->commandSetShipId(ship->getMultiplayerId());
            }
        }))->setPosition(0, 680, ATopCenter)->setSize(490, 50);

        // If this is the server, the "back" button goes to the scenario
        // selection/server creation screen.
        (new GuiButton(left_container, "DISCONNECT", "Scenario selection", [this]() {
            destroy();
            new ServerCreationScreen();
        }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);
    }else{
        // If this is a client, the "back" button disconnects from the server
        // and returns to the main menu.
        (new GuiButton(left_container, "DISCONNECT", "Disconnect", [this]() {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);
    }

    // The "Ready" button.
    ready_button = new GuiButton(right_container, "READY_BUTTON", "Ready", [this]() {
        this->onReadyClick();
    });
    ready_button->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Set the crew type selector's default to 6/5 person crew screens.
    crew_type_selector->setSelectionIndex(0);
    updateCrewTypeOptions();

    // Control code entry dialog.
    password_overlay = new GuiOverlay(this, "PASSWORD_OVERLAY", sf::Color::Black - sf::Color(0, 0, 0, 192));
    password_overlay->hide();
    password_entry_box = new GuiPanel(password_overlay, "PASSWORD_ENTRY_BOX");
    password_entry_box->setPosition(0, 350, ATopCenter)->setSize(600, 200);
    password_label = new GuiLabel(password_entry_box, "PASSWORD_LABEL", "Enter this ship's control code:", 30);
    password_label->setPosition(0, 40, ATopCenter);
    password_entry = new GuiTextEntry(password_entry_box, "PASSWORD_ENTRY", "");
    password_entry->setPosition(20, 0, ACenterLeft)->setSize(400, 50);
    password_cancel = new GuiButton(password_entry_box, "PASSWORD_CANCEL_BUTTON", "Cancel", [this]() {
        // Reset the dialog.
        password_label->setText("Enter this ship's control code:");
        password_entry->setText("");
        // Hide the password overlay and show the ship selection screen.
        password_overlay->hide();
        left_container->show();
        right_container->show();
        // Unselect player ship if cancelling.
        player_ship_list->setSelectionIndex(-1);
        my_player_info->commandSetShipId(-1);
        // Unselect GM station if cancelling.
        spectator_button->setValue(false);
    });
    password_cancel->setPosition(0, -20, ABottomCenter)->setSize(300, 50);

    // Control code entry button.
    password_entry_ok = new GuiButton(password_entry_box, "PASSWORD_ENTRY_OK", "Ok", [this]()
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(player_ship_list->getEntryValue(player_ship_list->getSelectionIndex()).toInt());

        // Get the password.
        string password = password_entry->getText().upper();

        if (spectator_button->getValue() == true) {
            if (password != gameGlobalInfo->gm_control_code)
            {
                LOG(INFO) << "Password doesn't match GM control code. Attempt: " << password;
                password_label->setText("Incorrect control code. Re-enter GM code:");
                password_entry->setText("");
            } else {
                // Password matches.
                LOG(INFO) << "Password matches GM control code.";
                // Notify the player.
                password_label->setText("Control code accepted.\nGranting access.");
                // Reset and hide the password field.
                password_entry->setText("");
                password_entry->hide();
                password_cancel->hide();
                password_entry_ok->hide();
                // Show a confirmation button.
                password_confirmation->show();
            }
        } else if (ship) {
            string control_code = ship->control_code;
            password_label->setText("Enter this ship's control code:");

            if (password != control_code)
            {
                // Password doesn't match. Unset the player ship selection.
                LOG(INFO) << "Password doesn't match control code. Attempt: " << password;
                my_player_info->commandSetShipId(-1);
                // Notify the player.
                password_label->setText("Incorrect control code. Re-enter code for " + ship->getCallSign() + ":");
                // Reset the dialog.
                password_entry->setText("");
            } else {
                // Password matches.
                LOG(INFO) << "Password matches control code.";
                // Set the player ship.
                my_player_info->commandSetShipId(ship->getMultiplayerId());
                // Notify the player.
                password_label->setText("Control code accepted.\nGranting access to " + ship->getCallSign() + ".");
                // Reset and hide the password field.
                password_entry->setText("");
                password_entry->hide();
                password_cancel->hide();
                password_entry_ok->hide();
                // Show a confirmation button.
                password_confirmation->show();
            }
        }
    });
    password_entry_ok->setPosition(420, 0, ACenterLeft)->setSize(160, 50);

    // Control code confirmation button
    password_confirmation = new GuiButton(password_entry_box, "PASSWORD_CONFIRMATION_BUTTON", "OK", [this]() {
        // Reset the dialog.
        password_entry->show();
        password_cancel->show();
        password_entry_ok->show();
        password_label->setText("Enter this ship's control code:")->setPosition(0, 40, ATopCenter);
        password_confirmation->hide();
        // Hide the dialog.
        password_overlay->hide();
        // Show the UI.
        left_container->show();
        right_container->show();
    });
    password_confirmation->setPosition(0, -20, ABottomCenter)->setSize(250, 50)->hide();
}

void ShipSelectionScreen::update(float delta)
{
    // If this is a client and is disconnected from the server, destroy the
    // screen and return to the main menu.
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }
    
    // Update the player ship list with all player ships.
    for(int n = 0; n < GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            string ship_name = ship->getFaction() + " " + ship->getTypeName() + " " + ship->getCallSign();

            int index = player_ship_list->indexByValue(string(n));
            // If a player ship isn't in already in the list, add it.
            if (index == -1)
            {
                index = player_ship_list->addEntry(ship_name, string(n));
                if (my_spaceship == ship)
                    player_ship_list->setSelectionIndex(index);
            }

            // If the ship is crewed, count how many positions are filled.
            int ship_position_count = 0;
            for (int n = 0; n < max_crew_positions; n++)
            {
                if (ship->hasPlayerAtPosition(ECrewPosition(n)))
                    ship_position_count += 1;
            }
            player_ship_list->setEntryName(index, ship_name + " (" + string(ship_position_count) + ")");
        }else{
            if (player_ship_list->indexByValue(string(n)) != -1)
                player_ship_list->removeEntry(player_ship_list->indexByValue(string(n)));
        }
    }
    // If a position already has a player on the currently selected player ship,
    // indicate that on the button.
    for(int n = 0; n < max_crew_positions; n++)
    {
        string button_text = getCrewPositionName(ECrewPosition(n));
        if (my_spaceship)
        {
            std::vector<string> players;
            foreach(PlayerInfo, i, player_info_list)
            {
                if (i->ship_id == my_spaceship->getMultiplayerId() && i->crew_position[n])
                {
                    players.push_back(i->name);
                }
            }
            std::sort(players.begin(), players.end());
            players.resize(std::distance(players.begin(), std::unique(players.begin(), players.end())));

            if (players.size() > 0)
            {
                crew_position_button[n]->setText(button_text + " (" + string(", ").join(players) + ")");
            } else {
                crew_position_button[n]->setText(button_text);
            }
        }
    }

    // If there aren't any player ships, show a label stating so.
    if (player_ship_list->entryCount() > 0)
    {
        no_ships_label->hide();
    }else{
        no_ships_label->show();
    }

    // Update the Ready button's state, which might have changed based on the
    // presence or absence of player ships.
    updateReadyButton();

    //Sync our configured user name with the server
    if (my_player_info->name != PreferencesManager::get("username"))
        my_player_info->commandSetName(PreferencesManager::get("username"));
}

void ShipSelectionScreen::updateReadyButton()
{
    // Update the Ready button based on crew position button states.
    // If the player is capable of displaying the main screen...
    if (my_player_info->isOnlyMainScreen())
    {
        // If the main screen button is both available and selected and a
        // player ship is also selected, and the player isn't being asked for a
        // command code, enable the Ready button.
        if (my_spaceship && main_screen_button->isVisible() && main_screen_button->getValue())
            ready_button->enable();
        // If the GM or spectator buttons are enabled, enable the Ready button.
        // TODO: Allow GM or spectator screens to require a control code.
        else if (game_master_button->getValue() || topdown_button->getValue() || cinematic_view_button->getValue() || spectator_button->getValue())
            ready_button->enable();
        // If a player ship and the window view are selected, enable the Ready
        // button.
        else if (my_spaceship && window_button->getValue())
            ready_button->enable();
        // Otherwise, disable the Ready button.
        else
            ready_button->disable();
    // If the player can't display the main screen...
    }else{
        // If a player ship is selected and the player isn't being asked for a
        // control code, enable the Ready button. Otherwise, disable it.
        if (my_spaceship)
            ready_button->enable();
        else
            ready_button->disable();
    }
}

void ShipSelectionScreen::updateCrewTypeOptions()
{
    // Hide and unselect alternative and view screens.
    game_master_button->hide();
    window_button->hide();
    window_angle->hide();
    topdown_button->hide();
    cinematic_view_button->hide();
    spectator_button->hide();
    main_screen_button->setVisible(canDoMainScreen());
    main_screen_button->setValue(my_player_info->main_screen);
    main_screen_controls_button->setVisible(crew_type_selector->getSelectionIndex() != 3);
    game_master_button->setValue(false);
    window_button->setValue(false);
    topdown_button->setValue(false);
    cinematic_view_button->setValue(false);
    spectator_button->setValue(false);

    // Hide and unselect each crew position button.
    for(int n = 0; n < max_crew_positions; n++)
    {
        crew_position_button[n]->setValue(false)->hide();
    }

    // Choose which set of screens to list from the crew type selector index.
    switch(crew_type_selector->getSelectionIndex())
    {
    case 0:
        for(int n = helmsOfficer; n <= relayOfficer; n++)
        {
            crew_position_button[n]->show();
        }
        break;
    case 1:
        for(int n = tacticalOfficer; n <= operationsOfficer; n++)
            crew_position_button[n]->show();
        break;
    case 2:
        crew_position_button[singlePilot]->show();
        crew_position_button[damageControl]->show();
        crew_position_button[powerManagement]->show();
        crew_position_button[databaseView]->show();
        crew_position_button[altRelay]->show();
        crew_position_button[commsOnly]->show();
        crew_position_button[shipLog]->show();
        break;
    case 3:
        main_screen_button->hide();
        game_master_button->setVisible(bool(game_server));
        window_button->setVisible(canDoMainScreen());
        window_angle->setVisible(canDoMainScreen());
        topdown_button->setVisible(canDoMainScreen());
        cinematic_view_button->setVisible(canDoMainScreen());
        spectator_button->setVisible(true);
        break;
    }

    // For each crew position, unselect the position if the button is hidden
    // and select the button if the current player has already selected that
    // position.
    for(int n = 0; n < max_crew_positions; n++)
    {
        if (!crew_position_button[n]->isVisible())
            my_player_info->commandSetCrewPosition(ECrewPosition(n), false);
        else
            crew_position_button[n]->setValue(my_player_info->crew_position[n]);
    }

    // Update the state of the Ready button, because position changes can
    // affect player readiness.
    updateReadyButton();
}

void ShipSelectionScreen::onReadyClick()
{
    // When the Ready button is clicked, destroy the ship selection screen and
    // create the position's screen. If selecting a non-player screen, set the
    // ship ID to -1 (no ship).
    if (game_master_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new GameMasterScreen();
    }else if (window_button->getValue())
    {
        destroy();
        uint8_t window_flags = PreferencesManager::get("ship_window_flags","1").toInt();
        new WindowScreen(int(window_angle->getValue()), window_flags);
    }else if(topdown_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new TopDownScreen();
    }else if(cinematic_view_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new CinematicViewScreen();
    }else if(spectator_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new SpectatorScreen();
    }else{
        destroy();
        my_player_info->spawnUI();
    }
}

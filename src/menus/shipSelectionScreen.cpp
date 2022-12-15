#include "shipSelectionScreen.h"

#include "featureDefs.h"
#include "glObjects.h"
#include "soundManager.h"
#include "random.h"
#include "multiplayer_client.h"

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

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_togglebutton.h"
#include "preferenceManager.h"

class PasswordDialog : public GuiOverlay
{
public:
    PasswordDialog(GuiContainer* parent, string id)
    : GuiOverlay(parent, id, glm::u8vec4(0,0,0,64))
    {
        hide();

        auto entry_box = new GuiPanel(this, "PASSWORD_ENTRY_BOX");
        entry_box->setPosition(0, 350, sp::Alignment::TopCenter)->setSize(600, 200);
        label = new GuiLabel(entry_box, "PASSWORD_LABEL", tr("Enter this ship's control code:"), 30);
        label->setPosition(0, 40, sp::Alignment::TopCenter);
        entry = new GuiTextEntry(entry_box, "PASSWORD_ENTRY", "");
        entry->setPosition(20, 0, sp::Alignment::CenterLeft)->setSize(400, 50);
        cancel = new GuiButton(entry_box, "PASSWORD_CANCEL_BUTTON", tr("button", "Cancel"), [this]() {
            // Reset the dialog.
            entry->setText("");
            // Hide the password overlay and show the ship selection screen.
            hide();
            on_cancel();
        });
        cancel->setPosition(0, -20, sp::Alignment::BottomCenter)->setSize(300, 50);

        entry_ok = new GuiButton(entry_box, "PASSWORD_ENTRY_OK", tr("Ok"), [this]()
        {
            string password = entry->getText().upper();
            if (this->on_password_check(password))
            {
                // Notify the player.
                label->setText(tr("Control code accepted.\nGranting access."));
                // Reset and hide the password field.
                entry->setText("");
                entry->hide();
                cancel->hide();
                entry_ok->hide();
                // Show a confirmation button.
                confirmation->show();
            } else {
                label->setText(tr("Incorrect control code. Re-enter code:"));
                entry->setText("");
            }
        });
        entry_ok->setPosition(420, 0, sp::Alignment::CenterLeft)->setSize(160, 50);

        // Control code confirmation button
        confirmation = new GuiButton(entry_box, "PASSWORD_CONFIRMATION_BUTTON", tr("OK"), [this]() {
            // Hide the dialog.
            hide();
            on_ready();
        });
        confirmation->setPosition(0, -20, sp::Alignment::BottomCenter)->setSize(250, 50)->hide();
    }

    void open(string label, std::function<bool(string)> on_password_check, std::function<void()> on_ready, std::function<void()> on_cancel)
    {
        this->label->setText(label);
        this->on_password_check = on_password_check;
        this->on_ready = on_ready;
        this->on_cancel = on_cancel;

        entry->show();
        cancel->show();
        entry_ok->show();
        confirmation->hide();
        show();
    }
private:
    std::function<bool(string)> on_password_check;
    std::function<void()> on_ready;
    std::function<void()> on_cancel;

    GuiLabel* label;
    GuiTextEntry* entry;
    GuiButton* cancel;
    GuiButton* entry_ok;
    GuiButton* confirmation;
};

ShipSelectionScreen::ShipSelectionScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Easiest place to ensure that positional sound is disabled on console
    // views. As soon as a 3D view is rendered, positional sound is re-enabled.
    soundManager->disablePositionalSound();

    // Draw a container with two columns.
    container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");
    left_container = new GuiElement(container, "");
    left_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    right_container = new GuiElement(container, "");
    right_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    auto right_panel = new GuiPanel(right_container, "DIRECT_OPTIONS_PANEL");
    right_panel->setPosition(0, 50, sp::Alignment::TopCenter)->setSize(550, 560);
    auto right_content = new GuiElement(right_panel, "");
    right_content->setMargins(50)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    // Game master button
    if (game_server) {
        auto game_master_button = new GuiButton(right_content, "GAME_MASTER_BUTTON", tr("Game master"), [this]() {
            if (gameGlobalInfo->gm_control_code.length() > 0)
            {
                LOG(INFO) << "Player selected gm mode, which has a control code.";
                password_dialog->open(tr("Enter the GM control code:"), [this](string code) {
                    return code == gameGlobalInfo->gm_control_code;
                }, [this](){
                    my_player_info->commandSetShipId(-1);
                    destroy();
                    new GameMasterScreen(getRenderLayer());
                }, [this](){
                    left_container->show();
                    right_container->show();
                });
                left_container->hide();
                right_container->hide();
            } else {
                my_player_info->commandSetShipId(-1);
                destroy();
                new GameMasterScreen(getRenderLayer());
            }
        });
        game_master_button->setSize(GuiElement::GuiSizeMax, 50);
    }

    // Spectator view button
    auto spectator_button = new GuiButton(right_content, "SPECTATOR_BUTTON", tr("Spectate (view all)"), [this]() {
        if (gameGlobalInfo->gm_control_code.length() > 0)
        {
            LOG(INFO) << "Player selected Spectate mode, which has a control code.";
            password_dialog->open(tr("Enter the GM control code:"), [this](string code) {
                return code == gameGlobalInfo->gm_control_code;
            }, [this](){
                my_player_info->commandSetShipId(-1);
                destroy();
                new SpectatorScreen(getRenderLayer());
            }, [this](){
                left_container->show();
                right_container->show();
            });
            left_container->hide();
            right_container->hide();
        } else {
            my_player_info->commandSetShipId(-1);
            destroy();
            new SpectatorScreen(getRenderLayer());
        }
    });
    spectator_button->setSize(GuiElement::GuiSizeMax, 50);

    // Spectator view button
    auto cinematic_button = new GuiButton(right_content, "", tr("Cinematic"), [this]() {
        my_player_info->commandSetShipId(-1);
        destroy();
        new CinematicViewScreen(getRenderLayer());
    });
    cinematic_button->setSize(GuiElement::GuiSizeMax, 50);

    if (game_server)
    {
        auto extra_settings_panel = new GuiPanel(this, "");
        extra_settings_panel->setSize(600, 325)->setPosition(0, 0, sp::Alignment::Center)->hide();
        auto extra_settings = new GuiElement(extra_settings_panel, "");
        extra_settings->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(25)->setAttribute("layout", "vertical");
        // Science scan complexity selector.
        auto row = new GuiElement(extra_settings, "");
        row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
        (new GuiLabel(row, "GAME_SCANNING_COMPLEXITY_LABEL", tr("Scan complexity: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
        (new GuiSelector(row, "GAME_SCANNING_COMPLEXITY", [](int index, string value) {
            gameGlobalInfo->scanning_complexity = EScanningComplexity(index);
        }))->setOptions({tr("scanning", "None (delay)"), tr("scanning", "Simple"), tr("scanning", "Normal"), tr("scanning", "Advanced")})->setSelectionIndex((int)gameGlobalInfo->scanning_complexity)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        // Hacking difficulty selector.
        row = new GuiElement(extra_settings, "");
        row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
        (new GuiLabel(row, "GAME_HACKING_DIFFICULTY_LABEL", tr("Hacking difficulty: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
        (new GuiSelector(row, "GAME_HACKING_DIFFICULTY", [](int index, string value) {
            gameGlobalInfo->hacking_difficulty = index;
        }))->setOptions({tr("hacking", "Simple"), tr("hacking", "Normal"), tr("hacking", "Difficult"), tr("hacking", "Fiendish")})->setSelectionIndex(gameGlobalInfo->hacking_difficulty)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        // Hacking games selector.
        row = new GuiElement(extra_settings, "");
        row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
        (new GuiLabel(row, "GAME_HACKING_GAMES_LABEL", tr("Hacking type: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
        (new GuiSelector(row, "GAME_HACKING_GAME", [](int index, string value) {
            gameGlobalInfo->hacking_games = EHackingGames(index);
        }))->setOptions({tr("hacking", "Mine"), tr("hacking", "Lights"), tr("hacking", "All")})->setSelectionIndex((int)gameGlobalInfo->hacking_games)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        // Frequency and system damage row.
        row = new GuiElement(extra_settings, "");
        row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
        (new GuiToggleButton(row, "GAME_FREQUENCIES_TOGGLE", tr("Beam/shield frequencies"), [](bool value) {
            gameGlobalInfo->use_beam_shield_frequencies = value == 1;
        }))->setValue(gameGlobalInfo->use_beam_shield_frequencies)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::CenterLeft);

        (new GuiToggleButton(row, "GAME_SYS_DAMAGE_TOGGLE", tr("Per-system damage"), [](bool value) {
            gameGlobalInfo->use_system_damage = value == 1;
        }))->setValue(gameGlobalInfo->use_system_damage)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::CenterRight);

        auto close_button = new GuiButton(extra_settings_panel, "", tr("Close"), [this, extra_settings_panel](){
            extra_settings_panel->hide();
            container->show();
        });
        close_button->setSize(200, 50)->setPosition(0, -25, sp::Alignment::BottomCenter);

        //Additional options
        auto extra_settings_button = new GuiButton(right_content, "", tr("Extra settings"), [this, extra_settings_panel]() {
            extra_settings_panel->show();
            container->hide();
        });
        extra_settings_button->setSize(GuiElement::GuiSizeMax, 50);
    }

    // If this is the server, add a panel to create player ships.
    if (game_server && gameGlobalInfo->allow_new_player_ships)
    {
        (new GuiPanel(left_container, "CREATE_SHIP_BOX"))->setPosition(0, 50, sp::Alignment::TopCenter)->setSize(550, 700);
    }

    // Player ship selection panel
    (new GuiPanel(left_container, "SHIP_SELECTION_BOX"))->setPosition(0, 50, sp::Alignment::TopCenter)->setSize(550, 560);
    (new GuiLabel(left_container, "SHIP_SELECTION_LABEL", tr("Select ship"), 30))->addBackground()->setPosition(0, 50, sp::Alignment::TopCenter)->setSize(510, 50);
    no_ships_label = new GuiLabel(left_container, "SHIP_SELECTION_NO_SHIPS_LABEL", tr("Waiting for server to spawn a ship"), 30);
    no_ships_label->setPosition(0, 100, sp::Alignment::TopCenter)->setSize(460, 50);

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
                password_dialog->open(tr("Enter this ship's control code:"), [this, ship](string code) {
                    return ship && ship->control_code == code;
                }, [this, ship](){
                    my_player_info->commandSetShipId(ship->getMultiplayerId());
                    crew_position_selection_overlay->show();
                    left_container->show();
                    right_container->show();
                }, [this](){
                    left_container->show();
                    right_container->show();
                });
            }
            // Otherwise, select and set this ship ID in the player info.
            else
            {
                my_player_info->commandSetShipId(ship->getMultiplayerId());
                crew_position_selection_overlay->show();
            }
        // If the selected item isn't a ship, reset the ship ID in player info.
        }else{
            my_player_info->commandSetShipId(-1);
        }
    });
    player_ship_list->setPosition(0, 100, sp::Alignment::TopCenter)->setSize(490, 500);

    // If this is the server, add buttons and a selector to create player ships.
    if (game_server && gameGlobalInfo->allow_new_player_ships)
    {
        GuiSelector* ship_template_selector = new GuiSelector(left_container, "CREATE_SHIP_SELECTOR", nullptr);
        // List only ships with templates designated for player use.
        std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::PlayerShip);
        std::sort(template_names.begin(), template_names.end());

        for(string& template_name : template_names)
        {
            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
            if (!ship_template->visible)
                continue;
            ship_template_selector->addEntry(template_name + " (" + ship_template->getClass() + ":" + ship_template->getSubClass() + ")", template_name);
        }
        ship_template_selector->setSelectionIndex(0);
        ship_template_selector->setPosition(0, 630, sp::Alignment::TopCenter)->setSize(490, 50);

        // Spawn a ship of the selected template near 0,0 and give it a random
        // heading.
        (new GuiButton(left_container, "CREATE_SHIP_BUTTON", tr("Spawn player ship"), [ship_template_selector]() {
            if (!gameGlobalInfo->allow_new_player_ships)
                return;
            P<PlayerSpaceship> ship = new PlayerSpaceship();

            if (ship)
            {
                // set the position before the template so that onNewPlayerShip has as much data as possible
                ship->setRotation(random(0, 360));
                ship->setPosition(glm::vec2(random(-100, 100), random(-100, 100)));
                ship->setTemplate(ship_template_selector->getSelectionValue());
                my_player_info->commandSetShipId(ship->getMultiplayerId());
            }
        }))->setPosition(0, 680, sp::Alignment::TopCenter)->setSize(490, 50);
    }

    if (game_server)
    {
        // If this is the server, the "back" button goes to the scenario
        // selection/server creation screen.
        (new GuiButton(left_container, "DISCONNECT", tr("Scenario selection"), [this]() {
            destroy();
            new ServerScenarioSelectionScreen();
        }))->setPosition(0, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
    }else{
        // If this is a client, the "back" button disconnects from the server
        // and returns to the main menu.
        (new GuiButton(left_container, "DISCONNECT", tr("Disconnect"), [this]() {
            destroy();
            disconnectFromServer();
            returnToMainMenu(getRenderLayer());
        }))->setPosition(0, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
    }

    // Control code entry dialog.
    password_dialog = new PasswordDialog(this, "PASSWORD_DIALOG");

    crew_position_selection_overlay = new GuiOverlay(this, "", glm::u8vec4(0,0,0,64));
    crew_position_selection_overlay->hide();
    crew_position_selection = new CrewPositionSelection(crew_position_selection_overlay, "", 0, [this](){
        crew_position_selection_overlay->hide();
        my_player_info->commandSetShipId(-1);
    }, [this](){
        crew_position_selection->spawnUI(getRenderLayer());
        destroy();
    });
}

void ShipSelectionScreen::update(float delta)
{
    // If this is a client and is disconnected from the server, destroy the
    // screen and return to the main menu.
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
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

    // If there aren't any player ships, show a label stating so.
    if (player_ship_list->entryCount() > 0)
    {
        no_ships_label->hide();
    }else{
        no_ships_label->show();
    }

    //Sync our configured user name with the server
    if (my_player_info->name != PreferencesManager::get("username"))
        my_player_info->commandSetName(PreferencesManager::get("username"));
}

CrewPositionSelection::CrewPositionSelection(GuiContainer* owner, string id, int _window_index, std::function<void()> on_cancel, std::function<void()> on_ready)
: GuiPanel(owner, id), window_index(_window_index)
{
    setSize(GuiElement::GuiSizeMax, 800);
    setPosition(0, 0, sp::Alignment::Center);
    setMargins(50);

    auto container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");

    auto one = new GuiPanel(container, "");
    one->setMargins(50, 50, 25, 100)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(one, "CREW_POSITION_SELECT_LABEL", tr("6/5 player crew"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setMargins(15, 0);
    auto layout = new GuiElement(one, "");
    layout->setMargins(25, 50)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    main_screen_button = new GuiToggleButton(layout, "", tr("Main screen"), [this](bool value) {
        my_player_info->commandSetMainScreen(window_index, value);
        unselectSingleOptions();
    });
    main_screen_button->setValue(my_player_info->main_screen & (1 << window_index));
    main_screen_button->setSize(GuiElement::GuiSizeMax, 50);
    auto create_crew_position_button = [this](GuiElement* layout, int n) {
        auto button = new GuiToggleButton(layout, "", getCrewPositionName(ECrewPosition(n)), [this, n](bool value){
            my_player_info->commandSetCrewPosition(window_index, ECrewPosition(n), value);
            unselectSingleOptions();
        });
        button->setSize(GuiElement::GuiSizeMax, 50);
        button->setIcon(getCrewPositionIcon(ECrewPosition(n)));
        button->setValue(my_player_info->crew_position[n] & (1 << window_index));
        crew_position_button[n] = button;
        return button;
    };
    for(int n=0; n<=int(relayOfficer); n++)
        create_crew_position_button(layout, n);

    auto two = new GuiPanel(container, "");
    two->setMargins(25, 50, 25, 100)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);;
    (new GuiLabel(two, "CREW_POSITION_SELECT_LABEL", tr("4/3/1 player crew"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setMargins(15, 0);
    layout = new GuiElement(two, "");
    layout->setMargins(25, 50)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    for(int n=int(tacticalOfficer); n<=int(singlePilot); n++)
        create_crew_position_button(layout, n);

    auto three = new GuiPanel(container, "");
    three->setMargins(25, 50, 50, 100)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);;
    (new GuiLabel(three, "CREW_POSITION_SELECT_LABEL", tr("Alternative options"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setMargins(15, 0);
    layout = new GuiElement(three, "");
    layout->setMargins(25, 50)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    for(int n=int(singlePilot) + 1; n<int(max_crew_positions); n++)
        create_crew_position_button(layout, n);

    // Main screen controls button
    main_screen_controls_button = new GuiToggleButton(layout, "MAIN_SCREEN_CONTROLS_ENABLE", tr("Main screen controls"), [this](bool value) {
        my_player_info->commandSetMainScreenControl(window_index, value);
    });
    main_screen_controls_button->setValue(my_player_info->main_screen_control)->setSize(GuiElement::GuiSizeMax, 50);

    // Window
    auto window_button_row = new GuiElement(layout, "");
    window_button_row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    window_button = new GuiToggleButton(window_button_row, "WINDOW_BUTTON", tr("Ship window"), [this](bool value) {
        disableAllExcept(window_button);
    });
    window_button->setSize(175, 50);

    window_angle = new GuiSlider(window_button_row, "WINDOW_ANGLE", 0.0, 359.0, 0.0, [this](float value) {
        window_angle_label->setText(string("{angle}°").format({{"angle", string(int(window_angle->getValue()))}}));
    });
    window_angle->setSize(GuiElement::GuiSizeMax, 50);
    window_angle_label = new GuiLabel(window_angle, "WINDOW_ANGLE_LABEL", "0°", 30);
    window_angle_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Top-down view button
    topdown_button = new GuiToggleButton(layout, "TOP_DOWN_3D_BUTTON", tr("Top-down 3D view"), [this](bool value) {
        disableAllExcept(topdown_button);
    });
    topdown_button->setSize(GuiElement::GuiSizeMax, 50);

    if (on_cancel) {
        auto cancel_button = new GuiButton(this, "CANCEL", tr("button", "Cancel"), on_cancel);
        cancel_button->setSize(300, 50)->setPosition(100, -25, sp::Alignment::BottomLeft);
    }

    ready_button = new GuiButton(this, "READY", tr("button", "Ready"), on_ready);
    ready_button->setSize(300, 50)->setPosition(-100, -25, sp::Alignment::BottomRight);
}

void CrewPositionSelection::onUpdate()
{
    bool any_selected = main_screen_button->getValue() || window_button->getValue() || topdown_button->getValue();
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
            any_selected = any_selected || crew_position_button[n]->getValue();
        }
    }

    ready_button->setEnable(any_selected);
}

void CrewPositionSelection::disableAllExcept(GuiToggleButton* button)
{
    for(int n = 0; n < max_crew_positions; n++)
    {
        if (crew_position_button[n] != button)
        {
            crew_position_button[n]->setValue(false);
            my_player_info->commandSetCrewPosition(window_index, ECrewPosition(n), false);
        }
    }
    if (main_screen_button != button)
    {
        main_screen_button->setValue(false);
        my_player_info->commandSetMainScreen(window_index, false);
    }
    if (main_screen_controls_button != button)
        main_screen_controls_button->setValue(false);
    if (window_button != button)
        window_button->setValue(false);
    if (topdown_button != button)
        topdown_button->setValue(false);
}

void CrewPositionSelection::unselectSingleOptions()
{
    window_button->setValue(false);
    topdown_button->setValue(false);
}

void CrewPositionSelection::spawnUI(RenderLayer* render_layer)
{
    // When the Ready button is clicked, destroy the ship selection screen and
    // create the position's screen. If selecting a non-player screen, set the
    // ship ID to -1 (no ship).
    if (window_button->getValue())
    {
        destroy();
        uint8_t window_flags = PreferencesManager::get("ship_window_flags", "1").toInt();
        new WindowScreen(render_layer, int(window_angle->getValue()), window_flags);
    }else if(topdown_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new TopDownScreen(render_layer);
    }else{
        destroy();
        my_player_info->spawnUI(window_index, render_layer);
    }
}

SecondMonitorScreen::SecondMonitorScreen(int monitor_index)
: GuiCanvas(window_render_layers[monitor_index]), monitor_index(monitor_index)
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");
}

void SecondMonitorScreen::update(float delta)
{
    if (!crew_position_selection && my_player_info && my_spaceship) {
        crew_position_selection = new CrewPositionSelection(this, "", monitor_index, nullptr, [this](){
            crew_position_selection->spawnUI(getRenderLayer());
            destroy();
        });
    }
    if (crew_position_selection && (!my_player_info || !my_spaceship)) {
        crew_position_selection->destroy();
        crew_position_selection = nullptr;
    }
}

#include "shipSelectionScreen.h"

#include "featureDefs.h"
#include "glObjects.h"
#include "soundManager.h"
#include "random.h"
#include "multiplayer_client.h"
#include "ecs/query.h"
#include "i18n.h"

#include "components/name.h"

#include "serverCreationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "scenarioInfo.h"
#include "screens/windowScreen.h"
#include "screens/topDownScreen.h"
#include "screens/cinematicViewScreen.h"
#include "screens/spectatorScreen.h"
#include "screens/gm/gameMasterScreen.h"
#include "components/database.h"
#include "menus/luaConsole.h"
#include "menus/optionsMenu.h"

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
        entry->setHidePassword();
        entry->enterCallback([this](string text) {
            if (confirmation->isVisible())
            {
                hide();
                on_ready();
            }
            if (text != "")
            {
                checkPassword();
            }
        });
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
            checkPassword();
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

    void open(string label, string preset_password, std::function<bool(string)> on_password_check, std::function<void()> on_ready, std::function<void()> on_cancel)
    {
        this->label->setText(label);
        this->on_password_check = on_password_check;
        this->on_ready = on_ready;
        this->on_cancel = on_cancel;

        entry->setText(preset_password);
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

    void checkPassword() {
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
    }

    GuiLabel* label;
    GuiButton* cancel;
    GuiButton* entry_ok;
    GuiButton* confirmation;

public:
    GuiTextEntry* entry;
};

ShipSelectionScreen::ShipSelectionScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Easiest place to ensure that positional sound is disabled on console
    // views. As soon as a 3D view is rendered, positional sound is re-enabled.
    soundManager->disablePositionalSound();

    // Draw a container with two columns.
    const int column_width = 550;
    container = new GuiElement(this, "MAIN_CONTAINER");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    container->setAttribute("layout", "horizontal");
    container->setAttribute("padding", "50");

    left_container = new GuiElement(container, "LEFT_CONTAINER");
    left_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    left_container->setAttribute("padding", "0, 10, 0, 0");
    left_column = new GuiElement(left_container, "LEFT_COLUMN");
    left_column->setSize(column_width, GuiElement::GuiSizeMax);
    left_column->setAttribute("layout", "vertical");
    left_column->setAttribute("alignment", "topright");

    right_container = new GuiElement(container, "RIGHT_CONTAINER");
    right_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    right_container->setAttribute("padding", "10, 0, 0, 0");
    right_column = new GuiElement(right_container, "RIGHT_COLUMN");
    right_column->setSize(column_width, GuiElement::GuiSizeMax);
    right_column->setAttribute("layout", "vertical");
    right_column->setAttribute("alignment", "topleft");

    // Right column
    right_panel = new GuiPanel(right_column, "DIRECT_OPTIONS_PANEL");
    right_panel->setAttribute("layout", "vertical");
    right_panel->setAttribute("padding", "20, 0");
    right_panel->setAttribute("margin", "0, 0, 0, 20");

    (new GuiLabel(right_panel, "DIRECT_OPTIONS_LABEL", tr("Additional views and options"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");
    // Game master button
    if (game_server) {
        auto game_master_button = new GuiButton(right_panel, "GAME_MASTER_BUTTON", tr("Game master"), [this]() {
            if (gameGlobalInfo->gm_control_code.length() > 0)
            {
                LOG(INFO) << "Player selected gm mode, which has a control code.";
                focus(password_dialog->entry);
                password_dialog->open(tr("Enter the GM control code:"), "", [this](string code) {
                    return code == gameGlobalInfo->gm_control_code;
                }, [this](){
                    my_player_info->commandSetShip({});
                    destroy();
                    new GameMasterScreen(getRenderLayer());
                }, [this](){
                    left_container->show();
                    right_container->show();
                });
                left_container->hide();
                right_container->hide();
            } else {
                my_player_info->commandSetShip({});
                destroy();
                new GameMasterScreen(getRenderLayer());
            }
        });
        game_master_button->setSize(GuiElement::GuiSizeMax, 50);
    }

    // Spectator view button
    auto spectator_button = new GuiButton(right_panel, "SPECTATOR_BUTTON", tr("Spectate (view all)"), [this]() {
        if (gameGlobalInfo->gm_control_code.length() > 0)
        {
            LOG(INFO) << "Player selected Spectate mode, which has a control code.";
            focus(password_dialog->entry);
            password_dialog->open(tr("Enter the GM control code:"), "", [this](string code) {
                return code == gameGlobalInfo->gm_control_code;
            }, [this](){
                my_player_info->commandSetShip({});
                destroy();
                new SpectatorScreen(getRenderLayer());
            }, [this](){
                left_container->show();
                right_container->show();
            });
            left_container->hide();
            right_container->hide();
        } else {
            my_player_info->commandSetShip({});
            destroy();
            new SpectatorScreen(getRenderLayer());
        }
    });
    spectator_button->setSize(GuiElement::GuiSizeMax, 50);

    // Spectator view button
    auto cinematic_button = new GuiButton(right_panel, "", tr("Cinematic view"), [this]() {
        my_player_info->commandSetShip({});
        destroy();
        new CinematicViewScreen(getRenderLayer());
    });
    cinematic_button->setSize(GuiElement::GuiSizeMax, 50);

    (new GuiButton(right_panel, "OPEN_OPTIONS", tr("mainMenu", "Options"), [this]() {
        new OptionsMenu(OptionsMenu::ReturnTo::OR_ShipSelection);
        this->destroy();
    }))->setSize(GuiElement::GuiSizeMax, 50);

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
        auto extra_settings_button = new GuiButton(right_panel, "", tr("Extra settings"), [this, extra_settings_panel]() {
            extra_settings_panel->show();
            container->hide();
        });
        extra_settings_button->setSize(GuiElement::GuiSizeMax, 50);
    }

    right_panel->setSize(GuiElement::GuiSizeMax, 30 + right_panel->children.size() * 50);

    right_panel_2 = new GuiPanel(right_column, "RIGHT_PANEL_2");
    right_panel_2->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    right_panel_2->setAttribute("layout", "vertical");
    right_panel_2->setAttribute("padding", "20, 20, 0, 20");
    right_panel_2_label = new GuiLabel(right_panel_2, "RIGHT_PANEL_2_LABEL", tr("Connected players"), 30);
    right_panel_2_label->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");
    right_panel_2_text = new GuiScrollText(right_panel_2, "RIGHT_PANEL_2_TEXT", tr("No players connected"));
    right_panel_2_text->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Left column
    left_panel = new GuiPanel(left_column, "CREATE_SHIP_BOX");
    left_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    left_panel->setAttribute("layout", "vertical");
    left_panel->setAttribute("padding", "20, 20, 0, 20");
    left_panel->setAttribute("margin", "0, 0, 0, 20");

    left_panel_2 = new GuiPanel(left_column, "LEFT_PANEL_2");
    left_panel_2->setSize(GuiElement::GuiSizeMax, 430);
    left_panel_2->setAttribute("layout", "vertical");
    left_panel_2->setAttribute("padding", "20, 20, 0, 20");
    left_panel_2->setAttribute("margin", "0, 0, 0, 20");
    left_panel_2_label = new GuiLabel(left_panel_2, "LEFT_PANEL_2_LABEL", "", 30);
    left_panel_2_label->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");
    ship_action_row = new GuiElement(left_panel_2, "SHIP_SPAWN_ROW");
    ship_action_row->setSize(GuiElement::GuiSizeMax, 50)->hide();
    ship_action_row->setAttribute("layout", "horizontal");
    ship_action_row->setAttribute("margin", "0, 0, 0, 10");
    left_panel_2_text = new GuiScrollText(left_panel_2, "LEFT_PANEL_2_TEXT", tr("No information for the selected ship type"));
    left_panel_2_text->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // If this is the server, add buttons and a selector to create player ships.
    if (game_server)
    {
        left_panel_2_label->setText(tr("Create player ship"));

        // List only ships with templates designated for player use.
        ship_spawn_info = gameGlobalInfo->getSpawnablePlayerShips();
        if (ship_spawn_info.size() > 0)
        {
            ship_action_row->show();
            left_panel_2_label->setText(tr("Create player ship"));
            ship_template_selector = new GuiSelector(ship_action_row, "CREATE_SHIP_SELECTOR", [this](int index, string value)
            {
                if (index < int(ship_spawn_info.size()))
                    left_panel_2_text->setText(ship_spawn_info[index].description);
            });
            for (const auto& info : ship_spawn_info)
                ship_template_selector->addEntry(info.label, info.label);

            ship_template_selector->setSelectionIndex(0);
            ship_template_selector->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

            // Spawn a ship of the selected template near 0,0 and give it a random
            // heading.
            ship_template_button = new GuiButton(ship_action_row, "CREATE_SHIP_BUTTON", tr("Create"), [this]() {
                auto index = ship_template_selector->getSelectionIndex();
                if (index < int(ship_spawn_info.size()))
                {
                    auto res = ship_spawn_info[index].create_callback.call<sp::ecs::Entity>();
                    LuaConsole::checkResult(res);
                    if (res.isOk())
                    {
                        //TODO: Apply some player properties like faction/position.
                    }
                }
            });
            ship_template_button->setSize(150, GuiElement::GuiSizeMax);
            left_panel_2_text->setText(ship_spawn_info[0].description);
        }
        else
        {
            left_panel_2_text->setText(tr("No description provided"));
            for (const auto& info : ScenarioInfo::getScenarios())
            {
                if (info.name == gameGlobalInfo->scenario)
                {
                    left_panel_2_label->setText(info.name);
                    left_panel_2_text->setText(info.description);
                }
            }
        }
    }

    if (game_client)
    {
        left_panel_2_label->setText(tr("Player ship description"));
        left_panel_2_text->setText(tr("No player ship description available"));

        (new GuiButton(ship_action_row, "JOIN_SHIP_BUTTON", tr("Join ship"), [this]() {
            joinPlayerShip(player_ship_list->getSelectionValue());
        }))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }

    // Player ship selection panel
    (new GuiLabel(left_panel, "SHIP_SELECTION_LABEL", tr("Select ship"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");
    no_ships_label = new GuiLabel(left_panel, "SHIP_SELECTION_NO_SHIPS_LABEL", tr("Waiting for server to spawn a ship"), 30);
    no_ships_label->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Player ship list
    player_ship_list = new GuiListbox(left_panel, "PLAYER_SHIP_LIST", [this](int index, string value) {
        if (game_server || last_selection_index == index || player_ship_list->entryCount() == 1)
            joinPlayerShip(value);

        last_selection_index = index;
    });
    player_ship_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    auto disconnect_row = new GuiElement(left_column, "DISCONNECT_ROW");
    disconnect_row->setSize(GuiElement::GuiSizeMax, 50);

    if (game_server)
    {
        // If this is the server, the "back" button goes to the scenario
        // selection/server creation screen.
        (new GuiButton(disconnect_row, "DISCONNECT", tr("Scenario selection"), [this]() {
            destroy();
            new ServerScenarioSelectionScreen();
        }))->setSize(300, GuiElement::GuiSizeMax)->setAttribute("alignment", "bottomcenter");
    }
    else
    {
        // If this is a client, the "back" button disconnects from the server
        // and returns to the main menu.
        (new GuiButton(disconnect_row, "DISCONNECT", tr("Disconnect"), [this]() {
            destroy();
            disconnectFromServer();
            returnToMainMenu(getRenderLayer());
        }))->setSize(300, GuiElement::GuiSizeMax)->setAttribute("alignment", "bottomcenter");
    }

    // Control code entry dialog.
    password_dialog = new PasswordDialog(this, "PASSWORD_DIALOG");

    crew_position_selection_overlay = new GuiOverlay(this, "", glm::u8vec4(0,0,0,64));
    crew_position_selection_overlay->hide();
    crew_position_selection = new CrewPositionSelection(crew_position_selection_overlay, "", 0, [this](){
        crew_position_selection_overlay->hide();
        my_player_info->commandSetShip({});
    }, [this](){
        crew_position_selection->spawnUI(getRenderLayer());
        destroy();
    });
}

void ShipSelectionScreen::update(float delta)
{
    // If this is a client and is disconnected from the server, destroy the
    // screen and return to the main menu.
    if (game_client)
    {
        if (game_client->getStatus() == GameClient::Disconnected)
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu(getRenderLayer());
            return;
        }

        string ship_type_name = "";
        string result = tr("No player ship description available");
        left_panel_2_label->setText(tr("Player ship description"));

        if (player_ship_list->getSelectionIndex() >= 0)
        {
            left_panel_2->show();
            if (auto ship = sp::ecs::Entity::fromString(player_ship_list->getSelectionValue()))
            {
                if (auto tn = ship.getComponent<TypeName>())
                    ship_type_name = tn->type_name;
            }
        }
        else if (player_ship_list->entryCount() > 0)
        {
            player_ship_list->setSelectionIndex(0);
        }
        else
        {
            left_panel_2->hide();
        }

        if (ship_type_name != "")
        {
            left_panel_2_label->setText(tr("{type} description").format({{"type", ship_type_name}}));
            ship_action_row->show();
            for (auto [entity, database] : sp::ecs::Query<Database>())
            {
                if (database.name == ship_type_name)
                {
                    result = database.description;
                    continue;
                }
            }
        }

        left_panel_2_text->setText(result);
    }

    // Update the player ship list with all player ships.
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
    {
        string ship_name = Faction::getInfo(entity).locale_name;
        if (auto tn = entity.getComponent<TypeName>())
            ship_name += " " + tn->type_name;
        if (auto cs = entity.getComponent<CallSign>())
            ship_name += " " + cs->callsign;

        int index = player_ship_list->indexByValue(entity.toString());
        // If a player ship isn't in already in the list, add it.
        if (index == -1)
        {
            index = player_ship_list->addEntry(ship_name, entity.toString());
            if (my_spaceship == entity)
                player_ship_list->setSelectionIndex(index);
        }

        // If the ship is crewed, count how many positions are filled.
        int ship_position_count = 0;
        for (int n = 0; n < static_cast<int>(CrewPosition::MAX); n++)
        {
            if (PlayerInfo::hasPlayerAtPosition(entity, CrewPosition(n)))
                ship_position_count += 1;
        }

        player_ship_list->setEntryName(index, ship_name + " (" + string(ship_position_count) + ")");
    }

    // Clear player ships that no longer exist.
    for (int i = 0; i < player_ship_list->entryCount(); i++)
    {
        bool keeper = false;

        for (auto [entity, pc] : sp::ecs::Query<PlayerControl>())
            if (entity.toString() == player_ship_list->getEntryValue(i)) keeper = true;

        if (!keeper) player_ship_list->removeEntry(i);
    }

    // If there aren't any player ships, show a label stating so.
    no_ships_label->setVisible(!(player_ship_list->entryCount() > 0));
    player_ship_list->setVisible(player_ship_list->entryCount() > 0);

    // Sync our configured user name with the server
    if (my_player_info->name != PreferencesManager::get("username"))
        my_player_info->commandSetName(PreferencesManager::get("username"));

    // Update the list of connected players
    string player_list = "";

    for (auto player : player_info_list)
    {
        player_list += player->name;
        auto player_ship = player->ship;
        auto tn = player_ship.getComponent<TypeName>();
        auto cs = player_ship.getComponent<CallSign>();
        if ((player_ship) && (tn || cs))
        {
            player_list += " (";
            player_list += Faction::getInfo(player_ship).locale_name;
            if (tn) player_list += " " + tn->localized;
            if (tn && cs) player_list += " ";
            if (cs) player_list += cs->callsign;
            player_list += ")";
        }
        player_list += "\n";
    }

    right_panel_2_text->setText(player_list);
}

void ShipSelectionScreen::joinPlayerShip(string entity_string)
{
    auto ship = sp::ecs::Entity::fromString(entity_string);

    // If the selected item is a ship ...
    if (auto pc = ship.getComponent<PlayerControl>())
    {
        // ... and it has a control code, ask the player for it.
        if (pc->control_code.length() > 0)
        {
            LOG(INFO) << "Player selected " << (ship.getComponent<CallSign>() ? ship.getComponent<CallSign>()->callsign : string("[NO CALLSIGN]")) << ", which has a control code.";
            // Hide the ship selection UI temporarily to deter sneaky ship thieves.
            left_container->hide();
            right_container->hide();
            // Show the control code entry dialog.
            focus(password_dialog->entry);
            password_dialog->open(tr("Enter this ship's control code:"), my_player_info->last_ship_password, [this, ship, pc](string code) {
                return ship && pc->control_code == code;
            }, [this, ship, pc](){
                my_player_info->commandSetShip(ship);
                crew_position_selection_overlay->show();
                my_player_info->last_ship_password = pc->control_code;
                left_container->show();
                right_container->show();
            }, [this](){
                left_container->show();
                right_container->show();
            });
        }
        else
        {
            // Otherwise, select and set this ship ID in the player info.
            my_player_info->commandSetShip(ship);
            crew_position_selection_overlay->show();
        }
    }
    else
    {
        // If the selected item isn't a ship, reset the ship ID in player info.
        my_player_info->commandSetShip({});
    }
}

CrewPositionSelection::CrewPositionSelection(GuiContainer* owner, string id, int _window_index, std::function<void()> on_cancel, std::function<void()> on_ready)
: GuiPanel(owner, id), window_index(_window_index)
{
    // Layout
    setSize(1120, 800);
    setPosition(0, 0, sp::Alignment::Center);
    setAttribute("layout", "vertical");
    setAttribute("margin", "50");
    setAttribute("padding", "20");

    auto container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");
    container->setAttribute("margin", "0, 0, 0, 20");

    auto left_container = new GuiElement(container, "");
    left_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    auto center_container = new GuiElement(container, "");
    center_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    center_container->setAttribute("margin", "20, 20, 0, 0");

    auto right_container = new GuiElement(container, "");
    right_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    auto bottom_row = new GuiElement(this, "");
    bottom_row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");

    // Left column
    auto standard_crew_panel = new GuiPanel(left_container, "");
    standard_crew_panel->setSize(GuiElement::GuiSizeMax, 80);
    standard_crew_panel->setAttribute("margin", "0, 0, 0, 20");
    standard_crew_panel->setAttribute("padding", "20, 20, 0, 20");
    standard_crew_panel->setAttribute("layout", "vertical");

    auto limited_crew_panel = new GuiPanel(left_container, "");
    limited_crew_panel->setSize(GuiElement::GuiSizeMax, 80);
    limited_crew_panel->setAttribute("margin", "0, 0, 0, 20");
    limited_crew_panel->setAttribute("padding", "20, 20, 0, 20");
    limited_crew_panel->setAttribute("layout", "vertical");
    (new GuiLabel(limited_crew_panel, "CREW_POSITION_SELECT_LABEL", tr("4/3/1 player crew"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");

    // 6/5 player crew panel
    (new GuiLabel(standard_crew_panel, "CREW_POSITION_SELECT_LABEL", tr("6/5 player crew"), 30.0f))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");

    auto create_crew_position_button = [this](GuiElement* standard_crew_panel, int n) {
        auto cp = CrewPosition(n);
        auto button = new GuiToggleButton(standard_crew_panel, "", getCrewPositionName(cp), [this, cp](bool value){
            my_player_info->commandSetCrewPosition(window_index, cp, value);
            unselectSingleOptions();
        });
        button->setSize(GuiElement::GuiSizeMax, 50);
        button->setIcon(getCrewPositionIcon(cp));
        button->setValue(size_t(window_index) < my_player_info->crew_positions.size() && my_player_info->crew_positions[window_index].has(cp));
        crew_position_button[n] = button;
        return button;
    };
    for (int n = 0; n <= int(CrewPosition::relayOfficer); n++)
    {
        create_crew_position_button(standard_crew_panel, n);
        standard_crew_panel->setSize(standard_crew_panel->getSize() + glm::vec2(0.0f, 50.0f));
    }

    // 4/3/1 player crew panel
    for (int n = int(CrewPosition::tacticalOfficer); n <= int(CrewPosition::singlePilot); n++)
    {
        create_crew_position_button(limited_crew_panel, n);
        limited_crew_panel->setSize(limited_crew_panel->getSize() + glm::vec2(0.0f, 50.0f));
    }

    // Center column
    auto space_screens_panel = new GuiPanel(center_container, "");
    space_screens_panel->setSize(GuiElement::GuiSizeMax, 230.0f);
    space_screens_panel->setAttribute("margin", "0, 0, 0, 20");
    space_screens_panel->setAttribute("padding", "20, 20, 0, 20");
    space_screens_panel->setAttribute("layout", "vertical");
    (new GuiLabel(space_screens_panel, "CREW_POSITION_SELECT_LABEL", tr("3D screens"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");

    // 3D screens panel
    // Main screen button
    main_screen_button = new GuiToggleButton(space_screens_panel, "", tr("Main screen"), [this](bool value) {
        my_player_info->commandSetMainScreen(window_index, value);
        unselectSingleOptions();
    });
    main_screen_button->setValue(my_player_info->main_screen & (1 << window_index));
    main_screen_button->setSize(GuiElement::GuiSizeMax, 50);

    // Window button
    auto window_button_row = new GuiElement(space_screens_panel, "");
    window_button_row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    window_button = new GuiToggleButton(window_button_row, "WINDOW_BUTTON", tr("Ship window"), [this](bool value) {
        disableAllExcept(window_button);
    });
    window_button->setSize(GuiElement::GuiSizeMax, 50);

    window_angle = new GuiTextEntry(window_button_row, "WINDOW_ANGLE","0");
    window_angle->setSize(75, 50);
    window_angle->setSelectOnFocus();
    window_angle->callback([this](string text) { // Check validity: Only allow numbers and no more than 3 digits. Angles above 360 are fine though.
        if (text !="" && text !="-") window_angle->setText(text.toInt());
        if (text.length() >3 && text.toInt()>=0 ) window_angle->setText(text.substr(0,3));
        if (text.length() >4 && text.toInt()<0 ) window_angle->setText(text.substr(0,4));
    });

    window_angle_label = new GuiLabel(window_button_row, "WINDOW_ANGLE_LABEL", "°", 30);
    window_angle_label->setSize(12, GuiElement::GuiSizeMax);

    // Top-down 3D view button
    topdown_button = new GuiToggleButton(space_screens_panel, "TOP_DOWN_3D_BUTTON", tr("Top-down 3D view"), [this](bool value) {
        disableAllExcept(topdown_button);
    });
    topdown_button->setSize(GuiElement::GuiSizeMax, 50);

    // Alternative options panel
    auto alternative_options_panel = new GuiPanel(center_container, "");
    alternative_options_panel->setSize(GuiElement::GuiSizeMax, 130.0f);
    alternative_options_panel->setAttribute("margin", "0, 0, 0, 20");
    alternative_options_panel->setAttribute("padding", "20, 20, 0, 20");
    alternative_options_panel->setAttribute("layout", "vertical");
    (new GuiLabel(alternative_options_panel, "CREW_POSITION_SELECT_LABEL", tr("Alternative options"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("margin", "0, 0, 0, 10");

    // Main screen controls button
    main_screen_controls_button = new GuiToggleButton(alternative_options_panel, "MAIN_SCREEN_CONTROLS_ENABLE", tr("Main screen controls"), [this](bool value) {
        my_player_info->commandSetMainScreenControl(window_index, value);
    });
    main_screen_controls_button->setValue(my_player_info->main_screen_control)->setSize(GuiElement::GuiSizeMax, 50);

    for (int n = int(CrewPosition::singlePilot) + 1; n < int(CrewPosition::MAX); n++)
    {
        create_crew_position_button(alternative_options_panel, n);
        alternative_options_panel->setSize(alternative_options_panel->getSize() + glm::vec2(0.0f, 50.0f));
    }

    // Right column
    // Info text panel
    auto station_info = new GuiScrollText(right_container, "STATION_INFO",
        tr("You can select multiple stations and switch between them during the game.\nIf mainscreen is selected alongside stations, it will be shown next to the current station (if the total screen size is wide enough).")
    );
    station_info->setSize(GuiElement::GuiSizeMax, 325)->setAttribute("margin", "0, 0, 0, 20");

    (new GuiLabel(right_container, "STATION_PLAYERS_LABEL", tr("Crew assignments"), 30.0f))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    station_players = new GuiScrollText(right_container, "STATION_PLAYERS", "");
    station_players->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Bottom row
    auto bottom_left = new GuiElement(bottom_row, "");
    bottom_left->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    auto bottom_right = new GuiElement(bottom_row, "");
    bottom_right->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    if (on_cancel)
        (new GuiButton(bottom_left, "CANCEL", tr("button", "Cancel"), on_cancel))->setSize(300, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::Center);

    ready_button = new GuiButton(bottom_right, "READY", tr("button", "Ready"), on_ready);
    ready_button->setSize(300, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::Center);
}

void CrewPositionSelection::onUpdate()
{
    auto pc = my_spaceship.getComponent<PlayerControl>();
    bool any_selected = main_screen_button->getValue() || window_button->getValue() || topdown_button->getValue();
    // If a position already has a player on the currently selected player ship,
    // indicate that on the button.
    string crew_text = "";

    for (int n = 0; n < static_cast<int>(CrewPosition::MAX); n++)
    {
        auto cp = CrewPosition(n);
        string button_text = getCrewPositionName(cp);

        if (my_spaceship)
        {
            std::vector<string> players;

            foreach(PlayerInfo, i, player_info_list)
            {
                if (i->ship == my_spaceship && i->hasPosition(cp))
                    players.push_back(i->name);
            }

            std::sort(players.begin(), players.end());
            players.resize(std::distance(players.begin(), std::unique(players.begin(), players.end())));

            if (players.size() > 0)
            {
                crew_position_button[n]->setText(button_text + " ["+ std::to_string(players.size()) +"]");
                if (!crew_text.empty()) crew_text += "\n";
                crew_text += button_text + ": " + string(", ").join(players);
            }
            else
            {
                crew_position_button[n]->setText(button_text);
            }

            crew_position_button[n]->setEnable(!pc || pc->allowed_positions.has(cp));
            any_selected = any_selected || crew_position_button[n]->getValue();
        }
    }

    if (crew_text.empty()) crew_text = tr("No crew members assigned");

    station_players->setText(crew_text);
    ready_button->setEnable(any_selected);
}

void CrewPositionSelection::disableAllExcept(GuiToggleButton* button)
{
    for(int n = 0; n < static_cast<int>(CrewPosition::MAX); n++)
    {
        if (crew_position_button[n] != button)
        {
            crew_position_button[n]->setValue(false);
            my_player_info->commandSetCrewPosition(window_index, CrewPosition(n), false);
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
        new WindowScreen(render_layer, window_angle->getText().toInt(), window_flags);
    }else if(topdown_button->getValue())
    {
        my_player_info->commandSetShip({});
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

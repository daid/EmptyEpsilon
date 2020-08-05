#include <i18n.h>
#include "preferenceManager.h"
#include "serverCreationScreen.h"
#include "shipSelectionScreen.h"
#include "gameGlobalInfo.h"
#include "epsilonServer.h"
#include "gui/scriptError.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "scenarioInfo.h"
#include "main.h"

ServerCreationScreen::ServerCreationScreen()
{
    assert(game_server);

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Set defaults from preferences.
    gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(PreferencesManager::get("server_config_warp_jump_drive_setting", "0").toInt());
    gameGlobalInfo->scanning_complexity = EScanningComplexity(PreferencesManager::get("server_config_scanning_complexity", "2").toInt());
    gameGlobalInfo->hacking_difficulty = PreferencesManager::get("server_config_hacking_difficulty", "1").toInt();
    gameGlobalInfo->hacking_games = EHackingGames(PreferencesManager::get("server_config_hacking_games", "2").toInt());
    gameGlobalInfo->use_beam_shield_frequencies = PreferencesManager::get("server_config_use_beam_shield_frequencies", "1").toInt();
    gameGlobalInfo->use_system_damage = PreferencesManager::get("server_config_use_system_damage", "1").toInt();
    gameGlobalInfo->allow_main_screen_tactical_radar = PreferencesManager::get("server_config_allow_main_screen_tactical_radar", "1").toInt();
    gameGlobalInfo->allow_main_screen_long_range_radar = PreferencesManager::get("server_config_allow_main_screen_long_range_radar", "1").toInt();

    // Create a two-column layout.
    GuiElement* container = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutVerticalColumns);
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    GuiElement* left_container = new GuiElement(container, "");
    GuiElement* right_container = new GuiElement(container, "");

    GuiElement* left_panel = new GuiAutoLayout(left_container, "", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_panel->setPosition(0, 20, ATopCenter)->setSize(550, GuiElement::GuiSizeMax);
    GuiElement* right_panel = new GuiAutoLayout(right_container, "", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_panel->setPosition(0, 20, ATopCenter)->setSize(550, GuiElement::GuiSizeMax);

    // Left column contents.
    // General section.
    (new GuiLabel(left_panel, "GENERAL_LABEL", tr("Server configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Server name row.
    GuiElement* row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "NAME_LABEL", tr("Server name: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiTextEntry(row, "SERVER_NAME", game_server->getServerName()))->callback([](string text){game_server->setServerName(text);})->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server password row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "PASSWORD_LABEL", tr("Server password: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiTextEntry(row, "SERVER_PASSWORD", ""))->callback([](string text){game_server->setPassword(text.upper());})->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // GM control code row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "GM_CONTROL_CODE_LABEL", tr("GM control code: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiTextEntry(row, "GM_CONTROL_CODE", ""))->callback([](string text){gameGlobalInfo->gm_control_code = text.upper();})->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server IP row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "IP_LABEL", tr("Server IP: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiLabel(row, "IP", sf::IpAddress::getLocalAddress().toString(), 30))->setAlignment(ACenterLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // LAN/Internet row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "LAN_INTERNET_LABEL", tr("Server visibility: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "LAN_INTERNET_SELECT", [](int index, string value) {
        if (index == 1)
            game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));
        else
            game_server->stopMasterServerRegistry();
    }))->setOptions({tr("LAN only"), tr("Internet")})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Player Ships section.
    (new GuiLabel(left_panel, "PLAYER_SHIP_LABEL", tr("Player ship options"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Warp/Jump drive row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "WARP_JUMP_LABEL", tr("Warp/Jump: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "WARP_JUMP_SELECT", [](int index, string value) {
        gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(index);
    }))->setOptions({tr("warp/jump", "Ship default"), tr("warp/jump", "Warp drive"), tr("warp/jump", "Jump drive"), tr("warp/jump", "Both"), tr("warp/jump", "Neither")})->setSelectionIndex((int)gameGlobalInfo->player_warp_jump_drive_setting)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Main screen section.
    (new GuiLabel(left_panel, "MAIN_SCREEN_LABEL", tr("Main screen options"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Radar row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiToggleButton(row, "MAIN_TACTICAL_TOGGLE", tr("Tactical radar"), [](bool value) {
        gameGlobalInfo->allow_main_screen_tactical_radar = value == 1;
    }))->setValue(gameGlobalInfo->allow_main_screen_tactical_radar)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterLeft);
    (new GuiToggleButton(row, "MAIN_LONG_RANGE_TOGGLE", tr("Long range radar"), [](bool value) {
        gameGlobalInfo->allow_main_screen_long_range_radar = value == 1;
    }))->setValue(gameGlobalInfo->allow_main_screen_long_range_radar)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterRight);

    // Game rules section.
    (new GuiLabel(left_panel, "GAME_RULES_LABEL", tr("Game rules"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Science scan complexity selector.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "GAME_SCANNING_COMPLEXITY_LABEL", tr("Scan complexity: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "GAME_SCANNING_COMPLEXITY", [](int index, string value) {
        gameGlobalInfo->scanning_complexity = EScanningComplexity(index);
    }))->setOptions({tr("scanning", "None (delay)"), tr("scanning", "Simple"), tr("scanning", "Normal"), tr("scanning", "Advanced")})->setSelectionIndex((int)gameGlobalInfo->scanning_complexity)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Hacking difficulty selector.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "GAME_HACKING_DIFFICULTY_LABEL", tr("Hacking difficulty: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "GAME_HACKING_DIFFICULTY", [](int index, string value) {
        gameGlobalInfo->hacking_difficulty = index;
    }))->setOptions({tr("hacking", "Simple"), tr("hacking", "Normal"), tr("hacking", "Difficult"), tr("hacking", "Fiendish")})->setSelectionIndex(gameGlobalInfo->hacking_difficulty)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Hacking games selector.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "GAME_HACKING_GAMES_LABEL", tr("Hacking type: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "GAME_HACKING_GAME", [](int index, string value) {
        gameGlobalInfo->hacking_games = EHackingGames(index);
    }))->setOptions({tr("hacking", "Mine"), tr("hacking", "Lights"), tr("hacking", "All")})->setSelectionIndex((int)gameGlobalInfo->hacking_games)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Frequency and system damage row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiToggleButton(row, "GAME_FREQUENCIES_TOGGLE", tr("Beam/shield frequencies"), [](bool value) {
        gameGlobalInfo->use_beam_shield_frequencies = value == 1;
    }))->setValue(gameGlobalInfo->use_beam_shield_frequencies)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterLeft);

    (new GuiToggleButton(row, "GAME_SYS_DAMAGE_TOGGLE", tr("Per-system damage"), [](bool value) {
        gameGlobalInfo->use_system_damage = value == 1;
    }))->setValue(gameGlobalInfo->use_system_damage)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterRight);

    // Right column contents.
    // Scenario section.
    (new GuiLabel(right_panel, "SCENARIO_LABEL", tr("Scenario"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // List each scenario derived from scenario_*.lua files in Resources.
    GuiListbox* scenario_list = new GuiListbox(right_panel, "SCENARIO_LIST", [this](int index, string value) {
        selectScenario(value);
    });
    scenario_list->setSize(GuiElement::GuiSizeMax, 300);

    // Show the scenario description text.
    GuiPanel* panel = new GuiPanel(right_panel, "SCENARIO_DESCRIPTION_BOX");
    panel->setSize(GuiElement::GuiSizeMax, 200);
    scenario_description = new GuiScrollText(panel, "SCENARIO_DESCRIPTION", "");
    scenario_description->setTextSize(24)->setMargins(15)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // If the scenario has variations, show and select from them.
    variation_container = new GuiAutoLayout(right_panel, "VARIATION_CONTAINER", GuiAutoLayout::LayoutVerticalTopToBottom);
    variation_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    row = new GuiAutoLayout(variation_container, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "VARIATION_LABEL", tr("Variation: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    variation_selection = new GuiSelector(row, "VARIATION_SELECT", [this](int index, string value) {
        gameGlobalInfo->variation = variation_names_list.at(index);
        variation_description->setText(variation_descriptions_list.at(index));
    });
    variation_selection->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    panel = new GuiPanel(variation_container, "VARIATION_DESCRIPTION_BOX");
    panel->setSize(GuiElement::GuiSizeMax, 150);
    variation_description = new GuiScrollText(panel, "VARIATION_DESCRIPTION", "");
    variation_description->setTextSize(24)->setMargins(15)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Buttons beneath the columns.
    // Close server button.
    (new GuiButton(left_container, "CLOSE_SERVER", tr("Close server"), [this]() {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Start server button.
    (new GuiButton(right_container, "START_SERVER", tr("Start scenario"), [this]() {
        startScenario();
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Fetch and sort all Lua files starting with "scenario_".
    std::vector<string> scenario_filenames = findResources("scenario_*.lua");
    std::sort(scenario_filenames.begin(), scenario_filenames.end());

    // We select the same mission as we had previously selected
    // unless that one doesnt exist in which case we select the first by default
    int mission_selected = 0;
    // For each scenario file, extract its name, then add it to the list.
    for(string filename : scenario_filenames)
    {
        ScenarioInfo info(filename);
        scenario_list->addEntry(info.name, filename);
        if (info.name == gameGlobalInfo->scenario)
        {
            mission_selected=scenario_list->entryCount()-1;
        }
    }

    scenario_list->setSelectionIndex(mission_selected);
    selectScenario(scenario_list->getSelectionValue());

    gameGlobalInfo->reset();
}

void ServerCreationScreen::selectScenario(string filename)
{
    // When a scenario is selected, display its description and variations.
    selected_scenario_filename = filename;

    // Open the scenario file.
    ScenarioInfo info(selected_scenario_filename);
    scenario_description->setText(info.description);

    // Initialize variables.
    variation_selection->setSelectionIndex(0);
    variation_names_list = {tr("variation", "None")};

    string variation_requested = variation_names_list[0];
    if (gameGlobalInfo->scenario == info.name)
    {
        variation_requested = gameGlobalInfo->variation;
    }

    variation_descriptions_list = {tr("No variation selected. Play the scenario as intended.")};
    variation_description->setText(variation_descriptions_list[0]);

    int selected_variation = 0;
    for(auto variation : info.variations)
    {
        variation_names_list.push_back(variation.first);
        variation_descriptions_list.push_back(variation.second);
        if (variation_requested == variation.first)
        {
            selected_variation=variation_names_list.size()-1;
        }
    }

    variation_selection->setOptions(variation_names_list);

    gameGlobalInfo->scenario = info.name;
    gameGlobalInfo->variation = variation_names_list[selected_variation];

    variation_selection->setSelectionIndex(selected_variation);
    variation_description->setText(variation_descriptions_list[selected_variation]);

    // Show the variation information only if there's more than 1.
    variation_container->setVisible(variation_names_list.size() > 1);
}

void ServerCreationScreen::startScenario()
{
    // Set these settings to use as future defaults.
    PreferencesManager::set("server_config_warp_jump_drive_setting", string(int(gameGlobalInfo->player_warp_jump_drive_setting)));
    PreferencesManager::set("server_config_scanning_complexity", string(int(gameGlobalInfo->scanning_complexity)));
    PreferencesManager::set("server_config_use_beam_shield_frequencies", string(int(gameGlobalInfo->use_beam_shield_frequencies)));
    PreferencesManager::set("server_config_use_system_damage", string(int(gameGlobalInfo->use_system_damage)));
    PreferencesManager::set("server_config_allow_main_screen_tactical_radar", string(int(gameGlobalInfo->allow_main_screen_tactical_radar)));
    PreferencesManager::set("server_config_allow_main_screen_long_range_radar", string(int(gameGlobalInfo->allow_main_screen_long_range_radar)));

    // Start the selected scenario.
    gameGlobalInfo->startScenario(selected_scenario_filename);

    // Destroy this screen and move on to ship selection.
    destroy();
    returnToShipSelection();
    new ScriptErrorRenderer();
}

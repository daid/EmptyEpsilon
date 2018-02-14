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
    gameGlobalInfo->long_range_radar_range = PreferencesManager::get("server_config_long_range_radar_range", "30000").toInt();
    gameGlobalInfo->scanning_complexity = EScanningComplexity(PreferencesManager::get("server_config_scanning_complexity", "2").toInt());
    gameGlobalInfo->use_beam_shield_frequencies = PreferencesManager::get("server_config_use_beam_shield_frequencies", "1").toInt();
    gameGlobalInfo->use_system_damage = PreferencesManager::get("server_config_use_system_damage", "1").toInt();
    gameGlobalInfo->allow_main_screen_tactical_radar = PreferencesManager::get("server_config_allow_main_screen_tactical_radar", "1").toInt();
    gameGlobalInfo->allow_main_screen_long_range_radar = PreferencesManager::get("server_config_allow_main_screen_long_range_radar", "1").toInt();
    gameGlobalInfo->allow_faction_aura = PreferencesManager::get("server_config_allow_faction_aura", "1").toInt();

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
    (new GuiLabel(left_panel, "GENERAL_LABEL", "Server configuration", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Server name row.
    GuiElement* row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "NAME_LABEL", "Server name: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiTextEntry(row, "SERVER_NAME", game_server->getServerName()))->callback([](string text){game_server->setServerName(text);})->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server password row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "PASSWORD_LABEL", "Server password: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiTextEntry(row, "SERVER_PASSWORD", ""))->callback([](string text){game_server->setPassword(text);})->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server IP row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "IP_LABEL", "Server IP: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiLabel(row, "IP", sf::IpAddress::getLocalAddress().toString(), 30))->setAlignment(ACenterLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // LAN/Internet row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "LAN_INTERNET_LABEL", "Server visibility: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "LAN_INTERNET_SELECT", [](int index, string value) {
        if (index == 1)
            game_server->registerOnMasterServer("http://daid.eu/ee/register.php");
        else
            game_server->stopMasterServerRegistry();
    }))->setOptions({"LAN only", "Internet"})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Player Ships section.
    (new GuiLabel(left_panel, "PLAYER_SHIP_LABEL", "Player ship options", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Warp/Jump drive row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "WARP_JUMP_LABEL", "Warp/Jump: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "WARP_JUMP_SELECT", [](int index, string value) {
        gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(index);
    }))->setOptions({"Ship default", "Warp drive", "Jump drive", "Both", "Neither"})->setSelectionIndex((int)gameGlobalInfo->player_warp_jump_drive_setting)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Radar range limit row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "RADAR_LABEL", "Radar range: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "RADAR_SELECT", [](int index, string value) {
        gameGlobalInfo->long_range_radar_range = index * 5000 + 10000;
    }))->setOptions({"10U", "15U", "20U", "25U", "30U", "35U", "40U", "45U", "50U"})->setSelectionIndex((gameGlobalInfo->long_range_radar_range - 10000.0) / 5000.0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Main screen section.
    (new GuiLabel(left_panel, "MAIN_SCREEN_LABEL", "Main screen options", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Radar row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiToggleButton(row, "MAIN_TACTICAL_TOGGLE", "Tactical radar", [](bool value) {
        gameGlobalInfo->allow_main_screen_tactical_radar = value == 1;
    }))->setValue(gameGlobalInfo->allow_main_screen_tactical_radar)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterLeft);
    (new GuiToggleButton(row, "MAIN_LONG_RANGE_TOGGLE", "Long range radar", [](bool value) {
        gameGlobalInfo->allow_main_screen_long_range_radar = value == 1;
    }))->setValue(gameGlobalInfo->allow_main_screen_long_range_radar)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenter);



    // Game rules section.
    (new GuiLabel(left_panel, "GAME_RULES_LABEL", "Game rules", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Science scan complexity selector.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "GAME_SCANNING_COMPLEXITY_LABEL", "Scan complexity: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiSelector(row, "GAME_SCANNING_COMPLEXITY", [](int index, string value) {
        gameGlobalInfo->scanning_complexity = EScanningComplexity(index);
    }))->setOptions({"None (delay)", "Simple", "Normal", "Advanced"})->setSelectionIndex((int)gameGlobalInfo->scanning_complexity)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Frequency and system damage row.
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiToggleButton(row, "GAME_FREQUENCIES_TOGGLE", "Beam/shield frequencies", [](bool value) {
        gameGlobalInfo->use_beam_shield_frequencies = value == 1;
    }))->setValue(gameGlobalInfo->use_beam_shield_frequencies)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterLeft);

    (new GuiToggleButton(row, "GAME_SYS_DAMAGE_TOGGLE", "Per-system damage", [](bool value) {
        gameGlobalInfo->use_system_damage = value == 1;
    }))->setValue(gameGlobalInfo->use_system_damage)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterRight);

    // Radar View mods
    row = new GuiAutoLayout(left_panel, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiToggleButton(row, "MAIN_FACTION_AURA_TOGGLE", "Faction Aura", [](bool value) {
        gameGlobalInfo->allow_faction_aura = value == 1;
    }))->setValue(gameGlobalInfo->allow_faction_aura)->setSize(275, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenterRight);


    // Right column contents.
    // Scenario section.
    (new GuiLabel(right_panel, "SCENARIO_LABEL", "Scenario", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
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
    (new GuiLabel(row, "VARIATION_LABEL", "Variation: ", 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
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
    (new GuiButton(left_container, "CLOSE_SERVER", "Close server", [this]() {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Start server button.
    (new GuiButton(right_container, "START_SERVER", "Start scenario", [this]() {
        startScenario();
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Fetch and sort all Lua files starting with "scenario_".
    std::vector<string> scenario_filenames = findResources("scenario_*.lua");
    std::sort(scenario_filenames.begin(), scenario_filenames.end());

    // For each scenario file, extract its name, then add it to the list.
    for(string filename : scenario_filenames)
    {
        ScenarioInfo info(filename);
        scenario_list->addEntry(info.name, filename);
    }
    // Select the first scenario in the list by default.
    scenario_list->setSelectionIndex(0);
    selectScenario(scenario_list->getSelectionValue());

    gameGlobalInfo->reset();
}

void ServerCreationScreen::selectScenario(string filename)
{
    // When a scenario is selected, display its description and variations.
    selected_scenario_filename = filename;

    // Initialize variables.
    scenario_description->setText("");

    variation_selection->setSelectionIndex(0);
    variation_names_list = {"None"};
    gameGlobalInfo->variation = variation_names_list[0];

    variation_descriptions_list = {"No variation."};
    variation_description->setText("No variation selected. Play the scenario as intended.");

    // Open the scenario file.
    ScenarioInfo info(selected_scenario_filename);
    scenario_description->setText(info.description);

    for(auto variation : info.variations)
    {
        variation_names_list.push_back(variation.first);
        variation_descriptions_list.push_back(variation.second);
    }

    variation_selection->setOptions(variation_names_list);
    // Show the variation information only if there's more than 1.
    variation_container->setVisible(variation_names_list.size() > 1);
}

void ServerCreationScreen::startScenario()
{
    // Set these settings to use as future defaults.
    PreferencesManager::set("server_config_warp_jump_drive_setting", string(int(gameGlobalInfo->player_warp_jump_drive_setting)));
    PreferencesManager::set("server_config_long_range_radar_range", string(gameGlobalInfo->long_range_radar_range, 0));
    PreferencesManager::set("server_config_scanning_complexity", string(int(gameGlobalInfo->scanning_complexity)));
    PreferencesManager::set("server_config_use_beam_shield_frequencies", string(int(gameGlobalInfo->use_beam_shield_frequencies)));
    PreferencesManager::set("server_config_use_system_damage", string(int(gameGlobalInfo->use_system_damage)));
    PreferencesManager::set("server_config_allow_main_screen_tactical_radar", string(int(gameGlobalInfo->allow_main_screen_tactical_radar)));
    PreferencesManager::set("server_config_allow_main_screen_long_range_radar", string(int(gameGlobalInfo->allow_main_screen_long_range_radar)));
    PreferencesManager::set("server_config_allow_faction_aura", string(int(gameGlobalInfo->allow_faction_aura)));

    // Start the selected scenario.
    gameGlobalInfo->startScenario(selected_scenario_filename);

    // Destroy this screen and move on to ship selection.
    destroy();
    returnToShipSelection();
    new ScriptErrorRenderer();
}

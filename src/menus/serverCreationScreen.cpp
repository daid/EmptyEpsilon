#include "preferenceManager.h"
#include "serverCreationScreen.h"
#include "shipSelectionScreen.h"
#include "gameGlobalInfo.h"
#include "epsilonServer.h"
#include "gui/scriptError.h"
#include "main.h"

ServerCreationScreen::ServerCreationScreen()
{
    assert(game_server);

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(PreferencesManager::get("server_config_warp_jump_drive_setting", "0").toInt());
    gameGlobalInfo->long_range_radar_range = PreferencesManager::get("server_config_long_range_radar_range", "30000").toInt();
    gameGlobalInfo->scanning_complexity = EScanningComplexity(PreferencesManager::get("server_config_scanning_complexity", "2").toInt());
    gameGlobalInfo->use_beam_shield_frequencies = PreferencesManager::get("server_config_use_beam_shield_frequencies", "1").toInt();
    gameGlobalInfo->use_system_damage = PreferencesManager::get("server_config_use_system_damage", "1").toInt();
    gameGlobalInfo->allow_main_screen_tactical_radar = PreferencesManager::get("server_config_allow_main_screen_tactical_radar", "1").toInt();
    gameGlobalInfo->allow_main_screen_long_range_radar = PreferencesManager::get("server_config_allow_main_screen_long_range_radar", "1").toInt();

    (new GuiLabel(this, "SCENARIO_LABEL", "Scenario", 30))->addBackground()->setPosition(-50, 50, ATopRight)->setSize(460, 50);
    GuiListbox* scenario_list = new GuiListbox(this, "SCENARIO_LIST", [this](int index, string value) {
        selectScenario(value);
    });
    scenario_list->setPosition(-50, 100, ATopRight)->setSize(460, 300);
    (new GuiPanel(this, "SCENARIO_DESCRIPTION_BOX"))->setPosition(-50, 50 + 360, ATopRight)->setSize(460, 200);
    scenario_description = new GuiScrollText(this, "SCENARIO_DESCRIPTION", "");
    scenario_description->setTextSize(20)->setPosition(-80, 60 + 360, ATopRight)->setSize(400, 180);

    variation_container = new GuiElement(this, "VARIATION_CONTAINER");
    variation_container->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    variation_selection = new GuiSelector(variation_container, "VARIATION_SELECT", [this](int index, string value) {
        gameGlobalInfo->variation = variation_names_list.at(index);
        variation_description->setText(variation_descriptions_list.at(index));
    });
    variation_selection->setPosition(-50, 380 + 230, ATopRight)->setSize(300, 50);
    (new GuiLabel(variation_container, "VARIATION_LABEL", "Variation:", 30))->setAlignment(ACenterRight)->setPosition(-350, 380 + 230, ATopRight)->setSize(250, 50);

    (new GuiPanel(variation_container, "VARIATION_DESCRIPTION_BOX"))->setPosition(-50, 380 + 230 + 50, ATopRight)->setSize(460, 120);
    variation_description = new GuiScrollText(variation_container, "VARIATION_DESCRIPTION", "");
    variation_description->setTextSize(20)->setPosition(-80, 60 + 380 + 230, ATopRight)->setSize(400, 100);

    float y = 50;
    (new GuiLabel(this, "GENERAL_LABEL", "General", 30))->addBackground()->setPosition(50, y, ATopLeft)->setSize(550, 50);
    y += 50;
    (new GuiTextEntry(this, "SERVER_NAME", game_server->getServerName()))->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "NAME_LABEL", "Server name:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);
    y += 50;
    (new GuiLabel(this, "IP", sf::IpAddress::getLocalAddress().toString(), 30))->addBackground()->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "IP_LABEL", "Server IP:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);

    y += 70;
    (new GuiLabel(this, "PLAYER_SHIP_LABEL", "Player ships", 30))->addBackground()->setPosition(50, y, ATopLeft)->setSize(550, 50);
    y += 50;
    (new GuiSelector(this, "WARP_JUMP_SELECT", [](int index, string value) {
        gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(index);
    }))->setOptions({"Ship default", "Warp-drive", "Jump-drive", "Both"})->setSelectionIndex((int)gameGlobalInfo->player_warp_jump_drive_setting)->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "WARP_JUMP_LABEL", "Warp/Jump:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);
    y += 50;
    (new GuiSelector(this, "RADAR_SELECT", [](int index, string value) {
        gameGlobalInfo->long_range_radar_range = index * 5000 + 10000;
    }))->setOptions({"10000", "15000", "20000", "25000", "30000", "35000", "40000", "45000", "50000"})->setSelectionIndex((gameGlobalInfo->long_range_radar_range - 10000.) / 5000.0)->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "RADAR_LABEL", "Radar range:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);

    y += 70;
    (new GuiLabel(this, "MAIN_SCREEN_LABEL", "Main screen", 30))->addBackground()->setPosition(50, y, ATopLeft)->setSize(550, 50);
    y += 50;
    (new GuiSelector(this, "MAIN_TACTICAL_SELECT", [](int index, string value) {
        gameGlobalInfo->allow_main_screen_tactical_radar = index == 1;
    }))->setOptions({"No", "Yes"})->setSelectionIndex(gameGlobalInfo->allow_main_screen_tactical_radar ? 1 : 0)->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "MAIN_TACTICAL_LABEL", "Tactical radar:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);
    y += 50;
    (new GuiSelector(this, "MAIN_LONG_RANGE_SELECT", [](int index, string value) {
        gameGlobalInfo->allow_main_screen_long_range_radar = index == 1;
    }))->setOptions({"No", "Yes"})->setSelectionIndex(gameGlobalInfo->allow_main_screen_long_range_radar ? 1 : 0)->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "MAIN_LONG_RANGE_LABEL", "Long range radar:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);

    y += 70;
    (new GuiLabel(this, "GAME_RULES_LABEL", "Game rules", 30))->addBackground()->setPosition(50, y, ATopLeft)->setSize(550, 50);
    y += 50;
    (new GuiSelector(this, "GAME_FREQUENCIES_SELECT", [](int index, string value) {
        gameGlobalInfo->use_beam_shield_frequencies = index == 1;
    }))->setOptions({"No", "Yes"})->setSelectionIndex(gameGlobalInfo->use_beam_shield_frequencies ? 1 : 0)->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "GAME_FREQUENCIES_LABEL", "Frequencies:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);
    y += 50;
    (new GuiSelector(this, "GAME_SYS_DAMAGE_SELECT", [](int index, string value) {
        gameGlobalInfo->use_system_damage = index == 1;
    }))->setOptions({"No", "Yes"})->setSelectionIndex(gameGlobalInfo->use_system_damage ? 1 : 0)->setPosition(300, y, ATopLeft)->setSize(300, 50);
    (new GuiLabel(this, "GAME_SYS_DAMAGE_LABEL", "System damage:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);
    y += 50;
    (new GuiLabel(this, "GAME_SCANNING_COMPLEXITY_LABEL", "Science scanning:", 30))->setAlignment(ACenterRight)->setPosition(50, y, ATopLeft)->setSize(250, 50);
    (new GuiSelector(this, "GAME_SCANNING_COMPLEXITY", [](int index, string value) {
        gameGlobalInfo->scanning_complexity = EScanningComplexity(index);
    }))->setOptions({"None (delay)", "Simple", "Normal", "Advanced"})->setSelectionIndex((int)gameGlobalInfo->scanning_complexity)->setPosition(300, y, ATopLeft)->setSize(300, 50);

    (new GuiButton(this, "CLOSE_SERVER", "Close server", [this]() {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
    }))->setPosition(150, -50, ABottomLeft)->setSize(300, 50);
    (new GuiButton(this, "START_SERVER", "Start", [this]() {
        startScenario();
    }))->setPosition(-150, -50, ABottomRight)->setSize(300, 50);

    std::vector<string> scenario_filenames = findResources("scenario_*.lua");
    std::sort(scenario_filenames.begin(), scenario_filenames.end());

    for(string filename : scenario_filenames)
    {
        P<ResourceStream> stream = getResourceStream(filename);
        if (!stream) continue;

        string name = filename.substr(9, -4);

        for(int i=0; i<10; i++)
        {
            string line = stream->readLine().strip();
            if (!line.startswith("--"))
                continue;
            line = line.substr(2).strip();
            if (line.startswith("Name:"))
                name = line.substr(5).strip();
        }

        scenario_list->addEntry(name, filename);
    }
    scenario_list->setSelectionIndex(0);
    selectScenario(scenario_list->getSelectionValue());

    gameGlobalInfo->reset();
}

void ServerCreationScreen::selectScenario(string filename)
{
    selected_scenario_filename = filename;

    scenario_description->setText("");

    variation_selection->setSelectionIndex(0);
    variation_names_list = {"None"};
    gameGlobalInfo->variation = variation_names_list[0];

    variation_descriptions_list = {"No variation."};
    variation_description->setText("No variation selected. Play the scenario as intended.");

    P<ResourceStream> stream = getResourceStream(selected_scenario_filename);
    if (!stream) return;

    for(int i=0; i<30; i++)
    {
        string line = stream->readLine().strip();
        if (!line.startswith("--"))
            continue;
        line = line.substr(2).strip();
        if (line.startswith("Description:"))
            scenario_description->setText(line.substr(12).strip());
        if (line.startswith("Variation["))
        {
            line = line.substr(10).strip();
            string variation_name = line.substr(0, line.find("]"));

            variation_names_list.push_back(variation_name);
            variation_descriptions_list.push_back(line.substr(line.find("]")+2).strip());
        }
    }
    
    variation_selection->setOptions(variation_names_list);
    variation_container->setVisible(variation_names_list.size() > 1);
}

void ServerCreationScreen::startScenario()
{
    PreferencesManager::set("server_config_warp_jump_drive_setting", string(int(gameGlobalInfo->player_warp_jump_drive_setting)));
    PreferencesManager::set("server_config_long_range_radar_range", string(gameGlobalInfo->long_range_radar_range, 0));
    PreferencesManager::set("server_config_scanning_complexity", string(int(gameGlobalInfo->scanning_complexity)));
    PreferencesManager::set("server_config_use_beam_shield_frequencies", string(int(gameGlobalInfo->use_beam_shield_frequencies)));
    PreferencesManager::set("server_config_use_system_damage", string(int(gameGlobalInfo->use_system_damage)));
    PreferencesManager::set("server_config_allow_main_screen_tactical_radar", string(int(gameGlobalInfo->allow_main_screen_tactical_radar)));
    PreferencesManager::set("server_config_allow_main_screen_long_range_radar", string(int(gameGlobalInfo->allow_main_screen_long_range_radar)));

    gameGlobalInfo->startScenario(selected_scenario_filename);

    destroy();
    new ShipSelectionScreen();
    new ScriptErrorRenderer();
}

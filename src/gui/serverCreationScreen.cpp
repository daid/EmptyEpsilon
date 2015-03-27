#include "serverCreationScreen.h"
#include "shipSelectionScreen.h"
#include "gameMasterUI.h"
#include "gameGlobalInfo.h"

ServerCreationScreen::ServerCreationScreen()
{
    assert(game_server);

    std::vector<string> scenario_filenames = findResources("scenario_*.lua");
    std::sort(scenario_filenames.begin(), scenario_filenames.end());

    for(unsigned int n=0; n<scenario_filenames.size(); n++)
    {
        P<ResourceStream> stream = getResourceStream(scenario_filenames[n]);
        if (!stream) continue;

        ScenarioInfo info;
        info.filename = scenario_filenames[n];
        info.name = scenario_filenames[n].substr(9, -4);

        for(int i=0; i<10; i++)
        {
            string line = stream->readLine().strip();
            if (!line.startswith("--"))
                continue;
            line = line.substr(2).strip();
            if (line.startswith("Name:"))
                info.name = line.substr(5).strip();
            if (line.startswith("Description:"))
                info.description = line.substr(12).strip();
        }

        scenarios.push_back(info);
    }

    active_scenario_index = 0;
}

void ServerCreationScreen::onGui()
{
    //Text entry off screen so the string is updated.
    game_server->setServerName(drawTextEntry(sf::FloatRect(0, -150, 300, 50), game_server->getServerName()));

    drawKeyValueDisplay(sf::FloatRect(100, 50, 500, 50), 0.3, "Name:", game_server->getServerName() + "_");
    drawKeyValueDisplay(sf::FloatRect(100, 100, 500, 50), 0.3, "Ip:", sf::IpAddress::getLocalAddress().toString());

    float x = 50;
    float y = 200;
    drawTextBox(sf::FloatRect(x, y, 550, 50), "Player ships", AlignCenter);
    y += 50;
    drawBox(sf::FloatRect(x, y, 550, 50));
    drawText(sf::FloatRect(x, y, 250, 50), "Warp/Jump: ", AlignRight);
    int offset = drawSelector(sf::FloatRect(x + 250, y, 300, 50), playerWarpJumpDriveToString(gameGlobalInfo->player_warp_jump_drive_setting), 30);
    gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(int(gameGlobalInfo->player_warp_jump_drive_setting) + offset);
    if (gameGlobalInfo->player_warp_jump_drive_setting < PWJ_ShipDefault)
        gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(int(PWJ_MAX) - 1);
    if (gameGlobalInfo->player_warp_jump_drive_setting >= PWJ_MAX)
        gameGlobalInfo->player_warp_jump_drive_setting = PWJ_ShipDefault;
    y += 50;
    drawBox(sf::FloatRect(x, y, 550, 50));
    drawText(sf::FloatRect(x, y, 250, 50), "Radar range: ", AlignRight);
    offset = drawSelector(sf::FloatRect(x + 250, y, 300, 50), string(int(gameGlobalInfo->long_range_radar_range)), 30);
    gameGlobalInfo->long_range_radar_range += offset * 5000.0;
    if (gameGlobalInfo->long_range_radar_range < 10000.0)
        gameGlobalInfo->long_range_radar_range = 10000.0;
    if (gameGlobalInfo->long_range_radar_range > 50000.0)
        gameGlobalInfo->long_range_radar_range = 50000.0;
    y += 50;
    drawTextBox(sf::FloatRect(x, y, 550, 50), "Main screen", AlignCenter);
    y += 50;
    drawBox(sf::FloatRect(x, y, 550, 50));
    drawText(sf::FloatRect(x, y, 250, 50), "Tactical radar: ", AlignRight);
    if (drawSelector(sf::FloatRect(x + 250, y, 300, 50), gameGlobalInfo->allow_main_screen_tactical_radar ? "Yes" : "No", 30))
        gameGlobalInfo->allow_main_screen_tactical_radar = !gameGlobalInfo->allow_main_screen_tactical_radar;
    y += 50;
    drawBox(sf::FloatRect(x, y, 550, 50));
    drawText(sf::FloatRect(x, y, 250, 50), "Long range radar: ", AlignRight);
    if (drawSelector(sf::FloatRect(x + 250, y, 300, 50), gameGlobalInfo->allow_main_screen_long_range_radar ? "Yes" : "No", 30))
        gameGlobalInfo->allow_main_screen_long_range_radar = !gameGlobalInfo->allow_main_screen_long_range_radar;
    y += 50;
    y += 50;
    drawTextBox(sf::FloatRect(x, y, 550, 50), "Game rules", AlignCenter);
    y += 50;
    drawBox(sf::FloatRect(x, y, 550, 50));
    drawText(sf::FloatRect(x, y, 250, 50), "Frequencies: ", AlignRight);
    if(drawSelector(sf::FloatRect(x + 250, y, 300, 50), gameGlobalInfo->use_beam_shield_frequencies ? "Yes" : "No"))
        gameGlobalInfo->use_beam_shield_frequencies = !gameGlobalInfo->use_beam_shield_frequencies;
    y += 50;
    drawBox(sf::FloatRect(x, y, 550, 50));
    drawText(sf::FloatRect(x, y, 250, 50), "System damage: ", AlignRight);
    if(drawSelector(sf::FloatRect(x + 250, y, 300, 50), gameGlobalInfo->use_system_damage ? "Yes" : "No"))
        gameGlobalInfo->use_system_damage = !gameGlobalInfo->use_system_damage;
    y += 50;

    drawBox(sf::FloatRect(620, 50, 460, 80 + scenarios.size() * 35));
    drawTextBox(sf::FloatRect(620, 50, 460, 50), "Scenario", AlignCenter);
    for(unsigned int n=0; n<scenarios.size(); n++)
    {
        if (drawToggleButton(sf::FloatRect(650, 110 + 35 * n, 400, 35), active_scenario_index == n, scenarios[n].name))
            active_scenario_index = n;
    }
    if (active_scenario_index < scenarios.size())
    {
        drawTextBox(sf::FloatRect(620, 150 + scenarios.size() * 35, 460, 200), scenarios[active_scenario_index].description, AlignTopLeft, 20);
    }

    if (drawButton(sf::FloatRect(200, 800, 300, 50), "Start"))
    {
        startScenario();
        destroy();
        new ShipSelectionScreen();
    }

    if (drawButton(sf::FloatRect(600, 800, 300, 50), "Game Master"))
    {
        startScenario();
        destroy();
        new GameMasterUI();
    }
}

void ServerCreationScreen::startScenario()
{
    P<ScriptObject> script = new ScriptObject();
    script->run(scenarios[active_scenario_index].filename);
    engine->registerObject("scenario", script);
}

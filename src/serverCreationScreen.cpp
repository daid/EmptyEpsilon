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
    game_server->setServerName(textEntry(sf::FloatRect(0, -150, 300, 50), game_server->getServerName()));
    
    keyValueDisplay(sf::FloatRect(100, 50, 500, 50), 0.3, "Name:", game_server->getServerName() + "_");
    keyValueDisplay(sf::FloatRect(100, 100, 500, 50), 0.3, "Ip:", sf::IpAddress::getLocalAddress().toString());
    
    textbox(sf::FloatRect(100, 200, 500, 50), "Player ships", AlignCenter);
    box(sf::FloatRect(100, 250, 500, 50));
    text(sf::FloatRect(100, 250, 200, 50), "Warp/Jump:", AlignRight);
    int offset = selector(sf::FloatRect(300, 250, 300, 50), playerWarpJumpDriveToString(gameGlobalInfo->player_warp_jump_drive_setting), 30);
    gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(int(gameGlobalInfo->player_warp_jump_drive_setting) + offset);
    if (gameGlobalInfo->player_warp_jump_drive_setting < PWJ_ShipDefault)
        gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(int(PWJ_MAX) - 1);
    if (gameGlobalInfo->player_warp_jump_drive_setting >= PWJ_MAX)
        gameGlobalInfo->player_warp_jump_drive_setting = PWJ_ShipDefault;
    box(sf::FloatRect(100, 300, 500, 50));
    text(sf::FloatRect(100, 300, 200, 50), "Radar range:", AlignRight);
    offset = selector(sf::FloatRect(300, 300, 300, 50), string(int(gameGlobalInfo->long_range_radar_range)), 30);
    gameGlobalInfo->long_range_radar_range += offset * 5000.0;
    if (gameGlobalInfo->long_range_radar_range < 10000.0)
        gameGlobalInfo->long_range_radar_range = 10000.0;
    if (gameGlobalInfo->long_range_radar_range > 50000.0)
        gameGlobalInfo->long_range_radar_range = 50000.0;
    box(sf::FloatRect(100, 350, 500, 50));
    text(sf::FloatRect(100, 350, 200, 50), "Frequencies:", AlignRight);
    if(selector(sf::FloatRect(300, 350, 300, 50), gameGlobalInfo->use_beam_shield_frequencies ? "Yes" : "No"))
        gameGlobalInfo->use_beam_shield_frequencies = !gameGlobalInfo->use_beam_shield_frequencies;

    box(sf::FloatRect(620, 50, 460, 80 + scenarios.size() * 35));
    textbox(sf::FloatRect(620, 50, 460, 50), "Scenario", AlignCenter);
    for(unsigned int n=0; n<scenarios.size(); n++)
    {
        if (toggleButton(sf::FloatRect(650, 110 + 35 * n, 400, 35), active_scenario_index == n, scenarios[n].name))
            active_scenario_index = n;
    }
    if (active_scenario_index < scenarios.size())
    {
        textbox(sf::FloatRect(620, 150 + scenarios.size() * 35, 460, 200), scenarios[active_scenario_index].description, AlignTopLeft, 20);
    }
    
    if (button(sf::FloatRect(200, 800, 300, 50), "Start"))
    {
        startScenario();
        destroy();
        new ShipSelectionScreen();
    }

    if (button(sf::FloatRect(600, 800, 300, 50), "Game Master"))
    {
        startScenario();
        destroy();
        new GameMasterUI();
    }
}

int lua_victory(lua_State* L)
{
    gameGlobalInfo->setVictory(luaL_checkstring(L, 1));
    if (engine->getObject("scenario"))
        engine->getObject("scenario")->destroy();
    engine->setGameSpeed(0.0);
    return 0;
}

void ServerCreationScreen::startScenario()
{
    P<ScriptObject> script = new ScriptObject();
    script->registerFunction("victory", lua_victory);
    script->run(scenarios[active_scenario_index].filename);
    engine->registerObject("scenario", script);
}

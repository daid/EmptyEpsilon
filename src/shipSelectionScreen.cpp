#include "shipSelectionScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "mainScreen.h"
#include "crewUI.h"
#include "gameMasterUI.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    active_scenario_index = 0;
    ship_template_index = 0;
    alternative_screen_selection = false;
    window_angle = 0;

    if (game_server)
    {
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
    }
}

void ShipSelectionScreen::onGui()
{
    if (game_client && !game_client->isConnected())
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }
    
    if (alternative_screen_selection)
    {
        if (game_server)
        {
            if (button(sf::FloatRect(800, 100, 300, 50), "Game Master"))
            {
                startScenario();
                
                my_spaceship = NULL;
                my_player_info->setShipId(-1);
                destroy();
                new GameMasterUI();
            }
        }
        if (my_spaceship)
        {
            if (button(sf::FloatRect(800, 150, 300, 50), "Window"))
            {
                startScenario();

                destroy();
                P<ShipWindowUI> ui = new ShipWindowUI();
                ui->window_angle = window_angle;
            }
            window_angle += selector(sf::FloatRect(800, 200, 300, 50), "Window: " + string(window_angle) + "deg", 30) * 15;
            if (window_angle < 0)
                window_angle += 360;
            if (window_angle >= 360)
                window_angle -= 360;
            
            if (button(sf::FloatRect(800, 250, 300, 50), "Top down 3D"))
            {
                startScenario();

                destroy();
                new TopDownUI();
            }
        }
    }else{
        if (my_spaceship)
        {
            int32_t my_ship_id = my_spaceship->getMultiplayerId();

            int main_screen_control_cnt = 0;
            int mainCnt = 0;
            foreach(PlayerInfo, i, playerInfoList)
            {
                if (i->ship_id == my_ship_id && i->isMainScreen())
                    mainCnt++;
                if (i->ship_id == my_ship_id && i->main_screen_control)
                    main_screen_control_cnt++;
            }

            if (toggleButton(sf::FloatRect(800, 100, 300, 50), my_player_info->isMainScreen(), "Main screen", 30))
            {
                for(int n=0; n<max_crew_positions; n++)
                    my_player_info->setCrewPosition(ECrewPosition(n), false);
            }
            text(sf::FloatRect(1100, 100, 300, 50), string(mainCnt));

            float y = 150;
            for(int n=0; n<max_crew_positions; n++)
            {
                if (n == singlePilot) y += 25;
                if (toggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->crew_position[n], getCrewPositionName(ECrewPosition(n))))
                {
                    bool active = !my_player_info->crew_position[n];
                    my_player_info->setCrewPosition(ECrewPosition(n), active);

                    if (active && my_spaceship)
                    {
                        int main_screen_control_cnt = 0;
                        foreach(PlayerInfo, i, playerInfoList)
                        {
                            if (i->ship_id == my_spaceship->getMultiplayerId() && i->main_screen_control)
                                main_screen_control_cnt++;
                        }
                        if (main_screen_control_cnt == 0)
                            my_player_info->setMainScreenControl(true);
                    }
                }
                int cnt = 0;
                foreach(PlayerInfo, i, playerInfoList)
                    if (i->ship_id == my_ship_id && i->crew_position[n])
                        cnt++;
                text(sf::FloatRect(1100, y, 300, 50), string(cnt));
                y += 50;
            }
            y += 25;
            if (!my_player_info->isMainScreen())
            {
                if (toggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->main_screen_control, "Control main screen"))
                    my_player_info->setMainScreenControl(!my_player_info->main_screen_control);
            }else{
                disabledButton(sf::FloatRect(800, y, 300, 50), "Control main screen");
            }
            text(sf::FloatRect(1100, y, 300, 50), string(main_screen_control_cnt));

            if (button(sf::FloatRect(800, 600, 300, 50), "Ready"))
            {
                startScenario();
                destroy();
                my_player_info->spawnUI();
            }

            if (active_scenario_index < int(scenarios.size()) && !engine->getObject("scenario"))
            {
                active_scenario_index += selector(sf::FloatRect(800, 650, 300, 50), scenarios[active_scenario_index].name);
                if (active_scenario_index < 0)
                    active_scenario_index = scenarios.size() - 1;
                if (active_scenario_index >= int(scenarios.size()))
                    active_scenario_index = 0;
                text(sf::FloatRect(800, 700, 300, 20), scenarios[active_scenario_index].description, AlignRight, 15);
            }
        }
    }

    for(int n=0; n<GameGlobalInfo::maxPlayerShips; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship && ship->ship_template)
        {
            if (n < 8)
            {
                if (toggleButton(sf::FloatRect(200, 150 + (n % 8) * 50, 300, 50), my_spaceship == ship, ship->ship_template->name + " " + string(n + 1)))
                {
                    my_spaceship = ship;
                    my_player_info->setShipId(my_spaceship->getMultiplayerId());
                }
            }else{
                if (toggleButton(sf::FloatRect(200 + 200 + (n / 8) * 100, 150 + (n % 8) * 50, 100, 50), my_spaceship == ship, string(n + 1)))
                {
                    my_spaceship = ship;
                    my_player_info->setShipId(my_spaceship->getMultiplayerId());
                }
            }
        }
    }

    if (game_server)
    {
        std::vector<string> templates = ShipTemplate::getPlayerTemplateNameList();
        game_server->setServerName(textEntry(sf::FloatRect(200, 50, 300, 50), game_server->getServerName()));
        text(sf::FloatRect(200, 100, 300, 50), sf::IpAddress::getLocalAddress().toString(), AlignCenter, 30);

        if (ship_template_index < int(templates.size()))
        {
            ship_template_index += selector(sf::FloatRect(200, 650, 300, 50), templates[ship_template_index]);
            if (ship_template_index < 0)
                ship_template_index = templates.size() - 1;
            if (ship_template_index >= int(templates.size()))
                ship_template_index = 0;
        }
        if (button(sf::FloatRect(200, 600, 300, 50), "Spawn player ship"))
        {
            my_spaceship = new PlayerSpaceship();
            my_spaceship->setShipTemplate(templates[ship_template_index]);
            my_spaceship->setRotation(random(0, 360));
            my_spaceship->targetRotation = my_spaceship->getRotation();
            my_spaceship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
            my_player_info->setShipId(my_spaceship->getMultiplayerId());
            if (gameGlobalInfo->insertPlayerShip(my_spaceship) < 0)
            {
                my_spaceship->destroy();
            }
        }
    }

    if (button(sf::FloatRect(500, 800, 300, 50), "Other options"))
    {
        alternative_screen_selection = !alternative_screen_selection;
        for(int n=0; n<max_crew_positions; n++)
            my_player_info->setCrewPosition(ECrewPosition(n), false);
    }
    
    if (game_server)
    {
        if (button(sf::FloatRect(50, 800, 300, 50), "Close server"))
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }
    }else{
        if (button(sf::FloatRect(50, 800, 300, 50), "Disconnect"))
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }
    }
}

int lua_victory(lua_State* L)
{
    int victory_faction = luaL_checkinteger(L, 1);
    gameGlobalInfo->setVictory(victory_faction);
    engine->getObject("scenario")->destroy();
    engine->setGameSpeed(0.0);
    return 0;
}

void ShipSelectionScreen::startScenario()
{
    if (game_server && !engine->getObject("scenario") && active_scenario_index < int(scenarios.size()))
    {
        P<ScriptObject> script = new ScriptObject();
        script->registerFunction("victory", lua_victory);
        script->run(scenarios[active_scenario_index].filename);
        engine->registerObject("scenario", script);
    }
}

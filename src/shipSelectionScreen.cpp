#include "shipSelectionScreen.h"
#include "epsilonServer.h"
#include "mainMenus.h"
#include "playerInfo.h"
#include "mainScreen.h"
#include "crewUI.h"
#include "gameMasterUI.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    active_scenario_index = 0;
    ship_template_index = 0;

    if (gameServer)
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
    if (gameClient && !gameClient->isConnected())
    {
        destroy();
        disconnectFromServer();
        new MainMenu();
        return;
    }

    if (mySpaceship)
    {
        int32_t my_ship_id = mySpaceship->getMultiplayerId();

        int main_screen_control_cnt = 0;
        int mainCnt = 0;
        foreach(PlayerInfo, i, playerInfoList)
        {
            if (i->ship_id == my_ship_id && i->isMainScreen())
                mainCnt++;
            if (i->ship_id == my_ship_id && i->main_screen_control)
                main_screen_control_cnt++;
        }

        text(sf::FloatRect(800, 100, 300, 50), string(my_player_info->isMainScreen() ? "*" : " ") + "Main screen", AlignCenter);
        text(sf::FloatRect(1100, 100, 300, 50), string(mainCnt));

        float y = 150;
        for(int n=0; n<max_crew_positions; n++)
        {
            if (n == singlePilot) y += 25;
            if (toggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->crew_position[n], getCrewPositionName(ECrewPosition(n))))
            {
                my_player_info->setCrewPosition(ECrewPosition(n), !my_player_info->crew_position[n]);
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
            if (gameServer && !engine->getObject("scenario") && active_scenario_index < int(scenarios.size()))
                engine->registerObject("scenario", new ScriptObject(scenarios[active_scenario_index].filename));
            destroy();
            if (my_player_info->isMainScreen())
            {
                new MainScreenUI();
            }else{
                new CrewUI();
            }
        }
    }

    for(int n=0; n<GameGlobalInfo::maxPlayerShips; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship && ship->shipTemplate)
        {
            if (n < 8)
            {
                if (toggleButton(sf::FloatRect(200, 150 + (n % 8) * 50, 300, 50), mySpaceship == ship, ship->shipTemplate->name + " " + string(n + 1)))
                {
                    mySpaceship = ship;
                    my_player_info->setShipId(mySpaceship->getMultiplayerId());
                }
            }else{
                if (toggleButton(sf::FloatRect(200 + 200 + (n / 8) * 100, 150 + (n % 8) * 50, 100, 50), mySpaceship == ship, string(n + 1)))
                {
                    mySpaceship = ship;
                    my_player_info->setShipId(mySpaceship->getMultiplayerId());
                }
            }
        }
    }

    if (gameServer)
    {
        std::vector<string> templates = ShipTemplate::getPlayerTemplateNameList();
        gameServer->setServerName(textEntry(sf::FloatRect(200, 50, 300, 50), gameServer->getServerName()));
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
            mySpaceship = new PlayerSpaceship();
            mySpaceship->setShipTemplate(templates[ship_template_index]);
            mySpaceship->setRotation(random(0, 360));
            mySpaceship->targetRotation = mySpaceship->getRotation();
            mySpaceship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
            my_player_info->setShipId(mySpaceship->getMultiplayerId());
            if (gameGlobalInfo->insertPlayerShip(mySpaceship) < 0)
            {
                mySpaceship->destroy();
            }
        }

        if (button(sf::FloatRect(1200, 150, 300, 50), "Game Master"))
        {
            if (gameServer && !engine->getObject("scenario") && active_scenario_index < int(scenarios.size()))
                engine->registerObject("scenario", new ScriptObject(scenarios[active_scenario_index].filename));

            mySpaceship = NULL;
            my_player_info->setShipId(-1);
            destroy();
            new GameMasterUI();
        }

        if (button(sf::FloatRect(50, 800, 300, 50), "Close server"))
        {
            destroy();
            disconnectFromServer();
            new MainMenu();
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
    }else{
        if (button(sf::FloatRect(50, 800, 300, 50), "Disconnect"))
        {
            destroy();
            disconnectFromServer();
            new MainMenu();
        }
    }
}

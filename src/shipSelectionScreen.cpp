#include "shipSelectionScreen.h"
#include "epsilonServer.h"
#include "mainMenus.h"
#include "playerInfo.h"
#include "mainScreen.h"
#include "crewUI.h"
#include "gameMasterUI.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    if (gameServer)
    {
        std::vector<string> scenarios = findResources("scenario_*.lua");
    }
}

void ShipSelectionScreen::onGui()
{
    int32_t my_ship_id = -1;
    if (mySpaceship)
        my_ship_id = mySpaceship->getMultiplayerId();
    {
        int mainCnt = 0;
        foreach(PlayerInfo, i, playerInfoList)
        {
            if (i->ship_id == my_ship_id && i->isMainScreen())
                mainCnt++;
        }

        text(sf::FloatRect(800, 100, 300, 50), string(myPlayerInfo->isMainScreen() ? "*" : " ") + "Main screen", AlignCenter);
        text(sf::FloatRect(1100, 100, 300, 50), string(mainCnt));
    }
    for(int n=0; n<maxCrewPositions; n++)
    {
        if (toggleButton(sf::FloatRect(800, 150 + 50 * n, 300, 50), myPlayerInfo->crewPosition[n], getCrewPositionName(ECrewPosition(n))))
        {
            myPlayerInfo->setCrewPosition(ECrewPosition(n), !myPlayerInfo->crewPosition[n]);
        }
        int cnt = 0;
        foreach(PlayerInfo, i, playerInfoList)
            if (i->ship_id == my_ship_id && i->crewPosition[n])
                cnt++;
        text(sf::FloatRect(1100, 150 + 50 * n, 300, 50), string(cnt));
    }

    if (mySpaceship)
    {
        if (button(sf::FloatRect(800, 700, 300, 50), "Ready"))
        {
            destroy();
            if (myPlayerInfo->isMainScreen())
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
                if (toggleButton(sf::FloatRect(200, 250 + (n % 8) * 50, 300, 50), mySpaceship == ship, ship->shipTemplate->name + " " + string(n)))
                {
                    mySpaceship = ship;
                    myPlayerInfo->setShipId(mySpaceship->getMultiplayerId());
                }
            }else{
                if (toggleButton(sf::FloatRect(200 + 200 + (n / 8) * 100, 250 + (n % 8) * 50, 100, 50), mySpaceship == ship, string(n)))
                {
                    mySpaceship = ship;
                    myPlayerInfo->setShipId(mySpaceship->getMultiplayerId());
                }
            }
        }
    }

    if (gameServer)
    {
        gameServer->setServerName(textEntry(sf::FloatRect(200, 50, 300, 50), gameServer->getServerName()));
        text(sf::FloatRect(200, 100, 300, 50), sf::IpAddress::getLocalAddress().toString(), AlignCenter, 30);
        if (button(sf::FloatRect(200, 700, 300, 50), "Spawn player ship"))
        {
            mySpaceship = new PlayerSpaceship();
            mySpaceship->setShipTemplate("Player Cruiser");
            mySpaceship->setRotation(random(0, 360));
            mySpaceship->targetRotation = mySpaceship->getRotation();
            mySpaceship->setPosition(sf::Vector2f(random(-10, 10), random(-10, 10)));
            myPlayerInfo->setShipId(mySpaceship->getMultiplayerId());
            if (gameGlobalInfo->insertPlayerShip(mySpaceship) < 0)
            {
                mySpaceship->destroy();
            }
        }
        
        if (button(sf::FloatRect(1200, 150, 300, 50), "Game Master"))
        {
            mySpaceship = NULL;
            myPlayerInfo->setShipId(-1);
            destroy();
            new GameMasterUI();
        }

        if (button(sf::FloatRect(50, 800, 300, 50), "Close server"))
        {
            destroy();
            disconnectFromServer();
            new MainMenu();
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

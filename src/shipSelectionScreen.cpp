#include "shipSelectionScreen.h"
#include "playerInfo.h"
#include "mainScreen.h"
#include "crewUI.h"

ShipSelectionScreen::ShipSelectionScreen()
{
}

void ShipSelectionScreen::onGui()
{
    {
        int mainCnt = 0;
        foreach(PlayerInfo, i, playerInfoList)
        {
            if (i->isMainScreen())
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
            if (i->crewPosition[n])
                cnt++;
        text(sf::FloatRect(1100, 150 + 50 * n, 300, 50), string(cnt));
    }

    if (gameServer)
    {
        if (button(sf::FloatRect(200, 700, 300, 50), "Spawn new ship"))
        {
            mySpaceship = new PlayerSpaceship();
            mySpaceship->setShipTemplate("Player Cruiser");
            mySpaceship->setRotation(random(0, 360));
            mySpaceship->setPosition(sf::Vector2f(random(-10, 10), random(-10, 10)));
            if (gameGlobalInfo->insertPlayerShip(mySpaceship) < 0)
            {
                mySpaceship->destroy();
            }
        }
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
            if (toggleButton(sf::FloatRect(200 + (n / 8) * 300, 250 + (n % 8) * 50, 300, 50), mySpaceship == ship, ship->shipTemplate->name + " " + string(n)))
                mySpaceship = ship;
        }
    }
    
    if (button(sf::FloatRect(1350, 830, 200, 50), "Quit game"))
        engine->shutdown();
}

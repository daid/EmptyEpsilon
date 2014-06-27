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
        foreach(PlayerInfo, i, player_info_list)
        {
            if (i->isMainScreen())
                mainCnt++;
        }

        text(sf::FloatRect(800, 100, 300, 50), string(my_player_info->isMainScreen() ? "*" : " ") + "Main screen", AlignCenter);
        text(sf::FloatRect(1100, 100, 300, 50), string(mainCnt));
    }
    for(int n = 0; n < max_crew_positions; n++)
    {
        if (toggleButton(sf::FloatRect(800, 150 + 50 * n, 300, 50), my_player_info->crewPosition[n], getCrewPositionName(ECrewPosition(n))))
        {
            my_player_info->setCrewPosition(ECrewPosition(n), !my_player_info->crewPosition[n]);
        }
        int cnt = 0;
        foreach(PlayerInfo, i, player_info_list)
            if (i->crewPosition[n])
                cnt++;
        text(sf::FloatRect(1100, 150 + 50 * n, 300, 50), string(cnt));
    }

    if (gameServer)
    {
        if (button(sf::FloatRect(800, 800, 300, 50), "Launch vessel"))
        {
            destroy();
            if (game_global_info->findPlayerShip(my_spaceship) < 0)
                game_global_info->insertPlayerShip(my_spaceship);
            if (my_player_info->isMainScreen())
            {
                new MainScreenUI();
            }else{
                new CrewUI();
            }
        }
    }
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        if (game_global_info->getPlayerShip(n))
        {
            if (button(sf::FloatRect(200, 300 + n * 50, 300, 50), "Join vessel " + string(n)))
            {
                my_spaceship = game_global_info->getPlayerShip(n);
                destroy();
                if (my_player_info->isMainScreen())
                {
                    new MainScreenUI();
                }else{
                    new CrewUI();
                }
            }
        }
    }
}

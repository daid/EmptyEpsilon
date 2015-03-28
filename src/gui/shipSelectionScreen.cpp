#include "shipSelectionScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "mainScreen.h"
#include "crewUI.h"
#include "gameMasterUI.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    ship_template_index = 0;
    alternative_screen_selection = false;
    window_angle = 0;
}

void ShipSelectionScreen::onGui()
{
    //Easiest place to ensure that positional sound is disabled on console views. As soon as a 3D view is rendered positional sound is enabled again.
    soundManager.disablePositionalSound();

    if (game_client && !game_client->isConnected())
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }

    drawBox(sf::FloatRect(780, 30, 340, 540));
    drawBox(sf::FloatRect(780, 80, 340, 490));
    if (alternative_screen_selection)
    {
        drawText(sf::FloatRect(780, 30, 340, 50), "Alternative options", AlignCenter);
        if (game_server)
        {
            if (drawButton(sf::FloatRect(800, 100, 300, 50), "Game Master"))
            {
                my_spaceship = NULL;
                my_player_info->setShipId(-1);
                destroy();
                new GameMasterUI();
            }
        }
        if (my_spaceship)
        {
            if (canDoMainScreen())
            {
                if (drawButton(sf::FloatRect(800, 150, 300, 50), "Window"))
                {
                    destroy();
                    P<ShipWindowUI> ui = new ShipWindowUI();
                    ui->window_angle = window_angle;
                }
                window_angle += drawSelector(sf::FloatRect(800, 200, 300, 50), "Window: " + string(window_angle) + "deg", 30) * 15;
                if (window_angle < 0)
                    window_angle += 360;
                if (window_angle >= 360)
                    window_angle -= 360;

                if (drawButton(sf::FloatRect(800, 250, 300, 50), "Top down 3D"))
                {
                    destroy();
                    new TopDownUI();
                }
            }
        }else{
            drawText(sf::FloatRect(800, 150, 300, 50), "Select a ship", AlignCenter, 30);
        }
    }else{
        drawText(sf::FloatRect(780, 30, 340, 50), "Normal options", AlignCenter);
        if (my_spaceship)
        {
            int32_t my_ship_id = my_spaceship->getMultiplayerId();

            int main_screen_control_count = 0;
            int main_count = 0;
            foreach(PlayerInfo, i, player_info_list)
            {
                if (i->ship_id == my_ship_id && i->isMainScreen())
                    main_count++;
                if (i->ship_id == my_ship_id && i->main_screen_control)
                    main_screen_control_count++;
            }

            if (canDoMainScreen())
            {
                if (drawToggleButton(sf::FloatRect(800, 100, 300, 50), my_player_info->isMainScreen(), "Main screen", 30))
                {
                    for(int n=0; n<max_crew_positions; n++)
                        my_player_info->setCrewPosition(ECrewPosition(n), false);
                }
            }else{
                drawDisabledButton(sf::FloatRect(800, 100, 300, 50), "Main screen", 30);
            }
            drawText(sf::FloatRect(800, 100, 280, 50), string(main_count), AlignRight, 30, sf::Color::Black);

            float y = 150;
            for(int n=0; n < max_crew_positions; n++)
            {
                if (n == singlePilot) y += 25;
                if (drawToggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->crew_position[n], getCrewPositionName(ECrewPosition(n))))
                {
                    bool active = !my_player_info->crew_position[n];
                    my_player_info->setCrewPosition(ECrewPosition(n), active);
                }
                int cnt = 0;
                foreach(PlayerInfo, i, player_info_list)
                    if (i->ship_id == my_ship_id && i->crew_position[n])
                        cnt++;
                drawText(sf::FloatRect(800, y, 280, 50), string(cnt), AlignRight, 30, sf::Color::Black);
                y += 50;
            }
            y += 25;
            if (!my_player_info->isMainScreen())
            {
                if (drawToggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->main_screen_control, "Main screen ctrl"))
                    my_player_info->setMainScreenControl(!my_player_info->main_screen_control);
            }else{
                drawDisabledButton(sf::FloatRect(800, y, 300, 50), "Main screen ctrl");
            }
            drawText(sf::FloatRect(800, y, 280, 50), string(main_screen_control_count), AlignRight, 30, sf::Color::Black);

            if (drawButton(sf::FloatRect(800, 600, 300, 50), "Ready"))
            {
                destroy();
                my_player_info->spawnUI();
            }
        }else{
            drawText(sf::FloatRect(800, 100, 300, 50), "Select a ship", AlignCenter, 30);
        }
    }

    int shipCount = 0;
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship && ship->ship_template)
        {
            if (n < 8)
            {
                if (drawToggleButton(sf::FloatRect(200, 150 + (n % 8) * 50, 300, 50), my_spaceship == ship, ship->ship_type_name + " " + string(n + 1)))
                {
                    my_spaceship = ship;
                    my_player_info->setShipId(my_spaceship->getMultiplayerId());
                }
            }else{
                if (drawToggleButton(sf::FloatRect(200 + 200 + (n / 8) * 100, 150 + (n % 8) * 50, 100, 50), my_spaceship == ship, string(n + 1)))
                {
                    my_spaceship = ship;
                    my_player_info->setShipId(my_spaceship->getMultiplayerId());
                }
            }
            shipCount++;
        }
    }
    if (shipCount == 0)
    {
        drawTextBox(sf::FloatRect(200, 150, 300, 100), "Waiting for server to spawn a ship", AlignCenter, 30);
    }

    if (game_server)
    {
        std::vector<string> templates = ShipTemplate::getPlayerTemplateNameList();
        drawTextBox(sf::FloatRect(200, 50, 300, 50), game_server->getServerName(), AlignCenter);
        drawText(sf::FloatRect(200, 100, 300, 50), sf::IpAddress::getLocalAddress().toString(), AlignCenter, 30);

        if (ship_template_index < int(templates.size()))
        {
            ship_template_index += drawSelector(sf::FloatRect(200, 650, 300, 50), templates[ship_template_index]);
            if (ship_template_index < 0)
                ship_template_index = templates.size() - 1;
            if (ship_template_index >= int(templates.size()))
                ship_template_index = 0;
        }
        if (drawButton(sf::FloatRect(200, 600, 300, 50), "Spawn player ship"))
        {
            my_spaceship = new PlayerSpaceship();
            if (my_spaceship)
            {
                my_spaceship->setShipTemplate(templates[ship_template_index]);
                my_spaceship->setRotation(random(0, 360));
                my_spaceship->target_rotation = my_spaceship->getRotation();
                my_spaceship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
                my_player_info->setShipId(my_spaceship->getMultiplayerId());
            }
        }
    }

    if (drawButton(sf::FloatRect(500, 800, 300, 50), "Other options"))
    {
        alternative_screen_selection = !alternative_screen_selection;
        for(int n=0; n<max_crew_positions; n++)
            my_player_info->setCrewPosition(ECrewPosition(n), false);
    }

    if (game_server)
    {
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Close server"))
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }
    }else{
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Disconnect"))
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }
    }
}

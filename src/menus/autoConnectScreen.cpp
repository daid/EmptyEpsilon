#include "main.h"
#include "autoConnectScreen.h"
#include "epsilonServer.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"

#include "gui/gui2_label.h"

AutoConnectScreen::AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen, int ship_index)
: crew_position(crew_position), control_main_screen(control_main_screen), ship_index(ship_index)
{
    scanner = new ServerScanner(VERSION_NUMBER);
    scanner->scanLocalNetwork();
    
    status_label = new GuiLabel(this, "STATUS", "Searching for server...", 50);
    status_label->setPosition(0, 300, ATopCenter)->setSize(0, 50);

    string position_name = "Main screen";
    if (crew_position < max_crew_positions)
        position_name = getCrewPositionName(crew_position);

    (new GuiLabel(this, "POSITION", position_name, 50))->setPosition(0, 400, ATopCenter)->setSize(0, 30);
}

AutoConnectScreen::~AutoConnectScreen()
{
    if (scanner)
        scanner->destroy();
}

void AutoConnectScreen::update(float delta)
{
    if (scanner)
    {
        std::vector<ServerScanner::ServerInfo> serverList = scanner->getServerList();

        if (serverList.size() > 0)
        {
            status_label->setText("Found server " + serverList[0].name);
            connect_to_address = serverList[0].address;
            new GameClient(VERSION_NUMBER, serverList[0].address);
            scanner->destroy();
        }else{
            status_label->setText("Searching for server...");
        }
    }else{
        switch(game_client->getStatus())
        {
        case GameClient::ReadyToConnect:
        case GameClient::Connecting:
        case GameClient::Authenticating:
            status_label->setText("Connecting: " + connect_to_address.toString());
            break;
        case GameClient::WaitingForPassword: //For now, just disconnect when we found a password protected server.
        case GameClient::Disconnected:
            disconnectFromServer();
            scanner = new ServerScanner(VERSION_NUMBER);
            scanner->scanLocalNetwork();
            break;
        case GameClient::Connected:
            if (game_client->getClientId() > 0)
            {
                foreach(PlayerInfo, i, player_info_list)
                    if (i->client_id == game_client->getClientId())
                        my_player_info = i;
                if (my_player_info && gameGlobalInfo)
                {
                    status_label->setText("Waiting for ship...");
                    if (!my_spaceship)
                    {
                        if (ship_index >= 0 && ship_index < GameGlobalInfo::max_player_ships)
                        {
                            checkForPlayerShip(ship_index);
                        }else{
                            for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
                            {
                                checkForPlayerShip(n);
                            }
                        }
                    }else{
                        if (my_spaceship->getMultiplayerId() == my_player_info->ship_id && (crew_position == max_crew_positions || my_player_info->crew_position[crew_position]))
                        {
                            destroy();
                            my_player_info->spawnUI();
                        }
                    }
                }else{
                    status_label->setText("Connected, waiting for game data...");
                }
            }
            break;
        }
    }
}

void AutoConnectScreen::checkForPlayerShip(int index)
{
    P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(index);
    if (ship && ship->ship_template)
    {
        int cnt = 0;
        foreach(PlayerInfo, i, player_info_list)
        {
            if (i->ship_id == ship->getMultiplayerId())
            {
                if (crew_position != max_crew_positions && i->crew_position[crew_position])
                    cnt++;
            }
        }
        if (cnt == 0)
        {
            if (crew_position != max_crew_positions)
            {
                my_player_info->setCrewPosition(crew_position, true);
                my_player_info->setMainScreenControl(control_main_screen);
            }
            my_player_info->setShipId(ship->getMultiplayerId());
            my_spaceship = ship;
        }
    }
}

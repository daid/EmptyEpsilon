#include "main.h"
#include "i18n.h"
#include "autoConnectScreen.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"
#include "multiplayer_client.h"
#include "multiplayer_server_scanner.h"
#include "ecs/query.h"
#include "components/faction.h"
#include "components/name.h"
#include "screens/windowScreen.h"
#include "config.h"

#include "gui/gui2_label.h"


AutoConnectScreen::AutoConnectScreen(CrewPosition crew_position, bool control_main_screen, string ship_filter)
: crew_position(crew_position), control_main_screen(control_main_screen)
{
    if (!game_client)
    {
        scanner = new ServerScanner(VERSION_NUMBER);
        scanner->scanLocalNetwork();
    }

    status_label = new GuiLabel(this, "STATUS", "Searching for server...", 50);
    status_label->setPosition(0, 300, sp::Alignment::TopCenter)->setSize(0, 50);

    string position_name = "Main screen";
    if (crew_position_raw >= 1000 && crew_position_raw <= 1360)
        position_name = tr("Ship window");
    if (crew_position != CrewPosition::MAX)
        position_name = getCrewPositionName(crew_position);

    (new GuiLabel(this, "POSITION", position_name, 50))->setPosition(0, 400, sp::Alignment::TopCenter)->setSize(0, 30);

    for(string filter : ship_filter.split(";"))
    {
        std::vector<string> key_value = filter.split("=", 1);
        string key = key_value[0].strip().lower();
        if (key.length() < 1)
            continue;

        if (key_value.size() == 1)
            ship_filters[key] = "1";
        else if (key_value.size() == 2)
            ship_filters[key] = key_value[1].strip();
        LOG(INFO) << "Auto connect filter: " << key << " = " << ship_filters[key];
    }

    if (PreferencesManager::get("instance_name") != "")
    {
        (new GuiLabel(this, "", PreferencesManager::get("instance_name"), 25))->setAlignment(sp::Alignment::CenterLeft)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(0, 18);
    }
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
        string autoconnect_address = PreferencesManager::get("autoconnect_address", "");

        if (autoconnect_address != "") {
            status_label->setText("Using autoconnect server " + autoconnect_address);
            connect_to_address = autoconnect_address;
            new GameClient(VERSION_NUMBER, autoconnect_address);
            scanner->destroy();
        } else {
            auto name_filter = PreferencesManager::get("autoconnect_servername", "");
            for (auto server : serverList) {
                if (name_filter != "" && name_filter != server.name)
                    continue;

                status_label->setText("Found server " + server.name);
                connect_to_address = server.address;
                new GameClient(VERSION_NUMBER, server.address);
                scanner->destroy();
                return;
            }

            status_label->setText("Searching for server...");
        }
    }else{
        switch(game_client->getStatus())
        {
        case GameClient::Connecting:
        case GameClient::Authenticating:
            if (!connect_to_address.getHumanReadable().empty())
                status_label->setText("Connecting: " + connect_to_address.getHumanReadable()[0]);
            else
                status_label->setText("Connecting...");
            break;
        case GameClient::WaitingForPassword:
            if (!tried_password) {
                auto password = PreferencesManager::get("autoconnect_password");
                if (password != "") {
                    game_client->sendPassword(password.upper());
                    tried_password = true;
                    return;
                }
            }
            // if we don't have a password or we already tried it and it didn't work,
            // fallthrough
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
                    my_player_info->commandSetName(PreferencesManager::get("username"));
                    if (!connect_to_address.getHumanReadable().empty())
                        status_label->setText("Waiting for ship on " + connect_to_address.getHumanReadable()[0] + "...");
                    else
                        status_label->setText("Waiting for ship...");
                    if (!my_spaceship)
                    {
                        for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
                        {
                            if (isValidShip(entity))
                            {
                                connectToShip(entity);
                                break;
                            }
                        }
                    } else {
                        if (my_spaceship == my_player_info->ship && (crew_position == CrewPosition::MAX || my_player_info->hasPosition(crew_position)))
                        {
                            destroy();
                            if (crew_position_raw >=1000 && crew_position_raw<=1360){
                                uint8_t window_flags = PreferencesManager::get("ship_window_flags", "1").toInt();
                                new WindowScreen(getRenderLayer(), crew_position_raw-1000, window_flags);
                            } else{
                                my_player_info->spawnUI(0, getRenderLayer());
                            }
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

bool AutoConnectScreen::isValidShip(sp::ecs::Entity ship)
{
    if (!ship)
        return false;

    for(auto it : ship_filters)
    {
        if (it.first == "solo")
        {
            int crew_at_position = 0;
            foreach(PlayerInfo, i, player_info_list)
            {
                if (i->ship == ship)
                {
                    if (crew_position != CrewPosition::MAX && i->hasPosition(crew_position))
                        crew_at_position++;
                }
            }
            if (crew_at_position > 0)
                return false;
        }
        else if (it.first == "faction")
        {
            if (&Faction::getInfo(ship) != FactionInfo::find(it.second))
                return false;
        }
        else if (it.first == "callsign")
        {
            auto cs = ship.getComponent<CallSign>();
            if (!cs || cs->callsign.lower() != it.second.lower())
                return false;
        }
        else if (it.first == "type")
        {
            auto tn = ship.getComponent<TypeName>();
            if (!tn || tn->type_name.lower() != it.second.lower())
                return false;
        }
        else
        {
            LOG(WARNING) << "Unknown ship filter: " << it.first << " = " << it.second;
        }
    }
    return true;
}

void AutoConnectScreen::connectToShip(sp::ecs::Entity ship)
{
    if (crew_position != CrewPosition::MAX)    //If we are not the main screen, setup the right crew position.
    {
        my_player_info->commandSetCrewPosition(0, crew_position, true);
        my_player_info->commandSetMainScreenControl(0, control_main_screen);
    } else {
        my_player_info->commandSetMainScreen(0, true);
    }
    my_player_info->commandSetShip(ship);
}

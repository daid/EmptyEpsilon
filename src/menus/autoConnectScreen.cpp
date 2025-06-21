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


AutoConnectScreen::AutoConnectScreen(std::vector<AutoConnectPosition> positions, bool control_main_screen, string ship_filter)
: positions(positions), control_main_screen(control_main_screen)
{
    if (positions.size() < 1)
        positions = {AutoConnectPosition("helms")};

    if (!game_client)
    {
        scanner = new ServerScanner(VERSION_NUMBER);
        scanner->scanLocalNetwork();
    }

    status_label = new GuiLabel(this, "STATUS", "Searching for server...", 50);
    status_label->setPosition(0, 300, sp::Alignment::TopCenter)->setSize(0, 50);

    (new GuiLabel(this, "POSITION", positions[0].describe(), 50))->setPosition(0, 400, sp::Alignment::TopCenter)->setSize(0, 30);

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

        if (!autoconnect_address.empty())
        {
            // Set autoconnect_port. If autoconnect_address specifies a port,
            // use that. Otherwise, use defaultServerPort.
            autoconnect_address = autoconnect_address.strip();
            int autoconnect_port = defaultServerPort;
            if (autoconnect_address.find(":") != -1)
            {
                autoconnect_port = autoconnect_address.substr(autoconnect_address.find(":") + 1).toInt();
                autoconnect_address = autoconnect_address.substr(0, autoconnect_address.find(":"));
                if (autoconnect_port < 10 || autoconnect_port > 65535)
                {
                    LOG(WARNING) << "Invalid autoconnect port " << autoconnect_port << ". Using default port " << defaultServerPort;
                    autoconnect_port = defaultServerPort;
                }
            }
            status_label->setText("Using autoconnect server " + autoconnect_address + ":" + std::to_string(autoconnect_port));
            connect_to_address = autoconnect_address;
            connect_to_port = autoconnect_port;
            tried_password = false;
            new GameClient(VERSION_NUMBER, connect_to_address, connect_to_port);
            scanner->destroy();
        } else {
            auto name_filter = PreferencesManager::get("autoconnect_servername", "");
            for (auto server : serverList) {
                if (name_filter != "" && name_filter != server.name)
                    continue;

                status_label->setText("Found server " + server.name);
                connect_to_address = server.address;
                connect_to_port = defaultServerPort;
                tried_password = false;
                new GameClient(VERSION_NUMBER, connect_to_address, connect_to_port);
                scanner->destroy();
                return;
            }

            status_label->setText("Searching for server...");
        }
    } else {
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
                        if (my_spaceship == my_player_info->ship)
                        {
                            destroy();
                            for (unsigned idx = 0; idx < positions.size() && idx < window_render_layers.size(); idx++)
                            {
                                auto pos = positions[idx];
                                auto layer = window_render_layers[idx];

                                if (pos.is_ship_window) {
                                    // TODO currently all ship windows share one angle
                                    uint8_t window_flags = PreferencesManager::get("ship_window_flags", "1").toInt();
                                    new WindowScreen(layer, pos.ship_window_angle, window_flags);
                                } else {
                                    my_player_info->spawnUI(idx, layer);
                                }
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
                    for (auto position : positions)
                        for (auto crew_position : position.crew_positions)
                            if (i->hasPosition(crew_position))
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
    int idx = 0;
    for (auto pos : positions)
    {
        for (auto crew_position : pos.crew_positions)
            my_player_info->commandSetCrewPosition(idx, crew_position, true);

        my_player_info->commandSetMainScreenControl(idx, control_main_screen);

        if (pos.is_main_screen)
            my_player_info->commandSetMainScreen(idx, true);

        idx++;
    }

    my_player_info->commandSetShip(ship);
}

AutoConnectPosition::AutoConnectPosition(string value)
{
    for (auto part : value.split(",")) {
        CrewPosition crew_position;
        auto parse_result = tryParseCrewPosition(part);
        if (parse_result.has_value()) {
            crew_position = *parse_result;
        } else {
            auto pos = part.toInt();
            if (!pos) {
                LOG(ERROR) << "Unknown crew position " << part;
                continue;
            }

            if (pos >= 1000 && pos <= 1360) {
                is_ship_window = true;
                ship_window_angle = pos - 1000;
                continue;
            }

            if (pos < 0) pos = 0;
            if (pos > static_cast<int>(CrewPosition::MAX)) pos = static_cast<int>(CrewPosition::MAX);
            crew_position = CrewPosition(pos);
        }

        if (crew_position == CrewPosition::MAX)
            is_main_screen = true;
        else
            crew_positions.add(crew_position);
    }
}

string AutoConnectPosition::describe()
{
    if (is_ship_window)
        return tr("Ship window");

    if (is_main_screen)
        return tr("Main screen");

    for (auto pos : crew_positions)
        return getCrewPositionName(pos);

    return "None";
}

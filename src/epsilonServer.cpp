#include "epsilonServer.h"
#include "components/maneuveringthrusters.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "soundManager.h"
#include "multiplayer_client.h"
#include "preferenceManager.h"
#include "GMActions.h"
#include "main.h"
#include "config.h"


EpsilonServer::EpsilonServer(int server_port)
: GameServer("Server", VERSION_NUMBER, server_port)
{
    if (game_server)
    {
        new GameGlobalInfo();
        new GameMasterActions();
        PlayerInfo* info = new PlayerInfo();
        info->client_id = 0;
        my_player_info = info;
        engine->setGameSpeed(0.0);

        for(auto proxy : PreferencesManager::get("serverproxy").split(":"))
        {
            if (proxy != "")
                connectToProxy(sp::io::network::Address(proxy));
        }
    }
}

void EpsilonServer::onNewClient(int32_t client_id)
{
    LOG(INFO) << "New client: " << client_id;
    PlayerInfo* info = new PlayerInfo();
    info->client_id = client_id;
}

void EpsilonServer::onDisconnectClient(int32_t client_id)
{
    LOG(INFO) << "Client left: " << client_id;
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->client_id == client_id)
        {
            for (auto position : i->crew_positions)
            {
                // Stop manual rotation if the player was controlling a ship.
                // Might be prudent to also stop impulse, warp, etc.
                if (position.has(CrewPosition::helmsOfficer)
                    || position.has(CrewPosition::tacticalOfficer)
                    || position.has(CrewPosition::singlePilot))
                {
                    if (auto thrusters = i->ship.getComponent<ManeuveringThrusters>())
                        thrusters->stop();
                }
            }
            i->destroy();
        }
    }
    player_info_list.update();
}

void disconnectFromServer()
{
    soundManager->stopMusic();

    if (game_client)
        game_client->destroy();
    if (game_server)
        game_server->destroy();
    if (gameGlobalInfo)
        gameGlobalInfo->destroy();
    if (gameMasterActions)
        gameMasterActions->destroy();
    foreach(PlayerInfo, i, player_info_list)
        i->destroy();
    if (my_player_info)
        my_player_info->destroy();
}

std::unordered_set<int32_t> EpsilonServer::onVoiceChat(int32_t client_id, int32_t target_identifier)
{
    if (target_identifier == 0)
    {
        //Communicate to local ship.
        sp::ecs::Entity ship;
        foreach(PlayerInfo, i, player_info_list)
            if (i->client_id == client_id)
                ship = i->ship;

        std::unordered_set<int32_t> result;
        foreach(PlayerInfo, i, player_info_list)
            if (i->ship == ship && i->client_id != client_id)
                result.insert(i->client_id);
        return result;
    }

    //Else communicate to everyone.
    return GameServer::onVoiceChat(client_id, target_identifier);
}


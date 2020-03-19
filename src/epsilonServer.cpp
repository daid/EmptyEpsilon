#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "GMActions.h"
#include "main.h"

EpsilonServer::EpsilonServer()
: GameServer("Server", VERSION_NUMBER)
{
    if (game_server)
    {
        new GameGlobalInfo();
        new GameMasterActions();
        PlayerInfo* info = new PlayerInfo();
        info->client_id = 0;
        my_player_info = info;
        engine->setGameSpeed(0.0);
        for(unsigned int n=0; n<factionInfo.size(); n++)
            factionInfo[n]->reset();
    }
}

EpsilonServer::~EpsilonServer()
{
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
        if (i->client_id == client_id)
            i->destroy();
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
        int32_t ship_id = -1;
        foreach(PlayerInfo, i, player_info_list)
            if (i->client_id == client_id)
                ship_id = i->ship_id;

        std::unordered_set<int32_t> result;
        foreach(PlayerInfo, i, player_info_list)
            if (i->ship_id == ship_id && i->client_id != client_id)
                result.insert(i->client_id);
        return result;
    }

    //Else communicate to everyone.
    return GameServer::onVoiceChat(client_id, target_identifier);
}


#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "gameStateLogger.h"
#include "main.h"
#include "preferenceManager.h"

EpsilonServer::EpsilonServer()
: GameServer("Server", VERSION_NUMBER)
{
    new GameGlobalInfo();
    PlayerInfo* info = new PlayerInfo();
    info->client_id = 0;
    my_player_info = info;
    engine->setGameSpeed(0.0);
    for(unsigned int n=0; n<factionInfo.size(); n++)
        factionInfo[n]->reset();

    if (PreferencesManager::get("game_logs", "1").toInt())
    {
        state_logger = new GameStateLogger();
        state_logger->start();
    } else if (state_logger)
        state_logger->destroy();
}

EpsilonServer::~EpsilonServer()
{
    if (state_logger)
        state_logger->destroy();
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
    foreach(PlayerInfo, i, player_info_list)
        i->destroy();
    if (my_player_info)
        my_player_info->destroy();
}

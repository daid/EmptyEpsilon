#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObject.h"
#include "spaceStation.h"
#include "cpuShip.h"
#include "asteroid.h"
#include "mine.h"
#include "main.h"

EpsilonServer::EpsilonServer()
: GameServer("Server", VERSION_NUMBER)
{
    new GameGlobalInfo();
    PlayerInfo* info = new PlayerInfo();
    info->clientId = 0;
    my_player_info = info;
    engine->setGameSpeed(0.0);
    for(unsigned int n=0; n<factionInfo.size(); n++)
        factionInfo[n]->reset();

    soundManager.playMusic("music/Dream Raid Full Version (Mock Up).ogg");
}

void EpsilonServer::onNewClient(int32_t clientId)
{
    printf("New client: %i\n", clientId);
    PlayerInfo* info = new PlayerInfo();
    info->clientId = clientId;
}

void EpsilonServer::onDisconnectClient(int32_t clientId)
{
    printf("Client left: %i\n", clientId);
    foreach(PlayerInfo, i, playerInfoList)
        if (i->clientId == clientId)
            i->destroy();
    playerInfoList.update();
}

void disconnectFromServer()
{
    soundManager.stopMusic();

    if (game_client)
        game_client->destroy();
    if (game_server)
        game_server->destroy();
    if (gameGlobalInfo)
        gameGlobalInfo->destroy();
    foreach(PlayerInfo, i, playerInfoList)
        i->destroy();
    foreach(GameEntity, e, entityList)
        e->destroy();
    foreach(SpaceObject, o, space_object_list)
        o->destroy();
    if (my_player_info)
        my_player_info->destroy();
    if (engine->getObject("scenario"))
        engine->getObject("scenario")->destroy();
}

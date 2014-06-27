#include "epsilonServer.h"
#include "playerInfo.h"
#include "spaceObject.h"
#include "spaceStation.h"
#include "main.h"

EpsilonServer::EpsilonServer()
: GameServer("Server", VERSION_NUMBER)
{
    new GameGlobalInfo();
    PlayerInfo* info = new PlayerInfo();
    info->client_id = 0;
    my_player_info = info;
    engine->setGameSpeed(0.0);

    //TMP
    my_spaceship = new SpaceShip();
    randomNebulas();
    //for(int n=0; n<50;n++)
    //    (new SpaceShip())->setPosition(sf::vector2FromAngle(0.0f) * (50.0f + n * 100.0f));
    (new SpaceShip())->setPosition(sf::Vector2f(100, 100));
    (new SpaceStation())->setPosition(sf::Vector2f(0, -500));
}

void EpsilonServer::onNewClient(int32_t client_id)
{
    printf("New client: %i\n", client_id);
    PlayerInfo* info = new PlayerInfo();
    info->client_id = client_id;
}

void EpsilonServer::onDisconnectClient(int32_t client_id)
{
    printf("Client left: %i\n", client_id);
    foreach(PlayerInfo, i, player_info_list)
        if (i->client_id == client_id)
            i->destroy();
    player_info_list.update();
}

void disconnectFromServer()
{
    if (gameClient)
        gameClient->destroy();
    if (game_global_info)
        game_global_info->destroy();
    foreach(PlayerInfo, i, player_info_list)
        i->destroy();
    foreach(GameEntity, e, entityList)
        e->destroy();
    foreach(SpaceObject, o, space_object_list)
        o->destroy();
    if (my_player_info)
        my_player_info->destroy();
}

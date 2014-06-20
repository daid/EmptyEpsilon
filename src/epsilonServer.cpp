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
    info->clientId = 0;
    myPlayerInfo = info;
    engine->setGameSpeed(0.0);
    
    //TMP
    mySpaceship = new SpaceShip();
    gameGlobalInfo->insertPlayerShip(mySpaceship);
    randomNebulas();
    
    //for(int n=0; n<50;n++)
    //    (new SpaceShip())->setPosition(sf::vector2FromAngle(0.0f) * (50.0f + n * 100.0f));
    P<SpaceShip> ship = new SpaceShip();
    ship->setPosition(sf::Vector2f(100, 100));
    gameGlobalInfo->insertPlayerShip(ship);
    
    (new SpaceStation())->setPosition(sf::Vector2f(0, -500));
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
    if (gameClient)
        gameClient->destroy();
    if (gameGlobalInfo)
        gameGlobalInfo->destroy();
    foreach(PlayerInfo, i, playerInfoList)
        i->destroy();
    foreach(GameEntity, e, entityList)
        e->destroy();
    foreach(SpaceObject, o, spaceObjectList)
        o->destroy();
    if (myPlayerInfo)
        myPlayerInfo->destroy();
}

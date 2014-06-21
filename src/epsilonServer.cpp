#include "epsilonServer.h"
#include "playerInfo.h"
#include "spaceObject.h"
#include "spaceStation.h"
#include "cpuShip.h"
#include "main.h"

EpsilonServer::EpsilonServer()
: GameServer("Server", VERSION_NUMBER)
{
    new GameGlobalInfo();
    PlayerInfo* info = new PlayerInfo();
    info->clientId = 0;
    myPlayerInfo = info;
    engine->setGameSpeed(0.0);
    
    soundManager.playMusic("music/Dream Raid Full Version (Mock Up).ogg");
    
    //TMP
    mySpaceship = new PlayerSpaceship();
    mySpaceship->setShipTemplate("player-cruiser");
    gameGlobalInfo->insertPlayerShip(mySpaceship);
    randomNebulas();
    
    P<PlayerSpaceship> ship = new PlayerSpaceship();
    ship->setShipTemplate("fighter");
    ship->setPosition(sf::Vector2f(100, 100));
    gameGlobalInfo->insertPlayerShip(ship);
    
    P<SpaceStation> station = new SpaceStation();
    station->setPosition(sf::Vector2f(0, -500));
    mySpaceship->commandSetTarget(station);
    
    for(int n=0; n<100; n++)
    {
        P<CpuShip> s = new CpuShip();
        s->setShipTemplate("fighter");
        s->setPosition(sf::vector2FromAngle(random(0, 360)) * random(5000, 20000));
    }
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

    if (gameClient)
        gameClient->destroy();
    if (gameServer)
        gameServer->destroy();
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

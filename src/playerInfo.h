#ifndef PLAYER_INFO_H
#define PLAYER_INFO_H

#include "engine.h"
#include "spaceship.h"

class PlayerInfo;
class GameGlobalInfo;
extern P<GameGlobalInfo> gameGlobalInfo;
extern P<PlayerInfo> myPlayerInfo;
extern P<SpaceShip> mySpaceship;
extern PVector<PlayerInfo> playerInfoList;

enum ECrewPosition
{
    helmsOfficer,
    tacticalOfficer,
    engineering,
    scienceOfficer,
    commsOfficer,
    maxCrewPositions
};

class GameGlobalInfo : public MultiplayerObject
{
public:
    static const int maxPlayerShips = 32;
private:
    int32_t playerShipId[maxPlayerShips];
public:
    GameGlobalInfo();
    
    P<SpaceShip> getPlayerShip(int index);
    void setPlayerShip(int index, P<SpaceShip> ship);
    
    int findPlayerShip(P<SpaceShip> ship);
    int insertPlayerShip(P<SpaceShip> ship);
};

class PlayerInfo : public MultiplayerObject
{
public:
    int32_t clientId;
    
    bool crewPosition[maxCrewPositions];
    
    PlayerInfo();
    
    bool isMainScreen();
    void setCrewPosition(ECrewPosition position, bool active);
    virtual void onReceiveCommand(int32_t clientId, sf::Packet& packet);
};

string getCrewPositionName(ECrewPosition position);

#endif//PLAYER_INFO_H

#ifndef PLAYER_INFO_H
#define PLAYER_INFO_H

#include "engine.h"
#include "playerSpaceship.h"

class PlayerInfo;
class GameGlobalInfo;
extern P<GameGlobalInfo> gameGlobalInfo;
extern P<PlayerInfo> myPlayerInfo;
extern P<PlayerSpaceship> mySpaceship;
extern PVector<PlayerInfo> playerInfoList;

enum ECrewPosition
{
    helmsOfficer,
    weaponsOfficer,
    engineering,
    scienceOfficer,
    commsOfficer,
    maxCrewPositions
};

class GameGlobalInfo : public MultiplayerObject
{
public:
    static const int maxPlayerShips = 32; //Cause we had to set it at something.
private:
    int32_t playerShipId[maxPlayerShips];
public:
    GameGlobalInfo();
<<<<<<< HEAD

    P<SpaceShip> getPlayerShip(int index);
    void setPlayerShip(int index, P<SpaceShip> ship);

    int findPlayerShip(P<SpaceShip> ship);
    int insertPlayerShip(P<SpaceShip> ship);
=======
    
    P<PlayerSpaceship> getPlayerShip(int index);
    void setPlayerShip(int index, P<PlayerSpaceship> ship);
    
    int findPlayerShip(P<PlayerSpaceship> ship);
    int insertPlayerShip(P<PlayerSpaceship> ship);
>>>>>>> origin/master
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

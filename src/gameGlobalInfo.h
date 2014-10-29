#ifndef GAME_GLOBAL_INFO_H
#define GAME_GLOBAL_INFO_H

#include "playerSpaceship.h"

class GameGlobalInfo;
extern P<GameGlobalInfo> gameGlobalInfo;

class NebulaInfo
{
public:
    sf::Vector3f vector;
    string textureName;
};

class GameGlobalInfo : public MultiplayerObject
{
public:
    static const int maxPlayerShips = 32;
    static const int maxNebula = 32;
private:
    int victory_faction;
    int32_t playerShipId[maxPlayerShips];
public:
    NebulaInfo nebulaInfo[maxNebula];
    
    GameGlobalInfo();

    P<PlayerSpaceship> getPlayerShip(int index);
    void setPlayerShip(int index, P<PlayerSpaceship> ship);

    int findPlayerShip(P<PlayerSpaceship> ship);
    int insertPlayerShip(P<PlayerSpaceship> ship);
    
    void setVictory(string faction_name) { victory_faction = FactionInfo::findFactionId(faction_name); }
    int getVictoryFactionId() { return victory_faction; }
};

#endif//GAME_GLOBAL_INFO_H

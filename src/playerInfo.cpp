#include "playerInfo.h"

static const int16_t CMD_UPDATE_CREW_POSITION = 0x0001;

P<GameGlobalInfo> gameGlobalInfo;
P<PlayerInfo> myPlayerInfo;
P<PlayerSpaceship> mySpaceship;
PVector<PlayerInfo> playerInfoList;

REGISTER_MULTIPLAYER_CLASS(GameGlobalInfo, "GameGlobalInfo")
GameGlobalInfo::GameGlobalInfo()
: MultiplayerObject("GameGlobalInfo")
{
    assert(!gameGlobalInfo);
    
    gameGlobalInfo = this;
    for(int n=0; n<maxPlayerShips; n++)
    {
        playerShipId[n] = -1;
        registerMemberReplication(&playerShipId[n]);
    }
}

P<PlayerSpaceship> GameGlobalInfo::getPlayerShip(int index)
{
    assert(index >= 0 && index < maxPlayerShips);
    if (gameServer)
        return gameServer->getObjectById(playerShipId[index]);
    return gameClient->getObjectById(playerShipId[index]);
}

void GameGlobalInfo::setPlayerShip(int index, P<PlayerSpaceship> ship)
{
    assert(index >= 0 && index < maxPlayerShips);
    assert(gameServer);
    
    if (ship)
        playerShipId[index] = ship->getMultiplayerId();
    else
        playerShipId[index] = -1;
}

int GameGlobalInfo::findPlayerShip(P<PlayerSpaceship> ship)
{
    for(int n=0; n<maxPlayerShips; n++)
        if (getPlayerShip(n) == ship)
            return n;
    return -1;
}
int GameGlobalInfo::insertPlayerShip(P<PlayerSpaceship> ship)
{
    for(int n=0; n<maxPlayerShips; n++)
    {
        if (!getPlayerShip(n))
        {
            setPlayerShip(n, ship);
            return n;
        }
    }
    return -1;
}


REGISTER_MULTIPLAYER_CLASS(PlayerInfo, "PlayerInfo");
PlayerInfo::PlayerInfo()
: MultiplayerObject("PlayerInfo")
{
    clientId = -1;
    registerMemberReplication(&clientId);

    for(int n=0; n<maxCrewPositions; n++)
    {
        crewPosition[n] = false;
        registerMemberReplication(&crewPosition[n]);
    }
    
    playerInfoList.push_back(this);
}

void PlayerInfo::setCrewPosition(ECrewPosition position, bool active)
{
    //crewPosition[position] = active;
    
    sf::Packet packet;
    packet << CMD_UPDATE_CREW_POSITION << int32_t(position) << active;
    sendCommand(packet);
}

void PlayerInfo::onReceiveCommand(int32_t clientId, sf::Packet& packet)
{
    if (clientId != this->clientId) return;
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_UPDATE_CREW_POSITION:
        {
            int32_t position;
            bool active;
            packet >> position >> active;
            crewPosition[position] = active;
        }
        break;
    }
}

bool PlayerInfo::isMainScreen()
{
    for(int n=0; n<maxCrewPositions; n++)
        if (crewPosition[n])
            return false;
    return true;
}

string getCrewPositionName(ECrewPosition position)
{
    switch(position)
    {
    case helmsOfficer: return "Helms";
    case weaponsOfficer: return "Weapons";
    case engineering: return "Engineering";
    case scienceOfficer: return "Science";
    case commsOfficer: return "Comms";
    default: return "ErrUnk: " + string(position);
    }
}

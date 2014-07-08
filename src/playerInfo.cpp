#include "playerInfo.h"

static const int16_t CMD_UPDATE_CREW_POSITION = 0x0001;
static const int16_t CMD_UPDATE_SHIP_ID = 0x0002;
static const int16_t CMD_UPDATE_MAIN_SCREEN_CONTROL = 0x0003;

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
    main_screen_control = false;
    registerMemberReplication(&clientId);

    for(int n=0; n<maxCrewPositions; n++)
    {
        crew_position[n] = false;
        registerMemberReplication(&crew_position[n]);
    }
    registerMemberReplication(&ship_id);
    registerMemberReplication(&main_screen_control);
    
    playerInfoList.push_back(this);
}

void PlayerInfo::setCrewPosition(ECrewPosition position, bool active)
{
    sf::Packet packet;
    packet << CMD_UPDATE_CREW_POSITION << int32_t(position) << active;
    sendCommand(packet);
}

void PlayerInfo::setShipId(int32_t id)
{
    sf::Packet packet;
    packet << CMD_UPDATE_SHIP_ID << id;
    sendCommand(packet);
}

void PlayerInfo::setMainScreenControl(bool control)
{
    sf::Packet packet;
    packet << CMD_UPDATE_MAIN_SCREEN_CONTROL << control;
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
            crew_position[position] = active;
            
            if (isMainScreen())
                main_screen_control = false;
            if (active && mySpaceship)
            {
                int main_screen_control_cnt = 0;
                foreach(PlayerInfo, i, playerInfoList)
                {
                    if (i->ship_id == mySpaceship->getMultiplayerId() && i->main_screen_control)
                        main_screen_control_cnt++;
                }
                if (main_screen_control_cnt == 0)
                    main_screen_control = true;
            }
        }
        break;
    case CMD_UPDATE_SHIP_ID:
        packet >> ship_id;
        break;
    case CMD_UPDATE_MAIN_SCREEN_CONTROL:
        packet >> main_screen_control;
        break;
    }
}

bool PlayerInfo::isMainScreen()
{
    for(int n=0; n<maxCrewPositions; n++)
        if (crew_position[n])
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
    case singlePilot: return "Single Pilot";
    default: return "ErrUnk: " + string(position);
    }
}

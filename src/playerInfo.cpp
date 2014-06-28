#include "playerInfo.h"

static const int16_t CMD_UPDATE_CREW_POSITION = 0x0001;

P<GameGlobalInfo> game_global_info;
P<PlayerInfo> my_player_info;
P<SpaceShip> my_spaceship;
PVector<PlayerInfo> player_info_list;

REGISTER_MULTIPLAYER_CLASS(GameGlobalInfo, "GameGlobalInfo")
GameGlobalInfo::GameGlobalInfo()
: MultiplayerObject("GameGlobalInfo")
{
    assert(!game_global_info);

    game_global_info = this;
    for(int n=0; n<max_player_ships; n++)
    {
        player_ship_id[n] = -1;
        registerMemberReplication(&player_ship_id[n]);
    }
}

P<SpaceShip> GameGlobalInfo::getPlayerShip(int index)
{
    assert(index >= 0 && index < max_player_ships);
    if (gameServer)
        return gameServer->getObjectById(player_ship_id[index]);
    return gameClient->getObjectById(player_ship_id[index]);
}

void GameGlobalInfo::setPlayerShip(int index, P<SpaceShip> ship)
{
    assert(index >= 0 && index < max_player_ships);
    assert(gameServer);

    if (ship)
        player_ship_id[index] = ship->getMultiplayerId();
    else
        player_ship_id[index] = -1;
}

int GameGlobalInfo::findPlayerShip(P<SpaceShip> ship)
{
    for(int n=0; n<max_player_ships; n++)
        if (getPlayerShip(n) == ship)
            return n;
    return -1;
}
int GameGlobalInfo::insertPlayerShip(P<SpaceShip> ship)
{
    for(int n=0; n<max_player_ships; n++)
    {
        if (!getPlayerShip(n))
        {
            setPlayerShip(n, ship);
            return n;
        }
    }
    printf("Unable to insert ship?!?\n");
    return -1;
}


REGISTER_MULTIPLAYER_CLASS(PlayerInfo, "PlayerInfo");
PlayerInfo::PlayerInfo()
: MultiplayerObject("PlayerInfo")
{
    client_id = -1;
    registerMemberReplication(&client_id);

    for(int n=0; n<max_crew_positions; n++)
    {
        crewPosition[n] = false;
        registerMemberReplication(&crewPosition[n]);
    }

    player_info_list.push_back(this);
}

void PlayerInfo::setCrewPosition(ECrewPosition position, bool active)
{
    //crewPosition[position] = active;

    sf::Packet packet;
    packet << CMD_UPDATE_CREW_POSITION << int32_t(position) << active;
    sendCommand(packet);
}

void PlayerInfo::onReceiveCommand(int32_t client_id, sf::Packet& packet)
{
    if (client_id != this->client_id) return;
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
    for(int n=0; n<max_crew_positions; n++)
        if (crewPosition[n])
            return false;
    return true;
}

string getCrewPositionName(ECrewPosition position)
{
    switch(position)
    {
    case helmsOfficer: return "Helms";
    case tacticalOfficer: return "Tactical";
    case engineering: return "Engineering";
    case scienceOfficer: return "Science";
    case commsOfficer: return "Comms";
    default: return "ErrUnk: " + string(position);
    }
}

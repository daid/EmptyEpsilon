#include "playerInfo.h"
#include "mainScreen.h"
#include "crewHelmsUI.h"
#include "crewWeaponsUI.h"
#include "crewEngineeringUI.h"
#include "crewScienceUI.h"
#include "crewCommsUI.h"
#include "crewSinglePilotUI.h"

static const int16_t CMD_UPDATE_CREW_POSITION = 0x0001;
static const int16_t CMD_UPDATE_SHIP_ID = 0x0002;
static const int16_t CMD_UPDATE_MAIN_SCREEN_CONTROL = 0x0003;

P<GameGlobalInfo> gameGlobalInfo;
P<PlayerInfo> my_player_info;
P<PlayerSpaceship> my_spaceship;
PVector<PlayerInfo> playerInfoList;

REGISTER_MULTIPLAYER_CLASS(GameGlobalInfo, "GameGlobalInfo")
GameGlobalInfo::GameGlobalInfo()
: MultiplayerObject("GameGlobalInfo")
{
    assert(!gameGlobalInfo);

    victory_faction = -1;
    gameGlobalInfo = this;
    for(int n=0; n<maxPlayerShips; n++)
    {
        playerShipId[n] = -1;
        registerMemberReplication(&playerShipId[n]);
    }
    registerMemberReplication(&victory_faction);
}

P<PlayerSpaceship> GameGlobalInfo::getPlayerShip(int index)
{
    assert(index >= 0 && index < maxPlayerShips);
    if (game_server)
        return game_server->getObjectById(playerShipId[index]);
    return game_client->getObjectById(playerShipId[index]);
}

void GameGlobalInfo::setPlayerShip(int index, P<PlayerSpaceship> ship)
{
    assert(index >= 0 && index < maxPlayerShips);
    assert(game_server);

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

    crew_active_position = helmsOfficer;
    for(int n=0; n<max_crew_positions; n++)
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
    for(int n=0; n<max_crew_positions; n++)
        if (crew_position[n])
            return false;
    return true;
}

void PlayerInfo::spawnUI()
{
    if (my_player_info->isMainScreen())
    {
        new MainScreenUI();
    }else{
        if (!crew_position[crew_active_position])
        {
            for(int n=0; n<max_crew_positions; n++)
            {
                if (crew_position[n])
                {
                    crew_active_position = ECrewPosition(n);
                    break;
                }
            }
        }
        switch(crew_active_position)
        {
        case helmsOfficer:
            new CrewHelmsUI();
            break;
        case weaponsOfficer:
            new CrewWeaponsUI();
            break;
        case engineering:
            new CrewEngineeringUI();
            break;
        case scienceOfficer:
            new CrewScienceUI();
            break;
        case commsOfficer:
            new CrewCommsUI();
            break;
        case singlePilot:
            new CrewSinglePilotUI();
            break;
        default:
            new CrewUI();
            break;
        }
    }
}

string getCrewPositionName(ECrewPosition position)
{
    switch(position)
    {
    case helmsOfficer: return "Helms";
    case weaponsOfficer: return "Weapons";
    case engineering: return "Engineering";
    case scienceOfficer: return "Science";
    case commsOfficer: return "Relay";
    case singlePilot: return "Single Pilot";
    default: return "ErrUnk: " + string(position);
    }
}

#include "playerInfo.h"
#include "screens/mainScreen.h"
#include "screens/crewStationScreen.h"

#include "screens/crew6/helmsScreen.h"
#include "screens/crew6/weaponsScreen.h"
#include "screens/crew6/engineeringScreen.h"
#include "screens/crew6/scienceScreen.h"
#include "screens/crew6/relayScreen.h"

#include "screens/crew4/tacticalScreen.h"
#include "screens/crew4/engineeringAdvancedScreen.h"
#include "screens/crew4/operationsScreen.h"

#include "screens/crew1/singlePilotScreen.h"

#include "screenComponents/selfDestructEntry.h"

static const int16_t CMD_UPDATE_CREW_POSITION = 0x0001;
static const int16_t CMD_UPDATE_SHIP_ID = 0x0002;
static const int16_t CMD_UPDATE_MAIN_SCREEN_CONTROL = 0x0003;

P<PlayerInfo> my_player_info;
P<PlayerSpaceship> my_spaceship;
PVector<PlayerInfo> player_info_list;

REGISTER_MULTIPLAYER_CLASS(PlayerInfo, "PlayerInfo");
PlayerInfo::PlayerInfo()
: MultiplayerObject("PlayerInfo")
{
    ship_id = -1;
    client_id = -1;
    main_screen_control = false;
    registerMemberReplication(&client_id);

    for(int n=0; n<max_crew_positions; n++)
    {
        crew_position[n] = false;
        registerMemberReplication(&crew_position[n]);
    }
    registerMemberReplication(&ship_id);
    registerMemberReplication(&main_screen_control);

    player_info_list.push_back(this);
}

void PlayerInfo::setCrewPosition(ECrewPosition position, bool active)
{
    sf::Packet packet;
    packet << CMD_UPDATE_CREW_POSITION << int32_t(position) << active;
    sendClientCommand(packet);
    
    crew_position[position] = active;
}

void PlayerInfo::setShipId(int32_t id)
{
    sf::Packet packet;
    packet << CMD_UPDATE_SHIP_ID << id;
    sendClientCommand(packet);
}

void PlayerInfo::setMainScreenControl(bool control)
{
    sf::Packet packet;
    packet << CMD_UPDATE_MAIN_SCREEN_CONTROL << control;
    sendClientCommand(packet);
    
    main_screen_control = control;
}

void PlayerInfo::onReceiveClientCommand(int32_t client_id, sf::Packet& packet)
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
        new ScreenMainScreen();
    }else{

        CrewStationScreen* screen = new CrewStationScreen();
        
        //Crew 6/5
        if (crew_position[helmsOfficer])
            screen->addStationTab(new HelmsScreen(screen), getCrewPositionName(helmsOfficer));
        if (crew_position[weaponsOfficer])
            screen->addStationTab(new WeaponsScreen(screen), getCrewPositionName(weaponsOfficer));
        if (crew_position[engineering])
            screen->addStationTab(new EngineeringScreen(screen), getCrewPositionName(engineering));
        if (crew_position[scienceOfficer])
            screen->addStationTab(new ScienceScreen(screen), getCrewPositionName(scienceOfficer));
        if (crew_position[relayOfficer])
            screen->addStationTab(new RelayScreen(screen), getCrewPositionName(relayOfficer));
        
        //Crew 4/3
        if (crew_position[tacticalOfficer])
            screen->addStationTab(new TacticalScreen(screen), getCrewPositionName(tacticalOfficer));
        if (crew_position[engineeringAdvanced])
            screen->addStationTab(new EngineeringAdvancedScreen(screen), getCrewPositionName(engineeringAdvanced));
        if (crew_position[operationsOfficer])
            screen->addStationTab(new OperationScreen(screen), getCrewPositionName(operationsOfficer));

        //Crew 1
        if (crew_position[singlePilot])
            screen->addStationTab(new SinglePilotScreen(screen), getCrewPositionName(singlePilot));
        
        GuiSelfDestructEntry* sde = new GuiSelfDestructEntry(screen, "SELF_DESTRUCT_ENTRY");
        for(int n=0; n<max_crew_positions; n++)
            if (crew_position[n])
                sde->enablePosition(ECrewPosition(n));
        screen->finishCreation();
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
    case relayOfficer: return "Relay";
    case tacticalOfficer: return "Tactical";
    case engineeringAdvanced: return "Engineering+";
    case operationsOfficer: return "Operations";
    case singlePilot: return "Single Pilot";
    default: return "ErrUnk: " + string(position);
    }
}

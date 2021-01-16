#include <i18n.h>
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
#ifndef __ANDROID__
#include "screens/crew1/cockpitScreen.h"
#endif

#include "screens/extra/damcon.h"
#include "screens/extra/powerManagement.h"
#include "screens/extra/databaseScreen.h"
#include "screens/extra/commsScreen.h"
#include "screens/extra/shipLogScreen.h"

#include "screenComponents/mainScreenControls.h"
#include "screenComponents/selfDestructEntry.h"

static const int16_t CMD_UPDATE_CREW_POSITION = 0x0001;
static const int16_t CMD_UPDATE_SHIP_ID = 0x0002;
static const int16_t CMD_UPDATE_MAIN_SCREEN = 0x0003;
static const int16_t CMD_UPDATE_MAIN_SCREEN_CONTROL = 0x0004;
static const int16_t CMD_UPDATE_NAME = 0x0005;

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
    registerMemberReplication(&name);
    registerMemberReplication(&main_screen);
    registerMemberReplication(&main_screen_control);

    player_info_list.push_back(this);
}

bool PlayerInfo::isOnlyMainScreen()
{
    if (!main_screen)
        return false;
    for(int n=0; n<max_crew_positions; n++)
        if (crew_position[n])
            return false;
    return true;
}

void PlayerInfo::commandSetCrewPosition(ECrewPosition position, bool active)
{
    sf::Packet packet;
    packet << CMD_UPDATE_CREW_POSITION << int32_t(position) << active;
    sendClientCommand(packet);

    crew_position[position] = active;
}

void PlayerInfo::commandSetShipId(int32_t id)
{
    sf::Packet packet;
    packet << CMD_UPDATE_SHIP_ID << id;
    sendClientCommand(packet);
}

void PlayerInfo::commandSetMainScreen(bool enabled)
{
    sf::Packet packet;
    packet << CMD_UPDATE_MAIN_SCREEN << enabled;
    sendClientCommand(packet);

    main_screen = enabled;
}

void PlayerInfo::commandSetMainScreenControl(bool control)
{
    sf::Packet packet;
    packet << CMD_UPDATE_MAIN_SCREEN_CONTROL << control;
    sendClientCommand(packet);

    main_screen_control = control;
}

void PlayerInfo::commandSetName(const string& name)
{
    sf::Packet packet;
    packet << CMD_UPDATE_NAME << name;
    sendClientCommand(packet);

    this->name = name;
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
        }
        break;
    case CMD_UPDATE_SHIP_ID:
        packet >> ship_id;
        break;
    case CMD_UPDATE_MAIN_SCREEN:
        packet >> main_screen;
        break;
    case CMD_UPDATE_MAIN_SCREEN_CONTROL:
        packet >> main_screen_control;
        break;
    case CMD_UPDATE_NAME:
        packet >> name;
        break;
    }
}

void PlayerInfo::spawnUI()
{
    if (my_player_info->isOnlyMainScreen())
    {
        new ScreenMainScreen();
    }else{

        CrewStationScreen* screen = new CrewStationScreen();
        if (main_screen && !crew_position[cockpitScreen])
            screen->enableMainScreen();
        auto container = screen->getTabContainer();

        // Crew 6/5
        if (crew_position[helmsOfficer])
            screen->addStationTab(new HelmsScreen(container), helmsOfficer, getCrewPositionName(helmsOfficer), getCrewPositionIcon(helmsOfficer));
        if (crew_position[weaponsOfficer])
            screen->addStationTab(new WeaponsScreen(container), weaponsOfficer, getCrewPositionName(weaponsOfficer), getCrewPositionIcon(weaponsOfficer));
        if (crew_position[engineering])
            screen->addStationTab(new EngineeringScreen(container), engineering, getCrewPositionName(engineering), getCrewPositionIcon(engineering));
        if (crew_position[scienceOfficer])
            screen->addStationTab(new ScienceScreen(container), scienceOfficer, getCrewPositionName(scienceOfficer), getCrewPositionIcon(scienceOfficer));
        if (crew_position[relayOfficer])
            screen->addStationTab(new RelayScreen(container, true), relayOfficer, getCrewPositionName(relayOfficer), getCrewPositionIcon(relayOfficer));

        // Crew 4/3
        if (crew_position[tacticalOfficer])
            screen->addStationTab(new TacticalScreen(container), tacticalOfficer, getCrewPositionName(tacticalOfficer), getCrewPositionIcon(tacticalOfficer));
        if (crew_position[engineeringAdvanced])
            screen->addStationTab(new EngineeringAdvancedScreen(container), engineeringAdvanced, getCrewPositionName(engineeringAdvanced), getCrewPositionIcon(engineeringAdvanced));
        if (crew_position[operationsOfficer])
            screen->addStationTab(new OperationScreen(container), operationsOfficer, getCrewPositionName(operationsOfficer), getCrewPositionIcon(operationsOfficer));

        // Crew 1
        if (crew_position[singlePilot])
            screen->addStationTab(new SinglePilotScreen(container), singlePilot, getCrewPositionName(singlePilot), getCrewPositionIcon(singlePilot));
#ifndef __ANDROID__
        if (crew_position[cockpitScreen])
            screen->addStationTab(new CockpitScreen(container), cockpitScreen, getCrewPositionName(cockpitScreen), getCrewPositionIcon(cockpitScreen));
#endif

        // Extra
        if (crew_position[damageControl])
            screen->addStationTab(new DamageControlScreen(container), damageControl, getCrewPositionName(damageControl), getCrewPositionIcon(damageControl));
        if (crew_position[powerManagement])
            screen->addStationTab(new PowerManagementScreen(container), powerManagement, getCrewPositionName(powerManagement), getCrewPositionIcon(powerManagement));
        if (crew_position[databaseView])
            screen->addStationTab(new DatabaseScreen(container), databaseView, getCrewPositionName(databaseView), getCrewPositionIcon(databaseView));
        if (crew_position[altRelay])
            screen->addStationTab(new RelayScreen(container, false), altRelay, getCrewPositionName(altRelay), getCrewPositionIcon(altRelay));
        if (crew_position[commsOnly])
            screen->addStationTab(new CommsScreen(container), commsOnly, getCrewPositionName(commsOnly), getCrewPositionIcon(commsOnly));
        if (crew_position[shipLog])
            screen->addStationTab(new ShipLogScreen(container), shipLog, getCrewPositionName(shipLog), getCrewPositionIcon(shipLog));

        GuiSelfDestructEntry* sde = new GuiSelfDestructEntry(container, "SELF_DESTRUCT_ENTRY");
        for(int n=0; n<max_crew_positions; n++)
            if (crew_position[n])
                sde->enablePosition(ECrewPosition(n));
        if (crew_position[tacticalOfficer])
        {
            sde->enablePosition(weaponsOfficer);
            sde->enablePosition(helmsOfficer);
        }
        if (crew_position[engineeringAdvanced])
        {
            sde->enablePosition(engineering);
        }
        if (crew_position[operationsOfficer])
        {
            sde->enablePosition(scienceOfficer);
            sde->enablePosition(relayOfficer);
        }

        if (main_screen_control)
            new GuiMainScreenControls(container);

        screen->finishCreation();
    }
}

string getCrewPositionName(ECrewPosition position)
{
    switch(position)
    {
    case helmsOfficer: return tr("station","Helms");
    case weaponsOfficer: return tr("station","Weapons");
    case engineering: return tr("station","Engineering");
    case scienceOfficer: return tr("station","Science");
    case relayOfficer: return tr("station","Relay");
    case tacticalOfficer: return tr("station","Tactical");
    case engineeringAdvanced: return tr("station","Engineering+");
    case operationsOfficer: return tr("station","Operations");
    case singlePilot: return tr("station","Single Pilot");
    case cockpitScreen: return tr("station","Cockpit View");
    case damageControl: return tr("station","Damage Control");
    case powerManagement: return tr("station","Power Management");
    case databaseView: return tr("station","Database");
    case altRelay: return tr("station","Strategic Map");
    case commsOnly: return tr("station","Comms");
    case shipLog: return tr("station","Ship's Log");
    default: return "ErrUnk: " + string(position);
    }
}

string getCrewPositionIcon(ECrewPosition position)
{
    switch(position)
    {
    case helmsOfficer: return "gui/icons/station-helm";
    case weaponsOfficer: return "gui/icons/station-weapons";
    case engineering: return "gui/icons/station-engineering";
    case scienceOfficer: return "gui/icons/station-science";
    case relayOfficer: return "gui/icons/station-relay";
    case tacticalOfficer: return "";
    case engineeringAdvanced: return "";
    case operationsOfficer: return "";
    case singlePilot: return "";
    case cockpitScreen: return "";
    case damageControl: return "";
    case powerManagement: return "";
    case databaseView: return "";
    case altRelay: return "";
    case commsOnly: return "";
    case shipLog: return "";
    default: return "ErrUnk: " + string(position);
    }
}

// Define script conversion function for the ECrewPosition enum.
template<> void convert<ECrewPosition>::param(lua_State* L, int& idx, ECrewPosition& cp)
{
    string str = string(luaL_checkstring(L, idx++)).lower();

    // 6/5 player crew
    if (str == "helms" || str == "helmsofficer")
        cp = helmsOfficer;
    else if (str == "weapons" || str == "weaponsofficer")
        cp = weaponsOfficer;
    else if (str == "engineering" || str == "engineeringsofficer")
        cp = engineering;
    else if (str == "science" || str == "scienceofficer")
        cp = scienceOfficer;
    else if (str == "relay" || str == "relayofficer")
        cp = relayOfficer;

    // 4/3 player crew
    else if (str == "tactical" || str == "tacticalofficer")
        cp = tacticalOfficer;    //helms+weapons-shields
    else if (str == "engineering+" || str == "engineering+officer" || str == "engineeringadvanced" || str == "engineeringadvancedofficer")
        cp = engineeringAdvanced;//engineering+shields
    else if (str == "operations" || str == "operationsofficer")
        cp = operationsOfficer; //science+comms

    // 1 player crew
    else if (str == "single" || str == "singlepilot")
        cp = singlePilot;
    else if (str == "cockpit" || str == "cockpitview")
        cp = cockpitScreen;

    // Extras
    else if (str == "damagecontrol")
        cp = damageControl;
    else if (str == "powermanagement")
        cp = powerManagement;
    else if (str == "database" || str == "databaseview")
        cp = databaseView;
    else if (str == "altrelay")
        cp = altRelay;
    else if (str == "commsonly")
        cp = commsOnly;
    else if (str == "shiplog")
        cp = shipLog;
    else
        luaL_error(L, "Unknown value for crew position: %s", str.c_str());
}

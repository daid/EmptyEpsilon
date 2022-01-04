#ifndef PLAYER_INFO_H
#define PLAYER_INFO_H

#include "multiplayer.h"
#include "scriptInterface.h"

enum ECrewPosition
{
    //6/5 player crew
    helmsOfficer,
    weaponsOfficer,
    engineering,
    scienceOfficer,
    relayOfficer,
    //4/3 player crew
    tacticalOfficer,    //helms+weapons-shields
    engineeringAdvanced,//engineering+shields
    operationsOfficer, //science+comms
    //1 player crew
    singlePilot,
    //extras
    damageControl,
    powerManagement,
    databaseView,
    altRelay,
    commsOnly,
    shipLog,
    max_crew_positions
};

class PlayerInfo;
class PlayerSpaceship;
class RenderLayer;
extern P<PlayerInfo> my_player_info;
extern P<PlayerSpaceship> my_spaceship;
extern PVector<PlayerInfo> player_info_list;

class PlayerInfo : public MultiplayerObject
{
public:
    int32_t client_id;

    uint32_t crew_position[max_crew_positions];
    uint32_t main_screen = 0;
    uint32_t main_screen_control = 0;
    int32_t ship_id;
    string name;

    PlayerInfo();

    void reset();

    bool isOnlyMainScreen(int monitor_index);

    void commandSetCrewPosition(int monitor_index, ECrewPosition position, bool active);
    void commandSetShipId(int32_t id);
    void commandSetMainScreen(int monitor_index, bool enabled);
    void commandSetMainScreenControl(int monitor_index, bool control);
    void commandSetName(const string& name);
    virtual void onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet) override;

    void spawnUI(int monitor_index, RenderLayer* render_layer);
};

REGISTER_MULTIPLAYER_ENUM(ECrewPosition);
string getCrewPositionName(ECrewPosition position);
string getCrewPositionIcon(ECrewPosition position);

/* Define script conversion function for the DamageInfo structure. */
template<> void convert<ECrewPosition>::param(lua_State* L, int& idx, ECrewPosition& cp);

#endif//PLAYER_INFO_H

#ifndef PLAYER_INFO_H
#define PLAYER_INFO_H

#include "engine.h"

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

    max_crew_positions
};

class PlayerInfo;
class PlayerSpaceship;
extern P<PlayerInfo> my_player_info;
extern P<PlayerSpaceship> my_spaceship;
extern PVector<PlayerInfo> player_info_list;

class PlayerInfo : public MultiplayerObject
{
public:
    int32_t client_id;

    bool crew_position[max_crew_positions];
    bool main_screen_control;
    int32_t ship_id;

    PlayerInfo();

    bool isMainScreen();
    void setCrewPosition(ECrewPosition position, bool active);
    void setShipId(int32_t id);
    void setMainScreenControl(bool control);
    virtual void onReceiveClientCommand(int32_t client_id, sf::Packet& packet);

    void spawnUI();
};

REGISTER_MULTIPLAYER_ENUM(ECrewPosition);
string getCrewPositionName(ECrewPosition position);
string getCrewPositionIcon(ECrewPosition position);

#endif//PLAYER_INFO_H

#ifndef PLAYER_INFO_H
#define PLAYER_INFO_H

#include "engine.h"
#include "spaceObjects/playerSpaceship.h"

class PlayerInfo;
extern P<PlayerInfo> my_player_info;
extern P<PlayerSpaceship> my_spaceship;
extern PVector<PlayerInfo> player_info_list;

class PlayerInfo : public MultiplayerObject
{
public:
    int32_t client_id;

    ECrewPosition crew_active_position;
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

string getCrewPositionName(ECrewPosition position);

#endif//PLAYER_INFO_H

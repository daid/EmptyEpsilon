#ifndef GAME_GLOBAL_INFO_H
#define GAME_GLOBAL_INFO_H

#include "spaceObjects/playerSpaceship.h"

class GameGlobalInfo;
extern P<GameGlobalInfo> gameGlobalInfo;

class NebulaInfo
{
public:
    sf::Vector3f vector;
    string textureName;
};

enum EPlayerWarpJumpDrive
{
    PWJ_ShipDefault = 0,
    PWJ_WarpDrive,
    PWJ_JumpDrive,
    PWJ_WarpAndJumpDrive,
    PWJ_MAX,
};

class GameGlobalInfo : public MultiplayerObject, public Updatable
{
public:
    static const int maxPlayerShips = 32;
    static const int maxNebula = 32;
private:
    int victory_faction;
    int32_t playerShipId[maxPlayerShips];
    int callsign_counter;
public:
    string global_message;
    float global_message_timeout;

    std::vector<float> reputation_points;
    NebulaInfo nebulaInfo[maxNebula];
    EPlayerWarpJumpDrive player_warp_jump_drive_setting;
    float long_range_radar_range;
    bool use_beam_shield_frequencies;
    bool use_system_damage;
    bool allow_main_screen_tactical_radar;
    bool allow_main_screen_long_range_radar;
    
    GameGlobalInfo();

    P<PlayerSpaceship> getPlayerShip(int index);
    void setPlayerShip(int index, P<PlayerSpaceship> ship);

    int findPlayerShip(P<PlayerSpaceship> ship);
    int insertPlayerShip(P<PlayerSpaceship> ship);
    
    void setVictory(string faction_name) { victory_faction = FactionInfo::findFactionId(faction_name); }
    int getVictoryFactionId() { return victory_faction; }
    
    virtual void update(float delta);
    
    string getNextShipCallsign();
};

string playerWarpJumpDriveToString(EPlayerWarpJumpDrive player_warp_jump_drive);

#endif//GAME_GLOBAL_INFO_H

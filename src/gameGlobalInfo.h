#ifndef GAME_GLOBAL_INFO_H
#define GAME_GLOBAL_INFO_H

#include "spaceObjects/playerSpaceship.h"
#include "script.h"
#include "GMScriptCallback.h"
#include "gameStateLogger.h"

class GameStateLogger;
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
    PWJ_None,
    PWJ_MAX,
};
enum EScanningComplexity
{
    SC_None = 0,
    SC_Simple,
    SC_Normal,
    SC_Advanced
};

class GameGlobalInfo : public MultiplayerObject, public Updatable
{
    P<GameStateLogger> state_logger;
public:
    /*!
     * \brief Maximum number of player ships.
     */
    static const int max_player_ships = 32;
    /*!
     * \brief Maximum number of visual background nebulas.
     */
    static const int max_nebulas = 32;
     /*!
     * \size of a sector.
     */
    static const int sector_size = 20000;
private:
    int victory_faction;
    int32_t playerShipId[max_player_ships];
    int callsign_counter;
    /*!
     * \brief List of known scripts
     */
    PVector<Script> script_list;
public:
    string global_message;
    float global_message_timeout;
    
    string banner_string;

    std::vector<float> reputation_points;
    NebulaInfo nebula_info[max_nebulas];
    EPlayerWarpJumpDrive player_warp_jump_drive_setting;
    EScanningComplexity scanning_complexity;
    /*!
     * \brief Range of the science radar.
     */
    float long_range_radar_range;
    bool use_beam_shield_frequencies;
    bool use_system_damage;
    bool allow_main_screen_tactical_radar;
    bool allow_main_screen_long_range_radar;
    string variation = "None";

    //List of script functions that can be called from the GM interface (Server only!)
    std::list<GMScriptCallback> gm_callback_functions;
    //When active, all comms request goto the GM as chat, and normal scripted converstations are disabled. This does not disallow player<->player ship comms.
    bool intercept_all_comms_to_gm;

    GameGlobalInfo();

    P<PlayerSpaceship> getPlayerShip(int index);
    void setPlayerShip(int index, P<PlayerSpaceship> ship);

    int findPlayerShip(P<PlayerSpaceship> ship);
    int insertPlayerShip(P<PlayerSpaceship> ship);
    /*!
     * \brief Set a faction to victorious.
     * \param string Name of the faction that won.
     */
    void setVictory(string faction_name) { victory_faction = FactionInfo::findFactionId(faction_name); }
    /*!
     * \brief Get ID of faction that won.
     * \param int
     */
    int getVictoryFactionId() { return victory_faction; }

    void addScript(P<Script> script);
    //Reset the global game state (called when we want to load a new scenario, and clear out this one)
    void reset();
    void startScenario(string filename);

    virtual void update(float delta);
    virtual void destroy();

    string getNextShipCallsign();
};

string playerWarpJumpDriveToString(EPlayerWarpJumpDrive player_warp_jump_drive);
string getSectorName(sf::Vector2f position);
sf::Vector2f getSectorPosition(string sectorName);
bool isValidSectorName(string sectorName);

REGISTER_MULTIPLAYER_ENUM(EScanningComplexity);

#endif//GAME_GLOBAL_INFO_H

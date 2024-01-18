#ifndef GAME_GLOBAL_INFO_H
#define GAME_GLOBAL_INFO_H

#include "script.h"
#include "GMScriptCallback.h"
#include "GMMessage.h"
#include "gameStateLogger.h"
#include "components/faction.h"
#include "Updatable.h"
#include "multiplayer.h"
#include "GMMessage.h"
#include "scriptInterface.h"
#include <list>
#include <functional>


class GameStateLogger;
class GameGlobalInfo;
extern P<GameGlobalInfo> gameGlobalInfo;

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
    SC_Advanced,
};
enum EHackingGames
{
    HG_Mine,
    HG_Lights,
    HG_All
};

class GameGlobalInfo : public MultiplayerObject, public Updatable
{
public:
    string global_message;
    float global_message_timeout;

    string banner_string;

    EScanningComplexity scanning_complexity;
    //Hacking difficulty ranges from 0 to 3
    int hacking_difficulty;
    EHackingGames hacking_games;
    bool use_beam_shield_frequencies;
    bool use_system_damage;
    bool allow_main_screen_tactical_radar;
    bool allow_main_screen_long_range_radar;
    string gm_control_code;
    float elapsed_time;
    string scenario;
    std::unordered_map<string, string> scenario_settings;

    //List of script functions that can be called from the GM interface (Server only!)
    std::list<GMScriptCallback> gm_callback_functions;
    std::list<GMMessage> gm_messages;
    //When active, all comms request goto the GM as chat, and normal scripted converstations are disabled. This does not disallow player<->player ship comms.
    bool intercept_all_comms_to_gm;

    //Callback called when a new player ship is created on the ship selection screen.
    sp::script::Callback on_new_player_ship;

    std::function<void(glm::vec2)> on_gm_click;

    GameGlobalInfo();
    virtual ~GameGlobalInfo();

    /*!
     * \brief Set a faction to victorious.
     * \param string Name of the faction that won.
     */
    void setVictory(string faction_name) { victory_faction = Faction::find(faction_name); }
    /*!
     * \brief Get ID of faction that won.
     * \param int
     */
    FactionInfo* getVictoryFaction() { if (!victory_faction) return nullptr; return victory_faction.getComponent<FactionInfo>(); }

    //Reset the global game state (called when we want to load a new scenario, and clear out this one)
    void reset();
    void setScenarioSettings(const string filename, std::unordered_map<string, string> new_settings);
    void startScenario(string filename, std::unordered_map<string, string> new_settings = {});

    virtual void update(float delta) override;
    virtual void destroy() override;
    string getMissionTime();

    string getNextShipCallsign();

    struct ShipSpawnInfo {
        string key;
        string label;
        string description;
    };
    std::vector<ShipSpawnInfo> getSpawnablePlayerShips();
    void spawnPlayerShip(string key);
    void execScriptCode(const string& code);
    bool allowNewPlayerShips();

    //List of extra scripts that run next to the main script.
    std::vector<std::unique_ptr<sp::script::Environment>> additional_scripts;
private:
    P<GameStateLogger> state_logger;
    sp::ecs::Entity victory_faction;
    int callsign_counter;

    std::unique_ptr<sp::script::Environment> main_script;
};

string getSectorName(glm::vec2 position);
glm::vec2 sectorToXY(string sectorName);

template<> int convert<EScanningComplexity>::returnType(lua_State* L, EScanningComplexity complexity);
template<> int convert<EHackingGames>::returnType(lua_State* L, EHackingGames games);

#endif//GAME_GLOBAL_INFO_H

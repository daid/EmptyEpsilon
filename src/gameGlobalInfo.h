#ifndef GAME_GLOBAL_INFO_H
#define GAME_GLOBAL_INFO_H

#include "script.h"
#include "script/gm.h"
#include "components/faction.h"
#include "Updatable.h"
#include "multiplayer.h"
#include <list>
#include <functional>
#include <unordered_map>


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
    string default_skybox = "default";
    string gm_control_code;
    float elapsed_time;
    string scenario;
    std::unordered_map<string, string> scenario_settings;

    //List of script functions that can be called from the GM interface (Server only!)
    std::list<GMScriptCallback> gm_callback_functions;
    std::list<string> gm_messages;
    //When active, all comms request goto the GM as chat, and normal scripted converstations are disabled. This does not disallow player<->player ship comms.
    bool intercept_all_comms_to_gm;

    //Callback called when a new player ship is created on the ship selection screen.
    sp::script::Callback on_new_player_ship;

    std::function<void(glm::vec2)> on_gm_click;
    const string DEFAULT_ON_GM_CLICK_CURSOR = "mouse_create.png";
    string on_gm_click_cursor = DEFAULT_ON_GM_CLICK_CURSOR;

    GameGlobalInfo();
    virtual ~GameGlobalInfo();

    void onReceiveServerCommand(sp::io::DataBuffer& packet) override;
    void playSoundOnMainScreen(sp::ecs::Entity ship, string sound_name);
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
        sp::script::Callback create_callback;
        string label;
        string description;
        string icon;
    };
    std::vector<ShipSpawnInfo> getSpawnablePlayerShips();
    struct ObjectSpawnInfo {
        sp::script::Callback create_callback;
        string label;
        string category;
        string description;
        string icon;
    };
    std::vector<ObjectSpawnInfo> getGMSpawnableObjects();
    string getEntityExportString(sp::ecs::Entity entity);
    void execScriptCode(const string& code);
    bool allowNewPlayerShips();

    //List of extra scripts that run next to the main script.
    std::vector<std::unique_ptr<sp::script::Environment>> additional_scripts;
    std::unique_ptr<sp::script::Environment> script_environment_base;
    std::unique_ptr<sp::script::Environment> main_scenario_script;
    std::vector<sp::script::CoroutinePtr> script_threads;
private:
    sp::ecs::Entity victory_faction;
    int callsign_counter;

    int main_script_error_count = 0;
    static constexpr int max_repeated_script_errors = 5;

    constexpr static int16_t CMD_PLAY_CLIENT_SOUND = 0x0001;
};

string getSectorName(glm::vec2 position);
glm::vec2 sectorToXY(string sectorName);

#endif//GAME_GLOBAL_INFO_H

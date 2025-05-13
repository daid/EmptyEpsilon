#include <i18n.h>
#include "menus/luaConsole.h"
#include "gameGlobalInfo.h"
#include "preferenceManager.h"
#include "scenarioInfo.h"
#include "multiplayer_client.h"
#include "soundManager.h"
#include "random.h"
#include "config.h"
#include "components/collision.h"
#include "systems/collision.h"
#include "ecs/query.h"
#include "menus/luaConsole.h"
#include "playerInfo.h"
#include <SDL_assert.h>

P<GameGlobalInfo> gameGlobalInfo;

REGISTER_MULTIPLAYER_CLASS(GameGlobalInfo, "GameGlobalInfo")
GameGlobalInfo::GameGlobalInfo()
: MultiplayerObject("GameGlobalInfo")
{
    SDL_assert(!gameGlobalInfo);

    callsign_counter = 0;
    gameGlobalInfo = this;

    global_message_timeout = 0.0;
    scanning_complexity = SC_Normal;
    hacking_difficulty = 2;
    hacking_games = HG_All;
    use_beam_shield_frequencies = true;
    use_system_damage = true;
    allow_main_screen_tactical_radar = true;
    allow_main_screen_long_range_radar = true;
    gm_control_code = "";
    elapsed_time = 0.0f;

    intercept_all_comms_to_gm = false;

    registerMemberReplication(&scanning_complexity);
    registerMemberReplication(&hacking_difficulty);
    registerMemberReplication(&hacking_games);
    registerMemberReplication(&global_message);
    registerMemberReplication(&global_message_timeout, 1.0);
    registerMemberReplication(&banner_string);
    registerMemberReplication(&victory_faction);
    registerMemberReplication(&use_beam_shield_frequencies);
    registerMemberReplication(&use_system_damage);
    registerMemberReplication(&allow_main_screen_tactical_radar);
    registerMemberReplication(&allow_main_screen_long_range_radar);
    registerMemberReplication(&gm_control_code);
    registerMemberReplication(&elapsed_time, 0.1);
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
GameGlobalInfo::~GameGlobalInfo()
{
}

void GameGlobalInfo::onReceiveServerCommand(sp::io::DataBuffer& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_PLAY_CLIENT_SOUND:{
        CrewPosition position;
        string sound_name;
        sp::ecs::Entity entity;
        packet >> entity >> position >> sound_name;
        if (my_spaceship == entity && my_player_info)
        {
            if ((position == CrewPosition::MAX && my_player_info->main_screen) || my_player_info->hasPosition(position))
            {
                soundManager->playSound(sound_name);
            }
        }
        }break;
    }
}

void GameGlobalInfo::playSoundOnMainScreen(sp::ecs::Entity ship, string sound_name)
{
    sp::io::DataBuffer packet;
    packet << CMD_PLAY_CLIENT_SOUND << ship << CrewPosition::MAX << sound_name;
    broadcastServerCommand(packet);
}

void GameGlobalInfo::update(float delta)
{
    if (global_message_timeout > 0.0f)
    {
        global_message_timeout -= delta;
    }
    if (my_player_info)
    {
        //Set the my_spaceship variable based on the my_player_info->ship_id
        if (my_spaceship != my_player_info->ship)
            my_spaceship = my_player_info->ship;
    }
    elapsed_time += delta;

    if (main_scenario_script && main_script_error_count < max_repeated_script_errors) {
        auto res = main_scenario_script->call<void>("update", delta);
        if (res.isErr() && res.error() != "Not a function") {
            LuaConsole::checkResult(res);
            main_script_error_count += 1;
            if (main_script_error_count == max_repeated_script_errors) {
                LuaConsole::addLog("5 repeated script update errors, stopping updates.");
            }
        } else {
            main_script_error_count = 0;
        }
    }
    for(auto& as : additional_scripts) {
        auto res = as->call<void>("update", delta);
        if (res.isErr() && res.error() != "Not a function")
            LuaConsole::checkResult(res);
    }
}

string GameGlobalInfo::getNextShipCallsign()
{
    callsign_counter += 1;
    switch(irandom(0, 9))
    {
    case 0: return "S" + string(callsign_counter);
    case 1: return "NC" + string(callsign_counter);
    case 2: return "CV" + string(callsign_counter);
    case 3: return "SS" + string(callsign_counter);
    case 4: return "VS" + string(callsign_counter);
    case 5: return "BR" + string(callsign_counter);
    case 6: return "CSS" + string(callsign_counter);
    case 7: return "UTI" + string(callsign_counter);
    case 8: return "VK" + string(callsign_counter);
    case 9: return "CCN" + string(callsign_counter);
    }
    return "SS" + string(callsign_counter);
}

void GameGlobalInfo::execScriptCode(const string& code)
{
    if (main_scenario_script) {
        auto res = main_scenario_script->run<sp::script::CaptureAllResults>("return " + code);
        if (res.isErr() && res.error().find('\n') < 0) // Errors without a traceback are parse errors, so we can try without the return.
            res = main_scenario_script->run<sp::script::CaptureAllResults>(code);
        LuaConsole::checkResult(res);
        for(const auto& s : res.value().result)
            LuaConsole::addLog(s);
    }
}

bool GameGlobalInfo::allowNewPlayerShips()
{
    auto res = main_scenario_script->call<bool>("allowNewPlayerShips");
    LuaConsole::checkResult(res);
    return res.value();
}

namespace sp::script {
    template<> struct Convert<std::vector<GameGlobalInfo::ShipSpawnInfo>> {
        static std::vector<GameGlobalInfo::ShipSpawnInfo> fromLua(lua_State* L, int idx) {
            std::vector<GameGlobalInfo::ShipSpawnInfo> result{};
            if (lua_istable(L, idx)) {
                for(int index=1; lua_geti(L, idx, index) == LUA_TTABLE; index++) {
                    lua_geti(L, -1, 1); auto callback = Convert<sp::script::Callback>::fromLua(L, -1); lua_pop(L, 1);
                    lua_geti(L, -1, 2); auto label = lua_tostring(L, -1); lua_pop(L, 1);
                    lua_geti(L, -1, 3); auto description = lua_tostring(L, -1); lua_pop(L, 1);
                    lua_pop(L, 1);
                    result.push_back({callback, label ? label : "", description ? description : ""});
                }
                lua_pop(L, 1);
            }
            return result;
        }
    };
}
std::vector<GameGlobalInfo::ShipSpawnInfo> GameGlobalInfo::getSpawnablePlayerShips()
{
    std::vector<GameGlobalInfo::ShipSpawnInfo> info;
    if (main_scenario_script) {
        auto res = main_scenario_script->call<std::vector<GameGlobalInfo::ShipSpawnInfo>>("getSpawnablePlayerShips");
        LuaConsole::checkResult(res);
        if (res.isOk())
            info = res.value();
    }
    return info;
}
namespace sp::script {
    template<> struct Convert<std::vector<GameGlobalInfo::ObjectSpawnInfo>> {
        static std::vector<GameGlobalInfo::ObjectSpawnInfo> fromLua(lua_State* L, int idx) {
            std::vector<GameGlobalInfo::ObjectSpawnInfo> result{};
            if (lua_istable(L, idx)) {
                for(int index=1; lua_geti(L, idx, index) == LUA_TTABLE; index++) {
                    lua_geti(L, -1, 1); auto callback = Convert<sp::script::Callback>::fromLua(L, -1); lua_pop(L, 1);
                    lua_geti(L, -1, 2); auto label = lua_tostring(L, -1); lua_pop(L, 1);
                    lua_geti(L, -1, 3); auto category = lua_tostring(L, -1); lua_pop(L, 1);
                    lua_pop(L, 1);
                    result.push_back({callback, label ? label : "", category ? category : ""});
                }
                lua_pop(L, 1);
            }
            return result;
        }
    };
}
std::vector<GameGlobalInfo::ObjectSpawnInfo> GameGlobalInfo::getGMSpawnableObjects()
{
    std::vector<GameGlobalInfo::ObjectSpawnInfo> info;
    if (main_scenario_script) {
        auto res = main_scenario_script->call<std::vector<GameGlobalInfo::ObjectSpawnInfo>>("getSpawnableGMObjects");
        LuaConsole::checkResult(res);
        if (res.isOk())
            info = res.value();
    }
    return info;
}


void GameGlobalInfo::reset()
{
    if (state_logger)
        state_logger->destroy();

    gm_callback_functions.clear();
    gm_messages.clear();
    on_gm_click = nullptr;

    sp::ecs::Entity::destroyAllEntities();
    main_scenario_script = nullptr;
    additional_scripts.clear();
    script_environment_base = nullptr;

    elapsed_time = 0.0f;
    callsign_counter = 0;
    global_message = "";
    global_message_timeout = 0.0f;
    banner_string = "";

    //Pause the game
    engine->setGameSpeed(0.0);

    foreach(PlayerInfo, p, player_info_list)
    {
        p->reset();
    }
}

void GameGlobalInfo::setScenarioSettings(const string filename, std::unordered_map<string, string> new_settings)
{
    // Use the parsed scenario metadata.
    ScenarioInfo info(filename);

    // Set the scenario name.
    gameGlobalInfo->scenario = info.name;
    LOG(INFO) << "Configuring settings for scenario " << gameGlobalInfo->scenario;

    // Set each scenario setting to either a matching passed new value, or the
    // default if there's no match (or no new value).
    for(auto& setting : info.settings)
    {
        // Initialize with defaults.
        gameGlobalInfo->scenario_settings[setting.key] = setting.default_option;

        // If new settings were passed ...
        if (!new_settings.empty())
        {
            // ... confirm that this setting key exists in the new settings.
            if (new_settings.find(setting.key) != new_settings.end())
            {
                if (new_settings[setting.key] != "")
                {
                    // If so, override the default with the new value.
                    gameGlobalInfo->scenario_settings[setting.key] = new_settings[setting.key];
                }
            }
        }

        // Log scenario setting confirmation.
        LOG(INFO) << setting.key << " scenario setting set to " << gameGlobalInfo->scenario_settings[setting.key];
    }
}

void GameGlobalInfo::startScenario(string filename, std::unordered_map<string, string> new_settings)
{
    reset();

    i18n::reset();
    i18n::load("locale/main." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/comms_ship." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/comms_station." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/factionInfo." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/science_db." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

    script_environment_base = std::make_unique<sp::script::Environment>();
    main_script_error_count = 0;
    if (setupScriptEnvironment(*script_environment_base.get())) {
        auto res = script_environment_base->runFile<void>("model_data.lua");
        LuaConsole::checkResult(res);
        if (!res.isErr()) {
            res = script_environment_base->runFile<void>("factionInfo.lua");
            LuaConsole::checkResult(res);
        }
        if (!res.isErr()) {
            res = script_environment_base->runFile<void>("shipTemplates.lua");
            LuaConsole::checkResult(res);
        }
        if (!res.isErr()) {
            res = script_environment_base->runFile<void>("science_db.lua");
            LuaConsole::checkResult(res);
        }
    }

    main_scenario_script = std::make_unique<sp::script::Environment>(script_environment_base.get());
    setupSubEnvironment(*main_scenario_script.get());
    //TODO: int max_cycles = PreferencesManager::get("script_cycle_limit", "0").toInt();
    //TODO: if (max_cycles > 0)
    //TODO:     script->setMaxRunCycles(max_cycles);

    // Initialize scenario settings.
    setScenarioSettings(filename, new_settings);

    auto res = main_scenario_script->runFile<void>(filename);
    LuaConsole::checkResult(res);
    if (res.isOk() && main_scenario_script->isFunction("init")) {
        res = main_scenario_script->call<void>("init");
        LuaConsole::checkResult(res);
        if (res.isErr()) {
            main_script_error_count = max_repeated_script_errors;
            LuaConsole::addLog("init() function failed, not going to call update()");
        }
    }

    if (PreferencesManager::get("game_logs", "1").toInt())
    {
        state_logger = new GameStateLogger();
        state_logger->start();
    }
}

void GameGlobalInfo::destroy()
{
    reset();
    MultiplayerObject::destroy();
}

string GameGlobalInfo::getMissionTime() {
    unsigned int seconds = gameGlobalInfo->elapsed_time;
    unsigned int minutes = (seconds / 60) % 60;
    unsigned int hours = (seconds / 60 / 60) % 24;
    seconds = seconds % 60;
    char buf[9];
    std::snprintf(buf, 9, "%02d:%02d:%02d", hours, minutes, seconds);
    return string(buf);
}

string getSectorName(glm::vec2 position)
{
    constexpr float sector_size = 20000;
    int sector_x = floorf(position.x / sector_size) + 5;
    int sector_y = floorf(position.y / sector_size) + 5;
    string y;
    string x;
    if (sector_y >= 0)
        if (sector_y < 26)
            y = string(char('A' + (sector_y)));
        else
            y = string(char('A' - 1 + (sector_y / 26))) + string(char('A' + (sector_y % 26)));
    else
        y = string(char('z' + ((sector_y + 1) / 26))) + ((sector_y  % 26) == 0 ? "a" : string(char('z' + 1 + (sector_y  % 26))));
    x = string(sector_x);
    return y + x;
}

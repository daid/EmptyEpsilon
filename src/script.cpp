#include <i18n.h>
#include "gameGlobalInfo.h"
#include "preferenceManager.h"
#include "script.h"
#include "resources.h"
#include "random.h"
#include "config.h"
#include "script/vector.h"
#include "menus/luaConsole.h"
#include "systems/comms.h"
#include "io/json.h"


/// void require(string filename)
/// Runs the Lua script with the given filename in the same context as the running Script.
/// Loads the localized file if it exists at locale/<FILENAME>.<LANGUAGE>.po.
static int luaRequire(lua_State* L)
{
    bool error = false;
    int old_top = lua_gettop(L);
    string filename = luaL_checkstring(L, 1);

    {
        //Start a new scope to ensure things are properly destroyed before we call lua_error(), as lua_error does not properly call destructors.
        P<ResourceStream> stream = getResourceStream(filename);
        if (!stream)
        {
            lua_pushstring(L, ("Require: Script not found: " + filename).c_str());
            error = true;
        }

        if (!error) {
            // Load the locale file for this script.
            i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

            string filecontents = stream->readAll();
            stream->destroy();
            stream = nullptr;

            if (luaL_loadbuffer(L, filecontents.c_str(), filecontents.length(), ("@" + filename).c_str()))
            {
                string error_string = luaL_checkstring(L, -1);
                lua_pushstring(L, ("require:" + error_string).c_str());
                error = true;
            }
        }
    }

    if (!error) {
        lua_pushvalue(L, lua_upvalueindex(1));
        lua_setupvalue(L, -2, 1);

        //Call the actual code.
        if (lua_pcall(L, 0, LUA_MULTRET, 0))
        {
            string error_string = luaL_checkstring(L, -1);
            lua_pushstring(L, ("require:" + error_string).c_str());
            error = true;
        }
    }

    if (error)
        return lua_error(L);
    return lua_gettop(L) - old_top;
}

static int luaTranslate(lua_State* L)
{
    auto str_1 = luaL_checkstring(L, 1);
    auto str_2 = luaL_optstring(L, 2, nullptr);
    if (str_2)
        lua_pushstring(L, tr(str_1, str_2).c_str());
    else
        lua_pushstring(L, tr(str_1).c_str());
    return 1;
}

static sp::ecs::Entity luaCreateEntity()
{
    return sp::ecs::Entity::create();
}

static int luaCreateObjectFunc(lua_State* L)
{
    lua_newtable(L);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);

    lua_getfield(L, -1, "__init__");
    if (lua_isfunction(L, -1)) {
        lua_pushvalue(L, -2);
        lua_call(L, 1, 0);
    } else {
        lua_pop(L, 1);
    }
    return 1;
}

static int luaCreateClass(lua_State* L)
{
    // Create a class, returns 1 variable, which is a table containing the functions for this class.
    lua_newtable(L); // Table to return
    lua_newtable(L); // Table to use as metatable for the class table.
    lua_newtable(L); // Table to use as metatable for the object table.
    lua_pushvalue(L, -3);
    lua_setfield(L, -2, "__index");
    lua_pushcclosure(L, luaCreateObjectFunc, 1);
    lua_setfield(L, -2, "__call");
    lua_setmetatable(L, -2);
    return 1;
}

static int luaPrintLog(lua_State* L, bool print)
{
    string message;
    int n = lua_gettop(L);  /* number of arguments */
    for (int i=1; i<=n; i++) {
        if (lua_istable(L, i)) {
            if (i > 1)
                message += " ";
            message += "{";
            lua_pushnil(L);
            bool first = true;
            while(lua_next(L, i)) {
                if (first) first = false; else message += ",";
                auto s = luaL_tolstring(L, -2, nullptr);
                if (s != nullptr) {
                    message += s;
                    message += "=";
                }
                lua_pop(L, 1);
                s = luaL_tolstring(L, -1, nullptr);
                if (s != nullptr) {
                    message += s;
                }
                lua_pop(L, 2);
            }
            message += "}";
        } else {
            auto s = luaL_tolstring(L, i, nullptr);
            if (s != nullptr) {
                if (i > 1)
                    message += " ";
                message += s;
            }
            lua_pop(L, 1);
        }
    }
    LOG(Info, "LUA:", message);
    if (print)
        LuaConsole::addLog(message);
    return 0;
}

static int luaPrint(lua_State* L)
{
    return luaPrintLog(L, true);
}

static int luaLog(lua_State* L)
{
    return luaPrintLog(L, false);
}

static int luaGetEntityFunctionTable(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "EFT");
    return 1;
}

static void luaVictory(string faction)
{
    gameGlobalInfo->setVictory(faction);
    if (engine->getObject("scenario"))
        engine->getObject("scenario")->destroy();
    engine->setGameSpeed(0.0);
}

static string luaGetScenarioSetting(string key)
{
    if (gameGlobalInfo->scenario_settings.find(key) != gameGlobalInfo->scenario_settings.end())
        return gameGlobalInfo->scenario_settings[key];
    return "";
}

static string luaGetScenarioVariation()
{
    if (gameGlobalInfo->scenario_settings.find("variation") != gameGlobalInfo->scenario_settings.end())
        return gameGlobalInfo->scenario_settings["variation"];
    return "None";
}

static void luaOnNewPlayerShip(sp::script::Callback callback)
{
    gameGlobalInfo->on_new_player_ship = callback;
}

static void luaGlobalMessage(string message, std::optional<float> timeout)
{
    gameGlobalInfo->global_message = message;
    gameGlobalInfo->global_message_timeout = timeout.has_value() ? timeout.value() : 5.0f;
}

static void luaAddGMFunction(string label, sp::script::Callback callback)
{
    gameGlobalInfo->gm_callback_functions.emplace_back(label);
    gameGlobalInfo->gm_callback_functions.back().callback = callback;
}

static void luaClearGMFunctions()
{
    gameGlobalInfo->gm_callback_functions.clear();
}

static int luaCreateAdditionalScript(lua_State* L)
{
    auto env = std::make_unique<sp::script::Environment>();
    setupScriptEnvironment(*env.get());
    auto ptr = reinterpret_cast<sp::script::Environment**>(lua_newuserdata(L, sizeof(sp::script::Environment*)));
    *ptr = env.get();
    luaL_getmetatable(L, "ScriptObject");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        luaL_newmetatable(L, "ScriptObject");
        lua_newtable(L);
        lua_pushcfunction(L, [](lua_State* LL) {
            auto ptr = reinterpret_cast<sp::script::Environment**>(luaL_checkudata(LL, 1, "ScriptObject"));
            if (!ptr) return 0;
            string filename = luaL_checkstring(LL, 2);
            i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));
            auto res = (*ptr)->runFile<void>(filename);
            LuaConsole::checkResult(res);
            return 0;
        });
        lua_setfield(L, -2, "run");
        lua_pushcfunction(L, [](lua_State* LL) {
            auto ptr = reinterpret_cast<sp::script::Environment**>(luaL_checkudata(LL, 1, "ScriptObject"));
            if (!ptr) return 0;
            string name = luaL_checkstring(LL, 2);
            string value = luaL_checkstring(LL, 3);
            (*ptr)->setGlobal(name, value);
            return 0;
        });
        lua_setfield(L, -2, "setVariable");
        lua_setfield(L, -2, "__index");
        lua_pushstring(L, "sandboxed");
        lua_setfield(L, -2, "__metatable");
    }
    lua_setmetatable(L, -2);
    gameGlobalInfo->additional_scripts.push_back(std::move(env));
    return 1;
}

static glm::vec2 luaSectorToXY(string sector)
{
    constexpr float sector_size = 20000;
    int x, y, intpart;

    if(sector.length() < 2){
        return glm::vec2(0,0);
    }

    // Y axis is complicated
    if(sector[0] >= char('A') && sector[1] >= char('A')){
        // Case with two letters
        char a1 = sector[0];
        char a2 = sector[1];
        try{
            intpart = stoi(sector.substr(2));
        }
        catch(const std::exception& e){
            return glm::vec2(0,0);
        }
        if(a1 > char('a')){
            // Case with two lowercase letters (zz10) counting down towards the North
            y = (((char('z') - a1) * 26) + (char('z') - a2 + 6)) * -sector_size; // 6 is the offset from F5 to zz5
        }else{
            // Case with two uppercase letters (AB20) counting up towards the South
            y = (((a1 - char('A')) * 26) + (a2 - char('A') + 21)) * sector_size; // 21 is the offset from F5 to AA5
        }
    }else{
        //Case with just one letter (A9/a9 - these are the same sector, as case only matters in the two-letter sectors)
        char alphaPart = toupper(sector[0]);
        try{
            intpart = stoi(sector.substr(1));
        }catch(const std::exception& e){
            return glm::vec2(0,0);
        }
        y = (alphaPart - char('F')) * sector_size;
    }
    // X axis is simple
    x = (intpart - 5) * sector_size; // 5 is the numeric component of the F5 origin
    return glm::vec2(x, y);
}

static void luaSetBanner(string banner)
{
    gameGlobalInfo->banner_string = banner;
}

static float luaGetScenarioTime()
{
    return gameGlobalInfo->elapsed_time;
}

static int luaGetEEVersion()
{
    return VERSION_NUMBER;
}

static nlohmann::json luaToJSONImpl(lua_State* L, int lua_index) {
    if (lua_isboolean(L, lua_index)) {
        return bool(lua_toboolean(L, lua_index));
    } else if (lua_isinteger(L, lua_index)) {
        return lua_tointeger(L, lua_index);
    } else if (lua_isnumber(L, lua_index)) {
        return lua_tonumber(L, lua_index);
    } else if (lua_isstring(L, lua_index)) {
        return lua_tostring(L, lua_index);
    } else if (lua_istable(L, lua_index)) {
        // Figure out of the table is a list or not.
        bool is_array = true;
        int index_max = std::numeric_limits<int>::min();
        int index_min = std::numeric_limits<int>::max();
        lua_pushnil(L);
        while(lua_next(L, lua_index) && is_array) {
            if (!lua_isinteger(L, -2)) {
                is_array = false;
            } else {
                int idx = lua_tointeger(L, -2);
                index_max = std::max(idx, index_max);
                index_min = std::min(idx, index_min);
            }
            lua_pop(L, 1);
        }
        if (is_array && index_min == 1 && index_max < 0x10000) {
            auto json = nlohmann::json::array();
            for(int idx=1; idx<=index_max; idx++) {
                lua_rawgeti(L, lua_index, idx);
                json.push_back(luaToJSONImpl(L, lua_gettop(L)));
                lua_pop(L, 1);
            }
            return json;
        } else {
            auto json = nlohmann::json::object();
            lua_pushnil(L);
            while(lua_next(L, lua_index)) {
                std::string key = "?";
                if (lua_isboolean(L, -2)) {
                    key = lua_toboolean(L, -2) ? "true" : "false";
                } else if (lua_isinteger(L, -2)) {
                    key = std::to_string(lua_tointeger(L, -2));
                } else if (lua_isnumber(L, -2)) {
                    key = std::to_string(lua_tonumber(L, -2));
                } else if (lua_isstring(L, -2)) {
                    key = lua_tostring(L, -2);
                }
                json[key] = luaToJSONImpl(L, lua_gettop(L));
                lua_pop(L, 1);
            }
            return json;
        }
    }
    return {};
}

static int luaToJSON(lua_State* L)
{
    auto argc = lua_gettop(L);
    for(int n=1; n<=argc; n++) {
        auto json = luaToJSONImpl(L, n);
        auto res = json.dump(-1, ' ', false, nlohmann::json::error_handler_t::replace);
        lua_pushstring(L, res.c_str());
    }
    return argc;
}

static void luaFromJSONImpl(lua_State* L, const nlohmann::json& json)
{
    if (json.is_boolean()) {
        lua_pushboolean(L, bool(json));
    } else if (json.is_string()) {
        auto s = static_cast<std::string>(json);
        lua_pushlstring(L, s.c_str(), s.size());
    } else if (json.is_number_integer()) {
        lua_pushinteger(L, int(json));
    } else if (json.is_number()) {
        lua_pushnumber(L, json);
    } else if (json.is_array()) {
        lua_newtable(L);
        int idx = 1;
        for(const auto& v : json) {
            luaFromJSONImpl(L, v);
            lua_rawseti(L, -2, idx++);
        }
    } else if (json.is_object()) {
        lua_newtable(L);
        for(const auto& v : json.items()) {
            lua_pushstring(L, v.key().c_str());
            luaFromJSONImpl(L, v.value());
            lua_rawset(L, -3);
        }
    } else {
        lua_pushnil(L);
    }
}

static int luaFromJSON(lua_State* L)
{
    bool error = false;
    auto argc = lua_gettop(L);
    for(int n=1; n<=argc; n++) {
        auto str = lua_tostring(L, n);
        std::string err;
        auto res = sp::json::parse(str, err);
        if (res.has_value()) {
            luaFromJSONImpl(L, res.value());
        } else {
            lua_pushstring(L, err.c_str());
            error = true;
            break;
        }
    }
    if (error)
        return lua_error(L);
    return argc;
}

bool setupScriptEnvironment(sp::script::Environment& env)
{
    // Load core global functions
    env.setGlobal("random", static_cast<float(*)(float, float)>(&random));
    env.setGlobal("irandom", &irandom);
    env.setGlobal("print", &luaPrint);
    env.setGlobal("log", &luaLog);
    env.setGlobalFuncWithEnvUpvalue("require", &luaRequire);
    env.setGlobal("_", &luaTranslate);
    
    env.setGlobal("createEntity", &luaCreateEntity);
    env.setGlobal("getLuaEntityFunctionTable", &luaGetEntityFunctionTable);
    
    env.setGlobal("createClass", &luaCreateClass);

    /// string getScenarioSetting(string key)
    /// Returns the given scenario setting's value, or an empty string if the setting is not found.
    /// Warning: Headless server modes might load scenarios without default setting values.
    /// Example: getScenarioSetting("Difficulty") -- if a scenario has Setting[Difficulty], returns its value, such as "Easy" or "Normal"
    env.setGlobal("getScenarioSetting", &luaGetScenarioSetting);
    // this returns the "variation" scenario setting for backwards compatibility
    /// string getScenarioVariation()
    /// [DEPRECATED]
    /// As getScenarioSetting("variation").
    env.setGlobal("getScenarioVariation", &luaGetScenarioVariation);
    env.setGlobal("onNewPlayerShip", &luaOnNewPlayerShip);
    /// void globalMessage(string message, std::optional<float> timeout)
    /// Displays a message on the main screens of all active player ships.
    /// The message appears for 5 seconds, but new messages immediately replace any displayed message.
    /// Example: globalMessage("You will soon die!")
    env.setGlobal("globalMessage", &luaGlobalMessage);
    /// void victory(string faction_name)
    /// Sets the given faction as the scenario's victor and ends the scenario.
    /// (The GM can unpause the game, but the scenario with its update function is destroyed.)
    /// Example: victory("Exuari") -- ends the scenario, Exuari win
    env.setGlobal("victory", &luaVictory);
    /// string getSectorName(float x, float y)
    /// Returns the name of the sector containing the given x/y coordinates.
    /// Coordinates 0,0 are the top-left ("northwest") point of sector F5.
    /// See also SpaceObject:getSectorName().
    /// Example: getSectorName(20000,-40000) -- returns "D6"
    env.setGlobal("getSectorName", &getSectorName);
    /// glm::vec2 sectorToXY(string sector_name)
    /// Returns the top-left ("northwest") x/y coordinates for the given sector mame.
    /// Examples:
    /// x,y = sectorToXY("A0") -- x = -100000, y = -100000
    /// x,y = sectorToXY("zz-23") -- x = -560000, y = -120000
    /// x,y = sectorToXY("BA12") -- x = 140000, y = 940000
    env.setGlobal("sectorToXY", &luaSectorToXY);
    /// void setBanner(string banner)
    /// Displays a scrolling banner containing the given text on the cinematic and top-down views.
    /// Example: setBanner("You will soon die!")
    env.setGlobal("setBanner", &luaSetBanner);
    /// float getScenarioTime()
    /// Returns the elapsed time of the scenario, in seconds.
    /// This timer stops when the game is paused.
    /// Example: getScenarioTime() -- after two minutes, returns 120.0
    env.setGlobal("getScenarioTime", &luaGetScenarioTime);


    env.setGlobal("addGMFunction", &luaAddGMFunction);
    env.setGlobal("clearGMFunctions", &luaClearGMFunctions);

    env.setGlobal("Script", &luaCreateAdditionalScript);

    env.setGlobal("setCommsMessage", &CommsSystem::luaSetCommsMessage);
    env.setGlobal("addCommsReply", &CommsSystem::luaAddCommsReply);
    env.setGlobal("commsSwitchToGM", &CommsSystem::luaCommsSwitchToGM);

    /// string toJSON(data)
    /// Returns a json string with the input data converted to json.
    env.setGlobal("toJSON", &luaToJSON);
    /// table/value fromJSON(data)
    /// Returns a table/value converted from a json string
    env.setGlobal("fromJSON", &luaFromJSON);

    env.setGlobal("getEEVersion", &luaGetEEVersion);

    auto res = env.runFile<void>("luax.lua");
    LuaConsole::checkResult(res);
    if (res.isErr())
        return false;
    res = env.runFile<void>("api/all.lua");
    LuaConsole::checkResult(res);
    if (res.isErr())
        return false;
    return true;
}

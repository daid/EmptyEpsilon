#include <i18n.h>
#include "gameGlobalInfo.h"
#include "soundManager.h"
#include "preferenceManager.h"
#include "script.h"
#include "resources.h"
#include "random.h"
#include "config.h"
#include "script/vector.h"
#include "menus/luaConsole.h"
#include "systems/comms.h"
#include "ecs/query.h"
#include "components/collision.h"
#include "systems/collision.h"
#include "playerInfo.h"
#include "io/json.h"
#include "script/enum.h"
#include "script/crewPosition.h"
#include "script/dataStorage.h"
#include "script/gm.h"
#include "script/component.h"
#include "script/damageInfo.h"
#include "script/scriptRandom.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/maneuveringthrusters.h"
#include "components/target.h"
#include "components/shields.h"
#include "components/coolant.h"
#include "components/beamweapon.h"
#include "components/internalrooms.h"
#include "components/zone.h"
#include "components/shiplog.h"
#include "components/selfdestruct.h"
#include "systems/jumpsystem.h"
#include "systems/missilesystem.h"
#include "systems/docking.h"
#include "systems/selfdestruct.h"
#include "systems/radarblock.h"
#include "math/centerOfMass.h"


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

static int luaQueryEntities(lua_State* L)
{
    auto key = luaL_checkstring(L, 1);
    auto it = sp::script::ComponentRegistry::components.find(key);
    if (it == sp::script::ComponentRegistry::components.end())
        return luaL_error(L, "Tried to query non-existing component %s", key);
    return it->second.query(L);
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

static string luaGetSectorName(float x, float y)
{
    return getSectorName({x, y});
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
    auto env = std::make_unique<sp::script::Environment>(gameGlobalInfo->script_environment_base.get());
    setupSubEnvironment(*env.get());
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
            if (res.isOk()) {
                res = (*ptr)->call<void>("init");
                LuaConsole::checkResult(res);
            }
            return 0;
        });
        lua_setfield(L, -2, "run");
        lua_pushcfunction(L, [](lua_State* LL)
        {
            auto ptr = reinterpret_cast<sp::script::Environment**>(luaL_checkudata(LL, 1, "ScriptObject"));
            if (!ptr) return 0;
            string name = luaL_checkstring(LL, 2);
            auto ltype = lua_type(LL, 3);
            // Strings
            if (ltype == LUA_TSTRING)
            {
                string value = lua_tostring(LL, 3);
                (*ptr)->setGlobal(name, value);
            }
            // Entities, as light userdata
            else if (ltype == LUA_TLIGHTUSERDATA)
            {
                sp::ecs::Entity entity = sp::script::Convert<sp::ecs::Entity>::fromLua(LL, 3);
                if (entity) (*ptr)->setGlobal(name, entity);
                else return luaL_error(LL, "Userdata was passed to setVariable, but it wasn't an entity");
            }
            // Numbers
            else if (ltype == LUA_TNUMBER)
            {
                float value = lua_tonumber(LL, 3);
                (*ptr)->setGlobal(name, value);
            }
            else
                return luaL_error(LL, "setVariable expects a string, float, or entity as the second argument");

            lua_settop(LL, 1);
            return 1;
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

static int luaSectorToXY(lua_State* L)
{
    string sector = luaL_checkstring(L, 1);
    constexpr float sector_size = 20000;
    int x, y, intpart;

    if(sector.length() < 2){
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        lua_pushboolean(L, false);
        return 3;
    }

    // Y axis is complicated
    if(sector[0] >= char('A') && sector[1] >= char('A')) {
        // Case with two letters
        char a1 = sector[0];
        char a2 = sector[1];
        try{
            intpart = stoi(sector.substr(2));
        } catch(const std::exception& e) {
            lua_pushnumber(L, 0);
            lua_pushnumber(L, 0);
            lua_pushboolean(L, false);
            return 3;
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
            lua_pushnumber(L, 0);
            lua_pushnumber(L, 0);
            lua_pushboolean(L, false);
            return 3;
        }
        y = (alphaPart - char('F')) * sector_size;
    }
    // X axis is simple
    x = (intpart - 5) * sector_size; // 5 is the numeric component of the F5 origin
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    lua_pushboolean(L, true);
    return 3;
}

static bool luaIsInsideZone(float x, float y, sp::ecs::Entity e)
{
    auto zone = e.getComponent<Zone>();
    if (!zone) return false;
    auto t = e.getComponent<sp::Transform>();
    if (!t) return false;
    return insidePolygon(zone->outline, t->getPosition() - glm::vec2(x, y));
}

static void luaSetBanner(string banner)
{
    gameGlobalInfo->banner_string = banner;
}

static void luaSetDefaultSkybox(string skybox)
{
    gameGlobalInfo->default_skybox = skybox;
}

static float luaGetScenarioTime()
{
    return gameGlobalInfo->elapsed_time;
}

static int luaGetAllObjects(lua_State* L)
{
    lua_newtable(L);
    int idx = 1;
    for(auto [e, t] : sp::ecs::Query<sp::Transform>()) {
        sp::script::Convert<sp::ecs::Entity>::toLua(L, e);
        lua_rawseti(L, -2, idx++);
    }
    return 1;
}

static int luaGetObjectsInRadius(lua_State* L)
{
    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);
    float r = luaL_checknumber(L, 3);

    glm::vec2 position(x, y);
    lua_newtable(L);
    int idx = 1;
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(r, r), position + glm::vec2(r, r))) {
        auto entity_transform = entity.getComponent<sp::Transform>();
        if (entity_transform) {
            if (glm::length2(entity_transform->getPosition() - position) < r*r) {
                sp::script::Convert<sp::ecs::Entity>::toLua(L, entity);
                lua_rawseti(L, -2, idx++);
            }
        }
    }
    return 1;
}

static int luaGetEnemiesInRadiusFor(lua_State* L)
{
    lua_newtable(L);
    int idx = 1;
    auto source = sp::script::Convert<sp::ecs::Entity>::fromLua(L, 1);
    if (!source) return 1;
    float r = luaL_checknumber(L, 2);
    auto source_transform = source.getComponent<sp::Transform>();
    if (!source_transform) return 1;
    auto position = source_transform->getPosition();
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(r, r), position + glm::vec2(r, r))) {
        auto entity_transform = entity.getComponent<sp::Transform>();
        if (entity_transform) {
            if (glm::length2(entity_transform->getPosition() - position) < r*r) {
                if (Faction::getRelation(entity, source) == FactionRelation::Enemy) {
                    sp::script::Convert<sp::ecs::Entity>::toLua(L, entity);
                    lua_rawseti(L, -2, idx++);
                }
            }
        }
    }
    return 1;
}

static void luaTransferPlayers(sp::ecs::Entity source, sp::ecs::Entity target, std::optional<CrewPosition> station)
{
    if (!target.getComponent<PlayerControl>()) return;
    // For each player, move them to the same station on the target.
    for(auto i : player_info_list)
        if (i->ship == source && (!station.has_value() || i->hasPosition(station.value())))
            i->ship = target;
}

static bool luaHasPlayerAtPosition(sp::ecs::Entity source, CrewPosition station)
{
    for(auto i : player_info_list)
        if (i->ship == source && i->hasPosition(station))
            return true;
    return false;
}

static int luaGetPlayersInfo(lua_State* L)
{
    auto source = sp::script::Convert<sp::ecs::Entity>::fromLua(L, 1);
    lua_newtable(L);
    int index = 1;
    for(auto i : player_info_list) {
        if (i->ship != source)
            continue;
        lua_newtable(L);
        lua_pushstring(L, i->name.c_str());
        lua_setfield(L, -2, "name");
        CrewPositions positions;
        for(auto cp : i->crew_positions) {
            positions.mask |= cp.mask;
        }
        sp::script::Convert<CrewPositions>::toLua(L, positions);
        lua_setfield(L, -2, "positions");
        lua_seti(L, -2, index);
        index++;
    }
    return 1;
}

void luaSetPlayerShipCustomFunction(sp::ecs::Entity entity, CustomShipFunctions::Function::Type type, string name, string caption, CrewPositions positions, sp::script::Callback callback, int order)
{
    auto csf = entity.getComponent<CustomShipFunctions>();
    if (!csf) return;
    int idx = -1;
    for(int n=0; n<int(csf->functions.size()); n++) {
        if (csf->functions[n].name == name) {
            idx = n;
        }
    }
    if (idx == -1) {
        idx = int(csf->functions.size());
        csf->functions.emplace_back();
    }
    auto& f = csf->functions[idx];
    f.type = type;
    f.name = name;
    f.caption = caption;
    f.crew_positions = positions;
    f.callback = callback;
    f.order = order;
    std::stable_sort(csf->functions.begin(), csf->functions.end());
    csf->functions_dirty = true;
}

void luaRemovePlayerShipCustomFunction(sp::ecs::Entity entity, string name)
{
    auto csf = entity.getComponent<CustomShipFunctions>();
    if (!csf) return;
    auto it = std::remove_if(csf->functions.begin(), csf->functions.end(), [csf, name](const CustomShipFunctions::Function& f) {
        return f.name == name;
    });
    if (it != csf->functions.end()) {
        csf->functions.erase(it, csf->functions.end());
        csf->functions_dirty = true;
    }
}

void luaAddEntryToShipsLog(sp::ecs::Entity entity, string entry, glm::u8vec4 color)
{
    auto sl = entity.getComponent<ShipLog>();
    if (!sl) return;
    sl->add(entry, color);
}


static sp::ecs::Entity luaGetPlayerShip(int index)
{
    if (index == -1) {
        for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
            return entity;
        return {};
    }
    if (index == -2)
        return my_spaceship;
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
        if (--index == 0)
            return entity;
    return {};
}

static int luaGetActivePlayerShips(lua_State* L)
{
    lua_newtable(L);
    int index = 1;
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>()) {
        sp::script::Convert<sp::ecs::Entity>::toLua(L, entity);
        lua_rawseti(L, -2, index++);
    }
    return 1;
}

static string luaGetGameLanguage()
{
    return PreferencesManager::get("language", "en").c_str();
}

/** Short lived object to do a scenario change on the update loop. See "setScenario" for details */
class ScenarioChanger : public Updatable
{
public:
    ScenarioChanger(string script_name, std::unordered_map<string, string>&& settings)
    : script_name(script_name), settings(std::move(settings))
    {
    }

    virtual void update(float delta) override
    {
        gameGlobalInfo->startScenario(script_name, settings);
        destroy();
    }
private:
    string script_name;
    std::unordered_map<string, string> settings;
};

static int luaSetScenario(lua_State* L)
{
    string script_name = luaL_checkstring(L, 1);
    std::unordered_map<string, string> settings;

    // Script filename must not be an empty string.
    if (script_name == "")
    {
        LOG(ERROR) << "setScenario() requires a non-empty value.";
        return 1;
    }

    if (lua_type(L, 2) == LUA_TSTRING) {
        LOG(WARNING) << "LUA: DEPRECATED setScenario() called with scenario variation. Passing the value as the \"variation\" scenario setting instead.";
        string variation = lua_tostring(L, 2);
        settings["variation"] = variation;
    }
    if (lua_istable(L, 2)) {
        lua_pushnil(L);
        while(lua_next(L, 2)) {
            settings[lua_tostring(L, -2)] = lua_tostring(L, -1);
            lua_pop(L, 1);
        }
    }
    new ScenarioChanger(script_name, std::move(settings));

    // This could be called from a currently active scenario script.
    // Calling GameGlobalInfo::startScenario is unsafe at this point,
    // as this will destroy the lua state that this function is running in.
    // So use the ScenarioChanger object which will do the change in the update loop. Which is safe.
    return 0;
}


static void luaShutdownGame()
{
    engine->shutdown();
}

static void luaPauseGame()
{
    engine->setGameSpeed(0.0);
}

static void luaUnpauseGame()
{
    engine->setGameSpeed(1.0);
}

static void luaPlaySoundFile(string filename)
{
    int n = filename.rfind(".");
    if (n > -1)
    {
        string filename_with_locale = filename.substr(0, n) + "." + PreferencesManager::get("language", "en") + filename.substr(n);
        if (getResourceStream(filename_with_locale)) {
            soundManager->playSound(filename_with_locale);
            return;
        }
    }
    soundManager->playSound(filename);
    return;
}

static void luaApplyDamageToEntity(sp::ecs::Entity e, float amount, DamageInfo info)
{
    DamageSystem::applyDamage(e, amount, info);
}

static int luaGetEEVersion()
{
    return VERSION_NUMBER;
}

static nlohmann::json luaToJSONImpl(lua_State* L, int lua_index) {
    LOG(DEBUG, lua_index);
    auto ltype = lua_type(L, lua_index);
    if (ltype == LUA_TBOOLEAN) {
        return bool(lua_toboolean(L, lua_index));
    } else if (ltype == LUA_TNUMBER) {
        if (lua_isinteger(L, lua_index))
            return lua_tointeger(L, lua_index);
        return lua_tonumber(L, lua_index);
    } else if (ltype == LUA_TSTRING) {
        return lua_tostring(L, lua_index);
    } else if (lua_istable(L, lua_index)) {
        // Figure out of the table is a list or not.
        bool is_array = true;
        int index_max = std::numeric_limits<int>::min();
        int index_min = std::numeric_limits<int>::max();
        lua_pushnil(L);
        while(is_array && lua_next(L, lua_index)) {
            if (!lua_isinteger(L, -2)) {
                is_array = false;
                lua_pop(L, 1);
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
                ltype = lua_type(L, -2);
                if (ltype == LUA_TBOOLEAN) {
                    key = lua_toboolean(L, -2) ? "true" : "false";
                } else if (ltype == LUA_TNUMBER) {
                    if (lua_isinteger(L, -2))
                        key = std::to_string(lua_tointeger(L, -2));
                    else
                        key = std::to_string(lua_tonumber(L, -2));
                } else if (ltype == LUA_TSTRING) {
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

namespace sp::script {
template<> struct Convert<EScanningComplexity> {
    static int toLua(lua_State* L, EScanningComplexity value) {
        switch(value) {
        default:
        case SC_None: lua_pushstring(L, "none"); break;
        case SC_Simple: lua_pushstring(L, "simple"); break;
        case SC_Normal: lua_pushstring(L, "normal"); break;
        case SC_Advanced: lua_pushstring(L, "advanced"); break;
        }
        return 1;
    }
};
}

static EScanningComplexity luaGetScanningComplexity()
{
    return gameGlobalInfo->scanning_complexity;
}

static int luaGetHackingDifficulty()
{
    return gameGlobalInfo->hacking_difficulty;
}

namespace sp::script {
template<> struct Convert<EHackingGames> {
    static int toLua(lua_State* L, EHackingGames value) {
        switch(value) {
        case HG_Mine: lua_pushstring(L, "mines"); break;
        case HG_Lights: lua_pushstring(L, "lights"); break;
        default:
        case HG_All: lua_pushstring(L, "all"); break;
        }
        return 1;
    }
};
}

static EHackingGames luaGetHackingGames()
{
    return gameGlobalInfo->hacking_games;
}

static bool luaAreBeamShieldFrequenciesUsed()
{
    return gameGlobalInfo->use_beam_shield_frequencies;
}

static bool luaIsPerSystemDamageUsed()
{
    return gameGlobalInfo->use_system_damage;
}

static bool luaIsTacticalRadarAllowed()
{
    return gameGlobalInfo->allow_main_screen_tactical_radar;
}

static bool luaIsLongRangeRadarAllowed()
{
    return gameGlobalInfo->allow_main_screen_long_range_radar;
}

void luaCommandTargetRotation(sp::ecs::Entity ship, float rotation) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandTargetRotation(rotation); return; }
    auto thrusters = ship.getComponent<ManeuveringThrusters>();
    if (thrusters) { thrusters->stop(); thrusters->target = rotation; }
}

void luaCommandImpulse(sp::ecs::Entity ship, float target) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandImpulse(target); return; }
    auto engine = ship.getComponent<ImpulseEngine>();
    if (engine) engine->request = target;
}

void luaCommandWarp(sp::ecs::Entity ship, int target) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandWarp(target); return; }
    auto warp = ship.getComponent<WarpDrive>();
    if (warp) warp->request = target;
}

void luaCommandJump(sp::ecs::Entity ship, float distance) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandJump(distance); return; }
    JumpSystem::initializeJump(ship, distance);
}

void luaCommandAbortJump(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandAbortJump(); return; }
    JumpSystem::abortJump(ship);
}

void luaCommandSetTarget(sp::ecs::Entity ship, sp::ecs::Entity target) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetTarget(target); return; }
    ship.getOrAddComponent<Target>().entity = target;
}

void luaCommandLoadTube(sp::ecs::Entity ship, int tube_nr, EMissileWeapons type) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandLoadTube(tube_nr, type); return; }
    auto missiletubes = ship.getComponent<MissileTubes>();
    if (missiletubes && tube_nr >= 0 && tube_nr < int(missiletubes->mounts.size()))
        MissileSystem::startLoad(ship, missiletubes->mounts[tube_nr], type);
}

void luaCommandUnloadTube(sp::ecs::Entity ship, int tube_nr) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandUnloadTube(tube_nr); return; }
    auto missiletubes = ship.getComponent<MissileTubes>();
    if (missiletubes && tube_nr >= 0 && tube_nr < int(missiletubes->mounts.size()))
        MissileSystem::startUnload(ship, missiletubes->mounts[tube_nr]);
}

void luaCommandFireTube(sp::ecs::Entity ship, int tube_nr, float missile_target_angle) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandFireTube(tube_nr, missile_target_angle); return; }
    auto missiletubes = ship.getComponent<MissileTubes>();
    if (missiletubes && tube_nr >= 0 && tube_nr < int(missiletubes->mounts.size())) {
        sp::ecs::Entity target;
        if (auto t = ship.getComponent<Target>())
            target = t->entity;
        MissileSystem::fire(ship, missiletubes->mounts[tube_nr], missile_target_angle, target);
    }
}

void luaCommandFireTubeAtTarget(sp::ecs::Entity ship, int tube_nr, sp::ecs::Entity target) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandFireTubeAtTarget(tube_nr, target); return; }
    
    float targetAngle = 0.0;
    auto missiletubes = ship.getComponent<MissileTubes>();

    if (!target || !missiletubes || tube_nr < 0 || tube_nr >= int(missiletubes->mounts.size()))
        return;

    targetAngle = MissileSystem::calculateFiringSolution(ship, missiletubes->mounts[tube_nr], target);
    if (targetAngle == std::numeric_limits<float>::infinity()) {
        if (auto transform = ship.getComponent<sp::Transform>())
            targetAngle = transform->getRotation() + missiletubes->mounts[tube_nr].direction;
    }

    luaCommandFireTube(ship, tube_nr, targetAngle);
}

void luaCommandSetShields(sp::ecs::Entity ship, bool active) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetShields(active); return; }
    auto shields = ship.getComponent<Shields>();
    if (shields) {
        if (shields->calibration_delay <= 0.0f && active != shields->active)
        {
            shields->active = active;
            if (active)
                gameGlobalInfo->playSoundOnMainScreen(ship, "sfx/shield_up.wav");
            else
                gameGlobalInfo->playSoundOnMainScreen(ship, "sfx/shield_down.wav");
        }
    }
}

void luaCommandMainScreenSetting(sp::ecs::Entity ship, MainScreenSetting mainScreen) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandMainScreenSetting(mainScreen); return; }
    if (auto pc = ship.getComponent<PlayerControl>())
        pc->main_screen_setting = mainScreen;
}
void luaCommandMainScreenOverlay(sp::ecs::Entity ship, MainScreenOverlay mainScreen) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandMainScreenOverlay(mainScreen); return; }
    if (auto pc = ship.getComponent<PlayerControl>())
        pc->main_screen_overlay = mainScreen;
}
void luaCommandScan(sp::ecs::Entity ship, sp::ecs::Entity target) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandScan(target); return; }
    if (auto scanner = ship.getComponent<ScienceScanner>())
    {
        scanner->delay = scanner->max_scanning_delay;
        scanner->target = target;
    }
}
void luaCommandSetSystemPowerRequest(sp::ecs::Entity ship, ShipSystem::Type system, float power_level) {
    if (my_player_info && my_player_info->ship == ship)
    {
        my_player_info->commandSetSystemPowerRequest(system, power_level);
        return;
    }

    if (auto sys = ShipSystem::get(ship, system))
        sys->power_request = std::clamp(power_level, 0.0f, 3.0f);
}
void luaCommandSetSystemCoolantRequest(sp::ecs::Entity ship, ShipSystem::Type system, float coolant_level) {
    if (my_player_info && my_player_info->ship == ship)
    {
        my_player_info->commandSetSystemCoolantRequest(system, coolant_level);
        return;
    }

    if (auto coolant = ship.getComponent<Coolant>())
    {
        if (auto sys = ShipSystem::get(ship, system))
            sys->coolant_request = std::clamp(coolant_level, 0.0f, std::min(coolant->max_coolant_per_system, coolant->max));
    }
}
void luaCommandDock(sp::ecs::Entity ship, sp::ecs::Entity station) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandDock(station); return; }
    DockingSystem::requestDock(ship, station);
}
void luaCommandUndock(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandUndock(); return; }
    DockingSystem::requestUndock(ship);
}
void luaCommandAbortDock(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandAbortDock(); return; }
    DockingSystem::abortDock(ship);
}
void luaCommandOpenTextComm(sp::ecs::Entity ship, sp::ecs::Entity obj) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandOpenTextComm(obj); return; }
    CommsSystem::openTo(ship, obj);
}
void luaCommandCloseTextComm(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandCloseTextComm(); return; }
    CommsSystem::close(ship);
}
void luaCommandAnswerCommHail(sp::ecs::Entity ship, bool awnser) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandAnswerCommHail(awnser); return; }
    CommsSystem::answer(ship, awnser);
}
void luaCommandSendComm(sp::ecs::Entity ship, int index) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSendComm(index); return; }
    CommsSystem::selectScriptReply(ship, index);
}
void luaCommandSendCommPlayer(sp::ecs::Entity ship, string message) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSendCommPlayer(message); return; }
    CommsSystem::textReply(ship, message);
}

void luaCommandSetAutoRepair(sp::ecs::Entity ship, bool enabled) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetAutoRepair(enabled); return; }
    if (auto ir = ship.getComponent<InternalRooms>())
        ir->auto_repair_enabled = enabled;
}

void luaCommandSetBeamFrequency(sp::ecs::Entity ship, int frequency) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetBeamFrequency(frequency); return; }
    if (auto beamweapons = ship.getComponent<BeamWeaponSys>())
        beamweapons->frequency = std::clamp(frequency, 0, BeamWeaponSys::max_frequency);
}

void luaCommandSetBeamSystemTarget(sp::ecs::Entity ship, ShipSystem::Type type) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetBeamSystemTarget(type); return; }
    if (auto beamweapons = ship.getComponent<BeamWeaponSys>())
        beamweapons->system_target = type;
}

void luaCommandSetShieldFrequency(sp::ecs::Entity ship, int frequency) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetShieldFrequency(frequency); return; }
    auto shields = ship.getComponent<Shields>();
    if (shields && shields->calibration_delay <= 0.0f && frequency != shields->frequency)
    {
        shields->frequency = frequency;
        shields->calibration_delay = shields->calibration_time;
        shields->active = false;
        if (shields->frequency < 0)
            shields->frequency = 0;
        if (shields->frequency > BeamWeaponSys::max_frequency)
            shields->frequency = BeamWeaponSys::max_frequency;
    }
}

static void luaCommandAddWaypoint(sp::ecs::Entity ship, float x, float y) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandAddWaypoint({x, y}); return; }
    if (auto wp = ship.getComponent<Waypoints>()) {
        wp->addNew({x, y});
    }
}

static void luaCommandRemoveWaypoint(sp::ecs::Entity ship, int index) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandRemoveWaypoint(index); return; }
    auto wp = ship.getComponent<Waypoints>();
    if (wp && index >= 0 && index < int(wp->waypoints.size())) {
        wp->waypoints.erase(wp->waypoints.begin() + index);
        wp->dirty = true;
    }
}
static void luaCommandMoveWaypoint(sp::ecs::Entity ship, int index, float x, float y) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandMoveWaypoint(index, {x, y}); return; }
    if (auto wp = ship.getComponent<Waypoints>()) {
        wp->move(index, {x, y});
    }
}
static void luaCommandActivateSelfDestruct(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandActivateSelfDestruct(); return; }
    SelfDestructSystem::activate(ship);
}
static void luaCommandCancelSelfDestruct(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandCancelSelfDestruct(); return; }
    if (auto self_destruct = ship.getComponent<SelfDestruct>()) {
        if (self_destruct->countdown <= 0.0f) {
            self_destruct->active = false;
        }
    }
}
static void luaCommandConfirmDestructCode(sp::ecs::Entity ship, int index, int code) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandConfirmDestructCode(index, code); return; }
    if (auto self_destruct = ship.getComponent<SelfDestruct>()) {
        if (index >= 0 && index < SelfDestruct::max_codes && int(self_destruct->code[index]) == code && self_destruct->active)
            self_destruct->confirmed[index] = true;
    }
}
static void luaCommandCombatManeuverBoost(sp::ecs::Entity ship, float amount) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandCombatManeuverBoost(amount); return; }
    //TODO
}
static void luaCommandLaunchProbe(sp::ecs::Entity ship, float x, float y) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandLaunchProbe({x, y}); return; }
    //TODO
}
static void luaCommandSetScienceLink(sp::ecs::Entity ship, sp::ecs::Entity probe) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetScienceLink(probe); return; }
    //TODO
}
static void luaCommandClearScienceLink(sp::ecs::Entity ship) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandClearScienceLink(); return; }
    //TODO
}
static void luaCommandSetAlertLevel(sp::ecs::Entity ship, AlertLevel level) {
    if (my_player_info && my_player_info->ship == ship) { my_player_info->commandSetAlertLevel(level); return; }
    //TODO
}

static void luaStartThread(sp::script::Callback callback)
{
    auto res = callback.callCoroutine();
    LuaConsole::checkResult(res);
    if (res.isOk() && res.value())
        gameGlobalInfo->new_script_threads.push_back(res.value());
}

static int luaYield(lua_State* lua)
{
    return lua_yield(lua, 0);
}

void setupSubEnvironment(sp::script::Environment& env)
{
    env.setGlobalFuncWithEnvUpvalue("require", &luaRequire);
}

bool setupScriptEnvironment(sp::script::Environment& env)
{
    // Load core global functions
    env.setGlobal("print", &luaPrint);
    env.setGlobal("log", &luaLog);
    env.setGlobalFuncWithEnvUpvalue("require", &luaRequire);
    env.setGlobal("_", &luaTranslate);
    
    env.setGlobal("createEntity", &luaCreateEntity);
    /// table getEntitiesWithComponent(string component_name)
    /// Returns a table of entities that have the given component type.
    /// Component names are typically lowercased versions of their C++ equivalents with words separated by underscores instead of by case.
    /// These names do not necessarily match their ShipSystem equivalents. For example, "beam_weapons" is the Lua component name to be used here, but "beamweapons" is the separate Lua ShipSystem name.
    /// Examples:
    ///   getEntitiesWithComponent("beam_weapons") -- returns a table of all entities with the BeamWeapons component.
    ///   getEntitiesWithComponent("beam_weapons")[1]:getCallSign() -- returns the callsign of the first identified entity with beam weapons
    env.setGlobal("getEntitiesWithComponent", &luaQueryEntities);
    env.setGlobal("getLuaEntityFunctionTable", &luaGetEntityFunctionTable);
    env.setGlobal("startThread", &luaStartThread);
    env.setGlobal("yield", &luaYield);
    
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
    env.setGlobal("getSectorName", &luaGetSectorName);
    /// glm::vec2 sectorToXY(string sector_name)
    /// Returns the top-left ("northwest") x/y coordinates for the given sector mame.
    /// If the sector name is invalid, this returns coordinates 0, 0. This function also returns a third optional Boolean value that indicates whether the sector name was valid.
    /// Examples:
    /// x, y = sectorToXY("F5") -- x = 0, y = 0
    /// x, y = sectorToXY("A0") -- x = -100000, y = -100000
    /// x, y = sectorToXY("zz-23") -- x = -560000, y = -120000
    /// x, y, valid = sectorToXY("BA12") -- x = 140000, y = 940000, valid = true
    /// x, y, valid = sectorToXY("FOOBAR9000") -- x = 0, y = 0, valid = false
    env.setGlobal("sectorToXY", &luaSectorToXY);
    /// bool isInsideZone(x, y, zone_entity)
    /// Checks whether the given x/y coordinates are within the specified zone.
    /// Example:
    /// square_zone = Zone():setPoints(-2000, 2000, 2000, 2000, 2000, -2000, -2000, -2000) -- draw a 4U square zone around coordinates 0, 0
    /// local inside_zone = isInsideZone(1000, 1000, square_zone) -- true, because coordinates 1000, 1000 are inside of the zone
    /// local outside_zone = isInsideZone(10000, 10000, square_zone) -- false, because coordinates 10000, 10000 are outside of the zone
    env.setGlobal("isInsideZone", &luaIsInsideZone);
    /// void setBanner(string banner)
    /// Displays a scrolling banner containing the given text on the cinematic and top-down views.
    /// Example: setBanner("You will soon die!")
    env.setGlobal("setBanner", &luaSetBanner);
    /// void setDefaultSkybox(string skybox)
    /// Sets the default skybox image set to use in 3D viewports. Each image set is a directory in resources/skybox containing top.png, right.png, left.png, front.png, bottom.png, and back.png images. Defaults to "default".
    /// Example: setDefaultSkybox("simulation")
    env.setGlobal("setDefaultSkybox", &luaSetDefaultSkybox);
    /// float getScenarioTime()
    /// Returns the elapsed time of the scenario, in seconds.
    /// This timer stops when the game is paused.
    /// Example: getScenarioTime() -- after two minutes, returns 120.0
    env.setGlobal("getScenarioTime", &luaGetScenarioTime);

    /// std::vector<sp::ecs::Entity> getAllObjects()
    /// Returns a list of all objects that have a position in the world.
    /// This can return a very long list and could slow down the game if called every tick.
    /// Example: getAllObjects()
    env.setGlobal("getAllObjects", &luaGetAllObjects);
    /// PVector<SpaceObject> getObjectsInRadius(float x, float y, float radius)
    /// Returns a list of all SpaceObjects within the given radius of the given x/y coordinates.
    /// Example: getObjectsInRadius(0,0,5000) -- returns all objects within 5U of 0,0
    env.setGlobal("getObjectsInRadius", &luaGetObjectsInRadius);
    /// PVector<SpaceObject> getEnemiesInRadiusFor(sp::ecs::Entity entity, float radius)
    /// Returns a list of all entities within the given radius that are enemies of the given entity
    /// Example: getEnemiesInRadiusFor(obj, 5000) -- returns all enemies within 5U of 0,0
    env.setGlobal("getEnemiesInRadiusFor", &luaGetEnemiesInRadiusFor);
    /// P<PlayerSpaceship> getPlayerShip(int index)
    /// Returns the PlayerSpaceship with the given index.
    /// PlayerSpaceships are 1-indexed.
    /// A new ship is assigned the lowest available index, and a destroyed ship leaves its index vacant.
    /// Pass -1 to return the first active player ship.
    /// Pass -2 to return the current player ship.
    /// Example: getPlayerShip(2) -- returns the second-indexed ship, if it exists
    env.setGlobal("getPlayerShip", &luaGetPlayerShip);
    /// PVector<PlayerSpaceship> getActivePlayerShips()
    /// Returns a 1-indexed list of active PlayerSpaceships.
    /// Unlike getPlayerShip()'s index, destroyed ships don't leave gaps.
    /// Example: getActivePlayerShips()[2] -- returns the second-indexed active ship
    env.setGlobal("getActivePlayerShips", &luaGetActivePlayerShips);
    /// string getGameLanguage()
    /// Returns the language as the string value of the language key in game preferences.
    /// Example: getGameLanguage() -- returns "en" if the game language is set to English
    env.setGlobal("getGameLanguage", &luaGetGameLanguage);
    /// void setScenario(string script_name, std::optional<string> variation_name)
    /// Launches the given scenario, even if another scenario is running.
    /// Paths are relative to the scripts/ directory.
    /// Example: setScenario("scenario_03_waves.lua") -- launches the scenario at scripts/scenario_03_waves.lua
    env.setGlobal("setScenario", &luaSetScenario);
    /// void shutdownGame()
    /// Shuts down the server.
    /// Use to gracefully shut down a headless server.
    /// Example: shutdownGame()
    env.setGlobal("shutdownGame", &luaShutdownGame);
    /// void pauseGame()
    /// Pauses the game.
    /// Use to pause a headless server, which doesn't have access to the GM screen.
    /// Example: pauseGame()
    env.setGlobal("pauseGame", &luaPauseGame);
    /// void unpauseGame()
    /// Unpauses the game.
    /// Use to unpause a headless server, which doesn't have access to the GM screen.
    /// Example: unpauseGame()
    env.setGlobal("unpauseGame", &luaUnpauseGame);
    /// void playSoundFile(string filename)
    /// Plays the given audio file on the server.
    /// Paths are relative to the resources/ directory.
    /// Works with any file format supported by SDL, including .wav, .ogg, .flac.
    /// The sound is played only on the server, and not on any clients.
    /// Example: playSoundFile("sfx/laser.wav")
    env.setGlobal("playSoundFile", &luaPlaySoundFile);

    env.setGlobal("applyDamageToEntity", &luaApplyDamageToEntity);

    env.setGlobal("commandTargetRotation", &luaCommandTargetRotation);
    env.setGlobal("commandImpulse", &luaCommandImpulse);
    env.setGlobal("commandWarp", &luaCommandWarp);
    env.setGlobal("commandJump", &luaCommandJump);
    env.setGlobal("commandAbortJump", &luaCommandAbortJump);
    env.setGlobal("commandSetTarget", &luaCommandSetTarget);
    env.setGlobal("commandLoadTube", &luaCommandLoadTube);
    env.setGlobal("commandUnloadTube", &luaCommandUnloadTube);
    env.setGlobal("commandFireTube", &luaCommandFireTube);
    env.setGlobal("commandFireTubeAtTarget", &luaCommandFireTubeAtTarget);
    env.setGlobal("commandSetShields", &luaCommandSetShields);
    env.setGlobal("commandMainScreenSetting", &luaCommandMainScreenSetting);
    env.setGlobal("commandMainScreenOverlay", &luaCommandMainScreenOverlay);
    env.setGlobal("commandScan", &luaCommandScan);
    env.setGlobal("commandSetSystemPowerRequest", &luaCommandSetSystemPowerRequest);
    env.setGlobal("commandSetSystemCoolantRequest", &luaCommandSetSystemCoolantRequest);
    env.setGlobal("commandDock", &luaCommandDock);
    env.setGlobal("commandUndock", &luaCommandUndock);
    env.setGlobal("commandAbortDock", &luaCommandAbortDock);
    env.setGlobal("commandOpenTextComm", &luaCommandOpenTextComm);
    env.setGlobal("commandCloseTextComm", &luaCommandCloseTextComm);
    env.setGlobal("commandAnswerCommHail", &luaCommandAnswerCommHail);
    env.setGlobal("commandSendComm", &luaCommandSendComm);
    env.setGlobal("commandSendCommPlayer", &luaCommandSendCommPlayer);
    env.setGlobal("commandSetAutoRepair", &luaCommandSetAutoRepair);
    env.setGlobal("commandSetBeamFrequency", &luaCommandSetBeamFrequency);
    env.setGlobal("commandSetBeamSystemTarget", &luaCommandSetBeamSystemTarget);
    env.setGlobal("commandSetShieldFrequency", &luaCommandSetShieldFrequency);
    env.setGlobal("commandAddWaypoint", &luaCommandAddWaypoint);
    env.setGlobal("commandRemoveWaypoint", &luaCommandRemoveWaypoint);
    env.setGlobal("commandMoveWaypoint", &luaCommandMoveWaypoint);
    env.setGlobal("commandActivateSelfDestruct", &luaCommandActivateSelfDestruct);
    env.setGlobal("commandCancelSelfDestruct", &luaCommandCancelSelfDestruct);
    env.setGlobal("commandConfirmDestructCode", &luaCommandConfirmDestructCode);
    env.setGlobal("commandCombatManeuverBoost", &luaCommandCombatManeuverBoost);
    env.setGlobal("commandLaunchProbe", &luaCommandLaunchProbe);
    env.setGlobal("commandSetScienceLink", &luaCommandSetScienceLink);
    env.setGlobal("commandClearScienceLink", &luaCommandClearScienceLink);
    env.setGlobal("commandSetAlertLevel", &luaCommandSetAlertLevel);

    env.setGlobal("transferPlayersFromShipToShip", &luaTransferPlayers);
    env.setGlobal("hasPlayerCrewAtPosition", &luaHasPlayerAtPosition);
    env.setGlobal("getPlayersInfo", &luaGetPlayersInfo);
    env.setGlobal("setPlayerShipCustomFunction", &luaSetPlayerShipCustomFunction);
    env.setGlobal("removePlayerShipCustomFunction", &luaRemovePlayerShipCustomFunction);
    env.setGlobal("addEntryToShipsLog", &luaAddEntryToShipsLog);

    env.setGlobal("isRadarBlockedFrom", &RadarBlockSystem::isRadarBlockedFrom);
    env.setGlobal("beamVsShieldFrequencyDamageFactor", &frequencyVsFrequencyDamageFactor);

    /// EScanningComplexity getScanningComplexity()
    /// Returns the running scenario's scanning complexity setting.
    /// Example: getScanningComplexity() -- returns "normal" by default
    env.setGlobal("getScanningComplexity", &luaGetScanningComplexity);
    /// int getHackingDifficulty()
    /// Returns the running scenario's hacking difficulty setting.
    /// The returned value is an integer between 0 and 3:
    /// 0 = Simple
    /// 1 = Normal
    /// 2 = Difficult (default)
    /// 3 = Fiendish 
    /// Example: getHackingDifficulty() -- returns 2 by default
    env.setGlobal("getHackingDifficulty", &luaGetHackingDifficulty);
    /// EHackingGames getHackingGames()
    /// Returns the running scenario's hacking difficulty setting.
    /// Example: getHackingGames() -- returns "all" by default
    env.setGlobal("getHackingGames", &luaGetHackingGames);
    /// bool areBeamShieldFrequenciesUsed()
    /// Returns whether the "Beam/Shield Frequencies" setting is enabled in the running scenario.
    /// Example: areBeamShieldFrequenciesUsed() -- returns true by default
    env.setGlobal("areBeamShieldFrequenciesUsed", &luaAreBeamShieldFrequenciesUsed);
    /// bool isPerSystemDamageUsed()
    /// Returns whether the "Per-System Damage" setting is enabled in the running scenario.
    /// Example: isPerSystemDamageUsed() -- returns true by default
    env.setGlobal("isPerSystemDamageUsed", &luaIsPerSystemDamageUsed);
    /// bool isTacticalRadarAllowed()
    /// Returns whether the "Tactical Radar" setting for main screens is enabled in the running scenario.
    /// Example: isTacticalRadarAllowed() -- returns true by default
    env.setGlobal("isTacticalRadarAllowed", &luaIsTacticalRadarAllowed);
    /// bool isLongRangeRadarAllowed()
    /// Returns whether the "Long Range Radar" setting for main screens is enabled in the running scenario.
    /// Example: isLongRangeRadarAllowed() -- returns true by default
    env.setGlobal("isLongRangeRadarAllowed", &luaIsLongRangeRadarAllowed);


    env.setGlobal("addGMFunction", &luaAddGMFunction);
    env.setGlobal("clearGMFunctions", &luaClearGMFunctions);

    env.setGlobal("Script", &luaCreateAdditionalScript);

    /// void setCommsMessage(string message)
    /// Sets the content of an accepted hail, or in a comms reply.
    /// If no message is set, attempting to open comms results in "no reply", or a dialogue with the message "?" in a reply.
    /// Use this only in replies (addCommsReply()), comms scripts (SpaceObject:setCommsScript()), or comms functions (SpaceObject:setCommsFunction()).
    /// When used in the callback function of addCommsReply(), this clears all existing replies.
    /// Example:
    /// -- Send a greeting upon hail if the player is friendly with the comms target
    /// function friendlyComms()
    ///   if comms_source:isFriendly(comms_target) then
    ///     setCommsMessage("Hello, friend!")
    ///   else
    ///     setCommsMessage("Who are you?")
    ///   end
    /// end
    /// -- When some_ship is hailed, run friendlyComms() with some_ship as the comms_target and the player as the comms_source
    /// some_ship:setCommsFunction(friendlyComms)
    env.setGlobal("setCommsMessage", &CommsSystem::luaSetCommsMessage);
    /// void addCommsReply(string message, ScriptSimpleCallback callback)
    /// Adds a selectable reply option to a communications dialogue as a button with the given text.
    /// When clicked, the button calls the given function.
    /// Use this only after comms messages (setCommsMessage() in comms scripts (SpaceObject:setCommsScript()), or comms functions (SpaceObject:setCommsFunction()).
    /// Comms scripts pass global variables `comms_target` and `comms_source`. See SpaceObject:setCommsScript().
    /// Comms functions pass only `comms_source`. See SpaceObject:setCommsFunction().
    /// Instead of using these globals, the callback function can take two parameters.
    /// To present multiple options in one comms message, call addCommsReply() for each option.
    /// To create a dialogue tree, run setCommsMessage() inside the addCommsReply() callback, then add new comms replies.
    /// Example:
    /// if comms_source:isFriendly(comms_target) then
    ///   setCommsMessage("Hello, friend!")
    ///   addCommsReply("Can you send a supply drop?", function(comms_source, comms_target) ... end) -- runs the given function when selected
    ///   ...
    /// Deprecated: In a comms script, `player` can also be used for `comms_source`.
    env.setGlobal("addCommsReply", &CommsSystem::luaAddCommsReply);
    /// void commsSwitchToGM()
    /// Switches a PlayerSpaceship communications dialogue from a comms script/function to interactive chat with the GM.
    /// When triggered, this opens a comms chat window on both the player crew's screen and GM console.
    /// Use this in a communication callback function, such as addCommsReply() or SpaceObject:setCommsFunction().
    /// Example:
    /// if comms_source:isFriendly(comms_target) then
    ///   setCommsMessage("Hello, friend!")
    ///   addCommsReply("I want to speak to your manager!", function() commsSwitchToGM() end) -- launches a GM chat when selected
    ///   ...
    env.setGlobal("commsSwitchToGM", &CommsSystem::luaCommsSwitchToGM);

    /// string toJSON(data)
    /// Returns a json string with the input data converted to json.
    env.setGlobal("toJSON", &luaToJSON);
    /// table/value fromJSON(data)
    /// Returns a table/value converted from a json string
    env.setGlobal("fromJSON", &luaFromJSON);

    env.setGlobal("getEEVersion", &luaGetEEVersion);
    registerScriptDataStorageFunctions(env);
    registerScriptGMFunctions(env);
    registerScriptRandomFunctions(env);

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

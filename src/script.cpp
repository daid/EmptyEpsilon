#include <i18n.h>
#include "gameGlobalInfo.h"
#include "preferenceManager.h"
#include "script.h"
#include "resources.h"
#include "random.h"
#include "menus/luaConsole.h"


/// void require(string filename)
/// Runs the Lua script with the given filename in the same context as the running Script.
/// Loads the localized file if it exists at locale/<FILENAME>.<LANGUAGE>.po.
static int luaRequire(lua_State* L)
{
    int old_top = lua_gettop(L);
    string filename = luaL_checkstring(L, 1);

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream)
    {
        lua_pushstring(L, ("Require: Script not found: " + filename).c_str());
        return lua_error(L);
    }

    // Load the locale file for this script.
    i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

    string filecontents = stream->readAll();
    stream->destroy();
    stream = nullptr;

    if (luaL_loadbuffer(L, filecontents.c_str(), filecontents.length(), ("@" + filename).c_str()))
    {
        string error_string = luaL_checkstring(L, -1);
        lua_pushstring(L, ("require:" + error_string).c_str());
        return lua_error(L);
    }
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setupvalue(L, -2, 1);

    //Call the actual code.
    if (lua_pcall(L, 0, LUA_MULTRET, 0))
    {
        string error_string = luaL_checkstring(L, -1);
        lua_pushstring(L, ("require:" + error_string).c_str());
        return lua_error(L);
    }

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

static int luaPrint(lua_State* L)
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
    LuaConsole::addLog(message);
    return 0;
}

static int luaGetEntityFunctionTable(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "EFT");
    return 1;
}

void setupScriptEnvironment(sp::script::Environment& env)
{
    // Load core global functions
    env.setGlobal("random", &random);
    env.setGlobal("irandom", &irandom);
    env.setGlobal("print", &luaPrint);
    env.setGlobalFuncWithEnvUpvalue("require", &luaRequire);
    env.setGlobal("_", &luaTranslate);
    env.setGlobal("createEntity", &luaCreateEntity);
    env.setGlobal("getLuaEntityFunctionTable", &luaGetEntityFunctionTable);
    env.setGlobal("createClass", &luaCreateClass);

    LuaConsole::checkResult(env.runFile<void>("luax.lua"));
    LuaConsole::checkResult(env.runFile<void>("api/all.lua"));

    LuaConsole::checkResult(env.runFile<void>("model_data.lua"));
    LuaConsole::checkResult(env.runFile<void>("factionInfo.lua"));
    LuaConsole::checkResult(env.runFile<void>("shipTemplates.lua"));
    //TODO: Load science database
}

/// A Script object can create and run another Lua script.
/// Other Scripts have their own lifetime, update, and init functions.
/// Scripts can destroy themselves (destroyScript()) or be destroyed by the main script.
/// Example: local script = Script():run("script.lua"); script:destroy();
REGISTER_SCRIPT_CLASS(Script)
{
    /// Runs a script with the given filename.
    /// Loads the localized file if it exists at locale/<FILENAME>.<LANGUAGE>.po.
    /// Returns true if the resulting SeriousProton ScriptObject was successfully run.
    /// Example: script = Script():run("script.lua")
    REGISTER_SCRIPT_CLASS_FUNCTION(Script, run);
    /// Sets a global variable in this Script instance that is accessible from the main Script.
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptObjectLegacy, setVariable<string>);
}

Script::Script()
{
    if (!gameGlobalInfo)
    {
        destroy();
        return;
    }

    gameGlobalInfo->addScript(this);
}

bool Script::run(string filename)
{
    // Load the locale file for this script.
    i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

    return ScriptObjectLegacy::run(filename);
}

static int require(lua_State* L)
{
    int old_top = lua_gettop(L);
    string filename = luaL_checkstring(L, 1);

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream)
    {
        LOG(ERROR) << "Require: Script not found: " << filename;
        lua_pushstring(L, ("Require: Script not found: " + filename).c_str());
        return lua_error(L);
    }

    // Load the locale file for this script.
    i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

    string filecontents = stream->readAll();
    stream->destroy();
    stream = nullptr;

    if (luaL_loadbuffer(L, filecontents.c_str(), filecontents.length(), filename.c_str()))
    {
        string error_string = luaL_checkstring(L, -1);
        LOG(ERROR) << "LUA: require: " << error_string;
        lua_pushstring(L, ("require:" + error_string).c_str());
        return lua_error(L);
    }
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setupvalue(L, -2, 1);

    //Call the actual code.
    if (lua_pcall(L, 0, LUA_MULTRET, 0))
    {
        string error_string = luaL_checkstring(L, -1);
        LOG(ERROR) << "LUA: require: " << error_string;
        lua_pushstring(L, ("require:" + error_string).c_str());
        return lua_error(L);
    }

    return lua_gettop(L) - old_top;
}
/// void require(string filename)
/// Runs the Lua script with the given filename in the same context as the running Script.
/// Loads the localized file if it exists at locale/<FILENAME>.<LANGUAGE>.po.
REGISTER_SCRIPT_FUNCTION(require);

static int _(lua_State* L)
{
    auto str_1 = luaL_checkstring(L, 1);
    auto str_2 = luaL_optstring(L, 2, nullptr);
    if (str_2)
        lua_pushstring(L, tr(str_1, str_2).c_str());
    else
        lua_pushstring(L, tr(str_1).c_str());
    return 1;
}
/// string _(string text, std::optional<string> default)
/// Adds a translation context to the given string.
/// Accepts either one or two values.
/// If passed one value, this function makes the string available for translation without a category.
/// If passed two values, the first value is the category, and the second is the string to translate.
/// Categorizing strings allows for organization, and for the content to be translated differently in multiple contexts if necessary.
/// Examples:
///   message1 = _("We will destroy you!") -- tags the string for translation
///   message2 = _("taunt", "We will destroy you!") -- categorizes the same string as a "taunt" for translation
///   message3 = _("promise", "We will destroy you!") -- categorizes the same string as a "promise" for translation
REGISTER_SCRIPT_FUNCTION(_);

#include <i18n.h>
#include "gameGlobalInfo.h"
#include "script.h"

/// Object which can be used to create and run another script.
/// Other scripts have their own lifetime, update and init functions.
/// Scripts can destroy themselves (destroyScript()), or be destroyed by the main script.
/// Example: local script = Script():run("script.lua"); script:destroy();
REGISTER_SCRIPT_CLASS(Script)
{
    /// Run a script with a certain filename
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptObject, run);
    /// Set a global variable in this script instance, this variable can be accessed in the main script.
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptObject, setVariable);
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

static int require(lua_State* L)
{
    string filename = luaL_checkstring(L, 1);

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream)
    {
        LOG(ERROR) << "Require: Script not found: " << filename;
        lua_pushstring(L, ("Require: Script not found: " + filename).c_str());
        return lua_error(L);
    }

    string filecontents;
    do
    {
        string line = stream->readLine();
        filecontents += line + "\n";
    }while(stream->tell() < stream->getSize());

    if (luaL_loadbuffer(L, filecontents.c_str(), filecontents.length(), filename.c_str()))
    {
        string error_string = luaL_checkstring(L, -1);
        LOG(ERROR) << "LUA: require: " << error_string;
        lua_pushstring(L, ("require:" + error_string).c_str());
        return lua_error(L);
    }

    //Call the actual code.
    if (lua_pcall(L, 0, 0, 0))
    {
        string error_string = luaL_checkstring(L, -1);
        LOG(ERROR) << "LUA: require: " << error_string;
        lua_pushstring(L, ("require:" + error_string).c_str());
        return lua_error(L);
    }

    return 0;
}
/// require(filename)
/// Run the script with the given filename in the same context as the current running script.
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
/// _(string)
/// Translate the given string with the user configured language.
REGISTER_SCRIPT_FUNCTION(_);

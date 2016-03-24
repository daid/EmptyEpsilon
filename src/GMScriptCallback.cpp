#include "GMScriptCallback.h"
#include "gameGlobalInfo.h"

GMScriptCallback::GMScriptCallback(string name)
: name(name)
{
}

static int addGMFunction(lua_State* L)
{
    const char* name = luaL_checkstring(L, 1);

    ScriptSimpleCallback callback;
    
    int idx = 2;
    convert<ScriptSimpleCallback>::param(L, idx, callback);

    gameGlobalInfo->gm_callback_functions.emplace_back(name);
    GMScriptCallback* callback_object = &gameGlobalInfo->gm_callback_functions.back();
    callback_object->callback = callback;

    return 0;
}
REGISTER_SCRIPT_FUNCTION(addGMFunction);

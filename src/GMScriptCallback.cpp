#include "GMScriptCallback.h"
#include "screens/gm/gameMasterScreen.h"
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
/// addGMFunction(name, function)
/// Add a function that can be called from the GM console. This can be used to create helper scripts for the GM.
/// Or to give the GM console certain control over the scenario.
REGISTER_SCRIPT_FUNCTION(addGMFunction);

static int getGMSelection(lua_State* L)
{
    PVector<SpaceObject> objects;
    foreach(Updatable, u, updatableList)
    {
        P<GameMasterScreen> game_master_screen = u;
        if (game_master_screen)
        {
            objects = game_master_screen->getSelection();
        }
    }
    return convert<PVector<SpaceObject> >::returnType(L, objects);
}
/// getGMSelection()
/// Returns an list of objects that the GM currently has selected.
REGISTER_SCRIPT_FUNCTION(getGMSelection);

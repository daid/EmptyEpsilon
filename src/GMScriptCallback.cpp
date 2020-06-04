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

static int removeGMFunction(lua_State* L)
{
    string name = luaL_checkstring(L, 1);

    gameGlobalInfo->gm_callback_functions.erase(std::remove_if(gameGlobalInfo->gm_callback_functions.begin(), gameGlobalInfo->gm_callback_functions.end(), [name](const GMScriptCallback& f) { return f.name == name; }), gameGlobalInfo->gm_callback_functions.end());

    return 0;
}
/// removeGMFunction(name)
/// Remove a function from the GM console
REGISTER_SCRIPT_FUNCTION(removeGMFunction);

static int clearGMFunctions(lua_State* L)
{
    gameGlobalInfo->gm_callback_functions.clear();
    return 0;
}
/// clearGMFunctions()
/// Remove all the GM functions from the GM console.
REGISTER_SCRIPT_FUNCTION(clearGMFunctions);

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

static int onGMClick(lua_State* L)
{
    ScriptSimpleCallback callback;

    int idx = 1;
    convert<ScriptSimpleCallback>::param(L,idx,callback);

    if (callback.isSet())
    {
        gameGlobalInfo->on_gm_click=[callback](sf::Vector2f position) mutable
        {
            callback.call(position.x,position.y);
        };
    }
    else
    {
        gameGlobalInfo->on_gm_click = nullptr;
    }

    return 0;
}
/// onGMClick(function)
/// Register a callback function that is called when the gm clicks on the background of their screen.
/// Example 1: onGMClick(function(x,y) print(x,y) end) -- print the x and y when clicked.
/// Example 2: onGMClick(nil) -- resets to no function being called on clicks
REGISTER_SCRIPT_FUNCTION(onGMClick);

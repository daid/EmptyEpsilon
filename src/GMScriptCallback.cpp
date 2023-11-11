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
/// void addGMFunction(string name, ScriptSimpleCallback callback)
/// Defines a function to call from a button on the GM console.
/// The name is also used as the button text.
/// Use this to create helper scripts for the GM or give the GM console certain controls over the scenario.
/// These work only when added via scenario script, but not via the HTTP API. (#1807)
/// Example: addGMFunction("Humans Win", function() victory("Human Navy") end)
REGISTER_SCRIPT_FUNCTION(addGMFunction);

static int removeGMFunction(lua_State* L)
{
    string name = luaL_checkstring(L, 1);

    gameGlobalInfo->gm_callback_functions.erase(std::remove_if(gameGlobalInfo->gm_callback_functions.begin(), gameGlobalInfo->gm_callback_functions.end(), [name](const GMScriptCallback& f) { return f.name == name; }), gameGlobalInfo->gm_callback_functions.end());

    return 0;
}
/// void removeGMFunction(string name)
/// Removes a function from the GM console.
/// Example: removeGMFunction("Humans Win")
REGISTER_SCRIPT_FUNCTION(removeGMFunction);

static int clearGMFunctions(lua_State* L)
{
    gameGlobalInfo->gm_callback_functions.clear();
    return 0;
}
/// void clearGMFunctions()
/// Removes all functions from the GM console.
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
/// PVector<SpaceObject> getGMSelection()
/// Returns a list of SpaceObjects selected on the GM console.
/// Use in GM functions to apply them to specific objects.
/// Example: addGMFunction("Destroy selected", function() for _, obj in ipairs(getGMSelection()) do obj:destroy() end end)
REGISTER_SCRIPT_FUNCTION(getGMSelection);

static int onGMClick(lua_State* L)
{
    ScriptSimpleCallback callback;

    int idx = 1;
    convert<ScriptSimpleCallback>::param(L,idx,callback);

    if (callback.isSet())
    {
        gameGlobalInfo->on_gm_click=[callback](glm::vec2 position) mutable
        {
            callback.call<void>(position.x, position.y);
        };
    }
    else
    {
        gameGlobalInfo->on_gm_click = nullptr;
    }

    return 0;
}
/// void onGMClick(ScriptSimpleCallback callback)
/// Defines a function to call when the GM clicks on the background of their console.
/// Passes the x and y game-space coordinates of the click location.
/// These work only when added via scenario script, but not via the HTTP API. (#1807)
/// Examples:
///   onGMClick(function(x,y) print(x,y) end) -- print the clicked position's coordinates
///   onGMClick(nil) -- reset the callback
REGISTER_SCRIPT_FUNCTION(onGMClick);

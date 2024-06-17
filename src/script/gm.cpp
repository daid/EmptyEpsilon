#include "gameGlobalInfo.h"
#include "screens/gm/gameMasterScreen.h"


static void lua_addGMMessage(string message)
{
    gameGlobalInfo->gm_messages.emplace_back(message);
}

static void lua_addGMFunction(string name, sp::script::Callback callback)
{
    gameGlobalInfo->gm_callback_functions.emplace_back(name);
    auto& callback_object = gameGlobalInfo->gm_callback_functions.back();
    callback_object.callback = callback;
}

static void lua_removeGMFunction(string name)
{
    gameGlobalInfo->gm_callback_functions.erase(std::remove_if(gameGlobalInfo->gm_callback_functions.begin(), gameGlobalInfo->gm_callback_functions.end(), [name](const GMScriptCallback& f) {
        return f.name == name;
    }), gameGlobalInfo->gm_callback_functions.end());
}

static void lua_clearGMFunctions()
{
    gameGlobalInfo->gm_callback_functions.clear();
}

static int lua_getGMSelection(lua_State* L)
{
    lua_newtable(L);
    for(auto u : updatableList)
    {
        P<GameMasterScreen> game_master_screen = u;
        if (game_master_screen) {
            int idx = 1;
            for(auto e : game_master_screen->getSelection()) {
                sp::script::Convert<sp::ecs::Entity>::toLua(L, e);
                lua_rawseti(L, -2, idx++);
            }
        }
    }
    return 1;
}

static void lua_onGMClick(sp::script::Callback callback)
{
    if (callback) {
        gameGlobalInfo->on_gm_click=[callback](glm::vec2 position) mutable {
            callback.call<void>(position.x, position.y);
        };
    } else {
        gameGlobalInfo->on_gm_click = nullptr;
    }
}

void registerScriptGMFunctions(sp::script::Environment& env)
{
    /// void addGMMessage(string message)
    /// Displays a dismissable message on the GM console.
    /// Example: addGMMessage("Five minutes remaining!")
    env.setGlobal("addGMMessage", &lua_addGMMessage);

    /// void addGMFunction(string name, ScriptSimpleCallback callback)
    /// Defines a function to call from a button on the GM console.
    /// The name is also used as the button text.
    /// Use this to create helper scripts for the GM or give the GM console certain controls over the scenario.
    /// These work only when added via scenario script, but not via the HTTP API. (#1807)
    /// Example: addGMFunction("Humans Win", function() victory("Human Navy") end)
    env.setGlobal("addGMFunction", &lua_addGMFunction);
    /// void removeGMFunction(string name)
    /// Removes a function from the GM console.
    /// Example: removeGMFunction("Humans Win")
    env.setGlobal("removeGMFunction", &lua_removeGMFunction);
    /// void clearGMFunctions()
    /// Removes all functions from the GM console.
    env.setGlobal("clearGMFunctions", &lua_clearGMFunctions);

    /// PVector<SpaceObject> getGMSelection()
    /// Returns a list of SpaceObjects selected on the GM console.
    /// Use in GM functions to apply them to specific objects.
    /// Example: addGMFunction("Destroy selected", function() for _, obj in ipairs(getGMSelection()) do obj:destroy() end end)
    env.setGlobal("getGMSelection", &lua_getGMSelection);
    /// void onGMClick(ScriptSimpleCallback callback)
    /// Defines a function to call when the GM clicks on the background of their console.
    /// Passes the x and y game-space coordinates of the click location.
    /// These work only when added via scenario script, but not via the HTTP API. (#1807)
    /// Examples:
    ///   onGMClick(function(x,y) print(x,y) end) -- print the clicked position's coordinates
    ///   onGMClick(nil) -- reset the callback
    env.setGlobal("onGMClick", &lua_onGMClick);
}
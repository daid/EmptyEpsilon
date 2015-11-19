#include "GMScriptCallback.h"
#include "gameGlobalInfo.h"

GMScriptCallback::GMScriptCallback(string name)
: name(name)
{
}

static int addGMFunction(lua_State* L)
{
    const char* name = luaL_checkstring(L, 1);

    //Check if the parameter is a function.
    luaL_checktype(L, 2, LUA_TFUNCTION);
    //Check if this function is a lua function, with an reference to the environment.
    //  (We need the environment reference to see if the script to which the function belongs is destroyed when calling the callback)
    if (lua_iscfunction(L, 2))
        luaL_error(L, "Cannot set a C binding as callback function.");
    lua_getupvalue(L, 2, 1);
    if (!lua_istable(L, -1))
        luaL_error(L, "??? Upvalue 1 of function is not a table...");
    lua_pushstring(L, "__script_pointer");
    lua_gettable(L, -2);
    if (!lua_islightuserdata(L, -1))
        luaL_error(L, "??? Cannot find reference back to script...");
    //Stack is now: [function_environment] [pointer]
    
    gameGlobalInfo->gm_callback_functions.emplace_back(name);
    ScriptCallback* callback_object = &gameGlobalInfo->gm_callback_functions.back();

    ///Code down here is a copy from scriptInterfaceMagic::template<class T> struct call<T, ScriptCallback T::* >::setcallbackFunction
    /// TODO: Clean up, as duplicate code is bad. (could be moved into the ScriptCallback class?)
    lua_pushlightuserdata(L, callback_object);
    lua_gettable(L, LUA_REGISTRYINDEX);
    //Get the table which matches this callback object. If there is no table, create it.
    if (lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_pushlightuserdata(L, callback_object);
        lua_pushvalue(L, -2);
        lua_settable(L, LUA_REGISTRYINDEX);
    }
    //The table at [-1] contains a list of callbacks.
    //Stack is now [function_environment] [pointer] [callback_table]
    
    int callback_count = luaL_len(L, -1);
    lua_pushnumber(L, callback_count + 1);
    //Push a new table on the stack, store the pointer to the script object and the function in there.
    lua_newtable(L);
    lua_pushstring(L, "script_pointer");
    lua_pushvalue(L, -5);
    lua_settable(L, -3);
    lua_pushstring(L, "function");
    lua_pushvalue(L, 2);
    lua_settable(L, -3);
    
    //Stack is now [function_environment] [pointer] [callback_table] [callback_index] [this_callback_table]
    //Push the new callback table in the list of callbacks.
    lua_settable(L, -3);
    
    lua_pop(L, 3);
    
    return 0;
}
REGISTER_SCRIPT_FUNCTION(addGMFunction);

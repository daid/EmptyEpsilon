#include "commsScriptInterface.h"

static CommsScriptInterface* comms_script_interface;

static int lua_isEnemy(lua_State* L)
{
    lua_pushboolean(L, comms_script_interface->ship->isEnemy(comms_script_interface->target));
    return 1;
}

static int lua_isFriendly(lua_State* L)
{
    lua_pushboolean(L, comms_script_interface->ship->isFriendly(comms_script_interface->target));
    return 1;
}

static int lua_getWeaponStorage(lua_State* L)
{
    int param = 1;
    EMissileWeapons weapon;
    convert<EMissileWeapons>::param(L, param, weapon);
    lua_pushinteger(L, comms_script_interface->ship->weapon_storage[weapon]);
    return 1;
}

static int lua_getWeaponStorageMax(lua_State* L)
{
    int param = 1;
    EMissileWeapons weapon;
    convert<EMissileWeapons>::param(L, param, weapon);
    lua_pushinteger(L, comms_script_interface->ship->weapon_storage_max[weapon]);
    return 1;
}

static int lua_setWeaponStorage(lua_State* L)
{
    int param = 1;
    EMissileWeapons weapon;
    int count;
    convert<EMissileWeapons>::param(L, param, weapon);
    convert<int>::param(L, param, count);
    comms_script_interface->ship->weapon_storage[weapon] = count;
    return 0;
}

static int lua_isDocked(lua_State* L)
{
    lua_pushboolean(L, comms_script_interface->ship->docking_state == DS_Docked && comms_script_interface->ship->docking_target == comms_script_interface->target);
    return 1;
}

static int lua_setCommsMessage(lua_State* L)
{
    comms_script_interface->has_message = true;
    comms_script_interface->ship->setCommsMessage(luaL_checkstring(L, 1));
    return 0;
}

static int lua_addCommsReply(lua_State* L)
{
    comms_script_interface->ship->addCommsReply(comms_script_interface->reply_id, luaL_checkstring(L, 1));
    if (!lua_isfunction(L, 2)) return luaL_argerror(L, 2, "2nd argument to addCommsReply should be a function");
    
    lua_setglobal(L, ("__commsReply" + string(comms_script_interface->reply_id)).c_str());
    comms_script_interface->reply_id++;
    return 0;
}

bool CommsScriptInterface::openCommChannel(P<PlayerSpaceship> ship, P<SpaceObject> target, string script_name)
{
    comms_script_interface = this;
    reply_id = 0;
    this->ship = ship;
    this->target = target;
    
    if (scriptObject)
        scriptObject->destroy();
    scriptObject = new ScriptObject();
    scriptObject->registerFunction("isEnemy", lua_isEnemy);
    scriptObject->registerFunction("isFriendly", lua_isFriendly);
    scriptObject->registerFunction("isDocked", lua_isDocked);
    scriptObject->registerFunction("setCommsMessage", lua_setCommsMessage);
    scriptObject->registerFunction("addCommsReply", lua_addCommsReply);
    scriptObject->registerFunction("getWeaponStorage", lua_getWeaponStorage);
    scriptObject->registerFunction("getWeaponStorageMax", lua_getWeaponStorageMax);
    scriptObject->registerFunction("setWeaponStorage", lua_setWeaponStorage);
    has_message = false;
    scriptObject->run(script_name);
    comms_script_interface = NULL;
    reply_id = 0;
    return has_message;
}

void CommsScriptInterface::commChannelMessage(int32_t message_id)
{
    comms_script_interface = this;
    scriptObject->callFunction("__commsReply" + string(message_id));
    comms_script_interface = NULL;
    reply_id = 0;
}

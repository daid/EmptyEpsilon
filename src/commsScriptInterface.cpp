#include "commsScriptInterface.h"
#include "cpuShip.h"

static CommsScriptInterface* comms_script_interface;

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
    scriptObject->registerObject(ship, "PlayerSpaceship", "player");
    if (P<CpuShip>(target))
        scriptObject->registerObject(target, "CpuShip", "comms_target");
    else
        scriptObject->registerObject(target, "SpaceObject", "comms_target");
    scriptObject->registerFunction("setCommsMessage", lua_setCommsMessage);
    scriptObject->registerFunction("addCommsReply", lua_addCommsReply);
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

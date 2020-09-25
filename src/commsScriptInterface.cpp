#include "commsScriptInterface.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/playerSpaceship.h"
static CommsScriptInterface* comms_script_interface = NULL;

static int setCommsMessage(lua_State* L)
{
    if (!comms_script_interface)
        return 0;
    comms_script_interface->setCommsMessage(luaL_checkstring(L, 1));
    return 0;
}

static int addCommsReply(lua_State* L)
{
    if (!comms_script_interface)
        return 0;

    ScriptSimpleCallback callback;
    int idx = 2;
    convert<ScriptSimpleCallback>::param(L, idx, callback);
    comms_script_interface->addCommsReply(luaL_checkstring(L, 1), callback);
    return 0;
}

static int commsSwitchToGM(lua_State* L)
{
    if (!comms_script_interface)
        return 0;

    comms_script_interface->switchToGM();
    return 0;
}

/// setCommsMessage(message)
/// Sets the message/reply shown to the comms officer.
REGISTER_SCRIPT_FUNCTION(setCommsMessage);
/// addCommsReply(message, function)
/// Add an reply option for communications.
REGISTER_SCRIPT_FUNCTION(addCommsReply);
/// Use this function from a communication callback function to switch the current
/// communication from scripted to a GM based chat.
REGISTER_SCRIPT_FUNCTION(commsSwitchToGM);

bool CommsScriptInterface::openCommChannel(P<PlayerSpaceship> ship, P<SpaceObject> target)
{
    string script_name = target->comms_script_name;
    comms_script_interface = this;

    reply_callbacks.clear();

    this->ship = ship;
    this->target = target;

    if (scriptObject)
        scriptObject->destroy();
    scriptObject = nullptr;
    has_message = false;

    if (script_name != "")
    {
        scriptObject = new ScriptObject();
        scriptObject->registerObject(ship, "player");
        scriptObject->registerObject(target, "comms_target");
        scriptObject->run(script_name);
    }else if (target->comms_script_callback.isSet())
    {
        target->comms_script_callback.getScriptObject()->registerObject(ship, "comms_source");
        target->comms_script_callback.getScriptObject()->registerObject(target, "comms_target");
        target->comms_script_callback.call();
    }
    comms_script_interface = nullptr;
    return has_message;
}

void CommsScriptInterface::commChannelMessage(int32_t message_id)
{
    comms_script_interface = this;

    if (message_id >= 0 && message_id < int(reply_callbacks.size()) && ship && target)
    {
        ScriptSimpleCallback callback = reply_callbacks[message_id];
        if (!scriptObject)
        {
            target->comms_script_callback.getScriptObject()->registerObject(ship, "comms_source");
            target->comms_script_callback.getScriptObject()->registerObject(target, "comms_target");
        }
        reply_callbacks.clear();
        callback.call();
    }

    comms_script_interface = nullptr;
}

void CommsScriptInterface::setCommsMessage(string message)
{
    has_message = true;
    ship->setCommsMessage(message);
}

void CommsScriptInterface::addCommsReply(string message, ScriptSimpleCallback callback)
{
    comms_script_interface->ship->addCommsReply(reply_callbacks.size(), message);
    reply_callbacks.push_back(callback);
}

void CommsScriptInterface::switchToGM()
{
    ship->switchCommsToGM();
}

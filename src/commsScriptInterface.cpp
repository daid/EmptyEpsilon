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

/// void setCommsMessage(string message)
/// Sets the content of an accepted hail, or in a comms reply.
/// If no message is set, attempting to open comms results in "no reply", or a dialogue with the message "?" in a reply.
/// Use this only in replies (addCommsReply()), comms scripts (SpaceObject:setCommsScript()), or comms functions (SpaceObject:setCommsFunction()).
/// When used in the callback function of addCommsReply(), this clears all existing replies.
/// Example:
/// -- Send a greeting upon hail if the player is friendly with the comms target
/// function friendlyComms()
///   if comms_source:isFriendly(comms_target) then
///     setCommsMessage("Hello, friend!")
///   else
///     setCommsMessage("Who are you?")
///   end
/// end
/// -- When some_ship is hailed, run friendlyComms() with some_ship as the comms_target and the player as the comms_source
/// some_ship:setCommsFunction(friendlyComms)
REGISTER_SCRIPT_FUNCTION(setCommsMessage);
/// void addCommsReply(string message, ScriptSimpleCallback callback)
/// Adds a selectable reply option to a communications dialogue as a button with the given text.
/// When clicked, the button calls the given function.
/// Use this only after comms messages (setCommsMessage() in comms scripts (SpaceObject:setCommsScript()), or comms functions (SpaceObject:setCommsFunction()).
/// Comms scripts pass global variables `comms_target` and `comms_source`. See SpaceObject:setCommsScript().
/// Comms functions pass only `comms_source`. See SpaceObject:setCommsFunction().
/// Instead of using these globals, the callback function can take two parameters.
/// To present multiple options in one comms message, call addCommsReply() for each option.
/// To create a dialogue tree, run setCommsMessage() inside the addCommsReply() callback, then add new comms replies.
/// Example:
/// if comms_source:isFriendly(comms_target) then
///   setCommsMessage("Hello, friend!")
///   addCommsReply("Can you send a supply drop?", function(comms_source, comms_target) ... end) -- runs the given function when selected
///   ...
/// Deprecated: In a comms script, `player` can also be used for `comms_source`.
REGISTER_SCRIPT_FUNCTION(addCommsReply);
/// void commsSwitchToGM()
/// Switches a PlayerSpaceship communications dialogue from a comms script/function to interactive chat with the GM.
/// When triggered, this opens a comms chat window on both the player crew's screen and GM console.
/// Use this in a communication callback function, such as addCommsReply() or SpaceObject:setCommsFunction().
/// Example:
/// if comms_source:isFriendly(comms_target) then
///   setCommsMessage("Hello, friend!")
///   addCommsReply("I want to speak to your manager!", function() commsSwitchToGM() end) -- launches a GM chat when selected
///   ...
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
        // consider "player" deprecated, but keep it for a long time
        scriptObject->registerObject(ship, "player");
        scriptObject->registerObject(ship, "comms_source");
        scriptObject->registerObject(target, "comms_target");
        scriptObject->run(script_name);
    }else if (target->comms_script_callback.isSet())
    {
        target->comms_script_callback.getScriptObject()->registerObject(ship, "comms_source");
        target->comms_script_callback.getScriptObject()->registerObject(target, "comms_target");
        target->comms_script_callback.call<void>(ship, target);
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
        callback.call<void>(ship, target);
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

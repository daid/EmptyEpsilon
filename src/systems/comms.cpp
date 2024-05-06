#include "systems/comms.h"
#include "components/comms.h"
#include "components/shiplog.h"
#include "components/name.h"
#include "i18n.h"
#include "multiplayer_server.h"
#include "gameGlobalInfo.h"
#include "ecs/query.h"
#include "gui/colorConfig.h"
#include "menus/luaConsole.h"


static sp::ecs::Entity script_active_entity;


void CommsSystem::update(float delta)
{
    for(auto [entity, comms] : sp::ecs::Query<CommsTransmitter>()) {
        if (comms.open_delay > 0.0f)
            comms.open_delay -= delta;
        if (game_server) {
            if (comms.state == CommsTransmitter::State::OpeningChannel && comms.open_delay <= 0.0f) {
                if (!comms.target) {
                    comms.state = CommsTransmitter::State::ChannelBroken;
                }else{
                    comms.script_replies.clear();
                    comms.script_replies_dirty = true;
                    if (auto other_transmitter = comms.target.getComponent<CommsTransmitter>())
                    {
                        comms.open_delay = channel_open_time;

                        if (other_transmitter->state == CommsTransmitter::State::Inactive || other_transmitter->state == CommsTransmitter::State::ChannelFailed || other_transmitter->state == CommsTransmitter::State::ChannelBroken || other_transmitter->state == CommsTransmitter::State::ChannelClosed)
                        {
                            other_transmitter->state = CommsTransmitter::State::BeingHailed;
                            other_transmitter->target = entity;
                            if (auto callsign = entity.getComponent<CallSign>())
                                other_transmitter->target_name = callsign->callsign;
                            else
                                other_transmitter->target_name = "?";
                        }
                    }else if (gameGlobalInfo->intercept_all_comms_to_gm) {
                        comms.state = CommsTransmitter::State::ChannelOpenGM;
                    }else if (openChannel(entity, comms.target)) {
                        comms.state = CommsTransmitter::State::ChannelOpen;
                    } else {
                        comms.state = CommsTransmitter::State::ChannelFailed;
                    }
                }
            }
            if (comms.state == CommsTransmitter::State::ChannelOpen || comms.state == CommsTransmitter::State::ChannelOpenPlayer)
            {
                if (!comms.target)
                    comms.state = CommsTransmitter::State::ChannelBroken;
            }
        }
    }
}

void CommsSystem::openTo(sp::ecs::Entity player, sp::ecs::Entity target)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    if (transmitter->state == CommsTransmitter::State::Inactive || transmitter->state == CommsTransmitter::State::BeingHailed || transmitter->state == CommsTransmitter::State::BeingHailedByGM || transmitter->state == CommsTransmitter::State::ChannelClosed) {
        if (target.hasComponent<CommsReceiver>() || target.hasComponent<CommsTransmitter>()) {
            transmitter->state = CommsTransmitter::State::OpeningChannel;
            transmitter->open_delay = channel_open_time;
            if (auto cs = target.getComponent<CallSign>())
                transmitter->target_name = cs->callsign;
            else
                transmitter->target_name = "?";
            transmitter->incomming_message = tr("chatdialog", "Opened comms with {name}").format({{"name", transmitter->target_name}});
            transmitter->target = target;
            if (auto log = player.getComponent<ShipLog>())
                log->add(tr("shiplog", "Hailing: {name}").format({{"name", transmitter->target_name}}), colorConfig.log_generic);
        } else {
            transmitter->state = CommsTransmitter::State::Inactive;
        }
    }
}

void CommsSystem::answer(sp::ecs::Entity player, bool allow)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    if (transmitter->state == CommsTransmitter::State::BeingHailed)
    {
        auto other = transmitter->target.getComponent<CommsTransmitter>();
        if (other)
        {
            if (allow)
            {
                transmitter->state = CommsTransmitter::State::ChannelOpenPlayer;
                other->state = CommsTransmitter::State::ChannelOpenPlayer;

                transmitter->incomming_message = tr("chatdialog", "Opened comms to {callsign}").format({{"callsign", transmitter->target_name}});
                other->incomming_message = tr("chatdialog", "Opened comms to {callsign}").format({{"callsign", other->target_name}});
                if (auto log = player.getComponent<ShipLog>())
                    log->add(tr("shiplog", "Opened communication channel to {callsign}").format({{"callsign", transmitter->target_name}}), colorConfig.log_generic);
                if (auto log = transmitter->target.getComponent<ShipLog>())
                    log->add(tr("shiplog", "Opened communication channel to {callsign}").format({{"callsign", other->target_name}}), colorConfig.log_generic);
            }else{
                if (auto log = player.getComponent<ShipLog>())
                    log->add(tr("shiplog", "Refused communications from {callsign}").format({{"callsign", transmitter->target_name}}), colorConfig.log_generic);
                if (auto log = transmitter->target.getComponent<ShipLog>())
                    log->add(tr("shiplog", "Refused communications to {callsign}").format({{"callsign", other->target_name}}), colorConfig.log_generic);
                transmitter->state = CommsTransmitter::State::Inactive;
                other->state = CommsTransmitter::State::ChannelFailed;
            }
        }else{
            if (allow)
            {
                if (!transmitter->target)
                {
                    if (auto log = player.getComponent<ShipLog>())
                        log->add(tr("shiplog", "Hail suddenly went dead."), colorConfig.log_generic);
                    transmitter->state = CommsTransmitter::State::ChannelBroken;
                }else{
                    if (auto log = player.getComponent<ShipLog>())
                        log->add(tr("shiplog", "Accepted hail from {callsign}").format({{"callsign", transmitter->target_name}}), colorConfig.log_generic);
                    transmitter->script_replies.clear();
                    transmitter->script_replies_dirty = true;
                    if (transmitter->incomming_message == "")
                    {
                        if (openChannel(player, transmitter->target))
                            transmitter->state = CommsTransmitter::State::ChannelOpen;
                        else
                            transmitter->state = CommsTransmitter::State::ChannelFailed;
                    }else{
                        // Set the comms message again, so it ends up in the ship's log.
                        // comms_incomming_message was set by "hailByObject", without ending up in the log.
                        setCommsMessage(player, transmitter->incomming_message);
                        transmitter->state = CommsTransmitter::State::ChannelOpen;
                    }
                }
            }else{
                if (auto cs = transmitter->target.getComponent<CallSign>()) {
                    if (auto log = player.getComponent<ShipLog>())
                        log->add(tr("shiplog", "Refused hail from {callsign}").format({{"callsign", cs->callsign}}), colorConfig.log_generic);
                }
                transmitter->state = CommsTransmitter::State::Inactive;
            }
        }
    }
    if (transmitter->state == CommsTransmitter::State::BeingHailedByGM)
    {
        if (allow)
        {
            transmitter->state = CommsTransmitter::State::ChannelOpenGM;

            if (auto log = player.getComponent<ShipLog>())
                log->add(tr("shiplog", "Opened communication channel to {name}").format({{"name", transmitter->target_name}}), colorConfig.log_generic);
            transmitter->incomming_message = tr("chatdialog", "Opened comms with {name}").format({{"name", transmitter->target_name}});
        }else{
            if (auto log = player.getComponent<ShipLog>())
                log->add(tr("shiplog", "Refused hail from {name}").format({{"name", transmitter->target_name}}), colorConfig.log_generic);
            transmitter->state = CommsTransmitter::State::Inactive;
        }
    }
}

void CommsSystem::close(sp::ecs::Entity player)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    // If comms are closed, state it and log it to the ship's log.
    if (transmitter->state != CommsTransmitter::State::Inactive)
    {
        if (transmitter->state == CommsTransmitter::State::ChannelOpenPlayer && transmitter->target)
        {
            auto other = transmitter->target.getComponent<CommsTransmitter>();
            if (other)
                other->state = CommsTransmitter::State::ChannelClosed;
            if (auto log = transmitter->target.getComponent<ShipLog>())
                log->add(tr("shiplog", "Communication channel closed by other side"), colorConfig.log_generic);
        }
        if (transmitter->state == CommsTransmitter::State::OpeningChannel && transmitter->target)
        {
            auto other = transmitter->target.getComponent<CommsTransmitter>();
            if (other)
            {
                if (other->state == CommsTransmitter::State::BeingHailed && other->target == player)
                {
                    other->state = CommsTransmitter::State::Inactive;
                    if (auto log = transmitter->target.getComponent<ShipLog>())
                        log->add(tr("shiplog", "Hailing from {callsign} stopped").format({{"callsign", other->target_name}}), colorConfig.log_generic);
                }
            }
        }
        if (auto log = player.getComponent<ShipLog>())
            log->add(tr("shiplog", "Communication channel closed"), colorConfig.log_generic);
        if (transmitter->state == CommsTransmitter::State::ChannelOpenGM)
            transmitter->state = CommsTransmitter::State::ChannelClosed;
        else
            transmitter->state = CommsTransmitter::State::Inactive;
    }
}

bool CommsSystem::hailByGM(sp::ecs::Entity player, string target_name)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return false;

    // If a ship's comms aren't engaged, receive the GM's hail.
    // Otherwise, return false.
    if (transmitter->state != CommsTransmitter::State::Inactive && transmitter->state != CommsTransmitter::State::ChannelBroken && transmitter->state != CommsTransmitter::State::ChannelClosed && transmitter->state != CommsTransmitter::State::ChannelFailed)
        return false;

    // Log the hail.
    if (auto log = player.getComponent<ShipLog>())
        log->add(tr("shiplog", "Hailed by {name}").format({{"name", target_name}}), colorConfig.log_generic);

    // Set comms to the hail state and notify Relay/comms.
    transmitter->state = CommsTransmitter::State::BeingHailedByGM;
    transmitter->target_name = target_name;
    transmitter->target = {};
    return true;
}

bool CommsSystem::hailByObject(sp::ecs::Entity player, sp::ecs::Entity source, const string& message)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return false;

    if (transmitter->state != CommsTransmitter::State::OpeningChannel || transmitter->state != CommsTransmitter::State::BeingHailed)
    {
        if (transmitter->target != source)
            return false;
    }

    // If comms are engaged, return false.
    if (transmitter->state == CommsTransmitter::State::BeingHailedByGM)
        return false;
    if (transmitter->state == CommsTransmitter::State::ChannelOpen)
        return false;
    if (transmitter->state == CommsTransmitter::State::ChannelOpenGM)
        return false;
    if (transmitter->state == CommsTransmitter::State::ChannelOpenPlayer)
        return false;

    // Receive a hail from the object.
    transmitter->target = source;
    if (auto cs = source.getComponent<CallSign>())
        transmitter->target_name = cs->callsign;
    else
        transmitter->target_name = "?";
    transmitter->state = CommsTransmitter::State::BeingHailed;
    transmitter->incomming_message = message;
    return true;
}

void CommsSystem::selectScriptReply(sp::ecs::Entity player, int index)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;
    if (transmitter->state != CommsTransmitter::State::ChannelOpen) return;
    if (!transmitter->target) return;

    script_active_entity = player;

    if (index >= 0 && index < int(transmitter->script_replies.size()) && transmitter->target)
    {
        if (auto log = player.getComponent<ShipLog>())
            log->add(transmitter->script_replies[index].message, colorConfig.log_send);
        auto callback = transmitter->script_replies[index].callback;
        if (!player.hasComponent<CommsTransmitterEnvironment>()) {
            callback.setGlobal("comms_source", player);
            callback.setGlobal("comms_target", transmitter->target);
        }
        transmitter->script_replies.clear();
        transmitter->script_replies_dirty = true;
        transmitter->incomming_message = "?";
        LuaConsole::checkResult(callback.call<void>(player, transmitter->target));
    }

    script_active_entity = {};
}

void CommsSystem::textReply(sp::ecs::Entity player, const string& message)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    if (transmitter->state == CommsTransmitter::State::ChannelOpenPlayer || transmitter->state == CommsTransmitter::State::ChannelOpenGM)
    {
        addCommsOutgoingMessage(player, message);
        auto other = transmitter->target.getComponent<CommsTransmitter>();
        if (transmitter->state == CommsTransmitter::State::ChannelOpenPlayer && other)
            addCommsIncommingMessage(transmitter->target, message);
    }
}

void CommsSystem::addCommsIncommingMessage(sp::ecs::Entity player, string message)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    // Record incoming comms messages to the ship's log.
    if (auto log = player.getComponent<ShipLog>())
        for(string line : message.split("\n"))
            log->add(line, glm::u8vec4(192, 192, 255, 255));
    // Add the message to the messaging window.
    transmitter->incomming_message = transmitter->incomming_message + "\n> " + message;
}

void CommsSystem::addCommsOutgoingMessage(sp::ecs::Entity player, string message)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    // Record incoming comms messages to the ship's log.
    if (auto log = player.getComponent<ShipLog>())
        for(string line : message.split("\n"))
            log->add(line, glm::u8vec4(192, 192, 255, 255));
    // Add the message to the messaging window.
    transmitter->incomming_message = transmitter->incomming_message + "\n< " + message;
}

void CommsSystem::setCommsMessage(sp::ecs::Entity player, string message)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return;

    // Record a new comms message to the ship's log.
    if (auto log = player.getComponent<ShipLog>())
        for(string line : message.split("\n"))
            log->add(line, glm::u8vec4(192, 192, 255, 255));
    // Display the message in the messaging window.
    transmitter->incomming_message = message;
}

bool CommsSystem::openChannel(sp::ecs::Entity player, sp::ecs::Entity target)
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!transmitter) return false;
    auto receiver = target.getComponent<CommsReceiver>();
    if (!receiver) return false;

    string script_name = receiver->script;
    script_active_entity = player;

    transmitter->script_replies.clear();
    transmitter->script_replies_dirty = true;
    transmitter->target = target;

    player.removeComponent<CommsTransmitterEnvironment>();
    transmitter->incomming_message = "???";

    if (script_name != "")
    {
        auto& env = player.addComponent<CommsTransmitterEnvironment>();
        env.script_environment = std::make_unique<sp::script::Environment>();
        if (setupScriptEnvironment(*env.script_environment)) {
            // consider "player" deprecated, but keep it for a long time
            env.script_environment->setGlobal("player", player);
            env.script_environment->setGlobal("comms_source", player);
            env.script_environment->setGlobal("comms_target", target);
            LuaConsole::checkResult(env.script_environment->runFile<void>(script_name));
        }
    }else if (receiver->callback)
    {
        receiver->callback.setGlobal("comms_source", player);
        receiver->callback.setGlobal("comms_target", transmitter->target);
        LuaConsole::checkResult(receiver->callback.call<void>(player, target));
    }
    script_active_entity = {};
    return transmitter->incomming_message != "???";
}

int CommsSystem::luaSetCommsMessage(lua_State* L)
{
    if (!script_active_entity)
        return 0;
    CommsSystem::setCommsMessage(script_active_entity, luaL_checkstring(L, 1));
    return 0;
}

int CommsSystem::luaAddCommsReply(lua_State* L)
{
    auto transmitter = script_active_entity.getComponent<CommsTransmitter>();
    if (!transmitter)
        return 0;

    string message = luaL_checkstring(L, 1);
    auto callback = sp::script::Convert<sp::script::Callback>::fromLua(L, 2);
    transmitter->script_replies.push_back({message, callback});
    transmitter->script_replies_dirty = true;
    return 0;
}

int CommsSystem::luaCommsSwitchToGM(lua_State* L)
{
    auto transmitter = script_active_entity.getComponent<CommsTransmitter>();
    if (!transmitter)
        return 0;

    transmitter->state = CommsTransmitter::State::ChannelOpenGM;
    if (transmitter->incomming_message == "?")
        transmitter->incomming_message = "";
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
//REGISTER_SCRIPT_FUNCTION(setCommsMessage);
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
//REGISTER_SCRIPT_FUNCTION(addCommsReply);
/// void commsSwitchToGM()
/// Switches a PlayerSpaceship communications dialogue from a comms script/function to interactive chat with the GM.
/// When triggered, this opens a comms chat window on both the player crew's screen and GM console.
/// Use this in a communication callback function, such as addCommsReply() or SpaceObject:setCommsFunction().
/// Example:
/// if comms_source:isFriendly(comms_target) then
///   setCommsMessage("Hello, friend!")
///   addCommsReply("I want to speak to your manager!", function() commsSwitchToGM() end) -- launches a GM chat when selected
///   ...
//REGISTER_SCRIPT_FUNCTION(commsSwitchToGM);

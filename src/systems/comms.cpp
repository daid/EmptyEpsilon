#include "systems/comms.h"
#include "components/comms.h"
#include "components/shiplog.h"
#include "components/name.h"
#include "i18n.h"
#include "preferenceManager.h"
#include "multiplayer_server.h"
#include "gameGlobalInfo.h"
#include "ecs/query.h"
#include "gui/colorConfig.h"
#include "menus/luaConsole.h"


static sp::ecs::Entity script_active_entity;


void CommsSystem::update(float delta)
{
    for(auto [entity, comms] : sp::ecs::Query<CommsTransmitter>()) {
        if (comms.open_delay > 0.0f) comms.open_delay -= delta;

        if (game_server)
        {
            // If the channel opening delay is expired, determine whether to
            // initialize comms with the target.
            if (comms.state == CommsTransmitter::State::OpeningChannel && comms.open_delay <= 0.0f)
            {
                // Exit with a broken channel if the target no longer exists.
                if (!comms.target)
                {
                    comms.state = CommsTransmitter::State::ChannelBroken;
                    return;
                }
                else
                {
                    comms.script_replies.clear();
                    comms.script_replies_dirty = true;

                    // If the other target is itself a comms transmitter, hail it.
                    if (auto other_transmitter = comms.target.getComponent<CommsTransmitter>())
                    {
                        comms.open_delay = channel_open_time;

                        if (other_transmitter->state == CommsTransmitter::State::Inactive
                            || other_transmitter->state == CommsTransmitter::State::ChannelFailed
                            || other_transmitter->state == CommsTransmitter::State::ChannelBroken
                            || other_transmitter->state == CommsTransmitter::State::ChannelClosed)
                        {
                            other_transmitter->state = CommsTransmitter::State::BeingHailed;
                            other_transmitter->target = entity;

                            if (auto callsign = entity.getComponent<CallSign>())
                                other_transmitter->target_name = callsign->callsign;
                            else
                                other_transmitter->target_name = "?";
                        }
                    }
                    // If all other comms are intercepted by the GM, open a chat
                    // with the GM.
                    else if (gameGlobalInfo->intercept_all_comms_to_gm && comms.state != CommsTransmitter::State::ChannelOpen)
                        comms.state = CommsTransmitter::State::ChannelOpenGM;
                    // Otherwise, open a standard comms channel to the target.
                    else if (openChannel(entity, comms.target))
                        comms.state = CommsTransmitter::State::ChannelOpen;
                    else
                        comms.state = CommsTransmitter::State::ChannelFailed;
                }
            }

            if (comms.state == CommsTransmitter::State::ChannelOpen || comms.state == CommsTransmitter::State::ChannelOpenPlayer)
            {
                // Exit with a broken channel if the target no longer exists.
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

    if (transmitter->state == CommsTransmitter::State::OpeningChannel || transmitter->state == CommsTransmitter::State::BeingHailed)
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

    // comms_script (comms from file) is prioritized over
    // comms_callback (comms from inline function). Scenario authors must clear
    // comms_script on an entity with a script in order to use comms_callback.
    if (script_name != "")
    {
        auto& env = player.addComponent<CommsTransmitterEnvironment>();
        env.script_environment = std::make_unique<sp::script::Environment>(gameGlobalInfo->script_environment_base.get());
        setupSubEnvironment(*env.script_environment.get());
        // Consider "player" deprecated, but keep it for a long time.
        env.script_environment->setGlobal("player", player);
        env.script_environment->setGlobal("comms_source", player);
        env.script_environment->setGlobal("comms_target", target);
        i18n::load("locale/" + script_name.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));
        LuaConsole::checkResult(env.script_environment->runFile<void>(script_name));
    }
    else if (receiver->callback)
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

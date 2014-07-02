#ifndef COMMS_SCRIPT_INTERFACE_H
#define COMMS_SCRIPT_INTERFACE_H

#include "engine.h"

class ScriptObject;
class PlayerSpaceship;
class SpaceObject;
class CommsScriptInterface : public sf::NonCopyable
{
public:
    bool has_message;
    int reply_id;
    P<ScriptObject> scriptObject;
    P<PlayerSpaceship> ship;
    P<SpaceObject> target;

    bool openCommChannel(P<PlayerSpaceship> ship, P<SpaceObject> target, string script_name);
    void commChannelMessage(int32_t message_id);
};

#include "playerSpaceship.h"

#endif//COMMS_SCRIPT_INTERFACE_H

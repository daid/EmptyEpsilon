#ifndef COMMS_SCRIPT_INTERFACE_H
#define COMMS_SCRIPT_INTERFACE_H

#include "engine.h"

///Forward declarations
class ScriptObject;
class PlayerSpaceship;
class SpaceObject;

class CommsScriptInterface : public sf::NonCopyable
{
public:
    bool openCommChannel(P<PlayerSpaceship> ship, P<SpaceObject> target);
    void commChannelMessage(int32_t message_id);
    
    void setCommsMessage(string message);
    void addCommsReply(string message, ScriptSimpleCallback callback);
private:
    bool has_message;
    std::vector<ScriptSimpleCallback> reply_callbacks;
    P<ScriptObject> scriptObject;
    P<PlayerSpaceship> ship;
    P<SpaceObject> target;
};

#endif//COMMS_SCRIPT_INTERFACE_H

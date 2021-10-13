#ifndef GM_ACTIONS
#define GM_ACTIONS

#include "engine.h"


class GameMasterActions;
extern P<GameMasterActions> gameMasterActions;

class GameMasterActions : public MultiplayerObject
{

public:

    GameMasterActions();

    void commandRunScript(string code);
    void commandSendGlobalMessage(string message);
    virtual void onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet) override;
};

#endif//GM_ACTIONS

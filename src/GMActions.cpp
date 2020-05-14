#include "GMActions.h"

#include "engine.h"
#include "gameGlobalInfo.h"

const static int16_t CMD_RUN_SCRIPT = 0x0000;
const static int16_t CMD_SEND_GLOBAL_MESSAGE = 0x0001;

P<GameMasterActions> gameMasterActions;

REGISTER_MULTIPLAYER_CLASS(GameMasterActions, "GameMasterActions")
GameMasterActions::GameMasterActions()
: MultiplayerObject("GameMasterActions")
{
    assert(!gameMasterActions);
    gameMasterActions = this;
}

void GameMasterActions::onReceiveClientCommand(int32_t client_id, sf::Packet& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_RUN_SCRIPT:
        {
            string code;
            packet >> code;
            if (code.length() > 0)
            {
                P<ScriptObject> so = new ScriptObject();
                so->runCode(code);
                so->destroy();
            }
        }
        break;
    case CMD_SEND_GLOBAL_MESSAGE:
        {
            string message;
            packet >> message;
            if (message.length() > 0)
            {
                gameGlobalInfo->global_message = message;
                gameGlobalInfo->global_message_timeout = 5.0;
            }
        }
        break;
    }
}

void GameMasterActions::commandRunScript(string code)
{
    sf::Packet packet;
    packet << CMD_RUN_SCRIPT << code;
    sendClientCommand(packet);
}
void GameMasterActions::commandSendGlobalMessage(string message)
{
    sf::Packet packet;
    packet << CMD_SEND_GLOBAL_MESSAGE << message;
    sendClientCommand(packet);
}
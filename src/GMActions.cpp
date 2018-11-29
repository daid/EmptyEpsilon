#include "GMActions.h"

#include "engine.h"
#include "gameGlobalInfo.h"

const static int16_t CMD_RUN_SCRIPT = 0x0000;
const static int16_t CMD_SEND_GLOBAL_MESSAGE = 0x0001;
const static int16_t CMD_INTERCEPT_ALL_COMMS_TO_GM = 0x0002;
const static int16_t CMD_CALL_GM_SCRIPT = 0x0003;
const static int16_t CMD_MOVE_OBJECTS = 0x0004;

P<GameMasterActions> gameMasterActions;

REGISTER_MULTIPLAYER_CLASS(GameMasterActions, "GameMasterActions")
GameMasterActions::GameMasterActions()
: MultiplayerObject("GameMasterActions"), gmSelectionForRunningScript(nullptr)
{
    assert(!gameMasterActions);
    gameMasterActions = this;
}

static inline sf::Packet& operator << (sf::Packet& packet, const P<SpaceObject>& object) { return packet << object->getMultiplayerId(); }
static inline sf::Packet& operator >> (sf::Packet& packet, P<SpaceObject>& object) { 
    int selectedItemId;
    packet >> selectedItemId;
    object = game_server->getObjectById(selectedItemId);
    return packet;
}
static inline sf::Packet& operator << (sf::Packet& packet, /*const*/ PVector<SpaceObject>& objects) { 
    packet << objects.size();
    foreach(SpaceObject, object, objects)
    {
        packet << object;
    }
    return packet;
}
static inline sf::Packet& operator >> (sf::Packet& packet, PVector<SpaceObject>& objects) { 
    int selectedItemsLeft;
    packet >> selectedItemsLeft;
    while (selectedItemsLeft--) {
        P<SpaceObject> object;
        packet >> object;
        if (object) objects.push_back(object);
    }
    return packet;
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
    case CMD_INTERCEPT_ALL_COMMS_TO_GM:
        {
            bool value;
            packet >> value;
            gameGlobalInfo->intercept_all_comms_to_gm = value;
        }
        break;
    case CMD_CALL_GM_SCRIPT:
        {
            int index;
            packet >> index;
            PVector<SpaceObject> selection;
            packet >> selection;
            // set selection for the possible duration of the script
            gmSelectionForRunningScript = &selection;
            int n = 0;
            for(ScriptSimpleCallback& callback : gameGlobalInfo->gm_callback_functions)
            {
                if (n == index)
                {
                    callback.call();
                    break;
                }
                n++;
            }
            // clear selection
            gmSelectionForRunningScript = nullptr;
        }
        break;
        case CMD_MOVE_OBJECTS:
        {
            sf::Vector2f delta;
            packet >> delta;
            PVector<SpaceObject> selection;
            packet >> selection;
            for(P<SpaceObject> obj : selection)
            {
                obj->setPosition(obj->getPosition() + delta);
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
void GameMasterActions::commandInterceptAllCommsToGm(bool value)
{
    sf::Packet packet;
    packet << CMD_INTERCEPT_ALL_COMMS_TO_GM << value;
    sendClientCommand(packet);
}
void GameMasterActions::commandCallGmScript(int index, PVector<SpaceObject> selection)
{
    sf::Packet packet;
    packet << CMD_CALL_GM_SCRIPT << index << selection;
    sendClientCommand(packet);
}
void GameMasterActions::commandMoveObjects(sf::Vector2f delta, PVector<SpaceObject> selection)
{
    sf::Packet packet;
    packet << CMD_MOVE_OBJECTS << delta << selection;
    sendClientCommand(packet);
}


static int addGMFunction(lua_State* L)
{
    const char* name = luaL_checkstring(L, 1);

    ScriptSimpleCallback callback;
    
    int idx = 2;
    convert<ScriptSimpleCallback>::param(L, idx, callback);

    gameGlobalInfo->gm_callback_names.emplace_back(name);
    gameGlobalInfo->gm_callback_functions.emplace_back(callback);

    return 0;
}
/// addGMFunction(name, function)
/// Add a function that can be called from the GM console. This can be used to create helper scripts for the GM.
/// Or to give the GM console certain control over the scenario.
REGISTER_SCRIPT_FUNCTION(addGMFunction);

static int removeGMFunction(lua_State* L)
{
    string name = luaL_checkstring(L, 1);
    std::vector<uint32_t> indexesToDelete;
    for (uint32_t i = 0; i < gameGlobalInfo->gm_callback_names.size(); ++i)
    {
        if (gameGlobalInfo->gm_callback_names[i] == name)
        {
            indexesToDelete.emplace_back(i);
        }
    }
    for (auto i = indexesToDelete.rbegin(); i != indexesToDelete.rend(); i++){
        gameGlobalInfo->gm_callback_names.erase(gameGlobalInfo->gm_callback_names.begin() + *i);
        gameGlobalInfo->gm_callback_functions.erase(gameGlobalInfo->gm_callback_functions.begin() + *i);
    }
    return 0;
}
/// removeGMFunction(name)
/// Remove a function from the GM console
REGISTER_SCRIPT_FUNCTION(removeGMFunction);

static int clearGMFunctions(lua_State* L)
{
    gameGlobalInfo->gm_callback_names.clear();
    gameGlobalInfo->gm_callback_functions.clear();
    return 0;
}
/// clearGMFunctions()
/// Remove all the GM functions from the GM console.
REGISTER_SCRIPT_FUNCTION(clearGMFunctions);

static int getGMSelection(lua_State* L)
{
    PVector<SpaceObject> objects;
    if (gameMasterActions->gmSelectionForRunningScript){
        objects = *gameMasterActions->gmSelectionForRunningScript;
    } 
    return convert<PVector<SpaceObject> >::returnType(L, objects);
}
/// getGMSelection()
/// Returns an list of objects that the GM currently has selected.
REGISTER_SCRIPT_FUNCTION(getGMSelection);


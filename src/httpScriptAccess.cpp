#include "httpScriptAccess.h"
#include "gameGlobalInfo.h"

bool HttpScriptHandler::handleRequest(HttpRequest& request, HttpServerConnection* connection)
{
    if (request.path == "/exec.lua")
    {
        if (!gameGlobalInfo)
        {
            connection->sendString("{\"ERROR\": \"No game\"}");
            return true;
        }
        P<ScriptObject> script = new ScriptObject();
        script->setMaxRunCycles(100000);
        string output;
        if (!script->runCode(request.post_data, output))
            connection->sendString("{\"ERROR\": \"Script error: " + script->getError() + "\"}");
        else
            connection->sendString(output);
        script->destroy();
        return true;
    }
    return false;
}

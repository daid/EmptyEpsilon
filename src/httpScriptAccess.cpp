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
            connection->sendString("{\"ERROR\": \"Script error\"}");
        else
            connection->sendString(output);
        return true;
    }
    else if (request.path == "/get_data.lua")
    {
        if (!gameGlobalInfo)
        {
            connection->sendString("{\"ERROR\": \"No game\"}");
            return true;
        }

        string luaCode;
        string objectId = "getPlayerShip(-1)";
        std::map<string, string>::iterator i;

        i = request.parameters.find(sOBJECT);
        if (i != request.parameters.end())
        {
            objectId = request.parameters[sOBJECT];
            request.parameters.erase(i);
        }

        luaCode = "object = " + objectId + "\n" +
               "if object == nil then return {error = \"No valid object\"} end\n" +
               "return {";

        for (i = request.parameters.begin(); i != request.parameters.end(); i++)
        {
            luaCode += i->first + " = object:" + i->second + ", ";
        }   luaCode += "}";

        P<ScriptObject> script = new ScriptObject();
        script->setMaxRunCycles(100000);

        string output;
        if (!script->runCode(luaCode, output))
            connection->sendString("{\"ERROR\": \"Script error\"}");
        else
            connection->sendString(output);
        return true;
    }
    else if (request.path == "/set_data.lua")
    {
        if (!gameGlobalInfo)
        {
            connection->sendString("{\"ERROR\": \"No game\"}");
            return true;
        }

        string luaCode;
        string objectId = "getPlayerShip(-1)";
        std::map<string, string>::iterator i;

        i = request.parameters.find(sOBJECT);
        if (i != request.parameters.end())
        {
            objectId = request.parameters[sOBJECT];
            request.parameters.erase(i);
        }

        luaCode = "object = " + objectId + "\n" +
               "if object == nil then return {error = \"No valid object\"} end\n";

        for (i = request.parameters.begin(); i != request.parameters.end(); i++)
        {
            if (i->second == sFALSE)
                luaCode += "object:" + i->first + ";\n";
            else
                luaCode += i->first + ":" + i->second + ";\n";
        }

        P<ScriptObject> script = new ScriptObject();
        script->setMaxRunCycles(100000);

        string output;
        if (!script->runCode(luaCode, output))
            connection->sendString("{\"ERROR\": \"Script error\"}");
        else
            connection->sendString(output);
        return true;
    }


    return false;
}

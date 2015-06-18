#include "httpScriptAccess.h"
#include "gameGlobalInfo.h"

#define sOBJECT "_OBJECT_"

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
    else if (request.path == "/get.lua")
    {
        /*
        Call LUA-exposed functions and return their result in a dictionary.
        Use _OBJECT_=someObjectGetter() to get the object of which to call functions
        Defaults to getPlayerShip(-1)

        Syntax: /get.lua?dictionaryKey=functionName("arguments)

        Example Getter: /get.lua?hull=getHull()&nukes=getWeaponStorage("nuke")
        Creates the following LUA-code:

        object = getPlayerShip(-1)
        if object == nil then return {error = "No valid object"} end
        return {hull = object:getHull(), nukes = object:getWeaponStorage("nuke"), }

        Returns: {hull = 100, nukes = 42}
        */
        if (!gameGlobalInfo)
        {
            connection->sendString("{\"ERROR\": \"No game\"}");
            return true;
        }

        string luaCode;
        string objectId = "getPlayerShip(-1)";
        std::map<string, string>::iterator i;
        P<ScriptObject> script;
        string output;

        // Look for _OBJECT_ in parameters. If not found, use default
        i = request.parameters.find(sOBJECT);
        if (i != request.parameters.end())
        {
            objectId = request.parameters[sOBJECT];
            request.parameters.erase(i);
        }

        luaCode = "object = " + objectId + "\n" +
                  "if object == nil then return {error = \"No valid object\"} end\n" +
                  "return {";

        // Loop through URL parameters
        for (i = request.parameters.begin(); i != request.parameters.end(); i++)
        {
            // Fail if trying to set stuff. We only do get.
            if (i->second.substr(0, 3) == "set")
            {
                connection->sendString("{\"ERROR\": \"Cannot set values through get.lua\", \"COMMAND\": \"" + i->second + "\"}");
                return true;
            }
            // Build LUA-code
            luaCode += i->first + " = object:" + i->second + ", ";
        }   luaCode += "}";

        // Run script
        script = new ScriptObject();
        script->setMaxRunCycles(100000);

        // Return dictionary with error, else output
        if (!script->runCode(luaCode, output))
        {
            connection->sendString("{\"ERROR\": \"Script error\"}");
        }
        else
        {
            connection->sendString(output);
        }
        script->destroy();
        return true;
    }
    else if (request.path == "/set.lua")
    {
        /*
        Call LUA-exposed functions with arguments.
        Use _OBJECT_=someObjectGetter() to get the object of which to call functions
        Defaults to getPlayerShip(-1)

        Syntax: /set.lua?someFunction('arg')&otherFunction(1,2,3)

        Example Setter: /set.lua?setShieldsActive(true)&setSpeed(200, 3)
        Creates the following LUA-code:

        object = getPlayerShip(-1)
        if object == nil then return {error = "No valid object"} end
        object:setShieldsActive(true);
        object:setSpeed(200, 3);

        Returns nothing, or ERROR on failure.
        */
        if (!gameGlobalInfo)
        {
            connection->sendString("{\"ERROR\": \"No game\"}");
            return true;
        }

        string luaCode;
        string objectId = "getPlayerShip(-1)";
        std::map<string, string>::iterator i;
        P<ScriptObject> script;
        string output;;

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
            if (i->second == "")
                luaCode += "object:" + i->first + ";\n";
            else
                luaCode += i->first + ":" + i->second + ";\n";
        }

        script = new ScriptObject();
        script->setMaxRunCycles(100000);

        if (!script->runCode(luaCode, output))
            connection->sendString("{\"ERROR\": \"Script error\"}");
        else
            connection->sendString(output);
        script->destroy();
        return true;
    }

    return false;
}

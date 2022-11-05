#include "httpScriptAccess.h"
#include "gameGlobalInfo.h"

#define sOBJECT "_OBJECT_"


EEHttpServer::EEHttpServer(int port, string static_file_path)
: server(port)
{
    server.setStaticFilePath(static_file_path);
    server.addURLHandler("/exec.lua", [](const sp::io::http::Server::Request& request) -> string
    {
        if (!gameGlobalInfo)
        {
            return "{\"ERROR\": \"No game\"}";
        }
        P<ScriptObject> script = new ScriptObject();
        script->setMaxRunCycles(100000);
        string output;
        if (!script->runCode(request.post_data, output))
            output = "{\"ERROR\": \"Script error: " + script->getError().replace("\"", "'") + "\"}";
        script->destroy();
        return output;
    });
    server.addURLHandler("/get.lua", [](const sp::io::http::Server::Request& request) -> string
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
            return "{\"ERROR\": \"No game\"}";
        }

        string luaCode;
        string objectId = "getPlayerShip(-1)";
        if (my_spaceship) {
            int index = gameGlobalInfo->findPlayerShip(my_spaceship);
            objectId = "getPlayerShip("+std::to_string(index+1)+")";
        }
        std::unordered_map<string, string>::const_iterator i;
        P<ScriptObject> script;
        string output;

        // Look for _OBJECT_ in parameters. If not found, use default
        i = request.query.find(sOBJECT);
        if (i != request.query.end())
        {
            objectId = i->second;
        }

        luaCode = "object = " + objectId + "\n" +
                  "if object == nil then return {error = \"No valid object\"} end\n" +
                  "return {";

        // Loop through URL parameters
        for (i = request.query.begin(); i != request.query.end(); i++)
        {
            if (i->first == sOBJECT)
                continue;
            // Fail if trying to set stuff. We only do get.
            if (i->second.substr(0, 3) == "set")
            {
                return "{\"ERROR\": \"Cannot set values through get.lua\", \"COMMAND\": \"" + i->second + "\"}";
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
            output = "{\"ERROR\": \"Script error\"}";
        }
        script->destroy();
        return output;
    });
    server.addURLHandler("/set.lua", [](const sp::io::http::Server::Request& request) -> string
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
            return "{\"ERROR\": \"No game\"}";
        }

        string luaCode;
        string objectId = "getPlayerShip(-1)";
        if (my_spaceship) {
            int index = gameGlobalInfo->findPlayerShip(my_spaceship);
            objectId = "getPlayerShip("+std::to_string(index+1)+")";
        }
        std::unordered_map<string, string>::const_iterator i;
        P<ScriptObject> script;
        string output;

        i = request.query.find(sOBJECT);
        if (i != request.query.end())
        {
            objectId = i->first;
        }

        luaCode = "object = " + objectId + "\n" +
               "if object == nil then return {error = \"No valid object\"} end\n";

        for (i = request.query.begin(); i != request.query.end(); i++)
        {
            if (i->first == sOBJECT)
                continue;
            if (i->second == "")
                luaCode += "object:" + i->first + ";\n";
            else
                luaCode += i->first + ":" + i->second + ";\n";
        }

        script = new ScriptObject();
        script->setMaxRunCycles(100000);

        if (!script->runCode(luaCode, output))
            output = "{\"ERROR\": \"Script error\"}";
        else
            output = "{}";
        script->destroy();
        return output;
    });
}

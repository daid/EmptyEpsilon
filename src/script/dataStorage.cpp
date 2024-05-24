#include "dataStorage.h"
#include "io/json.h"
#include <unordered_map>


static string scriptstorage_path = "scriptstorage.json";
std::unordered_map<std::string, std::string> data;

static void initScriptStorage()
{
    if (getenv("HOME"))
    {
        scriptstorage_path = string(getenv("HOME")) + "/.emptyepsilon/" + scriptstorage_path;
    }

    FILE* f = fopen(scriptstorage_path.c_str(), "rt");

    if (f)
    {
        std::string s;
        while(!feof(f))
        {
            char buffer[1024];
            auto size = fread(buffer, 1, sizeof(buffer), f);
            s += std::string(buffer, size);
        }
        fclose(f);

        std::string err;
        if (auto parsed_json = sp::json::parse(s, err); parsed_json)
        {
            auto json = parsed_json.value();
            for (const auto& [key, value] : json.items())
            {
                data[key] = value.get<std::string>();
            }
        }
        else
        {
            LOG(WARNING, "Unable to parse ", scriptstorage_path, ": ", err);
        }
    }
}

static int luaScriptDataStorageSet(lua_State* L)
{
    string key = luaL_checkstring(L, 2);
    string value = luaL_checkstring(L, 3);
    if (data[key] == value)
        return 0;

    data[key] = value;
    FILE* f = fopen(scriptstorage_path.c_str(), "wt");

    if (f)
    {
        auto s = nlohmann::json(data).dump();
        fwrite(s.data(), s.size(), 1, f);
        fclose(f);
    }
    return 0;
}

static int luaScriptDataStorageGet(lua_State* L)
{
    string key = luaL_checkstring(L, 2);
    auto it = data.find(key);
    if (it == data.end())
        return 0;
    lua_pushstring(L, it->second.c_str());
    return 1;
}

static int luaGetScriptStorage(lua_State* L)
{
    if (lua_getfield(L, LUA_REGISTRYINDEX, "ScriptDataStorageInstance") != LUA_TNIL)
        return 1;
    initScriptStorage();
    lua_pop(L, 1);
    lua_newtable(L); // object table
        lua_newtable(L); // meta table
            lua_pushstring(L, "__index");
            lua_newtable(L); // function table
                lua_pushstring(L, "get");
                lua_pushcfunction(L, &luaScriptDataStorageGet);
                lua_rawset(L, -3);
                lua_pushstring(L, "set");
                lua_pushcfunction(L, &luaScriptDataStorageSet);
                lua_rawset(L, -3);
            lua_rawset(L, -3);
            lua_pushstring(L, "__metatable");
            lua_pushstring(L, "sandbox");
            lua_rawset(L, -3);
        lua_setmetatable(L, -2);
    lua_pushvalue(L, -1);
    lua_setfield(L, LUA_REGISTRYINDEX, "ScriptDataStorageInstance");
    return 1;
}

/// The ScriptStorage persistently saves key/value pairs to a file.
/// These key/value pairs are permanently stored and survive server restarts.
/// Its default file path is $HOME/.emptyepsilon/scriptstorage.json.
/// See getScriptStorage().
//REGISTER_SCRIPT_CLASS(ScriptStorage)
    /// Returns the value for the given key from the persistent ScriptStorage as a JSON string.
    /// Returns nothing if the key is not found.
    /// Example:
    ///   storage = getScriptStorage()
    ///   storage:set('key', 'value')
    ///   storage:get('key') -- returns "value"
    //REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, get);
    /// Sets a key/value pair in the persistent ScriptStorage file.
    /// If the scriptstorage.json file doesn't exist, this function creates it.
    /// If the given key already exists, this function overwrites its value.
    /// Example:
    ///   storage = getScriptStorage()
    ///   storage:set('key', 'value') -- writes {"key":"value"} to scriptstorage.json
    //REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, set);

void registerScriptDataStorageFunctions(sp::script::Environment& env)
{
    /// P<ScriptStorage> getScriptStorage()
    /// Returns the ScriptStorage object, which can save and load key/value pairs.
    /// These key/value pairs are permanently stored and survive server restarts.
    /// To use this object, see ScriptStorage:get() and :set().
    /// Example: storage = getScriptStorage();
    env.setGlobal("getScriptStorage", &luaGetScriptStorage);
}

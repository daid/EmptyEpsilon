#include "dataStorage.h"
#include "io/json.h"
#include <unordered_map>


static string scriptstorage_path = "scriptstorage.json";
static nlohmann::json data;

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
            data = parsed_json.value();
        }
        else
        {
            LOG(WARNING, "Unable to parse ", scriptstorage_path, ": ", err);
        }
    }
}

static void luaPushJson(lua_State* L, const nlohmann::json& json)
{
    switch(json.type()) {
    case nlohmann::json::value_t::null:
        lua_pushnil(L);
        break;
    case nlohmann::json::value_t::object:
        lua_newtable(L);
        for(const auto& [key, value] : json.items()) {
            luaPushJson(L, key);
            luaPushJson(L, value);
            lua_settable(L, -3);
        }
        break;
    case nlohmann::json::value_t::array:
        lua_newtable(L);
        {
            int index = 1;
            for(const auto& value : json) {
                luaPushJson(L, value);
                lua_seti(L, -2, index++);
            }
        }
        break;
    case nlohmann::json::value_t::string:
        lua_pushstring(L, static_cast<std::string>(json).c_str());
        break;
    case nlohmann::json::value_t::boolean:
        lua_pushboolean(L, static_cast<bool>(json));
        break;
    case nlohmann::json::value_t::number_integer:
    case nlohmann::json::value_t::number_unsigned:
        lua_pushnumber(L, static_cast<int>(json));
        break;
    case nlohmann::json::value_t::number_float:
        lua_pushnumber(L, static_cast<float>(json));
        break;
    case nlohmann::json::value_t::binary:
        lua_pushnil(L);
        break;
    case nlohmann::json::value_t::discarded:
        lua_pushnil(L);
        break;
    }
}

static nlohmann::json luaGetJson(lua_State* L, int index)
{
    nlohmann::json res{nullptr};
    switch(lua_type(L, index))
    {
    case LUA_TBOOLEAN:
        res = bool(lua_toboolean(L, index));
        break;
    case LUA_TNUMBER:
        res = lua_tonumber(L, index);
        break;
    case LUA_TSTRING:
        res = lua_tostring(L, index);
        break;
    case LUA_TTABLE:
        index = lua_absindex(L, index);
        if (lua_rawlen(L, index) > 0) {
            res = nlohmann::json::array();
            for(int n=1; n<=lua_rawlen(L, index); n++) {
                lua_geti(L, index, n);
                res.push_back(luaGetJson(L, -1));
                lua_pop(L, 1);
            }
        } else {
            res = nlohmann::json::object();
            lua_pushnil(L);
            while(lua_next(L, index)) {
                auto key = luaGetJson(L, -2);
                auto value = luaGetJson(L, -1);
                if (key.is_string())
                    res[key] = value;
                lua_pop(L, 1);
            }
        }
        break;
    }
    return res;
}

static int luaScriptDataStorageSet(lua_State* L)
{
    string key = luaL_checkstring(L, 2);
    if (lua_isnil(L, 3)) {
        data.erase(key);
    } else {
        data[key] = luaGetJson(L, 3);
    }
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
    
    luaPushJson(L, *it);
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

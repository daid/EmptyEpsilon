#include <unordered_map>
#include "scriptInterface.h"
#include <json11/json11.hpp>


class ScriptStorage : public PObject
{
public:
    ScriptStorage()
    {
        FILE* f = fopen("scriptstorage.json", "rt");
        if (f)
        {
            std::string s;
            while(!feof(f))
            {
                char buffer[1024];
                auto size = fread(buffer, sizeof(buffer), 1, f);
                s += std::string(buffer, size);
            }
            fclose(f);

            std::string err;
            json11::Json json = json11::Json::parse(s, err);
            for(auto it : json.object_items())
            {
                data[it.first] = it.second.string_value();
            }
        }
    }

    void set(string key, string value)
    {
        if (data[key] == value)
            return;
        data[key] = value;

        FILE* f = fopen("scriptstorage.json", "wt");
        if (f)
        {
            json11::Json json{data};
            auto s = json.dump();
            fwrite(s.data(), s.size(), 1, f);
            fclose(f);
        }
    }

    string get(string key)
    {
        auto it = data.find(key);
        if (it == data.end())
            return "";
        return it->second;
    }

private:
    std::unordered_map<std::string, std::string> data;
};

REGISTER_SCRIPT_CLASS(ScriptStorage)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, get);
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, set);
}

static P<ScriptStorage> storage;

static int getScriptStorage(lua_State* L)
{
    if (!storage)
        storage = new ScriptStorage();
    return convert<P<ScriptStorage> >::returnType(L, storage);
}
/// getStorage()
/// Exposes the ScriptStorage object, which can be used to save/load key value pairs
/// These key value pairs are permanently stored and survive server restarts.
REGISTER_SCRIPT_FUNCTION(getScriptStorage);

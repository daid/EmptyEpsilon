#include <unordered_map>
#include "scriptInterface.h"
#include "io/json.h"


class ScriptStorage : public PObject
{
public:
    ScriptStorage()
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
                LOG(WARNING, "Unable to parse ", scriptstorage_path, ": ", err);
            
        }
    }

    void set(string key, string value)
    {
        if (data[key] == value)
        {
            return;
        }

        data[key] = value;
        FILE* f = fopen(scriptstorage_path.c_str(), "wt");

        if (f)
        {
            auto s = nlohmann::json(data).dump();
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
    string scriptstorage_path = "scriptstorage.json";
    std::unordered_map<std::string, std::string> data;
};

REGISTER_SCRIPT_CLASS(ScriptStorage)
{
    /// Get a value from persistent script storage.
    /// Requires the key as a string.
    /// Returns the value as a JSON string.
    /// Returns nothing if the key is not found.
    /// Example: storage = getScriptStorage()
    ///          storage:get('key')
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, get);
    /// Set a value in persistent script storage.
    /// Requires the key and value as strings.
    /// Creates scriptstorage.json if it doesn't exist.
    /// Example: storage = getScriptStorage()
    ///          storage:set('key', 'value')
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, set);
}

static P<ScriptStorage> storage;

static int getScriptStorage(lua_State* L)
{
    if (!storage)
        storage = new ScriptStorage();
    return convert<P<ScriptStorage> >::returnType(L, storage);
}

/// P<ScriptStorage> getScriptStorage()
/// Expose the ScriptStorage object, which can save and load key-value pairs
/// These key-value pairs are permanently stored and survive server restarts.
/// Returns a ScriptStorage object; see also ScriptStorage.get() and .set().
/// Example: storage = getScriptStorage();
REGISTER_SCRIPT_FUNCTION(getScriptStorage);

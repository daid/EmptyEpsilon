#include "scriptDataStorage.h"

REGISTER_SCRIPT_CLASS(ScriptStorage)
{
    /// Get a value from persistent script storage.
    /// Requires the key as a string.
    /// Returns the value as a JSON string.
    /// Returns nothing if the key is not found.
    /// Example: storage = getScriptStorage()
    ///          value = storage:get('key')
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, get);
    /// Set a value in persistent script storage.
    /// Requires the key and value as strings.
    /// Creates scriptstorage.json if it doesn't exist.
    /// Example: storage = getScriptStorage()
    ///          storage:set('key', 'value')
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptStorage, set);
}

ScriptStorage::ScriptStorage()
: scriptstorage_path("scriptstorage.json")
{
    // Store data in the HOME path if one's present.
    if (getenv("HOME"))
    {
        scriptstorage_path = string(getenv("HOME")) + "/.emptyepsilon/" + scriptstorage_path;
    }

    // If any script storage is present, read and parse it into the data array.
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
        json11::Json json = json11::Json::parse(s, err);

        for(auto it : json.object_items())
        {
            data[it.first] = it.second.string_value();
        }
    }
}

void ScriptStorage::set(string key, string value)
{
    // Don't duplicate data already in storage.
    if (data[key] == value)
    {
        return;
    }

    // Open the script storage file for writing, then parse the input into JSON
    // and write it to storage.
    data[key] = value;
    FILE* f = fopen(scriptstorage_path.c_str(), "wt");

    if (f)
    {
        json11::Json json{data};
        auto s = json.dump();
        fwrite(s.data(), s.size(), 1, f);
        fclose(f);
    }
}

string ScriptStorage::get(string key)
{
    // Return the data for the given key, or an empty string if the key isn't
    // found.
    auto it = data.find(key);

    if (it == data.end())
    {
        return "";
    }

    return it->second;
}

static int getScriptStorage(lua_State* L)
{
    if (!storage)
        storage = new ScriptStorage();
    return convert<P<ScriptStorage> >::returnType(L, storage);
}

/// Expose the ScriptStorage object, which can save and load key-value pairs.
/// These key-value pairs are permanently stored and survive server restarts.
/// The default storage path is in '$HOME/.emptyepsilon/scriptstorage.json',
/// or in the same directory as the executable if $HOME isn't defined.
/// Returns a ScriptStorage object. To retrieve data from that object, see the
/// ScriptStorage.get() and .set() functions.
/// Example: storage = getScriptStorage();
REGISTER_SCRIPT_FUNCTION(getScriptStorage);

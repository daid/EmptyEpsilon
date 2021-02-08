#ifndef SCRIPT_DATA_STORAGE_H
#define SCRIPT_DATA_STORAGE_H

#include "scriptInterface.h"
#include <unordered_map>
#include <json11/json11.hpp>

class ScriptStorage : public PObject
{
public:
    ScriptStorage();

    void set(string key, string value);
    string get(string key);

private:
    string scriptstorage_path;
    std::unordered_map<std::string, std::string> data;
};

static P<ScriptStorage> storage;

#endif // SCRIPT_DATA_STORAGE_H

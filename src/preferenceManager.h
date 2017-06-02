#ifndef PREFERENCES_MANAGER_H
#define PREFERENCES_MANAGER_H

#include "engine.h"

class PreferencesManager
{
private:
    static std::unordered_map<string, string> preference;
public:
    static void set(string key, string value);
    static string get(string key, string default_value="");
    
    static void load(string filename);
    static void save(string filename);
};

#endif//PREFERENCES_MANAGER_H

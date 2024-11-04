#include "preferenceManager.h"

#if defined(ANDROID)
#include <SDL.h>
#endif

std::unordered_map<string, string> PreferencesManager::preference;
std::unordered_map<string, string> PreferencesManager::temporary;

void PreferencesManager::set(string key, string value)
{
    preference[key] = value;
    temporary.erase(key);
}

void PreferencesManager::setTemporary(string key, string value)
{
    temporary[key] = value;
}

string PreferencesManager::get(string key, string default_value)
{
    if (temporary.find(key) != temporary.end())
        return temporary[key];
    if (preference.find(key) == preference.end())
        preference[key] = default_value;
    return preference[key];
}

void PreferencesManager::load(string filename)
{
#if defined(ANDROID)
    filename = string(SDL_AndroidGetInternalStoragePath()) + "/" + filename.substr(filename.rfind("/")+1);
#endif
    FILE* f = fopen(filename.c_str(), "r");
    if (f)
    {
        char buffer[1024];
        while(fgets(buffer, sizeof(buffer), f))
        {
            string line = string(buffer).strip();
            if (line.find("=") > -1)
            {
                if(line.find("#") != 0) {
                    string key = line.substr(0, line.find("="));
                    string value = line.substr(line.find("=") + 1);
                    preference[key] = value;
                }

            }
        }
        fclose(f);
    }
}

void PreferencesManager::save(string filename)
{
#if defined(ANDROID)
    //I guess nobody wants to set something like options.ini and then some_directory/options.ini
    //so here the directory hierarchy is not kept.
    //On Android you have to write your user files to a specific directory.
    filename = string(SDL_AndroidGetInternalStoragePath()) + "/" + filename.substr(filename.rfind("/")+1);
#endif
    FILE* f = fopen(filename.c_str(), "w");
    if (f)
    {
        fprintf(f, "# Empty Epsilon Settings\n# This file will be overwritten by EE.\n\n");
        fprintf(f, "# Include the following line to enable an experimental http server:\n# httpserver=8080\n\n");
        fprintf(f, "# Values for ship_window_flags and main_screen_flags are: spacedust:1, headings:2, callsigns:4 \n# Add them for any combination. Example: ship_window_flags=7 for all three\n\n");
        std::vector<string> keys;
        for(std::unordered_map<string, string>::iterator i = preference.begin(); i != preference.end(); i++)
        {
            keys.push_back(i->first);
        }
        std::sort(keys.begin(), keys.end());
        for(string key : keys)
        {
            fprintf(f, "%s=%s\n", key.c_str(), preference[key].c_str());
        }
        fclose(f);
    }
}

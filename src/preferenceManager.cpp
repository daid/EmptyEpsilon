#include "preferenceManager.h"

std::unordered_map<string, string> PreferencesManager::preference;

void PreferencesManager::set(string key, string value)
{
    preference[key] = value;
}

string PreferencesManager::get(string key, string default_value)
{
    if (preference.find(key) == preference.end())
        preference[key] = default_value;
    return preference[key];
}

void PreferencesManager::load(string filename)
{
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
    FILE* f = fopen(filename.c_str(), "w");
    if (f)
    {
        fprintf(f, "# Empty Epsilon Settings\n# This file will be overwritten by EE.\n\n");
        fprintf(f, "# Include the following line to enable an experimental http server:\n# httpserver=8080\n\n");
        fprintf(f, "# For possible hotkey values check: http://www.sfml-dev.org/documentation/2.3.1/classsf_1_1Keyboard.php#acb4cacd7cc5802dec45724cf3314a142\n\n");
        fprintf(f, "# Values for ship_window_flags are: spacedust:1, headings:2, callsigns:4 \n# Add them for any combination. Example: ship_window_caption=7 for all three\n\n");
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

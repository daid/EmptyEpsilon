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
        for(std::unordered_map<string, string>::iterator i = preference.begin(); i != preference.end(); i++)
        {
            fprintf(f, "%s=%s\n", i->first.c_str(), i->second.c_str());
        }
        fclose(f);
    }
}

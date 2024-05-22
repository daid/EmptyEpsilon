#include "config.h"
#include <stringImproved.h>
#include <io/keybinding.h>
#include <preferenceManager.h>
#include "gui/colorConfig.h"
#include "gui/hotkeyConfig.h"
#include <cstring>

#if STEAMSDK
#include "steam/steam_api.h"
#include "steamrichpresence.h"
#endif


string initConfiguration(int argc, char** argv)
{
    string configuration_path = ".";
    if (getenv("EE_CONF_DIR"))
        configuration_path = string(getenv("EE_CONF_DIR"));
    else if (getenv("HOME"))
        configuration_path = string(getenv("HOME")) + "/.emptyepsilon";
#ifdef STEAMSDK
    {
        char path_buffer[1024];
        if (SteamUser()->GetUserDataFolder(path_buffer, sizeof(path_buffer)))
            configuration_path = path_buffer;
    }
#endif
    LOG(Info, "Using ", configuration_path, " as configuration path");
    PreferencesManager::load(configuration_path + "/options.ini");

    for(int n=1; n<argc; n++)
    {
        char* value = strchr(argv[n], '=');
        if (!value) continue;
        *value++ = '\0';
        PreferencesManager::setTemporary(string(argv[n]).strip(), string(value).strip());
    }

    if (PreferencesManager::get("username", "") == "")
    {
#ifdef STEAMSDK
        PreferencesManager::setTemporary("username", SteamFriends()->GetPersonaName());
#else
        if (getenv("USERNAME"))
            PreferencesManager::setTemporary("username", getenv("USERNAME"));
        else if (getenv("USER"))
            PreferencesManager::setTemporary("username", getenv("USER"));
#endif
    }

    sp::io::Keybinding::loadKeybindings(configuration_path + "/keybindings.json");
    return configuration_path;
}
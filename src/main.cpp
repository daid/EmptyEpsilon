#include <memory>
#include <set>
#include <filesystem>
#include <string.h>
#include <i18n.h>
#include <multiplayer_proxy.h>
#ifdef _MSC_VER
#include <direct.h>
#else
#include <unistd.h>
#include <sys/stat.h>
#endif
#include <sys/types.h>
#include "textureManager.h"
#include "soundManager.h"
#include "gui/theme.h"
#include "menus/mainMenus.h"
#include "menus/autoConnectScreen.h"
#include "menus/shipSelectionScreen.h"
#include "main.h"
#include "epsilonServer.h"
#include "httpScriptAccess.h"
#include "preferenceManager.h"
#include "networkRecorder.h"
#include "tutorialGame.h"
#include "windowManager.h"
#include "init/config.h"
#include "init/resources.h"
#include "init/displaywindows.h"
#include "init/ecs.h"
#include "stdinLuaConsole.h"

#include "graphics/opengl.h"

#include "hardware/hardwareController.h"
#if WITH_DISCORD
#include "discord.h"
#endif
#if STEAMSDK
#include "steam/steam_api.h"
#include "steamrichpresence.h"
#endif

#include "shaderRegistry.h"
#include "glObjects.h"

glm::vec3 camera_position;
float camera_yaw;
float camera_pitch;
sp::Font* main_font;
sp::Font* bold_font;
RenderLayer* consoleRenderLayer;
RenderLayer* mouseLayer;
PostProcessor* glitchPostProcessor;
PostProcessor* warpPostProcessor;
PVector<Window> windows;
std::vector<RenderLayer*> window_render_layers;

#include "gui/layout/vertical.h"
#include "gui/layout/horizontal.h"
GUI_REGISTER_LAYOUT("default", GuiLayout);
GUI_REGISTER_LAYOUT("vertical", GuiLayoutVertical);
GUI_REGISTER_LAYOUT("verticalbottom", GuiLayoutVerticalBottom);
GUI_REGISTER_LAYOUT("horizontal", GuiLayoutHorizontal);
GUI_REGISTER_LAYOUT("horizontalright", GuiLayoutHorizontalRight);


int runProxyServer()
{
    int port = defaultServerPort;
    string password = "";
    int listenPort = defaultServerPort;
    string proxyName = "";
    auto parts = PreferencesManager::get("proxy").split(":");
    string host = parts[0];
    if (parts.size() > 1) port = parts[1].toInt();
    if (parts.size() > 2) password = parts[2].upper();
    if (parts.size() > 3) listenPort = parts[3].toInt();
    if (parts.size() > 4) proxyName = parts[4];
    if (host == "listen")
        new GameServerProxy(password, listenPort, proxyName);
    else
        new GameServerProxy(host, port, password, listenPort, proxyName);
    engine->runMainLoop();
    return 0;
}

int main(int argc, char** argv)
{
#ifdef DEBUG
    Logging::setLogLevel(LOGLEVEL_DEBUG);
#else
    Logging::setLogLevel(LOGLEVEL_INFO);
#endif
#if defined(_WIN32) && !defined(DEBUG)
    Logging::setLogFile("EmptyEpsilon.log");
#else
    Logging::setLogStdout();
#endif
    LOG(Info, "Starting...");
    new Engine();
    initSystemsAndComponents();

    auto configuration_path = initConfiguration(argc, argv);

    if (PreferencesManager::get("proxy") != "")
        return runProxyServer();

    if (PreferencesManager::get("headless") != "") {
        textureManager.setDisabled(true);
        Logging::setLogStdout();
    }

    initResourcePaths();
    textureManager.setDefaultSmooth(true);
    textureManager.setDefaultRepeated(true);
    i18n::load("locale/main." + PreferencesManager::get("language", "en") + ".po");
    keys.init();
    colorConfig.load();

    if (PreferencesManager::get("httpserver").toInt() != 0)
    {
        int port_nr = PreferencesManager::get("httpserver").toInt();
        if (port_nr < 10)
            port_nr = 80;
        LOG(INFO) << "Enabling HTTP script access on port: " << port_nr;
        LOG(INFO) << "NOTE: This is potentially a risk!";
        new EEHttpServer(port_nr, PreferencesManager::get("www_directory", "www"));
    }

    string theme_name = PreferencesManager::get("guitheme", "default");
    if (!GuiTheme::loadTheme(theme_name, "gui/"+theme_name+".theme.txt"))
    {
        LOG(ERROR, "Failed to load "+ theme_name + " theme, trying default. Resources missing or contains errors ? Check gui/" + theme_name + ".theme.txt");
        if (!GuiTheme::loadTheme("default", "gui/default.theme.txt"))
        {
            LOG(ERROR, "Failed to load default theme, exiting. Check gui/default.theme.txt"); //Yes, we may try to load twice default theme but this should be a rare error case which always finish in exit
            SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", "Failed to load gui theme, resources missing or contains errors ? Check gui/default.theme.txt", nullptr);
            return 1;
        }
        GuiTheme::setCurrentTheme("default");
    }
    else
    {
        GuiTheme::setCurrentTheme(theme_name);
    }

    if (PreferencesManager::get("headless") == "")
    {
        if (!createDisplayWindows())
            return 1;
    } else {
        new StdinLuaConsole();
    }

    soundManager->setMusicVolume(PreferencesManager::get("music_volume", "50").toFloat());
    soundManager->setMasterSoundVolume(PreferencesManager::get("sound_volume", "50").toFloat());

    const auto& active_theme = GuiTheme::getCurrentTheme();
    main_font = active_theme->getStyle("base")->get(GuiElement::State::Normal).font;
    bold_font = active_theme->getStyle("bold")->states[0].font;
    if (!main_font || !bold_font)
    {
        LOG(ERROR, "Missing font or bold font.");
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", "Failed to load main or bold font, resources missing?", nullptr);
        return 1;
    }

    sp::RenderTarget::setDefaultFont(main_font);

    // Apply baseline offset adjustments to fonts
    // Positive values move text down, negative values move text up
    main_font->setBaselineOffset(active_theme->getStyle("base")->get(GuiElement::State::Normal).offset);
    bold_font->setBaselineOffset(active_theme->getStyle("base")->get(GuiElement::State::Normal).offset);

    // On Android, this requires the 'record audio' permissions,
    // which is always a scary thing for users.
    // Since there is no way to access it (yet) via a touchscreen, compile out.
#if !defined(ANDROID)
    // Set up voice chat and key bindings.
    NetworkAudioRecorder* nar = new NetworkAudioRecorder();
    nar->addKeyActivation(&keys.voice_all, 0);
    nar->addKeyActivation(&keys.voice_ship, 1);
#endif

    P<HardwareController> hardware_controller = new HardwareController();
    hardware_controller->loadConfiguration(configuration_path + "/hardware.ini");

#if WITH_DISCORD
    {
        std::filesystem::path discord_sdk{
#ifdef RESOURCE_BASE_DIR
        RESOURCE_BASE_DIR
#endif
        };
        discord_sdk /= std::filesystem::path{ "plugins" } / DynamicLibrary::add_native_suffix("discord_game_sdk");
        new DiscordRichPresence(discord_sdk);
    }
#endif // WITH_DISCORD
#if STEAMSDK
    new SteamRichPresence();
#endif //STEAMSDK

    string tutorial = PreferencesManager::get("tutorial");   // use "00_all.lua" for all tutorials
    string server_scenario = PreferencesManager::get("server_scenario");

    if (!tutorial.empty())
    {
        LOG(DEBUG) << "Starting tutorial: " << tutorial;
        new TutorialGame(false, tutorial);
    }
    else if (server_scenario.empty())
        returnToMainMenu(defaultRenderLayer);
    else
    {
        // server_scenario creates a server running the specified scenario
        // using its defined default settings, and launches directly into
        // the ship selection screen instead of the main menu.

        // Create the server to listen on the assigned port.
        // Use the default port if server_port isn't set or has an invalid
        // value (toInt returns 0 if empty or not an int).
        int server_port = PreferencesManager::get("server_port").toInt();

        if (server_port < 10 || server_port > 65535)
        {
            LOG(Warning, "Invalid server_port " + string(server_port));
            server_port = defaultServerPort;
        }

        LOG(Info, "Launching server_scenario " + server_scenario + " on port " + string(server_port));
        new EpsilonServer(server_port);

        if(!gameGlobalInfo) // => failed to start server
            return 1;

        if (PreferencesManager::get("server_name") != "") game_server->setServerName(PreferencesManager::get("server_name"));
        if (PreferencesManager::get("server_password") != "") game_server->setPassword(PreferencesManager::get("server_password").upper());
        if (PreferencesManager::get("server_internet") == "1") game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));

        // Load the scenario and open the ship selection screen.
        gameGlobalInfo->startScenario(server_scenario, loadScenarioSettingsFromPrefs());
        new ShipSelectionScreen();
    }

    engine->runMainLoop();

    // Set FSAA and fullscreen defaults from windowManager.
    if (windows.size() > 0)
    {
        PreferencesManager::set("fsaa", windows[0]->getFSAA());
        PreferencesManager::set("fullscreen", (int)windows[0]->getMode());
    }

    // Set the default music_, sound_, and engine_volume to the current volume.
    PreferencesManager::set("music_volume", soundManager->getMusicVolume());
    PreferencesManager::set("sound_volume", soundManager->getMasterSoundVolume());
    PreferencesManager::set("engine_volume", PreferencesManager::get("engine_volume", "50"));

    // Enable music and engine sounds on the main screen only by default.
    if (PreferencesManager::get("music_enabled").empty())
        PreferencesManager::set("music_enabled", "2");

    if (PreferencesManager::get("engine_enabled").empty())
        PreferencesManager::set("engine_enabled", "2");

    if (PreferencesManager::get("headless") == "")
    {
#ifdef _WIN32
        mkdir(configuration_path.c_str());
#else
        mkdir(configuration_path.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
#endif
        PreferencesManager::save(configuration_path + "/options.ini");
        sp::io::Keybinding::saveKeybindings(configuration_path + "/keybindings.json");
    }
    windows.clear();
    delete engine;

    return 0;
}

void returnToMainMenu(RenderLayer* render_layer)
{
    if (render_layer != defaultRenderLayer) // Handle secondary monitors
    {
        returnToShipSelection(render_layer);
        return;
    }

    string headless = PreferencesManager::get("headless", "");
    if (!headless.empty())
    {
        // Create the server to listen on the assigned port.
        // Use the default port if server_port isn't set or has an invalid
        // value (toInt returns 0).
        int headless_port = PreferencesManager::get("server_port").toInt();
        // This is the same process as server_port and could be made DRY.
        if (headless_port < 10 || headless_port > 65535)
        {
            LOG(Warning, "Invalid server_port: " + string(headless_port));
            headless_port = defaultServerPort;
        }

        LOG(Info, "Launching headless scenario " + headless + " on port " + string(headless_port));
        new EpsilonServer(headless_port);

        if (PreferencesManager::get("headless_name") != "") game_server->setServerName(PreferencesManager::get("headless_name"));
        if (PreferencesManager::get("headless_password") != "") game_server->setPassword(PreferencesManager::get("headless_password").upper());
        if (PreferencesManager::get("headless_internet") == "1") game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));
        gameGlobalInfo->startScenario(headless, loadScenarioSettingsFromPrefs());

        if (PreferencesManager::get("startpaused") != "1")
            engine->setGameSpeed(1.0);
    }
    else if (!PreferencesManager::get("autoconnect").empty())
    {
        auto value = PreferencesManager::get("autoconnect");

        std::vector<AutoConnectPosition> window_positions;
        for (auto part : value.split(";"))
            window_positions.push_back(AutoConnectPosition(part));

        new AutoConnectScreen(window_positions, PreferencesManager::get("autocontrolmainscreen").toInt(), PreferencesManager::get("autoconnectship", "solo"));
    }
    else
    {
        new MainMenu();
    }
}

void returnToShipSelection(RenderLayer* render_layer)
{
    if (render_layer != defaultRenderLayer)
    {
        for(size_t n=0; n<window_render_layers.size(); n++)
            if (window_render_layers[n] == render_layer)
                new SecondMonitorScreen(n);
    } else {
        if (PreferencesManager::get("autoconnect") != "")
        {
            //If we are auto connect, return to the auto connect screen instead of the ship selection. The returnToMainMenu will handle this.
            returnToMainMenu(render_layer);
        }
        else
        {
            new ShipSelectionScreen();
        }
    }
}

void returnToOptionMenu(OptionsMenu::ReturnTo return_to)
{
    new OptionsMenu(return_to);
}

std::unordered_map<string, string> loadScenarioSettingsFromPrefs()
{
    string preferenceValue = PreferencesManager::get("scenario_settings");

    std::unordered_map<string, string> settings = {};
    if (preferenceValue == "")
        return settings;

    for(string setting : preferenceValue.split(";"))
    {
        auto [key, value] = setting.partition("=");
        if (!key.empty() && !value.empty())
            settings[key.strip()] = value.strip();
    }

    return settings;
}

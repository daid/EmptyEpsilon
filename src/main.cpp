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
#include "graphics/freetypefont.h"
#include "gui/mouseRenderer.h"
#include "gui/debugRenderer.h"
#include "gui/colorConfig.h"
#include "gui/theme.h"
#include "gui/hotkeyConfig.h"
#include "gui/joystickConfig.h"
#include "menus/mainMenus.h"
#include "menus/autoConnectScreen.h"
#include "menus/shipSelectionScreen.h"
#include "menus/optionsMenu.h"
#include "menus/luaConsole.h"
#include "factionInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceObject.h"
#include "packResourceProvider.h"
#include "main.h"
#include "epsilonServer.h"
#include "httpScriptAccess.h"
#include "preferenceManager.h"
#include "networkRecorder.h"
#include "tutorialGame.h"
#include "windowManager.h"

#include "graphics/opengl.h"

#include "hardware/hardwareController.h"
#if WITH_DISCORD
#include "discord.h"
#endif
#if STEAMSDK
#include "steam/steam_api.h"
#include "steamrichpresence.h"
#endif

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#include <mach-o/dyld.h>
#include <libgen.h>
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

int main(int argc, char** argv)
{
#ifdef __APPLE__
    // TODO: Find a proper solution.
    // Seems to be non-NULL even outside of a proper bundle.
    CFBundleRef bundle = CFBundleGetMainBundle();
    if (bundle)
    {
        char bundle_path[PATH_MAX], exe_path[PATH_MAX];

        CFURLRef bundleURL = CFBundleCopyBundleURL(bundle);
        CFURLGetFileSystemRepresentation(bundleURL, true, (unsigned char*)bundle_path, PATH_MAX);
        CFRelease(bundleURL);

        uint32_t size = sizeof(exe_path);
        if (_NSGetExecutablePath(exe_path, &size) != 0)
        {
          fprintf(stderr, "Failed to get executable path.\n");
          return 1;
        }

        char *exe_realpath = realpath(exe_path, NULL);
        char *exe_dir      = dirname(exe_realpath);

        if (strcmp(exe_dir, bundle_path))
        {
          char resources_path[PATH_MAX];

          CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(bundle);
          CFURLGetFileSystemRepresentation(resourcesURL, true, (unsigned char*)resources_path, PATH_MAX);
          CFRelease(resourcesURL);

          chdir(resources_path);
        }
        else
        {
          chdir(exe_dir);
        }

        free(exe_realpath);
        free(exe_dir);
    }
#endif

#ifdef DEBUG
    Logging::setLogLevel(LOGLEVEL_DEBUG);
#else
    Logging::setLogLevel(LOGLEVEL_INFO);
#endif
#if defined(_WIN32) && !defined(DEBUG)
    Logging::setLogFile("EmptyEpsilon.log");
#endif
    LOG(Info, "Starting...");
    new Engine();
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

    if (PreferencesManager::get("proxy") != "")
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

    if (PreferencesManager::get("headless") != "")
        textureManager.setDisabled(true);

    if (PreferencesManager::get("mod") != "")
    {
        string mod = PreferencesManager::get("mod");
        if (getenv("HOME"))
        {
            new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/resources/mods/" + mod);
            PackResourceProvider::addPackResourcesForDirectory(string(getenv("HOME")) + "/.emptyepsilon/resources/mods/" + mod);
        }
        new DirectoryResourceProvider("resources/mods/" + mod);
        PackResourceProvider::addPackResourcesForDirectory("resources/mods/" + mod);
    }

    new DirectoryResourceProvider("resources/");
    new DirectoryResourceProvider("scripts/");
    PackResourceProvider::addPackResourcesForDirectory("packs/");
    if (getenv("HOME"))
    {
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/resources/");
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/scripts/");
        PackResourceProvider::addPackResourcesForDirectory(string(getenv("HOME")) + "/.emptyepsilon/packs/");
    }
#ifdef RESOURCE_BASE_DIR
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "resources/");
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "scripts/");
    PackResourceProvider::addPackResourcesForDirectory(RESOURCE_BASE_DIR "packs");
#endif
    textureManager.setDefaultSmooth(true);
    textureManager.setDefaultRepeated(true);
    i18n::load("locale/main." + PreferencesManager::get("language", "en") + ".po");

    if (PreferencesManager::get("httpserver").toInt() != 0)
    {
        int port_nr = PreferencesManager::get("httpserver").toInt();
        if (port_nr < 10)
            port_nr = 80;
        LOG(INFO) << "Enabling HTTP script access on port: " << port_nr;
        LOG(INFO) << "NOTE: This is potentially a risk!";
        new EEHttpServer(port_nr, PreferencesManager::get("www_directory", "www"));
    }

    colorConfig.load();
    sp::io::Keybinding::loadKeybindings(configuration_path + "/keybindings.json");
    keys.init();

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

    //For now there is only one named theme : default.
    string theme_name = PreferencesManager::get("guitheme", "default");
    if (!GuiTheme::loadTheme(theme_name, "gui/" + theme_name +".theme.txt"))
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
        //Setup the rendering layers.
        defaultRenderLayer = new RenderLayer();
        consoleRenderLayer = new RenderLayer(defaultRenderLayer);
        mouseLayer = new RenderLayer(consoleRenderLayer);
        glitchPostProcessor = new PostProcessor("shaders/glitch", mouseLayer);
        glitchPostProcessor->enabled = false;
        warpPostProcessor = new PostProcessor("shaders/warp", glitchPostProcessor);
        warpPostProcessor->enabled = false;

        new LuaConsole();

        int width = 1200;
        int height = 900;
        int fsaa = 0;
        Window::Mode fullscreen = (Window::Mode)PreferencesManager::get("fullscreen", "1").toInt();

        if (PreferencesManager::get("fsaa").toInt() > 0)
        {
            fsaa = PreferencesManager::get("fsaa").toInt();
            if (fsaa < 2)
                fsaa = 2;
        }

#ifndef ANDROID
        if (PreferencesManager::get("touchscreen").toInt() == 0)
        {
            engine->registerObject("mouseRenderer", new MouseRenderer(mouseLayer));
        }
#endif

        windows.push_back(new Window({width, height}, fullscreen, warpPostProcessor, fsaa));
        window_render_layers.push_back(defaultRenderLayer);

        if (PreferencesManager::get("multimonitor", "0").toInt() != 0)
        {
            while(int(windows.size()) < SDL_GetNumVideoDisplays())
            {
                auto wrl = new RenderLayer();
                auto ml = new RenderLayer(wrl);
                new MouseRenderer(ml);
                windows.push_back(new Window({width, height}, fullscreen, ml, fsaa));
                window_render_layers.push_back(wrl);
                new SecondMonitorScreen(windows.size() - 1);
            }
        }

#if defined(DEBUG)
        // Synchronous gl debug output always in debug.
        constexpr bool wants_gl_debug = true;
        constexpr bool wants_gl_debug_synchronous = true;
#else
        auto wants_gl_debug = !PreferencesManager::get("gl_debug").empty();
        auto wants_gl_debug_synchronous = !PreferencesManager::get("gl_debug_synchronous").empty();
#endif
        if (wants_gl_debug)
        {
            if (sp::gl::enableDebugOutput(wants_gl_debug_synchronous))
                LOG(INFO, "GL Debug output enabled.");
            else
                LOG(WARNING, "GL Debug output requested but not available on this system.");
        }

        for(size_t n=0; n<windows.size(); n++)
        {
            P<Window> window = windows[n];
            string postfix = "";
            if (n > 0)
                postfix = " - " + string(int(n));
            if (PreferencesManager::get("instance_name") != "")
                window->setTitle("EmptyEpsilon - " + PreferencesManager::get("instance_name") + postfix);
            else
                window->setTitle("EmptyEpsilon" + postfix);
        }

        if (gl::isAvailable())
        {
            if (!ShaderRegistry::Shader::initialize())
            {
                LOG(ERROR, "Failed to initialize shaders, exiting.");
                SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", "Failed to initialize shaders (possible cause: cannot find shader files)", nullptr);
                return 1;
            }
        }
    }

    new DebugRenderer(mouseLayer);

    soundManager->setMusicVolume(PreferencesManager::get("music_volume", "50").toFloat());
    soundManager->setMasterSoundVolume(PreferencesManager::get("sound_volume", "50").toFloat());

    main_font = GuiTheme::getCurrentTheme()->getStyle("base")->states[0].font;
    bold_font = GuiTheme::getCurrentTheme()->getStyle("bold")->states[0].font;
    if (!main_font || !bold_font)
    {
        LOG(ERROR, "Missing font or bold font.");
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", "Failed to load main or bold font, resources missing?", nullptr);
        return 1;
    }

    sp::RenderTarget::setDefaultFont(main_font);

    {
        P<ScriptObject> modelDataScript = new ScriptObject("model_data.lua");
        if (modelDataScript->getError() != "") exit(1);
        modelDataScript->destroy();

        P<ScriptObject> shipTemplatesScript = new ScriptObject("shipTemplates.lua");
        if (shipTemplatesScript->getError() != "") exit(1);
        shipTemplatesScript->destroy();

        //Find out which model data isn't used by ship templates and output that to log.
        std::set<string> used_model_data;
        for(string template_name : ShipTemplate::getAllTemplateNames())
            used_model_data.insert(ShipTemplate::getTemplate(template_name)->model_data->getName());
        for(string name : ModelData::getModelDataNames())
        {
            if (used_model_data.find(name) == used_model_data.end())
            {
                LOG(INFO) << "Model data: " << name << " is not used by any ship template";
            }
        }
    }

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
        std::filesystem::path discord_sdk
        {
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

    if (PreferencesManager::get("server_scenario") == "")
        returnToMainMenu(defaultRenderLayer);
    else
    {
        // server_scenario creates a server running the specified scenario
        // using its defined default settings, and launches directly into
        // the ship selection screen instead of the main menu.

        // Create the server.
        new EpsilonServer(defaultServerPort);

        if(!gameGlobalInfo) // => failed to start server
            return 1;

        // Load the scenario and open the ship selection screen.
        gameGlobalInfo->startScenario(PreferencesManager::get("server_scenario"), loadScenarioSettingsFromPrefs());
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

    if (PreferencesManager::get("headless") != "")
    {
        new EpsilonServer(defaultServerPort);
        if (PreferencesManager::get("headless_name") != "") game_server->setServerName(PreferencesManager::get("headless_name"));
        if (PreferencesManager::get("headless_password") != "") game_server->setPassword(PreferencesManager::get("headless_password").upper());
        if (PreferencesManager::get("headless_internet") == "1") game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));
        gameGlobalInfo->startScenario(PreferencesManager::get("headless"), loadScenarioSettingsFromPrefs());

        if (PreferencesManager::get("startpaused") != "1")
            engine->setGameSpeed(1.0);
    }
    else if (PreferencesManager::get("autoconnect").toInt())
    {
        int crew_position = PreferencesManager::get("autoconnect").toInt() - 1;
        if (crew_position < 0) crew_position = 0;
        if (crew_position > max_crew_positions) crew_position = max_crew_positions;
        new AutoConnectScreen(ECrewPosition(crew_position), PreferencesManager::get("autocontrolmainscreen").toInt(), PreferencesManager::get("autoconnectship", "solo"));
    }
    else if (PreferencesManager::get("tutorial").toInt())
    {
        new TutorialGame(true);
    }else{
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
        if (PreferencesManager::get("autoconnect").toInt())
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

void returnToOptionMenu()
{
    new OptionsMenu();
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

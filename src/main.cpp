#include <memory>
#include <set>
#include <string.h>
#include <i18n.h>
#include <multiplayer_proxy.h>
#ifndef _MSC_VER
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
#include "gui/hotkeyConfig.h"
#include "gui/joystickConfig.h"
#include "menus/mainMenus.h"
#include "menus/autoConnectScreen.h"
#include "menus/shipSelectionScreen.h"
#include "menus/optionsMenu.h"
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
RenderLayer* mouseLayer;
PostProcessor* glitchPostProcessor;
PostProcessor* warpPostProcessor;
P<Window> main_window;

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
#ifdef CONFIG_DIR
    PreferencesManager::load(CONFIG_DIR "options.ini");
#endif
    if (getenv("HOME"))
        PreferencesManager::load(string(getenv("HOME")) + "/.emptyepsilon/options.ini");
    else
        PreferencesManager::load("options.ini");

    for(int n=1; n<argc; n++)
    {
        char* value = strchr(argv[n], '=');
        if (!value) continue;
        *value++ = '\0';
        PreferencesManager::set(string(argv[n]).strip(), string(value).strip());
    }

    new Engine();

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
    sp::io::Keybinding::loadKeybindings("keybindings.json");
    keys.init();

    if (PreferencesManager::get("username", "") == "")
    {
        if (getenv("USERNAME"))
            PreferencesManager::set("username", getenv("USERNAME"));
        else if (getenv("USER"))
            PreferencesManager::set("username", getenv("USER"));
    }

    if (PreferencesManager::get("headless") == "")
    {
        //Setup the rendering layers.
        defaultRenderLayer = new RenderLayer();
        mouseLayer = new RenderLayer(defaultRenderLayer);
        glitchPostProcessor = new PostProcessor("shaders/glitch", mouseLayer);
        glitchPostProcessor->enabled = false;
        warpPostProcessor = new PostProcessor("shaders/warp", glitchPostProcessor);
        warpPostProcessor->enabled = false;

        int width = 1200;
        int height = 900;
        int fsaa = 0;
        bool fullscreen = PreferencesManager::get("fullscreen", "1").toInt();

        if (PreferencesManager::get("fsaa").toInt() > 0)
        {
            fsaa = PreferencesManager::get("fsaa").toInt();
            if (fsaa < 2)
                fsaa = 2;
        }

        main_window = new Window({width, height}, fullscreen, warpPostProcessor, fsaa);
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

        if (PreferencesManager::get("instance_name") != "")
            main_window->setTitle("EmptyEpsilon - " + PreferencesManager::get("instance_name"));
        else
            main_window->setTitle("EmptyEpsilon");

        if (gl::isAvailable())
        {
            ShaderRegistry::Shader::initialize();
        }
    }
    if (PreferencesManager::get("touchscreen").toInt() == 0)
    {
        engine->registerObject("mouseRenderer", new MouseRenderer());
    }

    new DebugRenderer();

    soundManager->setMusicVolume(PreferencesManager::get("music_volume", "50").toFloat());
    soundManager->setMasterSoundVolume(PreferencesManager::get("sound_volume", "50").toFloat());

    P<ResourceStream> main_font_stream = getResourceStream(PreferencesManager::get("font_regular", "gui/fonts/BigShouldersDisplay-SemiBold.ttf"));
    main_font = new sp::FreetypeFont(main_font_stream);

    P<ResourceStream> bold_font_stream = getResourceStream(PreferencesManager::get("font_bold", "gui/fonts/BigShouldersDisplay-ExtraBold.ttf"));
    bold_font = new sp::FreetypeFont(bold_font_stream);

    sp::RenderTarget::setDefaultFont(main_font);

    {
        P<ScriptObject> modelDataScript = new ScriptObject("model_data.lua");
        if (modelDataScript->getError() != "") exit(1);
        modelDataScript->destroy();

        P<ScriptObject> shipTemplatesScript = new ScriptObject("shipTemplates.lua");
        if (shipTemplatesScript->getError() != "") exit(1);
        shipTemplatesScript->destroy();

        P<ScriptObject> factionInfoScript = new ScriptObject("factionInfo.lua");
        if (factionInfoScript->getError() != "") exit(1);
        factionInfoScript->destroy();

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
#ifdef CONFIG_DIR
    hardware_controller->loadConfiguration(CONFIG_DIR "hardware.ini");
#endif
    if (getenv("HOME"))
        hardware_controller->loadConfiguration(string(getenv("HOME")) + "/.emptyepsilon/hardware.ini");
    else
        hardware_controller->loadConfiguration("hardware.ini");

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

    returnToMainMenu();
    engine->runMainLoop();

    // Set FSAA and fullscreen defaults from windowManager.
    
    if (P<Window> window = main_window; window)
    {
        PreferencesManager::set("fsaa", window->getFSAA());
        PreferencesManager::set("fullscreen", window->isFullscreen() ? 1 : 0);
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
#ifndef _MSC_VER
        // MFC TODO: Fix me -- save prefs to user prefs dir on Windows.
        if (getenv("HOME"))
        {
#ifdef _WIN32
            mkdir((string(getenv("HOME")) + "/.emptyepsilon").c_str());
#else
            mkdir((string(getenv("HOME")) + "/.emptyepsilon").c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
#endif
            PreferencesManager::save(string(getenv("HOME")) + "/.emptyepsilon/options.ini");
        }else
#endif
        {
            PreferencesManager::save("options.ini");
        }
        sp::io::Keybinding::saveKeybindings("keybindings.json");
    }
    main_window = nullptr;
    delete engine;

    return 0;
}

void returnToMainMenu()
{
    if (PreferencesManager::get("headless") != "")
    {
        new EpsilonServer();
        if (PreferencesManager::get("headless_name") != "") game_server->setServerName(PreferencesManager::get("headless_name"));
        if (PreferencesManager::get("headless_password") != "") game_server->setPassword(PreferencesManager::get("headless_password").upper());
        if (PreferencesManager::get("headless_internet") == "1") game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));
        gameGlobalInfo->startScenario(PreferencesManager::get("headless"));

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

void returnToShipSelection()
{
    if (PreferencesManager::get("autoconnect").toInt())
    {
        //If we are auto connect, return to the auto connect screen instead of the ship selection. The returnToMainMenu will handle this.
        returnToMainMenu();
    }
    else
    {
        new ShipSelectionScreen();
    }
}

void returnToOptionMenu()
{
    new OptionsMenu();
}

#include <string.h>
#ifndef _MSC_VER
#include <unistd.h>
#include <sys/stat.h>
#endif
#include <sys/types.h>
#include "gui/mouseRenderer.h"
#include "gui/debugRenderer.h"
#include "gui/colorConfig.h"
#include "gui/hotkeyConfig.h"
#include "menus/mainMenus.h"
#include "menus/autoConnectScreen.h"
#include "menus/shipSelectionScreen.h"
#include "menus/optionsMenu.h"
#include "mouseCalibrator.h"
#include "factionInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceObject.h"
#include "packResourceProvider.h"
#include "scienceDatabase.h"
#include "main.h"
#include "epsilonServer.h"
#include "httpScriptAccess.h"
#include "preferenceManager.h"
#include "networkRecorder.h"
#include "tutorialGame.h"

#include "hardware/hardwareController.h"

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#include <mach-o/dyld.h>
#include <libgen.h>
#endif

sf::Vector3f camera_position;
float camera_yaw;
float camera_pitch;
sf::Font* main_font;
sf::Font* bold_font;
RenderLayer* backgroundLayer;
RenderLayer* objectLayer;
RenderLayer* effectLayer;
RenderLayer* hudLayer;
RenderLayer* mouseLayer;
PostProcessor* glitchPostProcessor;
PostProcessor* warpPostProcessor;

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
#if defined(__WIN32__) && !defined(DEBUG)
    Logging::setLogFile("EmptyEpsilon.log");
#endif
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

#ifdef RESOURCE_BASE_DIR
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "resources/");
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "scripts/");
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "packs/SolCommand/");
    PackResourceProvider::addPackResourcesForDirectory(RESOURCE_BASE_DIR "packs");
#endif
    if (getenv("HOME"))
    {
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/resources/");
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/scripts/");
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/packs/SolCommand/");
    }
    new DirectoryResourceProvider("resources/");
    new DirectoryResourceProvider("scripts/");
    new DirectoryResourceProvider("packs/SolCommand/");
    PackResourceProvider::addPackResourcesForDirectory("packs");
    textureManager.setDefaultSmooth(true);
    textureManager.setDefaultRepeated(true);
    textureManager.setAutoSprite(false);
    textureManager.getTexture("Tokka_WalkingMan.png", sf::Vector2i(6, 1)); //Setup the sprite mapping.

    if (PreferencesManager::get("httpserver").toInt() != 0)
    {
        int port_nr = PreferencesManager::get("httpserver").toInt();
        if (port_nr < 10)
            port_nr = 80;
        LOG(INFO) << "Enabling HTTP script access on port: " << port_nr;
        LOG(INFO) << "NOTE: This is potentially a risk!";
        HttpServer* server = new HttpServer(port_nr);
        server->addHandler(new HttpRequestFileHandler("www"));
        server->addHandler(new HttpScriptHandler());
    }

    colorConfig.load();
    hotkeys.load();

    if (PreferencesManager::get("headless") == "")
    {
        //Setup the rendering layers.
        backgroundLayer = new RenderLayer();
        objectLayer = new RenderLayer(backgroundLayer);
        effectLayer = new RenderLayer(objectLayer);
        hudLayer = new RenderLayer(effectLayer);
        mouseLayer = new RenderLayer(hudLayer);
        glitchPostProcessor = new PostProcessor("glitch", mouseLayer);
        glitchPostProcessor->enabled = false;
        warpPostProcessor = new PostProcessor("warp", glitchPostProcessor);
        warpPostProcessor->enabled = false;
        defaultRenderLayer = objectLayer;

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
        P<WindowManager> window_manager = new WindowManager(width, height, fullscreen, warpPostProcessor, fsaa);
        window_manager->setAllowVirtualResize(true);
        engine->registerObject("windowManager", window_manager);
    }
    if (PreferencesManager::get("touchscreen").toInt())
    {
        InputHandler::touch_screen = true;
    }
    if (!InputHandler::touch_screen)
    {
        engine->registerObject("mouseRenderer", new MouseRenderer());
    }

    new DebugRenderer();

    if (PreferencesManager::get("touchcalibfile") != "")
    {
        FILE* f = fopen(PreferencesManager::get("touchcalibfile").c_str(), "r");
        if (f)
        {
            float m[6];
            if (fscanf(f, "%f %f %f %f %f %f", &m[0], &m[1], &m[2], &m[3], &m[4], &m[5]) == 6)
                InputHandler::mouse_transform = sf::Transform(m[0], m[1], m[2], m[3], m[4], m[5], 0, 0, 1);
            fclose(f);
        }
    }

    soundManager->setMusicVolume(PreferencesManager::get("music_volume", "50").toFloat());
    soundManager->setMasterSoundVolume(PreferencesManager::get("sound_volume", "50").toFloat());

    if (PreferencesManager::get("disable_shaders").toInt())
        PostProcessor::setEnable(false);

    P<ResourceStream> main_font_stream = getResourceStream("gui/fonts/BebasNeue Regular.otf");
    main_font = new sf::Font();
    main_font->loadFromStream(**main_font_stream);

    P<ResourceStream> bold_font_stream = getResourceStream("gui/fonts/BebasNeue Bold.otf");
    bold_font = new sf::Font();
    bold_font->loadFromStream(**bold_font_stream);

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

        fillDefaultDatabaseData();

        P<ScriptObject> scienceInfoScript = new ScriptObject("science_db.lua");
        if (scienceInfoScript->getError() != "") exit(1);
        scienceInfoScript->destroy();

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

    P<HardwareController> hardware_controller = new HardwareController();
#ifdef CONFIG_DIR
    hardware_controller->loadConfiguration(CONFIG_DIR "hardware.ini");
#endif
    if (getenv("HOME"))
        hardware_controller->loadConfiguration(string(getenv("HOME")) + "/.emptyepsilon/hardware.ini");
    else
        hardware_controller->loadConfiguration("hardware.ini");

    returnToMainMenu();
    engine->runMainLoop();

    // Set FSAA and fullscreen defaults from windowManager.
    P<WindowManager> windowManager = engine->getObject("windowManager");
    if (windowManager)
    {
        PreferencesManager::set("fsaa", windowManager->getFSAA());
        PreferencesManager::set("fullscreen", windowManager->isFullscreen() ? 1 : 0);
    }

    // Set the default music_volume and sound_volume to the current volume.
    PreferencesManager::set("music_volume", soundManager->getMusicVolume());
    PreferencesManager::set("sound_volume", soundManager->getMasterSoundVolume());

    // Enable music on the main screen only by default.
    if (PreferencesManager::get("music_enabled").empty())
        PreferencesManager::set("music_enabled", "2");

    // Set shaders to default.
    PreferencesManager::set("disable_shaders", PostProcessor::isEnabled() ? 0 : 1);

    if (PreferencesManager::get("headless") == "")
    {
#ifndef _MSC_VER
		// MFC TODO: Fix me -- save prefs to user prefs dir on Windows.
        if (getenv("HOME"))
        {
#ifdef __WIN32__
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
    }

    delete engine;

    return 0;
}

void returnToMainMenu()
{
    if (PreferencesManager::get("headless") != "")
    {
        new EpsilonServer();
        if (PreferencesManager::get("headless_name") != "") game_server->setServerName(PreferencesManager::get("headless_name"));
        if (PreferencesManager::get("headless_password") != "") game_server->setPassword(PreferencesManager::get("headless_password"));
        if (PreferencesManager::get("headless_internet") == "1") game_server->registerOnMasterServer("http://daid.eu/ee/register.php");
        if (PreferencesManager::get("variation") != "") gameGlobalInfo->variation = PreferencesManager::get("variation");
        gameGlobalInfo->startScenario(PreferencesManager::get("headless"));

        engine->setGameSpeed(1.0);
    }
    else if (PreferencesManager::get("autoconnect").toInt())
    {
        int crew_position = PreferencesManager::get("autoconnect").toInt() - 1;
        if (crew_position < 0) crew_position = 0;
        if (crew_position > max_crew_positions) crew_position = max_crew_positions;
        new AutoConnectScreen(ECrewPosition(crew_position), PreferencesManager::get("autocontrolmainscreen").toInt(), PreferencesManager::get("autoconnectship", "solo"));
    }
    else if (PreferencesManager::get("touchcalib").toInt())
    {
        new MouseCalibrator(PreferencesManager::get("touchcalibfile"));
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

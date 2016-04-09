#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "gui/mouseRenderer.h"
#include "gui/debugRenderer.h"
#include "gui/colorConfig.h"
#include "menus/mainMenus.h"
#include "menus/autoConnectScreen.h"
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

#include "hardware/hardwareController.h"

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#include <mach-o/dyld.h>
#include <libgen.h>
#endif

#ifdef __linux__
#ifndef INSTALL_PREFIX
#define INSTALL_PREFIX "/usr/local"
#endif
#define RESOURCE_BASE_DIR INSTALL_PREFIX "/share/emptyepsilon/"
#endif

sf::Vector3f camera_position;
float camera_yaw;
float camera_pitch;
sf::Shader* objectShader;
sf::Shader* simpleObjectShader;
sf::Shader* basicShader;
sf::Shader* billboardShader;
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
#endif
#ifdef RESOURCE_BASE_DIR
    PreferencesManager::load(RESOURCE_BASE_DIR "options.ini");
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
#ifdef RESOURCE_BASE_DIR
        new DirectoryResourceProvider(RESOURCE_BASE_DIR "resources/mods/" + mod);
#endif
        if (getenv("HOME"))
            new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/resources/mods/" + mod);
        new DirectoryResourceProvider("resources/mods/" + mod);
    }
    
#ifdef RESOURCE_BASE_DIR
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "resources/");
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "scripts/");
    new DirectoryResourceProvider(RESOURCE_BASE_DIR "packs/SolCommand/");
    new PackResourceProvider(RESOURCE_BASE_DIR "packs/Angryfly.pack");
    new PackResourceProvider(RESOURCE_BASE_DIR "packs/msgamedev.pack");
#endif
    if (getenv("HOME"))
    {
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/resources/");
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/scripts/");
        new DirectoryResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/packs/SolCommand/");
        new PackResourceProvider(string(getenv("HOME")) + "/.emptyepsilon/packs/SolCommand/");
    }
    new DirectoryResourceProvider("resources/");
    new DirectoryResourceProvider("scripts/");
    new DirectoryResourceProvider("packs/SolCommand/");
    new PackResourceProvider("packs/Angryfly.pack");
    new PackResourceProvider("packs/msgamedev.pack");
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

    if (PreferencesManager::get("disable_shaders").toInt())
        PostProcessor::setEnable(false);

    P<ResourceStream> main_font_stream = getResourceStream("gui/fonts/BebasNeue Regular.otf");
    main_font = new sf::Font();
    main_font->loadFromStream(**main_font_stream);
    
    P<ResourceStream> bold_font_stream = getResourceStream("gui/fonts/BebasNeue Bold.otf");
    bold_font = new sf::Font();
    bold_font->loadFromStream(**bold_font_stream);

    if (sf::Shader::isAvailable())
    {
        objectShader = new sf::Shader();
        simpleObjectShader = new sf::Shader();
        basicShader = new sf::Shader();
        billboardShader = new sf::Shader();

        P<ResourceStream> vertexStream = getResourceStream("objectShader.vert");
        P<ResourceStream> fragmentStream = getResourceStream("objectShader.frag");
        objectShader->loadFromStream(**vertexStream, **fragmentStream);
        vertexStream = getResourceStream("simpleObjectShader.vert");
        fragmentStream = getResourceStream("simpleObjectShader.frag");
        simpleObjectShader->loadFromStream(**vertexStream, **fragmentStream);
        vertexStream = getResourceStream("basicShader.vert");
        fragmentStream = getResourceStream("basicShader.frag");
        basicShader->loadFromStream(**vertexStream, **fragmentStream);
        vertexStream = getResourceStream("billboardShader.vert");
        fragmentStream = getResourceStream("billboardShader.frag");
        billboardShader->loadFromStream(**vertexStream, **fragmentStream);
    }

    {
        P<ScriptObject> modelDataScript = new ScriptObject("model_data.lua");
        if (modelDataScript)
            modelDataScript->destroy();

        P<ScriptObject> shipTemplatesScript = new ScriptObject("shipTemplates.lua");
        if (shipTemplatesScript)
            shipTemplatesScript->destroy();

        P<ScriptObject> factionInfoScript = new ScriptObject("factionInfo.lua");
        if (factionInfoScript)
            factionInfoScript->destroy();

        fillDefaultDatabaseData();

        P<ScriptObject> scienceInfoScript = new ScriptObject("science_db.lua");
        if (scienceInfoScript)
            scienceInfoScript->destroy();
        
        //Find out which model data isn't used by ship templates and output that to log.
        std::set<string> used_model_data;
        for(string template_name : ShipTemplate::getTemplateNameList())
        {
            used_model_data.insert(ShipTemplate::getTemplate(template_name)->model_data->getName());
        }
        for(string name : ModelData::getModelDataNames())
        {
            if (used_model_data.find(name) == used_model_data.end())
            {
                LOG(INFO) << "Model data: " << name << " is not used by any ship template";
            }
        }
    }

    P<HardwareController> hardware_controller = new HardwareController();
#ifdef RESOURCE_BASE_DIR
    hardware_controller->loadConfiguration(RESOURCE_BASE_DIR "hardware.ini");
#endif
    if (getenv("HOME"))
        hardware_controller->loadConfiguration(string(getenv("HOME")) + "/.emptyepsilon/hardware.ini");
    else
        hardware_controller->loadConfiguration("hardware.ini");

    returnToMainMenu();
    engine->runMainLoop();

    P<WindowManager> windowManager = engine->getObject("windowManager");
    if (windowManager)
    {
        PreferencesManager::set("fsaa", windowManager->getFSAA());
        PreferencesManager::set("fullscreen", windowManager->isFullscreen() ? 1 : 0);
    }
    PreferencesManager::set("music_volume", soundManager->getMusicVolume());
    PreferencesManager::set("disable_shaders", PostProcessor::isEnabled() ? 0 : 1);

    if (PreferencesManager::get("headless") == "")
    {
        if (getenv("HOME"))
        {
#ifdef __WIN32__
            mkdir((string(getenv("HOME")) + "/.emptyepsilon").c_str());
#else
            mkdir((string(getenv("HOME")) + "/.emptyepsilon").c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
#endif
            PreferencesManager::save(string(getenv("HOME")) + "/.emptyepsilon/options.ini");
        }else{
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
        gameGlobalInfo->startScenario(PreferencesManager::get("headless"));
        engine->setGameSpeed(1.0);
    }
    else if (PreferencesManager::get("autoconnect").toInt())
    {
        int crew_position = PreferencesManager::get("autoconnect").toInt() - 1;
        if (crew_position < 0) crew_position = 0;
        if (crew_position > max_crew_positions) crew_position = max_crew_positions;
        new AutoConnectScreen(ECrewPosition(crew_position), PreferencesManager::get("autocontrolmainscreen").toInt(), PreferencesManager::get("autoconnectship", "-1").toInt());
    }
    else if (PreferencesManager::get("touchcalib").toInt())
    {
        new MouseCalibrator(PreferencesManager::get("touchcalibfile"));
    }else{
        new MainMenu();
    }
}

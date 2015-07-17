#include <string.h>
#include "gui/mouseRenderer.h"
#include "gui/debugRenderer.h"
#include "menus/mainMenus.h"
#include "mouseCalibrator.h"
#include "factionInfo.h"
#include "spaceObjects/spaceObject.h"
#include "packResourceProvider.h"
#include "scienceDatabase.h"
#include "main.h"
#include "epsilonServer.h"
#include "httpScriptAccess.h"
#include "preferenceManager.h"

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#endif

sf::Vector3f camera_position;
float camera_yaw;
float camera_pitch;
sf::Shader* objectShader;
sf::Shader* simpleObjectShader;
sf::Shader* basicShader;
sf::Shader* billboardShader;
sf::Font* mainFont;
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
    CFBundleRef bundle = CFBundleGetMainBundle();
    if (bundle)
    {
        CFURLRef url = CFBundleCopyResourcesDirectoryURL(bundle);
        char path[PATH_MAX];
        CFURLGetFileSystemRepresentation(url, true, (unsigned char*)path, PATH_MAX);
        chdir(path);
        CFRelease(url);
    }
#endif

#ifdef DEBUG
    Logging::setLogLevel(LOGLEVEL_DEBUG);
#endif
    PreferencesManager::load("options.ini");
    
    for(int n=1; n<argc; n++)
    {
        char* value = strchr(argv[n], '=');
        if (!value) continue;
        *value++ = '\0';
        PreferencesManager::set(string(argv[n]).strip(), string(value).strip());
    }
    
    new Engine();
    new DirectoryResourceProvider("resources/");
    new DirectoryResourceProvider("scripts/");
    new DirectoryResourceProvider("packs/SolCommand/");
    new PackResourceProvider("packs/Angryfly.pack");
    textureManager.setDefaultSmooth(true);
    textureManager.setDefaultRepeated(true);
    textureManager.setAutoSprite(false);
    textureManager.getTexture("Tokka_WalkingMan.png", sf::Vector2i(6, 1));
    
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

        int width = 1600;
        int height = 900;
        int fsaa = 0;
        bool fullscreen = PreferencesManager::get("fullscreen", "1").toInt();

        sf::VideoMode desktop = sf::VideoMode::getDesktopMode();
        if (desktop.height / 3 * 4 == desktop.width || PreferencesManager::get("screen43").toInt() != 0)
        {
            width = height / 3 * 4;
        }else{
            width = height * desktop.width / desktop.height;
            if (width < height / 3 * 4)
                width = height / 3 * 4;
        }
        if (PreferencesManager::get("fsaa").toInt() > 0)
        {
            fsaa = PreferencesManager::get("fsaa").toInt();
            if (fsaa < 2)
                fsaa = 2;
        }
        engine->registerObject("windowManager", new WindowManager(width, height, fullscreen, warpPostProcessor, fsaa));
    }
    if (PreferencesManager::get("touchscreen").toInt())
    {
        InputHandler::touch_screen = true;
    }else{
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

    P<ResourceStream> stream = getResourceStream("sansation.ttf");
    mainFont = new sf::Font();
    mainFont->loadFromStream(**stream);

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
    }
    
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

    PreferencesManager::save("options.ini");
    
    delete engine;
    
    return 0;
}

void returnToMainMenu()
{
    if (PreferencesManager::get("headless") != "")
    {
        new EpsilonServer();
        
        P<ScriptObject> script = new ScriptObject();
        script->run(PreferencesManager::get("headless"));
        engine->registerObject("scenario", script);
        engine->setGameSpeed(1.0);
    }
    else if (PreferencesManager::get("autoconnect").toInt())
    {
        int crew_position = PreferencesManager::get("autoconnect").toInt() - 1;
        if (crew_position < 0) crew_position = 0;
        if (crew_position > max_crew_positions) crew_position = max_crew_positions;
        new AutoConnectScreen(ECrewPosition(crew_position), PreferencesManager::get("autocontrolmainscreen").toInt());
    }
    else if (PreferencesManager::get("touchcalib").toInt())
    {
        new MouseCalibrator(PreferencesManager::get("touchcalibfile"));
    }else{
        new MainMenu();
    }
}

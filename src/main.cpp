#include <string.h>
#include "gui/gui.h"
#include "gui/mainMenus.h"
#include "mouseCalibrator.h"
#include "factionInfo.h"
#include "spaceObjects/spaceObject.h"
#include "packResourceProvider.h"
#include "scienceDatabase.h"
#include "main.h"
#include "httpScriptAccess.h"

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#endif

sf::Vector3f camera_position;
float camera_yaw;
float camera_pitch;
sf::Shader objectShader;
sf::Shader simpleObjectShader;
sf::Shader basicShader;
sf::Shader billboardShader;
sf::Font mainFont;
RenderLayer* backgroundLayer;
RenderLayer* objectLayer;
RenderLayer* effectLayer;
RenderLayer* hudLayer;
RenderLayer* mouseLayer;
PostProcessor* glitchPostProcessor;
PostProcessor* warpPostProcessor;

static std::map<string, string> startup_parameters;

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
    FILE* f = fopen("options.ini", "r");
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
                    startup_parameters[key] = value;
                }

            }
        }
        fclose(f);
    }
    for(int n=1; n<argc; n++)
    {
        char* value = strchr(argv[n], '=');
        if (!value) continue;
        *value++ = '\0';
        startup_parameters[string(argv[n]).strip()] = string(value).strip();
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
    
    if (startup_parameters["httpserver"].toInt() != 0)
    {
        LOG(INFO) << "Enabling HTTP script access.";
        LOG(INFO) << "NOTE: This is potentially a risk!";
        HttpServer* server = new HttpServer(startup_parameters["httpserver"].toInt());
        server->addHandler(new HttpRequestFileHandler("www"));
        server->addHandler(new HttpScriptHandler());
    }

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
    bool fullscreen = true;

    if (startup_parameters.find("fullscreen") != startup_parameters.end())
        fullscreen = startup_parameters["fullscreen"].toInt();

    sf::VideoMode desktop = sf::VideoMode::getDesktopMode();
    if (desktop.height / 3 * 4 == desktop.width || startup_parameters["screen43"].toInt() != 0)
    {
        width = height / 3 * 4;
    }else{
        width = height * desktop.width / desktop.height;
        if (width < height / 3 * 4)
            width = height / 3 * 4;
    }
    if (startup_parameters["fsaa"].toInt() > 0)
    {
        fsaa = startup_parameters["fsaa"].toInt();
        if (fsaa < 2)
            fsaa = 2;
    }
    engine->registerObject("windowManager", new WindowManager(width, height, fullscreen, warpPostProcessor, fsaa));
    if (startup_parameters["touchscreen"].toInt())
    {
        InputHandler::touch_screen = true;
    }else{
        engine->registerObject("mouseRenderer", new MouseRenderer());
    }
    if (startup_parameters["touchcalibfile"] != "")
    {
        FILE* f = fopen(startup_parameters["touchcalibfile"].c_str(), "r");
        if (f)
        {
            float m[6];
            if (fscanf(f, "%f %f %f %f %f %f", &m[0], &m[1], &m[2], &m[3], &m[4], &m[5]) == 6)
                InputHandler::mouse_transform = sf::Transform(m[0], m[1], m[2], m[3], m[4], m[5], 0, 0, 1);
            fclose(f);
        }
    }
    
    if (startup_parameters.find("music_volume") != startup_parameters.end())
        soundManager.setMusicVolume(startup_parameters["music_volume"].toFloat());
    else
        soundManager.setMusicVolume(50);

    P<ResourceStream> stream = getResourceStream("sansation.ttf");
    mainFont.loadFromStream(**stream);

    if (sf::Shader::isAvailable())
    {
        P<ResourceStream> vertexStream = getResourceStream("objectShader.vert");
        P<ResourceStream> fragmentStream = getResourceStream("objectShader.frag");
        objectShader.loadFromStream(**vertexStream, **fragmentStream);
        vertexStream = getResourceStream("simpleObjectShader.vert");
        fragmentStream = getResourceStream("simpleObjectShader.frag");
        simpleObjectShader.loadFromStream(**vertexStream, **fragmentStream);
        vertexStream = getResourceStream("basicShader.vert");
        fragmentStream = getResourceStream("basicShader.frag");
        basicShader.loadFromStream(**vertexStream, **fragmentStream);
        vertexStream = getResourceStream("billboardShader.vert");
        fragmentStream = getResourceStream("billboardShader.frag");
        billboardShader.loadFromStream(**vertexStream, **fragmentStream);
    }

    {
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

    f = fopen("options.ini", "w");
    if (f)
    {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        startup_parameters["fsaa"] = windowManager->getFSAA();
        startup_parameters["fullscreen"] = windowManager->isFullscreen() ? 1 : 0;
        startup_parameters["music_volume"] = soundManager.getMusicVolume();
        fprintf(f, "# Empty Epsilon Settings\n# This file will be overwritten by EE.\n\n");
        fprintf(f, "# Include the following line to enable an experimental http server:\n# httpserver=8080\n\n");
        for(std::map<string, string>::iterator i = startup_parameters.begin(); i != startup_parameters.end(); i++)
        {
            fprintf(f, "%s=%s\n", i->first.c_str(), i->second.c_str());
        }
        fclose(f);
    }
    
    delete engine;
    
    return 0;
}

void returnToMainMenu()
{
    if (startup_parameters["autoconnect"].toInt())
    {
        int crew_position = startup_parameters["autoconnect"].toInt() - 1;
        if (crew_position < 0) crew_position = 0;
        if (crew_position > max_crew_positions) crew_position = max_crew_positions;
        new AutoConnectScreen(ECrewPosition(crew_position), startup_parameters["autocontrolmainscreen"].toInt());
    }else if (startup_parameters["touchcalib"].toInt())
    {
        new MouseCalibrator(startup_parameters["touchcalibfile"]);
    }else{
        new MainMenu();
    }
}

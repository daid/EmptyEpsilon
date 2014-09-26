#include <string.h>
#include "gui.h"
#include "mainMenus.h"
#include "mouseCalibrator.h"
#include "factionInfo.h"
#include "spaceObject.h"
#include "packResourceProvider.h"
#include "main.h"

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#endif

sf::Vector3f cameraPosition;
float cameraRotation;
sf::Shader objectShader;
sf::Shader simpleObjectShader;
sf::Shader basicShader;
sf::Font mainFont;
RenderLayer* backgroundLayer;
RenderLayer* objectLayer;
RenderLayer* effectLayer;
RenderLayer* hudLayer;
RenderLayer* mouseLayer;
PostProcessor* glitchPostProcessor;

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
    for(int n=1; n<argc; n++)
    {
        char* value = strchr(argv[n], '=');
        if (!value) continue;
        *value++ = '\0';
        startup_parameters[string(argv[n]).strip()] = string(value).strip();
    }

    new Engine();
    new DirectoryResourceProvider("resources/");
    new DirectoryResourceProvider("packs/SolCommand/");
    new PackResourceProvider("packs/Angryfly.pack");
    textureManager.setDefaultSmooth(true);
    textureManager.setDefaultRepeated(true);
    textureManager.setAutoSprite(false);

    //Setup the rendering layers.
    backgroundLayer = new RenderLayer();
    objectLayer = new RenderLayer(backgroundLayer);
    effectLayer = new RenderLayer(objectLayer);
    hudLayer = new RenderLayer(effectLayer);
    mouseLayer = new RenderLayer(hudLayer);
    glitchPostProcessor = new PostProcessor("glitch", mouseLayer);
    glitchPostProcessor->enabled = false;
    defaultRenderLayer = objectLayer;

    int width = 1600;
    int height = 900;
    int fsaa = 0;
    bool fullscreen = true;

    if (startup_parameters.find("fullscreen") != startup_parameters.end())
        fullscreen = startup_parameters["fullscreen"].toInt();

    sf::VideoMode desktop = sf::VideoMode::getDesktopMode();
    if (desktop.height / 3 * 4 == desktop.width || startup_parameters["screen43"].toInt() != 0)
        width = height / 3 * 4;
    engine->registerObject("windowManager", new WindowManager(width, height, fullscreen, glitchPostProcessor, fsaa));
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
    soundManager.setMusicVolume(50);

    randomNebulas();
    
    P<ResourceStream> stream = getResourceStream("sansation.ttf");
    mainFont.loadFromStream(**stream);

    P<ResourceStream> vertexStream = getResourceStream("objectShader.vert");
    P<ResourceStream> fragmentStream = getResourceStream("objectShader.frag");
    objectShader.loadFromStream(**vertexStream, **fragmentStream);
    vertexStream = getResourceStream("simpleObjectShader.vert");
    fragmentStream = getResourceStream("simpleObjectShader.frag");
    simpleObjectShader.loadFromStream(**vertexStream, **fragmentStream);
    vertexStream = getResourceStream("basicShader.vert");
    fragmentStream = getResourceStream("basicShader.frag");
    basicShader.loadFromStream(**vertexStream, **fragmentStream);

    P<ScriptObject> shipTemplatesScript = new ScriptObject("shipTemplates.lua");
    if (shipTemplatesScript)
        shipTemplatesScript->destroy();
    
    P<ScriptObject> factionInfoScript = new ScriptObject("factionInfo.lua");
    if (factionInfoScript)
        factionInfoScript->destroy();
    
    returnToMainMenu();
    
    engine->runMainLoop();
    
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

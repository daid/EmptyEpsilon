#include <string.h>
#include "gui.h"
#include "mainMenus.h"
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
    if (startup_parameters["swapmousexy"].toInt())
    {
        InputHandler::swap_xy = true;
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
    shipTemplatesScript->destroy();
    
    factionInfo[0].name = "Neutral";
    factionInfo[1].name = "Human";
    factionInfo[2].name = "SpaceCow";
    factionInfo[3].name = "Sheeple";
    factionInfo[4].name = "PirateScorpions";
    factionInfo[0].gm_color = sf::Color(128, 128, 128);
    factionInfo[1].gm_color = sf::Color(255, 255, 255);
    factionInfo[2].gm_color = sf::Color(255, 0, 0);
    factionInfo[3].gm_color = sf::Color(255, 128, 0);
    factionInfo[4].gm_color = sf::Color(255, 0, 128);
    FactionInfo::setState(0, 4, FVF_Enemy);

    FactionInfo::setState(1, 2, FVF_Enemy);
    FactionInfo::setState(1, 3, FVF_Enemy);
    FactionInfo::setState(1, 4, FVF_Enemy);
    
    FactionInfo::setState(2, 3, FVF_Enemy);
    FactionInfo::setState(2, 4, FVF_Enemy);
    FactionInfo::setState(3, 4, FVF_Enemy);
    
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
    }else{
        new MainMenu();
    }
}

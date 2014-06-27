#include "gui.h"
#include "mainMenus.h"
#include "main.h"

sf::Shader objectShader;
sf::Font mainFont;
RenderLayer* backgroundLayer;
RenderLayer* objectLayer;
RenderLayer* effectLayer;
RenderLayer* hud_layer;
RenderLayer* mouseLayer;

int main(int argc, char** argv)
{
    new Engine();
    new DirectoryResourceProvider("resources/");
    textureManager.setDefaultSmooth(true);

    //Setup the rendering layers.
    backgroundLayer = new RenderLayer();
    objectLayer = new RenderLayer(backgroundLayer);
    effectLayer = new RenderLayer(objectLayer);
    hud_layer = new RenderLayer(effectLayer);
    mouseLayer = new RenderLayer(hud_layer);
    defaultRenderLayer = objectLayer;

    int width = 1600;
    int height = 900;
    int fsaa = 0;
    engine->registerObject("windowManager", new WindowManager(width, height, false, mouseLayer, fsaa));
    engine->registerObject("inputHandler", new InputHandler());
    engine->registerObject("mouseRenderer", new MouseRenderer());

    P<ResourceStream> stream = getResourceStream("sansation.ttf");
    mainFont.loadFromStream(**stream);

    P<ResourceStream> vertexStream = getResourceStream("objectShader.vert");
    P<ResourceStream> fragmentStream = getResourceStream("objectShader.frag");
    objectShader.loadFromStream(**vertexStream, **fragmentStream);

    new MainMenu();

    engine->runMainLoop();

    delete engine;
    return 0;
}

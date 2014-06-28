#include "gui.h"
#include "mainMenus.h"
#include "main.h"

sf::Shader object_shader;
sf::Font main_font;
RenderLayer* background_layer;
RenderLayer* object_layer;
RenderLayer* effect_layer;
RenderLayer* hud_layer;
RenderLayer* mouse_layer;

int main(int argc, char** argv)
{
    new Engine();
    new DirectoryResourceProvider("resources/");
    texture_manager.setDefaultSmooth(true);

    //Setup the rendering layers.
    background_layer = new RenderLayer();
    object_layer = new RenderLayer(background_layer);
    effect_layer = new RenderLayer(object_layer);
    hud_layer = new RenderLayer(effect_layer);
    mouse_layer = new RenderLayer(hud_layer);
    defaultRenderLayer = object_layer;

    int width = 1600;
    int height = 900;
    int fsaa = 0;
    engine->registerObject("windowManager", new WindowManager(width, height, false, mouse_layer, fsaa));
    engine->registerObject("inputHandler", new InputHandler());
    engine->registerObject("mouseRenderer", new MouseRenderer());

    P<ResourceStream> stream = getResourceStream("sansation.ttf");
    main_font.loadFromStream(**stream);

    P<ResourceStream> vertexStream = getResourceStream("objectShader.vert");
    P<ResourceStream> fragmentStream = getResourceStream("objectShader.frag");
    object_shader.loadFromStream(**vertexStream, **fragmentStream);

    new MainMenu();

    engine->runMainLoop();

    delete engine;
    return 0;
}

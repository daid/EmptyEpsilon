#include "displaywindows.h"
#include "main.h"
#include "menus/luaConsole.h"
#include <preferenceManager.h>
#include "windowManager.h"
#include "gui/mouseRenderer.h"
#include "graphics/opengl.h"
#include "menus/shipSelectionScreen.h"
#include "shaderRegistry.h"
#include "gui/mouseRenderer.h"
#include "gui/debugRenderer.h"
#include "glObjects.h"


bool createDisplayWindows()
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
            return false;
        }
    }

    new DebugRenderer(mouseLayer);
    return true;
}
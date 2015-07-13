#ifndef DEBUG_RENDERER_H
#define DEBUG_RENDERER_H

#include "engine.h"

class DebugRenderer : public Renderable, public InputEventHandler
{
private:
    sf::Clock fps_timer;
    float fps;
    int fps_counter;
    
    bool show_fps;
    bool show_datarate;
public:
    DebugRenderer();

    virtual void render(sf::RenderTarget& window);
    virtual void handleKeyPress(sf::Keyboard::Key key, int unicode);
};

#endif//DEBUG_RENDERER_H

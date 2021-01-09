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
    bool show_timing_graph;

    std::vector<Engine::EngineTiming> timing_graph_points;
public:
    DebugRenderer();

    virtual void render(sf::RenderTarget& window);
    virtual void handleTextEntered(sf::Event::TextEvent text, int unicode);
    virtual void handleKeyPress(sf::Event::KeyEvent key, int unicode);
};

#endif//DEBUG_RENDERER_H

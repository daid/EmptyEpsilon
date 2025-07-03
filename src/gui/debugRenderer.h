#ifndef DEBUG_RENDERER_H
#define DEBUG_RENDERER_H

#include "Renderable.h"
#include "timer.h"
#include "engine.h"


class DebugRenderer : public Renderable
{
private:
    sp::SystemStopwatch fps_timer;
    float fps;
    int fps_counter;

    bool show_fps;
    bool show_datarate;
    bool show_timing_graph;

    float scale = 10.0f;
    std::map<string, bool> timing_graph_enabled;
    std::vector<string> key_order;
    std::map<string, std::vector<float>> timing_graph_points;
public:
    DebugRenderer(RenderLayer* renderLayer);

    virtual void render(sp::RenderTarget& target) override;

    virtual bool onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//DEBUG_RENDERER_H

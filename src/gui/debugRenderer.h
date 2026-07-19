#pragma once

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

    std::map<string, std::vector<float>> timing_graph_points;
public:
    DebugRenderer(RenderLayer* renderLayer);

    virtual void render(sp::RenderTarget& target) override;
};

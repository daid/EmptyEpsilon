#include "debugRenderer.h"
#include "main.h"
#include "multiplayer_server.h"
#include "hotkeyConfig.h"


DebugRenderer::DebugRenderer()
: Renderable(mouseLayer)
{
    fps = 0.0;
    fps_counter = 0;

    show_fps = false;
    show_datarate = false;
    show_timing_graph = false;

#ifdef DEBUG
    show_fps = show_datarate = true;
#endif
}

void DebugRenderer::render(sp::RenderTarget& renderer)
{
    if (keys.debug_show_fps.getDown())
    {
        show_fps = !show_fps;
        show_datarate = !show_datarate;
    }
    if (keys.debug_show_timing.getDown())
    {
        show_timing_graph = !show_timing_graph;
        timing_graph_points.clear();
    }

    fps_counter++;
    if (fps_counter > 30)
    {
        fps = fps_counter / fps_timer.restart();
        fps_counter = 0;
    }
    string text = "";
    if (show_fps)
        text = text + "FPS: " + string(fps) + "\n";

    if (show_datarate && game_server)
    {
        text = text + string(game_server->getSendDataRate() / 1000, 1) + " kb per second\n";
        text = text + string(game_server->getSendDataRatePerClient() / 1000, 1) + " kb per client\n";
    }

    if (show_timing_graph)
    {
        auto window_size = renderer.getVirtualSize();
        if (timing_graph_points.size() > size_t(window_size.x))
            timing_graph_points.clear();
        timing_graph_points.push_back(engine->getEngineTiming());

        std::vector<glm::vec2> update_points;
        std::vector<glm::vec2> server_update_points;
        std::vector<glm::vec2> collision_points;
        std::vector<glm::vec2> render_points;
        for(unsigned int n=0; n<timing_graph_points.size(); n++)
        {
            update_points.emplace_back(float(n), window_size.y - timing_graph_points[n].update * 10000);
            server_update_points.emplace_back(float(n), window_size.y - timing_graph_points[n].server_update * 10000);
            collision_points.emplace_back(float(n), window_size.y - (timing_graph_points[n].update + timing_graph_points[n].collision) * 10000);
            render_points.emplace_back(float(n), window_size.y - (timing_graph_points[n].render + timing_graph_points[n].update + timing_graph_points[n].collision) * 10000);
        }
        renderer.drawLine(update_points, {255, 0, 0, 255});
        renderer.drawLine(server_update_points, {255, 255, 0, 255});
        renderer.drawLine(collision_points, {0, 255, 255, 255});
        renderer.drawLine(render_points, {0, 255, 0, 255});

        //60FPS line
        renderer.drawLine({0, window_size.y - 166}, {window_size.x, window_size.y - 166}, glm::u8vec4{255,255,255,128});

        renderer.drawText(
            sp::Rect(0, 0, 0, renderer.getVirtualSize().y - 18 * 4),
            "Update: " + string(timing_graph_points.back().update * 1000) + "ms",
            sp::Alignment::BottomLeft, 18, nullptr, glm::u8vec4{255,0,0,255});
        renderer.drawText(
            sp::Rect(0, 0, 0, renderer.getVirtualSize().y - 18 * 3),
            "ServerUpdate: " + string(timing_graph_points.back().server_update * 1000) + "ms",
            sp::Alignment::BottomLeft, 18, nullptr, glm::u8vec4{255,255,0,255});
        renderer.drawText(
            sp::Rect(0, 0, 0, renderer.getVirtualSize().y - 18 * 2),
            "Collision: " + string(timing_graph_points.back().collision * 1000) + "ms",
            sp::Alignment::BottomLeft, 18, nullptr, glm::u8vec4{0,255,255,255});
        renderer.drawText(
            sp::Rect(0, 0, 0, renderer.getVirtualSize().y - 18 * 1),
            "Render: " + string(timing_graph_points.back().render * 1000) + "ms",
            sp::Alignment::BottomLeft, 18, nullptr, glm::u8vec4{0,255,0,255});
    }
    renderer.drawText(sp::Rect(0, 0, 0, 0), text, sp::Alignment::TopLeft, 18);
}

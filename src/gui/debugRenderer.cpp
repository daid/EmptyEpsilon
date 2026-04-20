#include "debugRenderer.h"
#include "multiplayer_server.h"
#include "hotkeyConfig.h"

static glm::u8vec4 line_colors[] = {
    {255, 0, 0, 255},
    {0, 255, 0, 255},
    {0, 0, 255, 255},
    {0, 255, 255, 255},
    {255, 0, 255, 255},
    {255, 255, 0, 255},
};


DebugRenderer::DebugRenderer(RenderLayer* renderLayer)
: Renderable(renderLayer)
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
        size_t max_size = 0;
        for(auto it : timing_graph_points)
            max_size = std::max(it.second.size(), max_size);
        if (max_size > size_t(window_size.x)) {
            timing_graph_points.clear();
            max_size = 0;
        }
        for(auto [key, value] : engine->getEngineTiming()) {
            if (timing_graph_points[key].size() < max_size)
                timing_graph_points[key].resize(max_size, 0.0f);
            timing_graph_points[key].push_back(value);
        }

        // Update max_size after adding new points
        max_size = 0;
        for (auto it : timing_graph_points)
            max_size = std::max(it.second.size(), max_size);

        std::vector<string> key_order;
        std::map<string, float> total;
        for(auto& [key, data] : timing_graph_points) {
            float sum = 0;
            for(auto value : data)
                sum += value;
            total[key] = sum;
            key_order.push_back(key);
        }
        std::sort(key_order.begin(), key_order.end(), [&total](const auto& a, const auto& b) { return total[a] > total[b]; });

        std::map<string, std::vector<glm::vec2>> points;
        for (unsigned int n = 0; n < max_size; n++)
        {
            float sum = 0.0f;
            for (const auto& key : key_order)
            {
                // Bounds check if vectors are different sizes
                if (n < timing_graph_points[key].size())
                    sum += timing_graph_points[key][n];

                points[key].emplace_back(float(n), window_size.y - sum * 10000.0f);
            }
        }

        int index = 0;
        for (const auto& key : key_order)
        {
            renderer.drawLine(points[key], 1.0f, line_colors[index % 6]);
            index += 1;
        }

        // 60 FPS line
        renderer.drawLine({0, window_size.y - 166}, {window_size.x, window_size.y - 166}, 2.0f, glm::u8vec4{255,255,255,128});

        index = 0;
        for(const auto& key : key_order) {
            renderer.drawText(
                sp::Rect(0, 0, 0, 96 + 16 * index),
                key + ": " + string(timing_graph_points[key].back() * 1000, 5) + "ms",
                sp::Alignment::BottomLeft, 16, nullptr, line_colors[index % 6]);
            index += 1;
        }
    }
    renderer.drawText(sp::Rect(0, 0, 0, 0), text, sp::Alignment::TopLeft, 18);
}

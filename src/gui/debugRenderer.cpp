#include "debugRenderer.h"
#include "main.h"

DebugRenderer::DebugRenderer()
: Renderable(mouseLayer)
{
    fps_timer.restart();
    fps = 0.0;
    fps_counter = 0;

    show_fps = false;
    show_datarate = false;
    show_timing_graph = false;

#ifdef DEBUG
    show_fps = show_datarate = true;
#endif
}

void DebugRenderer::render(sf::RenderTarget& window)
{
    fps_counter++;
    if (fps_counter > 30)
    {
        fps = fps_counter / fps_timer.restart().asSeconds();
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
        if (timing_graph_points.size() > window.getView().getSize().x)
            timing_graph_points.clear();
        timing_graph_points.push_back(engine->getEngineTiming());
        sf::VertexArray update_points(sf::LinesStrip, timing_graph_points.size());
        sf::VertexArray collision_points(sf::LinesStrip, timing_graph_points.size());
        sf::VertexArray render_points(sf::LinesStrip, timing_graph_points.size());
        for(unsigned int n=0; n<timing_graph_points.size(); n++)
        {
            update_points[n].position.x = float(n);
            update_points[n].position.y = window.getView().getSize().y - timing_graph_points[n].update * 10000;
            collision_points[n].position.x = float(n);
            collision_points[n].position.y = window.getView().getSize().y - (timing_graph_points[n].update + timing_graph_points[n].collision) * 10000;
            render_points[n].position.x = float(n);
            render_points[n].position.y = window.getView().getSize().y - (timing_graph_points[n].render + timing_graph_points[n].update + timing_graph_points[n].collision) * 10000;
            
            update_points[n].color = sf::Color::Red;
            collision_points[n].color = sf::Color::Blue;
            render_points[n].color = sf::Color::Green;
        }
        window.draw(update_points);
        window.draw(collision_points);
        window.draw(render_points);
    }

    sf::Text textElement(text, *mainFont, 18);
    textElement.setPosition(0, 0);
    window.draw(textElement);
}

void DebugRenderer::handleKeyPress(sf::Keyboard::Key key, int unicode)
{
    if (key == sf::Keyboard::F10)
    {
        show_fps = !show_fps;
        show_datarate = !show_datarate;
    }
    if (key == sf::Keyboard::F11)
    {
        show_timing_graph = !show_timing_graph;
        timing_graph_points.clear();
        if (show_timing_graph)
            P<WindowManager>(engine->getObject("windowManager"))->setFrameLimit(0);
        else
            P<WindowManager>(engine->getObject("windowManager"))->setFrameLimit(60);
    }
}

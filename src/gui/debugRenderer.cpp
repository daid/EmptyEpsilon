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
        sf::VertexArray server_update_points(sf::LinesStrip, timing_graph_points.size());
        sf::VertexArray collision_points(sf::LinesStrip, timing_graph_points.size());
        sf::VertexArray render_points(sf::LinesStrip, timing_graph_points.size());
        for(unsigned int n=0; n<timing_graph_points.size(); n++)
        {
            update_points[n].position.x = float(n);
            update_points[n].position.y = window.getView().getSize().y - timing_graph_points[n].update * 10000;
            server_update_points[n].position.x = float(n);
            server_update_points[n].position.y = window.getView().getSize().y - timing_graph_points[n].server_update * 10000;
            collision_points[n].position.x = float(n);
            collision_points[n].position.y = window.getView().getSize().y - (timing_graph_points[n].update + timing_graph_points[n].collision) * 10000;
            render_points[n].position.x = float(n);
            render_points[n].position.y = window.getView().getSize().y - (timing_graph_points[n].render + timing_graph_points[n].update + timing_graph_points[n].collision) * 10000;

            update_points[n].color = sf::Color::Red;
            server_update_points[n].color = sf::Color::Yellow;
            collision_points[n].color = sf::Color::Cyan;
            render_points[n].color = sf::Color::Green;
        }
        window.draw(server_update_points);
        window.draw(update_points);
        window.draw(collision_points);
        window.draw(render_points);

        sf::Text text_update("Update: " + string(timing_graph_points.back().update * 1000) + "ms", *main_font, 18);
        sf::Text text_server_update("ServerUpdate: " + string(timing_graph_points.back().server_update * 1000) + "ms", *main_font, 18);
        sf::Text text_collision("Collision: " + string(timing_graph_points.back().collision * 1000) + "ms", *main_font, 18);
        sf::Text text_render("Render: " + string(timing_graph_points.back().render * 1000) + "ms", *main_font, 18);

        sf::VertexArray fps60_line(sf::LinesStrip, 2);
        fps60_line[0].position = sf::Vector2f(0, window.getView().getSize().y - 166);
        fps60_line[1].position = sf::Vector2f(window.getView().getSize().x, window.getView().getSize().y - 166);
        fps60_line[0].color = sf::Color(255, 255, 255, 128);
        fps60_line[1].color = sf::Color(255, 255, 255, 128);
        window.draw(fps60_line);

        text_update.setPosition(0, window.getView().getSize().y - 18 * 4 - 170);
        text_server_update.setPosition(0, window.getView().getSize().y - 18 * 3 - 170);
        text_collision.setPosition(0, window.getView().getSize().y - 18 * 2 - 170);
        text_render.setPosition(0, window.getView().getSize().y - 18 - 170);
        text_update.setColor(sf::Color::Red);
        text_server_update.setColor(sf::Color::Yellow);
        text_collision.setColor(sf::Color::Cyan);
        text_render.setColor(sf::Color::Green);
        window.draw(text_update);
        window.draw(text_server_update);
        window.draw(text_collision);
        window.draw(text_render);
    }

    sf::Text textElement(text, *main_font, 18);
    textElement.setPosition(0, 0);
    window.draw(textElement);
}

void DebugRenderer::handleKeyPress(sf::Event::KeyEvent key, int unicode)
{
    if (key.code == sf::Keyboard::F10)
    {
        show_fps = !show_fps;
        show_datarate = !show_datarate;
    }
    if (key.code == sf::Keyboard::F11)
    {
        show_timing_graph = !show_timing_graph;
        timing_graph_points.clear();
        if (show_timing_graph)
            P<WindowManager>(engine->getObject("windowManager"))->setFrameLimit(0);
        else
            P<WindowManager>(engine->getObject("windowManager"))->setFrameLimit(60);
    }
}

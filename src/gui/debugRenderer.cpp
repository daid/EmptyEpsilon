#include "debugRenderer.h"
#include "main.h"

DebugRenderer::DebugRenderer()
: Renderable(mouseLayer)
{
    bool default_show_value = false;
#ifdef DEBUG
    default_show_value = true;
#endif

    fps_timer.restart();
    fps = 0.0;
    fps_counter = 0;

    show_fps = default_show_value;
    show_datarate = default_show_value;
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

    sf::Text textElement(text, mainFont, 18);
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
}

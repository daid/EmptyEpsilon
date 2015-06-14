#include "debugRenderer.h"
#include "main.h"

DebugRenderer::DebugRenderer()
: Renderable(mouseLayer)
{
    fps_timer.restart();
    fps = 0.0;
    fps_counter = 0;
}

void DebugRenderer::render(sf::RenderTarget& window)
{
    fps_counter++;
    if (fps_counter > 30)
    {
        fps = fps_counter / fps_timer.restart().asSeconds();
        fps_counter = 0;
    }
    string text = "FPS: " + string(fps);
    if (game_server)
    {
        text = text + "\n" + string(game_server->getSendDataRate() / 1000) + " kb per second";
        text = text + "\n" + string(game_server->getSendDataRatePerClient() / 1000) + " kb per client";
    }

    sf::Text textElement(text, mainFont, 18);
    textElement.setPosition(0, 0);
    window.draw(textElement);
}

void DebugRenderer::handleKeyPress(sf::Keyboard::Key key, int unicode)
{
}

#include "mouseRenderer.h"
#include "main.h"

MouseRenderer::MouseRenderer()
: Renderable(mouseLayer)
{
    visible = true;
}

void MouseRenderer::render(sf::RenderTarget& window)
{
    if (!visible) return;

    sf::Vector2f mouse = InputHandler::getMousePos();

    sf::Sprite mouseSprite;
    textureManager.setTexture(mouseSprite, "mouse.png");
    mouseSprite.setPosition(mouse);
    window.draw(mouseSprite);
}

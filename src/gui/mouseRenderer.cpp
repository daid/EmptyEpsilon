#include "mouseRenderer.h"
#include "main.h"

MouseRenderer::MouseRenderer()
: Renderable(mouseLayer)
{
    visible = true;
}

void MouseRenderer::render(sp::RenderTarget& renderer)
{
    if (!visible) return;

    auto mouse = InputHandler::getMousePos();

    renderer.drawSprite("mouse.png", mouse, 32.0);
}

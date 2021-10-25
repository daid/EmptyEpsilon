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

    renderer.drawSprite("mouse.png", position, 32.0);
}

bool MouseRenderer::onPointerMove(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (id == -1)
        this->position = position;
    return false;
}

void MouseRenderer::onPointerLeave(sp::io::Pointer::ID id)
{
    if (id == -1)
        this->position = {-1, -1};
}

void MouseRenderer::onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (id == -1)
        this->position = position;
}

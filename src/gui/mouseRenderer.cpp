#include "mouseRenderer.h"
#include "main.h"

#include <SDL_mouse.h>

MouseRenderer::MouseRenderer()
: Renderable(mouseLayer)
{
    visible = true;
    SDL_ShowCursor(SDL_DISABLE);
}

MouseRenderer::~MouseRenderer()
{
    SDL_ShowCursor(SDL_ENABLE);
}

void MouseRenderer::render(sp::RenderTarget& renderer)
{
    if (!visible) return;

    auto mouse = InputHandler::getMousePos();

    renderer.drawSprite("mouse.png", mouse, 32.0);
}

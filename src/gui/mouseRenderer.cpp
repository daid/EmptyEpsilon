#include "mouseRenderer.h"
#include "main.h"
#include "theme.h"

MouseRenderer::MouseRenderer(RenderLayer* render_layer)
: Renderable(render_layer)
{
    visible = true;
    setSpriteThemed("mouse.default");
}

void MouseRenderer::render(sp::RenderTarget& renderer)
{
    if (!visible) return;

    renderer.drawSprite(sprite, position, 32.0);
}

bool MouseRenderer::onPointerMove(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (id == -1) {
        this->position = position;
        visible = true;
    }
    return false;
}

void MouseRenderer::onPointerLeave(sp::io::Pointer::ID id)
{
    if (id == -1)
        visible = false;
}

void MouseRenderer::onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (id == -1) {
        this->position = position;
        visible = true;
    }
}

void MouseRenderer::setSpriteThemed(string theme_element)
{
    sprite = GuiTheme::getCurrentTheme()->getStyle(theme_element)->get(GuiElement::State::Normal).texture;
}

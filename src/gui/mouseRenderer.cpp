#include "mouseRenderer.h"
#include "main.h"

MouseRenderer::MouseRenderer(RenderLayer* render_layer)
: Renderable(render_layer)
{
#ifdef DEBUG
    show_bounds = true;
#endif
}

void MouseRenderer::render(sp::RenderTarget& renderer)
{
    if (!visible) return;

    renderer.drawSprite(sprite, position + cursor_hotspot, sprite_size, sprite_color);

    if (show_bounds)
    {
        // Draw yellow square around cursor sprite.
        const float sprite_bounds = sprite_size * 0.5f;
        const glm::vec2 center = position + cursor_hotspot;
        const glm::vec2 top_left{center.x - sprite_bounds, center.y - sprite_bounds};
        const glm::vec2 top_right{center.x + sprite_bounds, center.y - sprite_bounds};
        const glm::vec2 bottom_right{center.x + sprite_bounds, center.y + sprite_bounds};
        const glm::vec2 bottom_left{center.x - sprite_bounds, center.y + sprite_bounds};
        renderer.drawLine({top_left, top_right, bottom_right, bottom_left, top_left}, {255, 255, 0, 200});

        // Draw white crosshair on click point.
        renderer.drawLine(position - glm::vec2{2.0f, 0.0f}, position + glm::vec2{2.0f, 0.0f}, {255, 255, 255, 255});
        renderer.drawLine(position - glm::vec2{0.0f, 2.0f}, position + glm::vec2{0.0f, 2.0f}, {255, 255, 255, 255});
    }
}

bool MouseRenderer::onPointerMove(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (id == -1)
    {
        this->position = position;
        visible = true;
    }
    return false;
}

void MouseRenderer::onPointerLeave(sp::io::Pointer::ID id)
{
    if (id == -1) visible = false;
}

void MouseRenderer::onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    onPointerMove(position, id);
}

void MouseRenderer::setSpriteImage(string sprite_image)
{
    sprite = sprite_image;
}

void MouseRenderer::setSpriteSize(float size)
{
    // Render the sprite no smaller than 2x2.
    const float new_size = std::max(2.0f, size);

    // Set the click point in the new size to the same position relative to its
    // current size.
    cursor_hotspot = cursor_hotspot * (new_size / sprite_size);
    sprite_size = new_size;
}

void MouseRenderer::setSpriteColor(glm::u8vec4 color)
{
    sprite_color = color;
}

void MouseRenderer::setCursorHotspot(glm::vec2 point)
{
    // Bind click point to sprite bounds.
    const float sprite_bounds = sprite_size * 0.5f;
    cursor_hotspot = glm::clamp(point, -sprite_bounds, sprite_bounds);
}

void MouseRenderer::setCursorHotspotCenter()
{
    cursor_hotspot = glm::vec2{0.0f, 0.0f};
}

void MouseRenderer::setCursorHotspotTopLeft()
{
    const float sprite_bounds = sprite_size * 0.5f;
    cursor_hotspot = glm::vec2{sprite_bounds, sprite_bounds};
}

#include "mouseRenderer.h"
#include "main.h"

MouseRenderer::MouseRenderer(RenderLayer* render_layer)
: Renderable(render_layer)
{
}

void MouseRenderer::render(sp::RenderTarget& renderer)
{
    if (!visible) return;

    renderer.drawSprite(sprite, position + cursor_hotspot, sprite_size, sprite_color);
    if (!overlay1.empty())
        renderer.drawSprite(overlay1, position + overlay1_offset, overlay1_size, overlay1_color);
    if (!overlay2.empty())
        renderer.drawSprite(overlay2, position + overlay2_offset, overlay2_size, overlay2_color);
    if (!overlay3.empty())
        renderer.drawSprite(overlay3, position + overlay3_offset, overlay3_size, overlay3_color);

    if (show_bounds)
    {
        // Draw yellow square around cursor sprite.
        const float sprite_bounds = sprite_size * 0.5f;
        const glm::vec2 center = position + cursor_hotspot;
        const glm::vec2 top_left{center.x - sprite_bounds, center.y - sprite_bounds};
        const glm::vec2 top_right{center.x + sprite_bounds, center.y - sprite_bounds};
        const glm::vec2 bottom_right{center.x + sprite_bounds, center.y + sprite_bounds};
        const glm::vec2 bottom_left{center.x - sprite_bounds, center.y + sprite_bounds};
        renderer.drawLine({top_left, top_right, bottom_right, bottom_left, top_left}, {255, 255, 0, 64});

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

void MouseRenderer::setSprite(string image, glm::vec2 offset, float size, glm::u8vec4 color)
{
    setSpriteImage(image);
    setCursorHotspot(offset);
    setSpriteSize(size);
    setSpriteColor(color);
}

void MouseRenderer::setOverlay1(string image, glm::vec2 offset, float size, glm::u8vec4 color)
{
    overlay1 = image;
    overlay1_offset = offset;
    overlay1_size = size;
    overlay1_color = color;
}

void MouseRenderer::setOverlay2(string image, glm::vec2 offset, float size, glm::u8vec4 color)
{
    overlay2 = image;
    overlay2_offset = offset;
    overlay2_size = size;
    overlay2_color = color;
}

void MouseRenderer::setOverlay3(string image, glm::vec2 offset, float size, glm::u8vec4 color)
{
    overlay3 = image;
    overlay3_offset = offset;
    overlay3_size = size;
    overlay3_color = color;
}

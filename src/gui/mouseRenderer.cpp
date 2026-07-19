#include "mouseRenderer.h"

MouseRenderer::MouseRenderer(RenderLayer* render_layer)
: Renderable(render_layer)
{
}

void MouseRenderer::render(sp::RenderTarget& renderer)
{
    if (!visible) return;

    renderer.drawSprite(primary.sprite, position + primary.offset, primary.size, primary.color);
    for (const auto& overlay : overlays)
        renderer.drawSprite(overlay.sprite, position + overlay.offset, overlay.size, overlay.color);

    if (show_bounds)
    {
        // Draw yellow square around primary cursor sprite.
        const float bounds = primary.size * 0.5f;
        const glm::vec2 center = position + primary.offset;
        renderer.drawLine(
            {
                {center.x - bounds, center.y - bounds},
                {center.x + bounds, center.y - bounds},
                {center.x + bounds, center.y + bounds},
                {center.x - bounds, center.y + bounds},
                {center.x - bounds, center.y - bounds},
            },
            {255, 255, 0, 64});

        // Draw white crosshair on cursor hotspot.
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

void MouseRenderer::setPrimary(string sprite, float size, glm::u8vec4 color)
{
    primary.sprite = sprite;
    // Clamp sprite size to minimum 2x2 pixels.
    primary.size = std::max(2.0f, size);
    primary.color = color;
}

void MouseRenderer::setCursorHotspot(glm::vec2 point)
{
    // Hotspot should be within sprite bounds.
    const float bounds = primary.size * 0.5f;
    primary.offset = glm::clamp(point, -bounds, bounds);
}

void MouseRenderer::setCursorHotspotCenter()
{
    primary.offset = glm::vec2{0.0f, 0.0f};
}

void MouseRenderer::setCursorHotspotTopLeft()
{
    const float bounds = primary.size * 0.5f;
    primary.offset = glm::vec2{bounds, bounds};
}

void MouseRenderer::addOverlay(string sprite, glm::vec2 offset, float size, glm::u8vec4 color)
{
    overlays.push_back({
        sprite,
        offset,
        // Clamp sprite size to minimum 2x2 pixels.
        std::max(2.0f, size),
        color
    });
}

void MouseRenderer::clearOverlays()
{
    overlays.clear();
}

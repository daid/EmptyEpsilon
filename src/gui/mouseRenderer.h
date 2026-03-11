#pragma once

#include "Renderable.h"

// Render the mouse cursor. Defaults to 32x32 sprite resources/cursors/mouse.png
// with the cursor hotspot at the top-left corner.
class MouseRenderer : public Renderable
{
public:
    // Show the mouse cursor.
    bool visible = true;
    // Show sprite outline (yellow) and cursor hotspot (white crosshair) for
    // debugging. Set via GuiCanvas Copy input.
    bool show_bounds = false;

    // Cursor sprite layer
    struct CursorLayer
    {
        string sprite = "cursors/mouse.png";
        glm::vec2 offset{0.0f, 0.0f};
        float size = 32.0f;
        glm::u8vec4 color{255, 255, 255, 255};
    };

    MouseRenderer(RenderLayer* render_layer);
    virtual void render(sp::RenderTarget& window) override;

    // Callback run when the cursor moves.
    virtual bool onPointerMove(glm::vec2 position, sp::io::Pointer::ID id) override;
    // Callback run when the cursor leaves the window.
    virtual void onPointerLeave(sp::io::Pointer::ID id) override;
    // Callback run when the cursor is being dragged.
    virtual void onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    // Expose the cursor's screen-space position.
    glm::vec2 getPosition() const { return position; }

    // Set the primary cursor sprite image, size, and color. Does not change
    // the default top-left cursor hotspot.
    void setPrimary(string image = "cursors/mouse.png", float size = 32.0f, glm::u8vec4 color = {255, 255, 255, 255});
    // Set the cursor hotspot offset from its screen position, in pixels.
    // Clamped to the primary sprite's half-size.
    void setCursorHotspot(glm::vec2 point);
    // Set the cursor hotspot to the primary sprite's center (0, 0).
    void setCursorHotspotCenter();
    // Set the cursor hotspot to the primary sprite's upper-left corner.
    void setCursorHotspotTopLeft();

    // Add an overlay sprite drawn over the cursor, offset from the cursor's
    // screen position in screen pixels.
    void addOverlay(string image, glm::vec2 offset = {0.0f, 0.0f}, float size = 32.0f, glm::u8vec4 color = {255, 255, 255, 255});
    // Remove all overlay sprites. Does not affect the primary sprite.
    void clearOverlays();
private:
    // The cursor's screen-space position.
    glm::vec2 position;
    // The primary cursor sprite. primary.offset is the cursor hotspot and must
    // be within the sprite bounds.
    CursorLayer primary{"cursors/mouse.png", {16.0f, 16.0f}, 32.0f, {255, 255, 255, 255}};
    // Overlay sprites drawn over the primary, offset from the cursor position.
    std::vector<CursorLayer> overlays;
};

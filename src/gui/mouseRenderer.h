#pragma once

#include "Renderable.h"

// Render the mouse cursor. Defaults to 32x32 sprite resources/cursors/mouse.png
// with the click point at the center.
class MouseRenderer : public Renderable
{
public:
    // Show the mouse cursor.
    bool visible = true;
    // Show sprite outline (yellow) and click point (white crosshair) for
    // debugging.
    bool show_bounds = false;

    MouseRenderer(RenderLayer* render_layer);
    virtual void render(sp::RenderTarget& window) override;

    // Callback run when the cursor moves.
    virtual bool onPointerMove(glm::vec2 position, sp::io::Pointer::ID id) override;
    // Callback run when the cursor leaves the window.
    virtual void onPointerLeave(sp::io::Pointer::ID id) override;
    // Callback run when the cursor is being dragged.
    virtual void onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    // Expose the cursor's position.
    glm::vec2 getPosition() const { return position; }

    // Set the square cursor sprite image to a path relative to resources/.
    // Scales to sprite_size.
    void setSpriteImage(string sprite_image);
    // Set the length of the square cursor sprite's side in pixels.
    void setSpriteSize(float size);
    // Set the cursor sprite's RGBA color.
    void setSpriteColor(glm::u8vec4 color);
    // Set the cursor sprite's click point, in pixels relative to its center
    // point (0, 0). Positive
    void setCursorHotspot(glm::vec2 point);
    // Convenience function to set the cursor's click point to the sprite's
    // center point (0, 0).
    void setCursorHotspotCenter();
    // Convenience function to set the cursor's click point to the sprite's
    // upper-leftmost point.
    void setCursorHotspotTopLeft();
private:
    // The cursor's position.
    glm::vec2 position;
    // The cursor's sprite, relative to resources/.
    // TODO: Set via theme.
    string sprite = "cursors/mouse.png";
    // The length of the square cursor sprite's side in pixels.
    float sprite_size = 32.0f;
    // The cursor sprite's RGBA color.
    glm::u8vec4 sprite_color{255, 255, 255, 255};
    // The cursor sprite's click point, in pixels relative to its center point
    // (0, 0).
    glm::vec2 cursor_hotspot{16.0f, 16.0f};
};

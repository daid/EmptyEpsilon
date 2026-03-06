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
    // debugging. Set via GuiCanvas Copy input.
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

    // Set all cursor sprite properties at once. offset is from the hotspot.
    void setSprite(string image, glm::vec2 offset = {0.0f, 0.0f}, float size = 32.0f, glm::u8vec4 color = {255, 255, 255, 255});
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

    // Optional overlay sprites drawn over the cursor. offset is from the
    // hotspot in screen pixels. Cleared by passing an empty image string.
    void setOverlay1(string image, glm::vec2 offset = {0.0f, 0.0f}, float size = 32.0f, glm::u8vec4 color = {255, 255, 255, 255});
    void clearOverlay1() { overlay1 = ""; }
    void setOverlay2(string image, glm::vec2 offset = {0.0f, 0.0f}, float size = 32.0f, glm::u8vec4 color = {255, 255, 255, 255});
    void clearOverlay2() { overlay2 = ""; }
    void setOverlay3(string image, glm::vec2 offset = {0.0f, 0.0f}, float size = 32.0f, glm::u8vec4 color = {255, 255, 255, 255});
    void clearOverlay3() { overlay3 = ""; }
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
    // Optional overlay sprites drawn over the cursor, offset from the hotspot.
    // TODO: Refactor as struct vector?
    string overlay1;
    float overlay1_size = 32.0f;
    glm::u8vec4 overlay1_color{255, 255, 255, 255};
    glm::vec2 overlay1_offset{0.0f, 0.0f};
    string overlay2;
    float overlay2_size = 32.0f;
    glm::u8vec4 overlay2_color{255, 255, 255, 255};
    glm::vec2 overlay2_offset{0.0f, 0.0f};
    string overlay3;
    float overlay3_size = 32.0f;
    glm::u8vec4 overlay3_color{255, 255, 255, 255};
    glm::vec2 overlay3_offset{0.0f, 0.0f};
};

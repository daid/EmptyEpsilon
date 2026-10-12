#pragma once

#include "gui/gui2_element.h"
#include "components/rendering.h"

class GuiRotatingModelView : public GuiElement
{
private:
    sp::ecs::Entity &entity;
    // Zoom 1.0 = default, >1 zooms in, <1 zooms out
    float zoom_level = 1.0f;
    // Default to filling 90% of narrowest dimension
    float desired_fill_percentage = 0.90f;

    // Mouse interaction state
    bool mouse_down = false;
    bool is_dragging = false;
    glm::vec2 mouse_down_position{0.0f, 0.0f};

    // Manual rotation defaults
    bool manual_rotation_allowed = true;
    bool manual_rotation_mode = false;
    float manual_rotation_x = -30.0f;
    float manual_rotation_z = 0.0f;

#ifdef DEBUG
    bool debug_show_normal_map = true;
    // Azimuth: degrees around Z axis (0 = forward, 90 = right).
    // Elevation: degrees from the horizontal plane, -90..90
    // (0 = flat, 90 = straight down from above, -90 = straight up from below).
    float debug_light_azimuth = 45.f;
    float debug_light_elevation = 45.f;
#endif

public:
    GuiRotatingModelView(GuiContainer* owner, string id, sp::ecs::Entity& entity);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseWheelScroll(glm::vec2 position, float value) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiRotatingModelView* setFillPercentage(float percentage);
    GuiRotatingModelView* setZoom(float zoom);
    GuiRotatingModelView* setManualRotationAllowed(bool allowed);

#ifdef DEBUG
    GuiRotatingModelView* setDebugShowNormalMap(bool show) { debug_show_normal_map = show; return this; }
    GuiRotatingModelView* setDebugLightAzimuth(float degrees) { debug_light_azimuth = degrees; return this; }
    GuiRotatingModelView* setDebugLightElevation(float degrees) { debug_light_elevation = degrees; return this; }
#endif
};

#ifdef DEBUG
class GuiRotatingModelDebugView : public GuiRotatingModelView
{
public:
    GuiRotatingModelDebugView(GuiContainer* owner, string id, sp::ecs::Entity& entity);
};
#endif

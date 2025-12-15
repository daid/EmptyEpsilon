#pragma once

#include "engine.h"
#include "components/collision.h"

#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "screenComponents/viewport3d.h"

class GuiButton;
class GuiElement;
class GuiHelpOverlay;
class GuiSelector;
class GuiToggleButton;
class MouseRenderer;

class CinematicViewScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    sp::ecs::Entity target;

    GuiElement* camera_controls;
    GuiSelector* camera_lock_selector;
    GuiToggleButton* camera_lock_toggle;
    GuiToggleButton* camera_lock_tot_toggle;
    GuiToggleButton* camera_lock_cycle_toggle;
    GuiButton* callsigns_toggle;
    GuiToggleButton* mouselook_toggle;
    GuiButton* ui_toggle;
    GuiHelpOverlay* keyboard_help;

    float min_camera_distance = 300.0f;
    float max_camera_distance = 1000.0f;
    float camera_sensitivity = 0.15f;
    glm::vec2 camera_rotation_vector{0.0f, 0.0f};
    glm::vec2 camera_destination{0.0f, 0.0f};
    // camera_position, _yaw, _pitch are defined in main.
    float angle_yaw = -90.0f;
    float angle_pitch = 45.0f;
    float camera_translation_speed = 10.0f;
    const float camera_translation_min = 10.0f;
    const float camera_translation_max = 50.0f;
    float camera_rotation_speed = 1.0f;
    const float camera_rotation_min = 1.0f;
    const float camera_rotation_max = 4.0f;
    P<MouseRenderer> mouse_renderer;
    bool mouselook = false;
    bool invert_mouselook_y = false;

    glm::vec2 diff_2D{0.0f, 0.0f};
    glm::vec3 diff_3D{0.0f, 0.0f, 0.0f};
    float distance_2D = 0.0f;
    float distance_3D = 0.0f;

    glm::vec2 target_position_2D{0.0f, 0.0f};
    glm::vec3 target_position_3D{0.0f, 0.0f, 0.0f};
    glm::vec2 camera_position_2D{0.0f, 0.0f};
    float target_rotation = 0.0f;

    sp::ecs::Entity target_of_target;
    glm::vec2 tot_position_2D{0.0f, 0.0f};
    glm::vec3 tot_position_3D{0.0f, 0.0f, 0.0f};
    glm::vec2 tot_diff_2D{0.0f, 0.0f};
    glm::vec3 tot_diff_3D{0.0f, 0.0f, 0.0f};
    float tot_angle = 0.0f;
    float tot_distance_2D = 0.0f;
    float tot_distance_3D = 0.0f;

    float cycle_time = 0.0f;
    const float cycle_period = 30.0f;

public:
    explicit CinematicViewScreen(RenderLayer* render_layer);
    virtual ~CinematicViewScreen();

    void setTargetTransform(sp::Transform* transform);
    void setMouselook(bool value);
    void updateCamera(sp::Transform* main_transform, sp::Transform* tot_transform);

    virtual void update(float delta) override;
    virtual bool onPointerMove(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onPointerUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

#ifndef CINEMATIC_VIEW_SCREEN_H
#define CINEMATIC_VIEW_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "screenComponents/viewport3d.h"

class GuiSelector;
class GuiToggleButton;

class CinematicViewScreen : public GuiCanvas, public Updatable
{
private:
    const double pi = M_PI;

    GuiViewport3D* viewport;
    P<PlayerSpaceship> target;
    GuiSelector* camera_lock_selector;
    GuiToggleButton* camera_lock_toggle;
    GuiToggleButton* camera_lock_tot_toggle;
    GuiToggleButton* camera_lock_cycle_toggle;
    float min_camera_distance;
    float max_camera_distance;
    glm::vec2 camera_rotation_vector{0, 0};
    glm::vec2 camera_destination{0, 0};
    float angle_yaw;
    float angle_pitch;

    glm::vec2 diff_2D{0, 0};
    glm::vec3 diff_3D{};
    float distance_2D;
    float distance_3D;

    glm::vec2 target_position_2D{0, 0};
    glm::vec3 target_position_3D{};
    // camera_position is a Vector3, so no need to declare one here.
    glm::vec2 camera_position_2D{0, 0};
    float target_rotation;

    P<SpaceObject> target_of_target;

    glm::vec2 tot_position_2D{0, 0};
    glm::vec3 tot_position_3D{};
    glm::vec2 tot_diff_2D{0, 0};
    glm::vec3 tot_diff_3D{};
    float tot_angle;
    float tot_distance_2D;
    float tot_distance_3D;

    float cycle_time;

public:
    explicit CinematicViewScreen(RenderLayer* render_layer, int playerShip = 0);

    virtual void update(float delta) override;
};

#endif//CINEMATIC_VIEW_SCREEN_H

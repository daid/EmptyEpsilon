#include "viewportMainScreen.h"
#include "playerInfo.h"
#include "preferenceManager.h"
#include "components/collision.h"
#include "components/target.h"
#include "main.h"

GuiViewportMainScreen::GuiViewportMainScreen(GuiContainer* owner, string id)
: GuiViewport3D(owner, id)
{
    uint8_t flags = PreferencesManager::get("main_screen_flags","7").toInt();

    if (flags & flag_callsigns)
      showCallsigns();
    if (flags & flag_headings)
      showHeadings();
    if (flags & flag_spacedust)
      showSpacedust();

    first_person = PreferencesManager::get("first_person") == "1";
}

void GuiViewportMainScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        auto pc = my_spaceship.getComponent<PlayerControl>();
        auto transform = my_spaceship.getComponent<sp::Transform>();
        if (!transform)
            return;
        auto target_ship = my_spaceship.getComponent<Target>();
        float target_camera_yaw = transform->getRotation();
        switch(pc ? pc->main_screen_setting : MainScreenSetting::Front)
        {
        case MainScreenSetting::Back: target_camera_yaw += 180; break;
        case MainScreenSetting::Left: target_camera_yaw -= 90; break;
        case MainScreenSetting::Right: target_camera_yaw += 90; break;
        case MainScreenSetting::Target:
            if (target_ship && target_ship->entity)
            {
                if (auto tt = target_ship->entity.getComponent<sp::Transform>()) {
                    auto target_camera_diff = transform->getPosition() - tt->getPosition();
                    target_camera_yaw = vec2ToAngle(target_camera_diff) + 180;
                }
            }
            break;
        default: break;
        }
        camera_pitch = 30.0f;

        float camera_ship_distance = 420.0f;
        float camera_ship_height = 420.0f;
        if (first_person)
        {
            float radius = 300.0f;
            auto physics = my_spaceship.getComponent<sp::Physics>();
            if (physics)
                radius = physics->getSize().x;
            camera_ship_distance = -radius;
            camera_ship_height = radius / 10.f;
            camera_pitch = 0;
        }
        auto cameraPosition2D = transform->getPosition() + vec2FromAngle(target_camera_yaw) * -camera_ship_distance;
        glm::vec3 targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);
        if (first_person)
        {
            camera_position = targetCameraPosition;
            camera_yaw = target_camera_yaw;
        }
        else
        {
            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw += angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
        }
    }
    GuiViewport3D::onDraw(renderer);
}

#include "viewportMainScreen.h"
#include "playerInfo.h"
#include "preferenceManager.h"
#include "spaceObjects/playerSpaceship.h"

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

void GuiViewportMainScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        P<SpaceObject> target_ship = my_spaceship->getTarget();
        float target_camera_yaw = my_spaceship->getRotation();
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Back: target_camera_yaw += 180; break;
        case MSS_Left: target_camera_yaw -= 90; break;
        case MSS_Right: target_camera_yaw += 90; break;
        case MSS_Target:
            if (target_ship)
            {
                auto target_camera_diff = my_spaceship->getPosition() - target_ship->getPosition();
                target_camera_yaw = vec2ToAngle(target_camera_diff) + 180;
            }
            break;
        default: break;
        }
        camera_pitch = 30.0f;

        float camera_ship_distance = 420.0f;
        float camera_ship_height = 420.0f;
        if (first_person)
        {
            camera_ship_distance = -my_spaceship->getRadius();
            camera_ship_height = my_spaceship->getRadius() / 10.f;
            camera_pitch = 0;
        }
        auto cameraPosition2D = my_spaceship->getPosition() + vec2FromAngle(target_camera_yaw) * -camera_ship_distance;
        glm::vec3 targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);
#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
        {
            targetCameraPosition.x = my_spaceship->getPosition().x;
            targetCameraPosition.y = my_spaceship->getPosition().y;
            targetCameraPosition.z = 3000.0;
            camera_pitch = 90.0f;
        }
#endif
        if (first_person)
        {
            camera_position = targetCameraPosition;
            camera_yaw = target_camera_yaw;
        }
        else
        {
            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
        }
    }
    GuiViewport3D::onDraw(window);
}

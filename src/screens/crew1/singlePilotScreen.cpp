#include "main.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "singlePilotScreen.h"
#include "singlePilotView.h"
#include "gui/gui2_element.h"

#include "screenComponents/viewport3d.h"

#include "screenComponents/alertOverlay.h"

SinglePilotScreen::SinglePilotScreen(GuiContainer* owner)
: GuiOverlay(owner, "SINGLEPILOT_SCREEN", colorConfig.background)
{
    // Create a 3D viewport behind everything, to serve as the right-side panel
    viewport = new GuiViewport3D(this, "3D_VIEW");
    viewport->setPosition(1000, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Create left panel for controls.
    left_panel = new GuiElement(this, "LEFT_PANEL");
    left_panel->setPosition(0, 0, ATopLeft)->setSize(1000, GuiElement::GuiSizeMax);
    
    // single pilot
    single_pilot_view = new SinglePilotView(left_panel, my_spaceship);
    single_pilot_view->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    background_crosses = new GuiOverlay(left_panel, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));
}

void SinglePilotScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);

    // Responsively show/hide the 3D viewport.
    if (viewport->getRect().width < viewport->getRect().height / 3.0f)
    {
        viewport->hide();
        left_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    else
    {
        viewport->show();
        left_panel->setSize(1000, GuiElement::GuiSizeMax);
    }

    if (my_spaceship)
    {
        float target_camera_yaw = my_spaceship->getRotation();
        camera_pitch = 30.0f;

        const float camera_ship_distance = 420.0f;
        const float camera_ship_height = 420.0f;
        sf::Vector2f cameraPosition2D = my_spaceship->getPosition() + sf::vector2FromAngle(target_camera_yaw) * -camera_ship_distance;
        sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);
#ifdef DEBUG
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Z))
        {
            targetCameraPosition.x = my_spaceship->getPosition().x;
            targetCameraPosition.y = my_spaceship->getPosition().y;
            targetCameraPosition.z = 3000.0;
            camera_pitch = 90.0f;
        }
#endif
        camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
        camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
    }
}
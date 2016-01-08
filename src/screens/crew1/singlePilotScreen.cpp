#include "main.h"
#include "playerInfo.h"
#include "singlePilotScreen.h"

#include "screenComponents/viewport3d.h"

#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

SinglePilotScreen::SinglePilotScreen(GuiContainer* owner)
: GuiOverlay(owner, "SINGLEPILOT_SCREEN", sf::Color::Black)
{
    viewport = new GuiViewport3D(this, "3D_VIEW");
    viewport->setPosition(1000, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    GuiElement* left_panel = new GuiElement(this, "LEFT_PANEL");
    left_panel->setPosition(0, 0, ATopLeft)->setSize(1000, GuiElement::GuiSizeMax);

    radar = new GuiRadarView(left_panel, "TACTICAL_RADAR", 5000.0, &targets);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 650);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableTargetProjections()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            targets.setToClosestTo(position, 250);
            if (my_spaceship && targets.get())
                my_spaceship->commandSetTarget(targets.get());
            else if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
        },
        [this](sf::Vector2f position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
        },
        [this](sf::Vector2f position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
        }
    );

    energy_display = new GuiKeyValueDisplay(left_panel, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setTextSize(20)->setPosition(-20, -140, ABottomRight)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(left_panel, "HEADING_DISPLAY", 0.45, "Heading", "");
    heading_display->setTextSize(20)->setPosition(-20, -100, ABottomRight)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(left_panel, "VELOCITY_DISPLAY", 0.45, "Speed", "");
    velocity_display->setTextSize(20)->setPosition(-20, -60, ABottomRight)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(left_panel, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setTextSize(20)->setPosition(-20, -20, ABottomRight)->setSize(240, 40);
    
    missile_aim = new GuiRotationDial(left_panel, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
        radar->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 700);
    tube_controls = new GuiMissileTubeControls(left_panel, "MISSILE_TUBES");
    lock_aim = new GuiToggleButton(left_panel, "LOCK_AIM", "Lock", nullptr);
    lock_aim->setPosition(300, 130, ATopCenter)->setSize(130, 50);
    lock_aim->setValue(true);

    GuiAutoLayout* engine_layout = new GuiAutoLayout(left_panel, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalLeftToRight);
    engine_layout->setPosition(20, 70, ATopLeft)->setSize(GuiElement::GuiSizeMax, 250);
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);

    (new GuiDockingButton(left_panel, "DOCKING"))->setPosition(20, 20, ATopLeft)->setSize(280, 50);
    (new GuiShieldsEnableButton(left_panel, "SHIELDS_ENABLE"))->setPosition(300, 20, ATopLeft)->setSize(280, 50);

    (new GuiOpenCommsButton(left_panel, "OPEN_COMMS_BUTTON", &targets))->setPosition(-20, 20, ATopRight)->setSize(250, 50);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    //TODO: Fit this somewhere on the already full and chaotic tactical UI...
    //(new GuiCombatManeuver(left_panel, "COMBAT_MANEUVER"))->setPosition(-50, -50, ABottomRight)->setSize(280, 265);
}

void SinglePilotScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1));
        float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(string(velocity, 1) + "km/min");
        
        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);

        shields_display->setValue(string(my_spaceship->getShieldPercentage(0)) + "% " + string(my_spaceship->getShieldPercentage(1)) + "%");
        targets.set(my_spaceship->getTarget());
        
        if (lock_aim->getValue())
        {
            missile_aim->setValue(my_spaceship->getRotation());
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
            radar->setMissileTargetAngle(missile_aim->getValue());
        }
    }
    GuiOverlay::onDraw(window);

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

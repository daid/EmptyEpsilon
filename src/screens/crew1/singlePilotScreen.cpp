#include "main.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "singlePilotScreen.h"
#include "preferenceManager.h"

#include "screenComponents/viewport3d.h"

#include "screenComponents/alertOverlay.h"
#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/aimLock.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_rotationdial.h"

SinglePilotScreen::SinglePilotScreen(GuiContainer* owner)
: GuiOverlay(owner, "SINGLEPILOT_SCREEN", colorConfig.background)
{
    // Create a 3D viewport behind everything, to serve as the right-side panel
    viewport = new GuiViewport3D(this, "3D_VIEW");
    viewport->setPosition(1000, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    first_person = PreferencesManager::get("first_person") == "1";

    // Create left panel for controls.
    left_panel = new GuiElement(this, "LEFT_PANEL");
    left_panel->setPosition(0, 0, ATopLeft)->setSize(1000, GuiElement::GuiSizeMax);

    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(left_panel, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradientSingle");

    background_crosses = new GuiOverlay(left_panel, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // 5U tactical radar with piloting features.
    radar = new GuiRadarView(left_panel, "TACTICAL_RADAR", 5000.0, &targets);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 650);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
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

    // Joystick controls.
    radar->setJoystickCallbacks(
        [this](float x_position) {
            if (my_spaceship)
            {
                float angle = my_spaceship->getRotation() + x_position;
                my_spaceship->commandTargetRotation(angle);
            }
        },
        [this](float y_position) {
            if (my_spaceship && (fabs(y_position) > 20))
            {
                // Add some more hysteresis, since y-axis can be hard to keep at 0
                float value;
                if (y_position > 0)
                    value = (y_position-20) * 1.25 / 100;
                else
                    value = (y_position+20) * 1.25 / 100;

                my_spaceship->commandCombatManeuverBoost(-value);
            }
            else if (my_spaceship)
            {
                my_spaceship->commandCombatManeuverBoost(0.0);
            }
        },
        [this](float z_position) {
            if (my_spaceship)
                my_spaceship->commandImpulse(-(z_position / 100));
        },
        [this](float r_position) {
            if (my_spaceship)
                my_spaceship->commandCombatManeuverStrafe(r_position / 100);
        }
    );

    // Ship stats and combat maneuver at bottom right corner of left panel.
    (new GuiCombatManeuver(left_panel, "COMBAT_MANEUVER"))->setPosition(-20, -180, ABottomRight)->setSize(200, 150);

    energy_display = new GuiKeyValueDisplay(left_panel, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(-20, -140, ABottomRight)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(left_panel, "HEADING_DISPLAY", 0.45, "Heading", "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setPosition(-20, -100, ABottomRight)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(left_panel, "VELOCITY_DISPLAY", 0.45, "Speed", "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setPosition(-20, -60, ABottomRight)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(left_panel, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setIcon("gui/icons/shields")->setTextSize(20)->setPosition(-20, -20, ABottomRight)->setSize(240, 40);

    // Unlocked missile aim dial and lock controls.
    missile_aim = new GuiRotationDial(left_panel, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 700);

    // Weapon tube controls.
    tube_controls = new GuiMissileTubeControls(left_panel, "MISSILE_TUBES");
    tube_controls->setPosition(20, -20, ABottomLeft);
    radar->enableTargetProjections(tube_controls);

    // Engine layout in top left corner of left panel.
    GuiAutoLayout* engine_layout = new GuiAutoLayout(left_panel, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalLeftToRight);
    engine_layout->setPosition(20, 80, ATopLeft)->setSize(GuiElement::GuiSizeMax, 250);
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);

    // Docking, comms, and shields buttons across top.
    (new GuiDockingButton(left_panel, "DOCKING"))->setPosition(20, 20, ATopLeft)->setSize(250, 50);
    (new GuiOpenCommsButton(left_panel, "OPEN_COMMS_BUTTON", "Open Comms", &targets))->setPosition(270, 20, ATopLeft)->setSize(250, 50);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiShieldsEnableButton(left_panel, "SHIELDS_ENABLE"))->setPosition(520, 20, ATopLeft)->setSize(250, 50);

    // Missile lock button near top right of left panel.
    lock_aim = new AimLockButton(left_panel, "LOCK_AIM", tube_controls, missile_aim);
    lock_aim->setPosition(250, 70, ATopCenter)->setSize(130, 50);
    
    (new GuiCustomShipFunctions(this, singlePilot, ""))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void SinglePilotScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1));
        float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(string(velocity, 1) + DISTANCE_UNIT_1K + "/min");

        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);

        shields_display->setValue(string(my_spaceship->getShieldPercentage(0)) + "% " + string(my_spaceship->getShieldPercentage(1)) + "%");

        missile_aim->setVisible(tube_controls->getManualAim());

        targets.set(my_spaceship->getTarget());
    }
    GuiOverlay::onDraw(window);

    // Responsively show/hide the 3D viewport.
    if (viewport->getRect().width < viewport->getRect().height / 3.0f)
    {
        viewport->hide();
        left_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    } else {
        viewport->show();
        left_panel->setSize(1000, GuiElement::GuiSizeMax);
    }

    if (my_spaceship)
    {
        float target_camera_yaw = my_spaceship->getRotation();
        camera_pitch = 30.0f;

        float camera_ship_distance = 420.0f;
        float camera_ship_height = 420.0f;

        if (first_person)
        {
            camera_ship_distance = -(my_spaceship->getRadius() * 1.5);
            camera_ship_height = my_spaceship->getRadius() / 10.f;
            camera_pitch = 0;
        }

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
        if (first_person)
        {
            camera_position = targetCameraPosition;
            camera_yaw = target_camera_yaw;
        } else {
            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
        }
    }
}

void SinglePilotScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && my_spaceship)
    {
        if (key.hotkey == "TURN_LEFT")
            my_spaceship->commandTargetRotation(my_spaceship->getRotation() - 5.0f);
        else if (key.hotkey == "TURN_RIGHT")
            my_spaceship->commandTargetRotation(my_spaceship->getRotation() + 5.0f);
    }
    if (key.category == "WEAPONS" && my_spaceship)
    {
        if (key.hotkey == "NEXT_ENEMY_TARGET")
        {
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (current_found && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && my_spaceship->isEnemy(obj) && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    continue;
                }
                if (my_spaceship->isEnemy(obj) && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
        }
        if (key.hotkey == "NEXT_TARGET")
        {
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (obj == my_spaceship)
                    continue;
                if (current_found && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get() || obj == my_spaceship)
                    continue;
                if (sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
        }
        if (key.hotkey == "AIM_MISSILE_LEFT")
        {
            missile_aim->setValue(missile_aim->getValue() - 5.0f);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
        if (key.hotkey == "AIM_MISSILE_RIGHT")
        {
            missile_aim->setValue(missile_aim->getValue() + 5.0f);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
    }
}

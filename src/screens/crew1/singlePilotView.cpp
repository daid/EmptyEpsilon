#include "singlePilotView.h"

#include "engine.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

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

SinglePilotView::SinglePilotView(GuiContainer* owner, P<PlayerSpaceship>& targetSpaceship)
: GuiElement(owner, "SINGLE_PILOT_VIEW"), target_spaceship(targetSpaceship)
{
    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(this, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradientSingle");

    // 5U tactical radar with piloting features.
    radar = new GuiRadarView(this, "TACTICAL_RADAR", 5000.0, &targets, target_spaceship);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 650);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (target_spaceship && targets.get())
                target_spaceship->commandSetTarget(targets.get());
            else if (target_spaceship)
                target_spaceship->commandTargetRotation(sf::vector2ToAngle(position - target_spaceship->getPosition()));
        },
        [this](sf::Vector2f position) {
            if (target_spaceship)
                target_spaceship->commandTargetRotation(sf::vector2ToAngle(position - target_spaceship->getPosition()));
        },
        [this](sf::Vector2f position) {
            if (target_spaceship)
                target_spaceship->commandTargetRotation(sf::vector2ToAngle(position - target_spaceship->getPosition()));
        }
    );

    // Joystick controls.
    radar->setJoystickCallbacks(
        [this](float x_position) {
            if (target_spaceship)
            {
                float angle = target_spaceship->getRotation() + x_position;
                target_spaceship->commandTargetRotation(angle);
            }
        },
        [this](float y_position) {
            if (target_spaceship && (fabs(y_position) > 20))
            {
                // Add some more hysteresis, since y-axis can be hard to keep at 0
                float value;
                if (y_position > 0)
                    value = (y_position-20) * 1.25 / 100;
                else
                    value = (y_position+20) * 1.25 / 100;

                target_spaceship->commandCombatManeuverBoost(-value);
            }
            else if (target_spaceship)
            {
                target_spaceship->commandCombatManeuverBoost(0.0);
            }
        },
        [this](float z_position) {
            if (target_spaceship)
                target_spaceship->commandImpulse(-(z_position / 100));
        },
        [this](float r_position) {
            if (target_spaceship)
                target_spaceship->commandCombatManeuverStrafe(r_position / 100);
        }
    );

    // Ship stats and combat maneuver at bottom right corner of left panel.
    (new GuiCombatManeuver(this, "COMBAT_MANEUVER", target_spaceship))->setPosition(-20, -180, ABottomRight)->setSize(200, 150);

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(-20, -140, ABottomRight)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(this, "HEADING_DISPLAY", 0.45, "Heading", "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setPosition(-20, -100, ABottomRight)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(this, "VELOCITY_DISPLAY", 0.45, "Speed", "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setPosition(-20, -60, ABottomRight)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setIcon("gui/icons/shields")->setTextSize(20)->setPosition(-20, -20, ABottomRight)->setSize(240, 40);

    // Unlocked missile aim dial and lock controls.
    missile_aim = new GuiRotationDial(this, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 700);

    // Weapon tube controls.
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES", target_spaceship);
    tube_controls->setPosition(20, -20, ABottomLeft);
    radar->enableTargetProjections(tube_controls);

    // Engine layout in top left corner of left panel.
    GuiAutoLayout* engine_layout = new GuiAutoLayout(this, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalLeftToRight);
    engine_layout->setPosition(20, 80, ATopLeft)->setSize(GuiElement::GuiSizeMax, 250);
    (new GuiImpulseControls(engine_layout, "IMPULSE", target_spaceship))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP", target_spaceship))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP", target_spaceship))->setSize(100, GuiElement::GuiSizeMax);

    // Docking, comms, and shields buttons across top.
    (new GuiDockingButton(this, "DOCKING", target_spaceship))->setPosition(20, 20, ATopLeft)->setSize(250, 50);
    if (target_spaceship == my_spaceship) 
    {
        (new GuiOpenCommsButton(this, "OPEN_COMMS_BUTTON", &targets))->setPosition(270, 20, ATopLeft)->setSize(250, 50);
        (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE", target_spaceship))->setPosition(520, 20, ATopLeft)->setSize(250, 50);

    // Missile lock button near top right of left panel.
    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim, target_spaceship);
    lock_aim->setPosition(250, 70, ATopCenter)->setSize(130, 50);
    
    (new GuiCustomShipFunctions(this, singlePilot, "", target_spaceship))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void SinglePilotView::onDraw(sf::RenderTarget& window)
{
    if (target_spaceship)
    {
        energy_display->setValue(string(int(target_spaceship->energy_level)));
        heading_display->setValue(string(fmodf(target_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1));
        float velocity = sf::length(target_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(string(velocity, 1) + DISTANCE_UNIT_1K + "/min");

        warp_controls->setVisible(target_spaceship->has_warp_drive);
        jump_controls->setVisible(target_spaceship->has_jump_drive);

        shields_display->setValue(string(target_spaceship->getShieldPercentage(0)) + "% " + string(target_spaceship->getShieldPercentage(1)) + "%");

        missile_aim->setVisible(tube_controls->getManualAim());

        targets.set(target_spaceship->getTarget());
    }
    GuiElement::onDraw(window);
}

void SinglePilotView::onHotkey(const HotkeyResult& key)
{
    if (isVisible()){
        if (key.category == "HELMS" && target_spaceship)
        {
            if (key.hotkey == "TURN_LEFT")
                target_spaceship->commandTargetRotation(target_spaceship->getRotation() - 5.0f);
            else if (key.hotkey == "TURN_RIGHT")
                target_spaceship->commandTargetRotation(target_spaceship->getRotation() + 5.0f);
        }
        if (key.category == "WEAPONS" && target_spaceship)
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
                    if (current_found && sf::length(obj->getPosition() - target_spaceship->getPosition()) < 5000 && target_spaceship->isEnemy(obj) && target_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(target_spaceship))
                    {
                        targets.set(obj);
                        target_spaceship->commandSetTarget(targets.get());
                        return;
                    }
                }
                foreach(SpaceObject, obj, space_object_list)
                {
                    if (obj == targets.get())
                    {
                        continue;
                    }
                    if (target_spaceship->isEnemy(obj) && sf::length(obj->getPosition() - target_spaceship->getPosition()) < 5000 && target_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(target_spaceship))
                    {
                        targets.set(obj);
                        target_spaceship->commandSetTarget(targets.get());
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
                    if (obj == target_spaceship)
                        continue;
                    if (current_found && sf::length(obj->getPosition() - target_spaceship->getPosition()) < 5000 && obj->canBeTargetedBy(target_spaceship))
                    {
                        targets.set(obj);
                        target_spaceship->commandSetTarget(targets.get());
                        return;
                    }
                }
                foreach(SpaceObject, obj, space_object_list)
                {
                    if (obj == targets.get() || obj == target_spaceship)
                        continue;
                    if (sf::length(obj->getPosition() - target_spaceship->getPosition()) < 5000 && obj->canBeTargetedBy(target_spaceship))
                    {
                        targets.set(obj);
                        target_spaceship->commandSetTarget(targets.get());
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
}

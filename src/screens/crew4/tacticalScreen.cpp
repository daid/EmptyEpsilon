#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "tacticalScreen.h"

#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/aimLock.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_rotationdial.h"

TacticalScreen::TacticalScreen(GuiContainer* owner)
: GuiOverlay(owner, "TACTICAL_SCREEN", colorConfig.background)
{
    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(this, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradientSingle");

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Short-range tactical radar with a 5U range.
    radar = new GuiRadarView(this, "TACTICAL_RADAR", 5000.0, &targets, my_spaceship);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 750);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);

    // Control targeting and piloting with radar interactions.
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

    // Ship statistics in the top left corner.
    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(this, "HEADING_DISPLAY", 0.45, "Heading", "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(this, "VELOCITY_DISPLAY", 0.45, "Speed", "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setIcon("gui/icons/shields")->setTextSize(20)->setPosition(20, 220, ATopLeft)->setSize(240, 40);

    // Weapon tube loading controls in the bottom left corner.
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES", my_spaceship);
    tube_controls->setPosition(20, -20, ABottomLeft);
    radar->enableTargetProjections(tube_controls);

    // Weapon tube locking, and manual aiming controls.
    missile_aim = new GuiRotationDial(this, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->hide()->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim, my_spaceship);
    lock_aim->setPosition(250, 20, ATopCenter)->setSize(110, 50);

    // Combat maneuver and propulsion controls in the bottom right corner.
    (new GuiCombatManeuver(this, "COMBAT_MANEUVER", my_spaceship))->setPosition(-20, -390, ABottomRight)->setSize(200, 150);
    GuiAutoLayout* engine_layout = new GuiAutoLayout(this, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalRightToLeft);
    engine_layout->setPosition(-20, -80, ABottomRight)->setSize(GuiElement::GuiSizeMax, 300);
    (new GuiImpulseControls(engine_layout, "IMPULSE", my_spaceship))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP", my_spaceship))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP", my_spaceship))->setSize(100, GuiElement::GuiSizeMax);
    (new GuiDockingButton(this, "DOCKING", my_spaceship))->setPosition(-20, -20, ABottomRight)->setSize(280, 50);

    (new GuiCustomShipFunctions(this, tacticalOfficer, "", my_spaceship))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void TacticalScreen::onDraw(sf::RenderTarget& window)
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
        targets.set(my_spaceship->getTarget());
    }
    GuiOverlay::onDraw(window);
}

void TacticalScreen::onHotkey(const HotkeyResult& key)
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

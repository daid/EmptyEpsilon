#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "tacticalScreen.h"
#include "preferenceManager.h"

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
#include "screenComponents/powerDamageIndicator.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"
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
    radar = new GuiRadarView(this, "TACTICAL_RADAR", &targets);
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
    radar->setAutoRotating(PreferencesManager::get("tactical_radar_lock","0")=="1");

    GuiAutoLayout* stats = new GuiAutoLayout(this, "STATS", GuiAutoLayout::LayoutVerticalTopToBottom);
    stats->setPosition(20, 100, ATopLeft)->setSize(240, 160);

    // Ship statistics in the top left corner.
    energy_display = new GuiKeyValueDisplay(stats, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(stats, "HEADING_DISPLAY", 0.45, tr("Heading"), "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(stats, "VELOCITY_DISPLAY", 0.45, tr("Speed"), "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(stats, "SHIELDS_DISPLAY", 0.45, tr("Shields"), "");
    shields_display->setIcon("gui/icons/shields")->setTextSize(20)->setSize(240, 40);

    // Weapon tube loading controls in the bottom left corner.
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    tube_controls->setPosition(20, -20, ABottomLeft);
    radar->enableTargetProjections(tube_controls);

    // Beam controls beneath the radar.
    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        GuiElement* beam_info_box = new GuiElement(this, "BEAM_INFO_BOX");
        beam_info_box->setPosition(0, -20, ABottomCenter)->setSize(500, 50);
        (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", tr("Beams"), 30))->addBackground()->setPosition(0, 0, ABottomLeft)->setSize(80, 50);
        (new GuiBeamFrequencySelector(beam_info_box, "BEAM_FREQUENCY_SELECTOR"))->setPosition(80, 0, ABottomLeft)->setSize(132, 50);
        (new GuiPowerDamageIndicator(beam_info_box, "", SYS_BeamWeapons, ACenterLeft))->setPosition(0, 0, ABottomLeft)->setSize(212, 50);
        (new GuiBeamTargetSelector(beam_info_box, "BEAM_TARGET_SELECTOR"))->setPosition(0, 0, ABottomRight)->setSize(288, 50);
    }

    // Weapon tube locking, and manual aiming controls.
    missile_aim = new AimLock(this, "MISSILE_AIM", radar, -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->hide()->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim);
    lock_aim->setPosition(250, 20, ATopCenter)->setSize(110, 50);

    // Combat maneuver and propulsion controls in the bottom right corner.
    (new GuiCombatManeuver(this, "COMBAT_MANEUVER"))->setPosition(-20, -390, ABottomRight)->setSize(200, 150);
    GuiAutoLayout* engine_layout = new GuiAutoLayout(this, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalRightToLeft);
    engine_layout->setPosition(-20, -80, ABottomRight)->setSize(GuiElement::GuiSizeMax, 300);
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);
    (new GuiDockingButton(this, "DOCKING"))->setPosition(-20, -20, ABottomRight)->setSize(280, 50);

    (new GuiCustomShipFunctions(this, tacticalOfficer, ""))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void TacticalScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1));
        float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(tr("{value} {unit}/min").format({{"value", string(velocity, 1)}, {"unit", DISTANCE_UNIT_1K}}));

        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);

        string shields_value = string(my_spaceship->getShieldPercentage(0)) + "%";
        if (my_spaceship->hasSystem(SYS_RearShield))
        {
            shields_value += " " + string(my_spaceship->getShieldPercentage(1)) + "%";
        }
        shields_display->setValue(shields_value);
        if (my_spaceship->hasSystem(SYS_FrontShield) || my_spaceship->hasSystem(SYS_RearShield))
        {
            shields_display->show();
        } else {
            shields_display->hide();
        }

        targets.set(my_spaceship->getTarget());
    }
    GuiOverlay::onDraw(window);
}

bool TacticalScreen::onJoystickAxis(const AxisAction& axisAction){
    if(my_spaceship){
        if (axisAction.category == "HELMS"){
            if (axisAction.action == "IMPULSE"){
                my_spaceship->commandImpulse(axisAction.value);
                return true;
            } else if (axisAction.action == "ROTATE"){
                my_spaceship->commandTurnSpeed(axisAction.value);
                return true;
            } else if (axisAction.action == "STRAFE"){
                my_spaceship->commandCombatManeuverStrafe(axisAction.value);
                return true;
            } else if (axisAction.action == "BOOST"){
                my_spaceship->commandCombatManeuverBoost(axisAction.value);
                return true;
            }
        }
    }
    return false;
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
                if (current_found && sf::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && my_spaceship->isEnemy(obj) && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
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
                if (my_spaceship->isEnemy(obj) && sf::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
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
                if (current_found && sf::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && obj->canBeTargetedBy(my_spaceship))
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
                if (sf::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && obj->canBeTargetedBy(my_spaceship))
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

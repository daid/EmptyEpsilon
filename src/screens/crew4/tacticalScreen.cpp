#include "tacticalScreen.h"
#include <i18n.h>
#include "playerInfo.h"
#include "featureDefs.h"
#include "gameGlobalInfo.h"
#include "preferenceManager.h"

#include "components/reactor.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/collision.h"
#include "components/maneuveringthrusters.h"
#include "components/shields.h"
#include "components/target.h"
#include "components/radar.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"

#include "screenComponents/aimLock.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"
#include "screenComponents/combatManeuver.h"
#include "screenComponents/customShipFunctions.h"
#include "screenComponents/dockingButton.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/infoDisplay.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/missileTubeControls.h"
#include "screenComponents/powerDamageIndicator.h"
#include "screenComponents/radarView.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/warpControls.h"

#include "gui/theme.h"
#include "gui/gui2_image.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"

TacticalScreen::TacticalScreen(GuiContainer* owner)
: GuiOverlay(owner, "TACTICAL_SCREEN", GuiTheme::getColor("background"))
{
    // Render the radar shadow and background decorations.
    (new GuiImage(this, "BACKGROUND_GRADIENT", ""))->setTextureThemed("background.gradient_single")->setPosition(glm::vec2(0, 0), sp::Alignment::Center)->setSize(1200, 900);

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiledThemed("background.crosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Short-range tactical radar with a 5U range.
    radar = new GuiRadarView(this, "TACTICAL_RADAR", &targets);
    radar->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 750);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);

    // Control targeting and piloting with radar interactions.
    radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            auto last_target = targets.get();
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (my_spaceship && targets.get() && (targets.get() != last_target)) {
                my_player_info->commandSetTarget(targets.get());
                drag_rotate = false;
            } else if (auto transform = my_spaceship.getComponent<sp::Transform>()) {
                my_player_info->commandTargetRotation(vec2ToAngle(position - transform->getPosition()));
                drag_rotate = true;
            }
        },
        [this](glm::vec2 position) {
            if (drag_rotate) {
                if (auto transform = my_spaceship.getComponent<sp::Transform>())
                    my_player_info->commandTargetRotation(vec2ToAngle(position - transform->getPosition()));
            }
        },
        [this](glm::vec2 position) {
            drag_rotate=false;
        }, nullptr
    );
    radar->setAutoRotating(PreferencesManager::get("tactical_radar_lock","0")=="1");

    auto stats = new GuiElement(this, "STATS");
    stats->setPosition(20, 100, sp::Alignment::TopLeft)->setSize(240, 160)->setAttribute("layout", "vertical");

    // Ship statistics in the top left corner.
    auto energy_display = new EnergyInfoDisplay(stats, "ENERGY_DISPLAY", 0.45);
    energy_display->setSize(240, 40);
    auto heading_display = new HeadingInfoDisplay(stats, "HEADING_DISPLAY", 0.45);
    heading_display->setSize(240, 40);
    auto velocity_display = new VelocityInfoDisplay(stats, "VELOCITY_DISPLAY", 0.45);
    velocity_display->setSize(240, 40);
    auto shields_display = new ShieldsInfoDisplay(stats, "SHIELDS_DISPLAY", 0.45);
    shields_display->setSize(240, 40);

    // Weapon tube loading controls in the bottom left corner.
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    tube_controls->setPosition(20, -20, sp::Alignment::BottomLeft);
    radar->enableTargetProjections(tube_controls);

    beam_info_box = new GuiElement(this, "BEAM_INFO_BOX");
    beam_info_box
        ->setPosition(0.0f, -20.0f, sp::Alignment::BottomCenter)
        ->setSize(500.0f, 50.0f)
        ->hide();

    // Beam controls beneath the radar.
    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        beam_info_box->show();
        (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", tr("Beams"), 30))->addBackground()->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(80, 50);
        (new GuiBeamFrequencySelector(beam_info_box, "BEAM_FREQUENCY_SELECTOR"))->setPosition(80, 0, sp::Alignment::BottomLeft)->setSize(132, 50);
        (new GuiPowerDamageIndicator(beam_info_box, "", ShipSystem::Type::BeamWeapons, sp::Alignment::CenterLeft))->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(212, 50);
        (new GuiBeamTargetSelector(beam_info_box, "BEAM_TARGET_SELECTOR"))->setPosition(0, 0, sp::Alignment::BottomRight)->setSize(288, 50);
    }

    // Weapon tube locking, and manual aiming controls.
    missile_aim = new AimLock(this, "MISSILE_AIM", radar, -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->hide()->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim);
    lock_aim->setPosition(250, 20, sp::Alignment::TopCenter)->setSize(110, 50);

    // Combat maneuver and propulsion controls in the bottom right corner.
    (new GuiCombatManeuver(this, "COMBAT_MANEUVER"))->setPosition(-20, -390, sp::Alignment::BottomRight)->setSize(200, 150);
    GuiElement* engine_layout = new GuiElement(this, "ENGINE_LAYOUT");
    engine_layout->setPosition(-20, -80, sp::Alignment::BottomRight)->setSize(GuiElement::GuiSizeMax, 300)->setAttribute("layout", "horizontalright");
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);
    (new GuiDockingButton(this, "DOCKING"))->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(280, 50);

    (new GuiCustomShipFunctions(this, CrewPosition::tacticalOfficer, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void TacticalScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        warp_controls->setVisible(my_spaceship.hasComponent<WarpDrive>());
        jump_controls->setVisible(my_spaceship.hasComponent<JumpDrive>());
        beam_info_box->setVisible(my_spaceship.hasComponent<BeamWeaponSys>() && (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage));

        const bool has_tubes = my_spaceship.hasComponent<MissileTubes>();
        lock_aim->setVisible(has_tubes);
        missile_aim->setVisible(has_tubes && tube_controls->getManualAim());

        auto target = my_spaceship.getComponent<Target>();
        targets.set(target ? target->entity : sp::ecs::Entity{});
    }
    GuiOverlay::onDraw(renderer);
}

void TacticalScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        auto thrusters = my_spaceship.getComponent<ManeuveringThrusters>();
        float turn_scale = thrusters ? thrusters->speed : 10.0f;
        auto continuous_angle = (keys.helms_turn_right.getContinuousValue() - keys.helms_turn_left.getContinuousValue()) * turn_scale;
        continuous_angle += (keys.helms_turn_right.getAxis0Value() - keys.helms_turn_left.getAxis0Value()) * turn_scale;
        continuous_angle += (keys.helms_turn_right.getAxis1Value() - keys.helms_turn_left.getAxis1Value()) * turn_scale;
        float discrete_angle = 0.0f;
        if (keys.helms_turn_right.isDiscreteStepDown() || keys.helms_turn_right.isRepeatReady()) discrete_angle += 5.0f;
        if (keys.helms_turn_left.isRepeatReady()) discrete_angle -= 5.0f;
        if (continuous_angle != 0.0f)
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(transform->getRotation() + continuous_angle + discrete_angle);
            continuous_turning = true;
        }
        else if (discrete_angle != 0.0f)
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(transform->getRotation() + discrete_angle);
            continuous_turning = false;
        }
        else if (continuous_turning)
        {
            my_player_info->commandTurnSpeed(0.0f);
            continuous_turning = false;
        }

        if (keys.weapons_enemy_next_target.isDiscreteStepDown() || keys.weapons_enemy_next_target.isRepeatReady())
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>()) {
                auto lrr = my_spaceship.getComponent<LongRangeRadar>();
                targets.setNext(transform->getPosition(), lrr ? lrr->short_range : 5000.0f, TargetsContainer::Targetable, FactionRelation::Enemy);
                my_player_info->commandSetTarget(targets.get());
            }
        }
        if (keys.weapons_next_target.isDiscreteStepDown() || keys.weapons_next_target.isRepeatReady())
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>()) {
                auto lrr = my_spaceship.getComponent<LongRangeRadar>();
                targets.setNext(transform->getPosition(), lrr ? lrr->short_range : 5000.0f, TargetsContainer::Targetable);
                my_player_info->commandSetTarget(targets.get());
            }
        }

        auto aim_adjust = (keys.weapons_aim_left.getContinuousValue() + keys.weapons_aim_left.getAxis0Value() + keys.weapons_aim_left.getAxis1Value())
            - (keys.weapons_aim_right.getContinuousValue() + keys.weapons_aim_right.getAxis0Value() + keys.weapons_aim_right.getAxis1Value());
        if (aim_adjust != 0.0f)
        {
            missile_aim->setValue(missile_aim->getValue() - 5.0f * aim_adjust);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
        if (keys.weapons_aim_left.isDiscreteStepDown() || keys.weapons_aim_left.isRepeatReady())
        {
            missile_aim->setValue(missile_aim->getValue() - 5.0f);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
        if (keys.weapons_aim_right.isDiscreteStepDown() || keys.weapons_aim_right.isRepeatReady())
        {
            missile_aim->setValue(missile_aim->getValue() + 5.0f);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
    }
}

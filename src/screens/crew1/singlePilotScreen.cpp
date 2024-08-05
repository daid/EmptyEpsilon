#include "main.h"
#include "i18n.h"
#include "featureDefs.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "singlePilotScreen.h"
#include "preferenceManager.h"

#include "components/reactor.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/collision.h"
#include "components/maneuveringthrusters.h"
#include "components/shields.h"
#include "components/target.h"
#include "components/radar.h"

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
#include "screenComponents/powerDamageIndicator.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_rotationdial.h"
#include "gui/gui2_image.h"
#include "gui/gui2_label.h"

SinglePilotScreen::SinglePilotScreen(GuiContainer* owner)
: GuiOverlay(owner, "SINGLEPILOT_SCREEN", colorConfig.background)
{
    // Render the radar shadow and background decorations.
    (new GuiImage(this, "BACKGROUND_GRADIENT", "gui/background/gradientSingle.png"))->setPosition(glm::vec2(0, 0), sp::Alignment::Center)->setSize(1200, 900);

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // 5U tactical radar with piloting features.
    radar = new GuiRadarView(this, "TACTICAL_RADAR", &targets);
    radar->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 650);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (my_spaceship && targets.get())
                my_player_info->commandSetTarget(targets.get());
            else if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(vec2ToAngle(position - transform->getPosition()));
        },
        [](glm::vec2 position) {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(vec2ToAngle(position - transform->getPosition()));
        },
        [](glm::vec2 position) {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(vec2ToAngle(position - transform->getPosition()));
        }
    );
    radar->setAutoRotating(PreferencesManager::get("single_pilot_radar_lock","0")=="1");

    // Ship stats and combat maneuver at bottom right corner of left panel.
    combat_maneuver = new GuiCombatManeuver(this, "COMBAT_MANEUVER");
    combat_maneuver->setPosition(-20, -180, sp::Alignment::BottomRight)->setSize(200, 150)->setVisible(my_spaceship && my_spaceship.hasComponent<CombatManeuveringThrusters>());

    auto stats = new GuiElement(this, "STATS");
    stats->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(240, 160)->setAttribute("layout", "vertical");
    energy_display = new GuiKeyValueDisplay(stats, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(stats, "HEADING_DISPLAY", 0.45, tr("Heading"), "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(stats, "VELOCITY_DISPLAY", 0.45, tr("Speed"), "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(stats, "SHIELDS_DISPLAY", 0.45, tr("Shields"), "");
    shields_display->setIcon("gui/icons/shields")->setTextSize(20)->setSize(240, 40);

    // Unlocked missile aim dial and lock controls.
    missile_aim = new AimLock(this, "MISSILE_AIM", radar, -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 700);

    // Weapon tube controls.
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    tube_controls->setPosition(20, -20, sp::Alignment::BottomLeft);
    radar->enableTargetProjections(tube_controls);

    // Beam controls beneath the radar.
    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        GuiElement* beam_info_box = new GuiElement(this, "BEAM_INFO_BOX");
        beam_info_box->setPosition(0, -20, sp::Alignment::BottomCenter)->setSize(500, 50);
        (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", tr("Beams"), 30))->addBackground()->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(80, 50);
        (new GuiBeamFrequencySelector(beam_info_box, "BEAM_FREQUENCY_SELECTOR"))->setPosition(80, 0, sp::Alignment::BottomLeft)->setSize(132, 50);
        (new GuiPowerDamageIndicator(beam_info_box, "", ShipSystem::Type::BeamWeapons, sp::Alignment::CenterLeft))->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(212, 50);
        (new GuiBeamTargetSelector(beam_info_box, "BEAM_TARGET_SELECTOR"))->setPosition(0, 0, sp::Alignment::BottomRight)->setSize(288, 50);
    }

    // Engine layout in top left corner of left panel.
    auto engine_layout = new GuiElement(this, "ENGINE_LAYOUT");
    engine_layout->setPosition(20, 80, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 250)->setAttribute("layout", "horizontal");
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);

    // Docking, comms, and shields buttons across top.
    (new GuiDockingButton(this, "DOCKING"))->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(250, 50);
    (new GuiOpenCommsButton(this, "OPEN_COMMS_BUTTON", tr("Open Comms"), &targets))->setPosition(270, 20, sp::Alignment::TopLeft)->setSize(250, 50);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(520, 20, sp::Alignment::TopLeft)->setSize(250, 50);

    // Missile lock button near top right of left panel.
    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim);
    lock_aim->setPosition(250, 70, sp::Alignment::TopCenter)->setSize(130, 50);

    (new GuiCustomShipFunctions(this, CrewPosition::singlePilot, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void SinglePilotScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        auto reactor = my_spaceship.getComponent<Reactor>();
        energy_display->setVisible(reactor);
        if (reactor)
            energy_display->setValue(string(int(reactor->energy)));
        auto transform = my_spaceship.getComponent<sp::Transform>();
        auto physics = my_spaceship.getComponent<sp::Physics>();
        if (transform)
            heading_display->setValue(string(transform->getRotation() - 270, 1));
        if (physics) {
            float velocity = glm::length(physics->getVelocity()) / 1000 * 60;
            velocity_display->setValue(tr("{value} {unit}/min").format({{"value", string(velocity, 1)}, {"unit", DISTANCE_UNIT_1K}}));
        }

        warp_controls->setVisible(my_spaceship.hasComponent<WarpDrive>());
        jump_controls->setVisible(my_spaceship.hasComponent<JumpDrive>());

        auto shields = my_spaceship.getComponent<Shields>();
        if (shields) {
            string shields_value = "";
            for(auto& shield : shields->entries)
                shields_value += string(shield.level * 100.0f / shield.max, 0) + "% ";
            shields_display->show();
            shields_display->setValue(shields_value);
        } else {
            shields_display->hide();
        }

        missile_aim->setVisible(tube_controls->getManualAim());

        auto target = my_spaceship.getComponent<Target>();
        if (target)
            targets.set(target->entity);
        else
            targets.set(sp::ecs::Entity{});
    }
    GuiOverlay::onDraw(renderer);
}

void SinglePilotScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        auto angle = (keys.helms_turn_right.getValue() - keys.helms_turn_left.getValue()) * 5.0f;
        if (angle != 0.0f)
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(transform->getRotation() + angle);
        }

        if (keys.weapons_enemy_next_target.getDown())
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>()) {
                auto lrr = my_spaceship.getComponent<LongRangeRadar>();
                targets.setNext(transform->getPosition(), lrr ? lrr->short_range : 5000.0f, TargetsContainer::Targetable, FactionRelation::Enemy);
                my_player_info->commandSetTarget(targets.get());
            }
        }
        if (keys.weapons_next_target.getDown())
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>()) {
                auto lrr = my_spaceship.getComponent<LongRangeRadar>();
                targets.setNext(transform->getPosition(), lrr ? lrr->short_range : 5000.0f, TargetsContainer::Targetable);
                my_player_info->commandSetTarget(targets.get());
            }
        }

        auto aim_adjust = keys.weapons_aim_left.getValue() - keys.weapons_aim_right.getValue();
        if (aim_adjust != 0.0f)
        {
            missile_aim->setValue(missile_aim->getValue() - 5.0f * aim_adjust);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
    }
}

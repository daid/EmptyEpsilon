#include <i18n.h>
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "weaponsScreen.h"
#include "preferenceManager.h"

#include "components/reactor.h"
#include "components/shields.h"
#include "components/target.h"
#include "components/radar.h"
#include "components/beamweapon.h"
#include "components/collision.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/aimLock.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"
#include "screenComponents/powerDamageIndicator.h"
#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_rotationdial.h"
#include "gui/gui2_label.h"
#include "gui/gui2_image.h"
#include "gui/gui2_keyvaluedisplay.h"


WeaponsScreen::WeaponsScreen(GuiContainer* owner)
: GuiOverlay(owner, "WEAPONS_SCREEN", colorConfig.background)
{
    // Render the radar shadow and background decorations.
    (new GuiImage(this, "BACKGROUND_GRADIENT", "gui/background/gradient.png"))->setPosition(glm::vec2(0, 0), sp::Alignment::Center)->setSize(1200, 900);

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    radar = new GuiRadarView(this, "HELMS_RADAR", &targets);
    radar->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (my_spaceship && targets.get())
                my_player_info->commandSetTarget(targets.get());
            else if (my_spaceship)
                my_player_info->commandSetTarget({});
        }, nullptr, nullptr
    );
    radar->setAutoRotating(PreferencesManager::get("weapons_radar_lock","0")=="1");

    missile_aim = new AimLock(this, "MISSILE_AIM", radar, -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 850);

    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    tube_controls->setPosition(20, -20, sp::Alignment::BottomLeft);
    radar->enableTargetProjections(tube_controls);

    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim);
    lock_aim->setPosition(250, 20, sp::Alignment::TopCenter)->setSize(130, 50);

    beam_shield_box = new GuiElement(this, "BEAM_SHIELD_BOX");
    beam_shield_box
        ->setPosition(-20.0f, -20.0f, sp::Alignment::BottomRight)
        ->setSize(280.0f, 300.0f
            - (gameGlobalInfo->use_beam_shield_frequencies ? 0.0f : 50.0f)
            - (gameGlobalInfo->use_system_damage ? 0.0f : 50.0f)
            - (!gameGlobalInfo->use_beam_shield_frequencies && !gameGlobalInfo->use_system_damage ? 100.0f : 0.0f)
            - (my_spaceship.hasComponent<Shields>() ? 0.0f : 100.0f)
            - (my_spaceship.hasComponent<Shields>() && gameGlobalInfo->use_beam_shield_frequencies ? 0.0f : 50.0f)
        )
        ->setAttribute("layout", "vertical");

    // Beam weapon targeting controls
    beam_label = new GuiLabel(beam_shield_box, "BEAM_TARGETING_LABEL", tr("Beam targeting"), 30.0f);
    beam_label
        ->addBackground()
        ->setSize(200.0f, 50.0f)
        ->setAttribute("margin", "80, 0, 0, 0");

    beam_frequency_row = new GuiElement(beam_shield_box, "BEAM_FREQUENCY_ROW");
    beam_frequency_row
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setAttribute("layout", "horizontal");
    beam_frequency_label = new GuiLabel(beam_frequency_row, "", tr("beam_weapon_frequency", "Freq "), 30.0f);
    beam_frequency_label
        ->setAlignment(sp::Alignment::CenterRight)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiBeamFrequencySelector(beam_frequency_row, ""))
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    beam_system_row = new GuiElement(beam_shield_box, "BEAM_SYSTEM_ROW");
    beam_system_row
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setAttribute("layout", "horizontal");
    beam_system_label = new GuiLabel(beam_system_row, "", tr("beam_weapon_targeted_system", "Sys "), 30.0f);
    beam_system_label
        ->setAlignment(sp::Alignment::CenterRight)
        ->setSize(GuiElement::GuiSizeMax, 50.0f);
    (new GuiBeamTargetSelector(beam_system_row, ""))
        ->setPopupWidth(300.0f)
        ->setSize(200.0f, 50.0f);

    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        (new GuiPowerDamageIndicator(this, "", ShipSystem::Type::BeamWeapons, sp::Alignment::CenterLeft))
            ->setPosition(-20.0f, -150.0f, sp::Alignment::BottomRight)
            ->setSize(280.0f, 100.0f
                - (gameGlobalInfo->use_beam_shield_frequencies ? 0.0f : 50.0f)
                - (gameGlobalInfo->use_system_damage ? 0.0f : 50.0f));
    }

    // The shield frequency selector includes a shield activation toggle.
    shield_label = new GuiLabel(beam_shield_box, "SHIELD_CONTROL_LABEL", tr("Shield controls"), 30.0f);
    shield_label
        ->addBackground()
        ->setSize(280.0f, 50.0f);

    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        (new GuiShieldFrequencySelect(beam_shield_box, "SHIELD_FREQ"))
            ->setSize(GuiElement::GuiSizeMax, 100.0f);
    }
    else
    {
        (new GuiShieldsEnableButton(beam_shield_box, "SHIELDS_ENABLE"))
            ->setSize(GuiElement::GuiSizeMax, 50.0f);
    }

    auto stats = new GuiElement(this, "WEAPONS_STATS");
    stats->setPosition(20, 100, sp::Alignment::TopLeft)->setSize(240, 120)->setAttribute("layout", "vertical");

    energy_display = new GuiKeyValueDisplay(stats, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setSize(240, 40);
    front_shield_display = new GuiKeyValueDisplay(stats, "FRONT_SHIELD_DISPLAY", 0.45, tr("shields","Front"), "");
    front_shield_display->setIcon("gui/icons/shields-fore")->setTextSize(20)->setSize(240, 40);
    rear_shield_display = new GuiKeyValueDisplay(stats, "REAR_SHIELD_DISPLAY", 0.45, tr("shields", "Rear"), "");
    rear_shield_display->setIcon("gui/icons/shields-aft")->setTextSize(20)->setSize(240, 40);

    (new GuiCustomShipFunctions(this, CrewPosition::weaponsOfficer, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void WeaponsScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        auto reactor = my_spaceship.getComponent<Reactor>();
        energy_display->setVisible(reactor);
        if (reactor)
            energy_display->setValue(string(int(reactor->energy)));

        auto shields = my_spaceship.getComponent<Shields>();
        if (shields && shields->entries.size() > 0) {
            front_shield_display->setValue(string(shields->entries[0].percentage()) + "%");
            front_shield_display->show();
        } else {
            front_shield_display->hide();
        }
        if (shields && shields->entries.size() > 1) {
            rear_shield_display->setValue(string(shields->entries[1].percentage()) + "%");
            rear_shield_display->show();
        } else {
            rear_shield_display->hide();
        }

        if (auto tg = my_spaceship.getComponent<Target>())
            targets.set(tg->entity);
        else
            targets.set(sp::ecs::Entity{});

        missile_aim->setVisible(tube_controls->getManualAim());

        if (beam_shield_box)
        {
            beam_shield_box->setVisible(my_spaceship.hasComponent<BeamWeaponSys>() || my_spaceship.hasComponent<Shields>());

            if (beam_shield_box->isVisible())
            {
                beam_label->setVisible(gameGlobalInfo->use_system_damage || gameGlobalInfo->use_beam_shield_frequencies);
                beam_frequency_row->setVisible(gameGlobalInfo->use_beam_shield_frequencies);
                beam_system_row->setVisible(gameGlobalInfo->use_system_damage);
                const bool has_shields = my_spaceship.hasComponent<Shields>();

                shield_label->setVisible(has_shields);
                float window_width_excess = has_shields ? renderer.getVirtualSize().x - 1260.0f : 80.0f;

                // Widen group label on wider viewports.
                if (window_width_excess > 0.0f)
                {
                    beam_label
                        ->setSize(200.0f + std::min(80.0f, window_width_excess), 50.0f)
                        ->setAttribute("margin", static_cast<string>(static_cast<int>(std::clamp(80.0f - window_width_excess, 0.0f, 80.0f))) + ", 0, 0, 0");
                }

                // Expand abbreviated labels on wider viewports.
                if (window_width_excess > 60.0f)
                {
                    beam_frequency_label->setText(tr("beam_weapon_frequency", "Frequency"));
                    beam_system_label->setText(tr("beam_weapon_targeted_system", "System"));
                }
                else
                {
                    beam_frequency_label->setText(tr("beam_weapon_frequency", "Freq "));
                    beam_system_label->setText(tr("beam_weapon_targeted_system", "Sys "));
                }
            }
        }
    }

    GuiOverlay::onDraw(renderer);
}

void WeaponsScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
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

#include "scannerScreen.h"
#include <i18n.h>
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "featureDefs.h"

#include "components/collision.h"
#include "components/name.h"
#include "components/hull.h"
#include "components/radar.h"
#include "components/shields.h"
#include "components/beamweapon.h"
#include "components/scanning.h"

#include "systems/radarblock.h"

#include "screenComponents/frequencyCurve.h"
#include "screenComponents/scanningDialog.h"
#include "gui/gui2_button.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_selector.h"
#include "screenComponents/rotatingModelView.h"

ScannerScreen::ScannerScreen(GuiContainer* owner)
: GuiOverlay(owner, "SCANNER_SCREEN", colorConfig.background)
{
    (new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255}))
        ->setTextureTiled("gui/background/crosses.png");

    label = new GuiLabel(this, "SCANNER_LABEL", tr("scienceButton", "No previous scan contact"), 40.0f);
    label
        ->setSize(GuiElement::GuiSizeMax, 40.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::Center);
    dialog = new GuiScanningDialog(this, "SCANNER");
    progress = new GuiProgressbar(this, "SCANNER_PROGRESS", 0.0f, 6.0f, 0.0f);
    progress
        ->setPosition(0.0f, 0.0f, sp::Alignment::Center)
        ->setSize(500.0f, 50.0f)
        ->hide();

    // Scanner target info.
    right_sidebar = new GuiElement(this, "SCANNER_RIGHT_SIDEBAR");
    right_sidebar
        ->setPosition(-20.0f, 170.0f, sp::Alignment::TopRight)
        ->setSize(300.0f, GuiElement::GuiSizeMax)
        ->setMargins(0, 0, 0, 75)
        ->setAttribute("layout", "vertical");

    left_sidebar = new GuiElement(this, "SCANNER_LEFT_SIDEBAR");
    left_sidebar
        ->setPosition(20.0f, 170.0f, sp::Alignment::TopLeft)
        ->setSize(300.0f, GuiElement::GuiSizeMax)
        ->setMargins(0, 0, 0, 75)
        ->setAttribute("layout", "vertical");

    // Simple scan data.
    info_target = new GuiLabel(right_sidebar, "SCANNER_TARGET_LABEL", tr("scanner", "No previous target"), 30.0f);
    info_target
        ->addBackground()
        ->setSize(GuiElement::GuiSizeMax, 50.0f);
    info_callsign = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_CALLSIGN", 0.4, tr("science", "Callsign"), "");
    info_callsign->setSize(GuiElement::GuiSizeMax, 30);
    info_distance = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_DISTANCE", 0.4, tr("science", "Distance"), "");
    info_distance->setSize(GuiElement::GuiSizeMax, 30);
    info_heading = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_HEADING", 0.4, tr("science", "Bearing"), "");
    info_heading->setSize(GuiElement::GuiSizeMax, 30);
    info_relspeed = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_REL_SPEED", 0.4, tr("science", "Rel. Speed"), "");
    info_relspeed->setSize(GuiElement::GuiSizeMax, 30);
    info_faction = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_FACTION", 0.4, tr("science", "Faction"), "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);
    info_type = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_TYPE", 0.4, tr("science", "Type"), "");
    info_type->setSize(GuiElement::GuiSizeMax, 30);
    info_shields = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_SHIELDS", 0.4, tr("science", "Shields"), "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);
    info_hull = new GuiKeyValueDisplay(right_sidebar, "SCIENCE_HULL", 0.4, tr("science", "Hull"), "");
    info_hull->setSize(GuiElement::GuiSizeMax, 30);

    // Full scan data
    // List each system's status.
    info_systems = new GuiLabel(left_sidebar, "SCANNER_SYSTEMS", tr("Scanned systems"), 30.0f);
    info_systems
        ->addBackground()
        ->setSize(GuiElement::GuiSizeMax, 50.0f);
    for(int n = 0; n < ShipSystem::COUNT; n++)
    {
        info_system[n] = new GuiKeyValueDisplay(left_sidebar, "SCIENCE_SYSTEM_" + string(n), 0.75, getLocaleSystemName(ShipSystem::Type(n)), "-");
        info_system[n]->setSize(GuiElement::GuiSizeMax, 30);
        info_system[n]->hide();
    }

    // Prep and hide the frequency graphs.
    info_shield_frequency = new GuiFrequencyCurve(left_sidebar, "SCIENCE_SHIELD_FREQUENCY", false, true);
    info_shield_frequency->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info_beam_frequency = new GuiFrequencyCurve(left_sidebar, "SCIENCE_BEAM_FREQUENCY", true, false);
    info_beam_frequency->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Show shield and beam frequencies only if enabled by the server.
    if (!gameGlobalInfo->use_beam_shield_frequencies)
    {
        info_shield_frequency->hide();
        info_beam_frequency->hide();
    }

    // Prep and hide the description text area.
    info_description = new GuiScrollFormattedText(right_sidebar, "SCIENCE_DESC", "");
    info_description->setTextSize(28)->setMargins(20, 0, 0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();
}

void ScannerScreen::onDraw(sp::RenderTarget& target)
{
    GuiOverlay::onDraw(target);
    auto ss = my_spaceship.getComponent<ScienceScanner>();
    if (!ss) return;
    if (last_target != ss->target && ss->target != sp::ecs::Entity()) last_target = ss->target;

    // If the cached target entity exists, is scanned, is within long-range radar range and is radar visible to the player ship, show its current information up to its scan level, its database entry?, and its mesh.
    // If the cached target isn't radar visible to the player ship or out of range, stop updating information about it and indicate that it is out of sensor contact.
    // If the cached target entity isn't scanned, don't show any information about it.
    // If the cached target entity no longer exists, don't show any information about it.
    // Don't update the cache until a scan of another target is in progress.
    // When/if the science radar target is replicated, maybe update this to the current science target instead of a cached scan target.
    if (ss->delay > 0.0f)
    {
        if (gameGlobalInfo->scanning_complexity == EScanningComplexity::SC_None)
        {
            progress
                ->setText(tr("scienceButton", "Scanning..."))
                ->setRange(0.0f, ss->max_scanning_delay)
                ->setValue(ss->delay)
                ->show();
            label->hide();
            dialog->hide();
        }
        else
        {
            progress->hide();
            label
                ->setText(tr("scienceButton", "Scanning..."))
                ->show();
            dialog->show();
        }
    }
    else
    {
        progress->hide();
        label->show();
        if (last_target)
            label->setText(tr("scanner", "Tracking most recent scan"));
        else
            label->setText(tr("scanner", "Most recent scan contact lost"));
        dialog->show();
    }

    // Display and update information on cached last target if still visible to
    // the player's radar.
    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    bool in_range = false;
    if (last_target && lrr)
    {
        info_target->setText(tr("scanner", "Most recent scan"));

        auto my_transform = my_spaceship.getComponent<sp::Transform>();
        auto target_transform = last_target.getComponent<sp::Transform>();

        if (my_transform && target_transform)
        {
            auto position_diff = target_transform->getPosition() - my_transform->getPosition();
            float distance = glm::length(position_diff);

            if (distance <= lrr->long_range)
            {
                float heading = vec2ToAngle(position_diff) - 270.0f;
                while (heading < 0) heading += 360.0f;

                info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
                info_heading->setValue(string(static_cast<int>(heading)));

                auto my_physics = my_spaceship.getComponent<sp::Physics>();
                auto target_physics = last_target.getComponent<sp::Physics>();

                if (my_physics && target_physics)
                {
                    float rel_velocity = dot(target_physics->getVelocity(), position_diff / distance) - dot(my_physics->getVelocity(), position_diff / distance);

                    if (std::abs(rel_velocity) < 0.01f) rel_velocity = 0.0f;
                    info_relspeed->setValue(tr("science", "{relative_speed}/min").format({{"relative_speed", string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K}}));
                }

                // Not in range if radar blocked.
                in_range = !(RadarBlockSystem::isRadarBlockedFrom(my_transform->getPosition(), last_target, lrr->short_range));
            }
        }

        // Update data only if still in range.
        if (in_range)
        {
            if (auto cs = last_target.getComponent<CallSign>())
                info_callsign->setValue(cs->callsign);

            auto scanstate_component = last_target.getComponent<ScanState>();
            auto scanstate = scanstate_component ? scanstate_component->getStateFor(my_spaceship) : ScanState::State::FullScan;

            auto sd = last_target.getComponent<ScienceDescription>();
            string description = "";
            if (sd)
            {
                switch (scanstate)
                {
                case ScanState::State::NotScanned: description = sd->not_scanned; break;
                case ScanState::State::FriendOrFoeIdentified: description = sd->friend_or_foe_identified; break;
                case ScanState::State::SimpleScan: description = sd->simple_scan; break;
                case ScanState::State::FullScan: description = sd->full_scan; break;
                }
            }
            if (description.empty())
                info_description->hide();
            else
                info_description->setText(description)->show();

            // On a simple scan or deeper, show the faction, ship type, shields,
            // hull integrity, and database reference button.
            if (scanstate >= ScanState::State::SimpleScan)
            {
                auto faction = Faction::getInfo(last_target);
                info_faction->setValue(faction.locale_name);

                if (auto tn = last_target.getComponent<TypeName>())
                    info_type->setValue(tn->localized);

                if (auto shields = last_target.getComponent<Shields>())
                {
                    string str = "";
                    for (size_t n = 0; n < shields->entries.size(); n++)
                    {
                        if (n > 0) str += ":";
                        str += string(int(shields->entries[n].level));
                    }
                    info_shields->setValue(str);
                }

                if (auto hull = last_target.getComponent<Hull>())
                    info_hull->setValue(int(ceil(hull->current)));
            }
            else
            {
                info_faction->setValue("");
                info_type->setValue("");
                info_shields->setValue("");
                info_hull->setValue("");
            }

            // On a full scan, show tactical and systems data (if any), and its
            // description (if one is set).
            if (scanstate >= ScanState::State::FullScan)
            {
                left_sidebar->show();
                info_shield_frequency->show();
                info_beam_frequency->show();

                for (int n = 0; n < ShipSystem::COUNT; n++)
                    info_system[n]->show();

                info_description->show();

                // If beam and shield frequencies are enabled on the server,
                // populate their graphs.
                if (gameGlobalInfo->use_beam_shield_frequencies)
                {
                    auto shieldsystem = last_target.getComponent<Shields>();
                    info_shield_frequency->setFrequency(shieldsystem ? shieldsystem->frequency : -1);
                    auto beamsystem = last_target.getComponent<BeamWeaponSys>();
                    info_beam_frequency->setFrequency(beamsystem ? beamsystem->frequency : -1);

                    // Show on graph information that target has no shields instead of frequencies. 
                    info_shield_frequency->setEnemyHasEquipment(shieldsystem);

                    // Show on graph information that target has no beams instad of frequencies. 
                    info_beam_frequency->setEnemyHasEquipment(beamsystem);
                }

                // Show the status of each subsystem.
                for (int n = 0; n < ShipSystem::COUNT; n++)
                {
                    if (auto sys = ShipSystem::get(last_target, ShipSystem::Type(n)))
                    {
                        const float system_health = sys->health;
                        info_system[n]->setValue(string(int(system_health * 100.0f)) + "%")->setColor(glm::u8vec4(255, 127.5f * (system_health + 1), 127.5f * (system_health + 1), 255));
                    }
                }
            }
            else left_sidebar->hide();
        }
        else label->setText(tr("scanner", "Most recent scan contact lost"));
    }
    else info_target->setText(tr("scanner", "No recent scan"));
}

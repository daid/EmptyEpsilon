#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "scienceScreen.h"
#include "preferenceManager.h"
#include "multiplayer_client.h"
#include "i18n.h"
#include "featureDefs.h"

#include "components/beamweapon.h"
#include "components/shields.h"
#include "components/hull.h"
#include "components/collision.h"
#include "components/radar.h"
#include "components/scanning.h"
#include "components/name.h"

#include "systems/radarblock.h"

#include "screenComponents/radarView.h"
#include "screenComponents/rawScannerDataRadarOverlay.h"
#include "screenComponents/scanTargetButton.h"
#include "screenComponents/frequencyCurve.h"
#include "screenComponents/scanningDialog.h"
#include "screenComponents/databaseView.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_image.h"

ScienceScreen::ScienceScreen(GuiContainer* owner, bool allow_scanning, CrewPosition crew_position)
: GuiOverlay(owner, "SCIENCE_SCREEN", colorConfig.background), allow_scanning(allow_scanning)
{
    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    targets.setAllowWaypointSelection();

    // Render the radar shadow and background decorations.
    background_gradient = new GuiImage(this, "BACKGROUND_GRADIENT", "gui/background/gradientOffset.png");
    background_gradient->setPosition(glm::vec2(105, 0), sp::Alignment::CenterLeft)->setSize(1200, 900);

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Draw the radar.
    radar_view = new GuiElement(this, "RADAR_VIEW");
    radar_view->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Draw the science radar.
    science_radar = new GuiRadarView(radar_view, "SCIENCE_RADAR", lrr ? lrr->long_range : 30000.0f, &targets);
    science_radar->setPosition(120, 0, sp::Alignment::CenterLeft)->setSize(900,GuiElement::GuiSizeMax);
    science_radar->setRangeIndicatorStepSize(5000.0)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
    science_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            if (auto scanner = my_spaceship.getComponent<ScienceScanner>())
                if (scanner->delay > 0.0f)
                    return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr
    );
    science_radar->setAutoRotating(PreferencesManager::get("science_radar_lock","0")=="1");
    new RawScannerDataRadarOverlay(science_radar, "");

    // Draw and hide the probe radar.
    probe_radar = new GuiRadarView(radar_view, "PROBE_RADAR", 5000, &targets);
    probe_radar->setPosition(120, 0, sp::Alignment::CenterLeft)->setSize(900,GuiElement::GuiSizeMax)->hide();
    probe_radar->setAutoCentering(false)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NoFogOfWar);
    probe_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            if (auto scanner = my_spaceship.getComponent<ScienceScanner>())
                if (scanner->delay > 0.0f)
                    return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr
    );
    new RawScannerDataRadarOverlay(probe_radar, "");

    sidebar_selector = new GuiSelector(radar_view, "", [this](int index, string value)
    {
        info_sidebar->setVisible(index == 0);
        custom_function_sidebar->setVisible(index == 1);
    });
    sidebar_selector->setOptions({tr("scienceTab", "Scanning"), tr("scienceTab", "Other")});
    sidebar_selector->setSelectionIndex(0);
    sidebar_selector->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, 50);

    // Target scan data sidebar.
    info_sidebar = new GuiElement(radar_view, "SIDEBAR");
    info_sidebar->setPosition(-20, 170, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    info_sidebar->setMargins(0, 0, 0, 75);
    
    custom_function_sidebar = new GuiCustomShipFunctions(radar_view, crew_position, "");
    custom_function_sidebar->setPosition(-15, 210, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax)->hide();

    // Scan button (link to scanner on altScience).
    scan_button = new GuiScanTargetButton(info_sidebar, "SCAN_BUTTON", &targets, allow_scanning);
    scan_button->setSize(GuiElement::GuiSizeMax, 50)->setVisible(my_spaceship.hasComponent<ScienceScanner>());

    // Simple scan data.
    info_callsign = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_CALLSIGN", 0.4, tr("science", "Callsign"), "");
    info_callsign->setSize(GuiElement::GuiSizeMax, 30);
    info_distance = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_DISTANCE", 0.4, tr("science", "Distance"), "");
    info_distance->setSize(GuiElement::GuiSizeMax, 30);
    info_heading = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_HEADING", 0.4, tr("science", "Bearing"), "");
    info_heading->setSize(GuiElement::GuiSizeMax, 30);
    info_relspeed = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_REL_SPEED", 0.4, tr("science", "Rel. Speed"), "");
    info_relspeed->setSize(GuiElement::GuiSizeMax, 30);
    info_faction = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_FACTION", 0.4, tr("science", "Faction"), "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);
    info_type = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_TYPE", 0.4, tr("science", "Type"), "");
    info_type->setSize(GuiElement::GuiSizeMax, 30);
    info_type_button = new GuiButton(info_type, "SCIENCE_TYPE_BUTTON", tr("scienceButton", "DB"), [this, allow_scanning]() {
        if (!allow_scanning) return;

        auto ship = targets.get();
        if (auto tn = ship.getComponent<TypeName>())
        {
            if (database_view->findAndDisplayEntry(tn->type_name) || database_view->findAndDisplayEntry(tn->localized))
            {
                view_mode_selection->setSelectionIndex(1);
                radar_view->hide();
                background_gradient->hide();
                database_view->show();
            }
        }
    });
    info_type_button->setTextSize(20)->setPosition(0, 1, sp::Alignment::TopLeft)->setSize(50, 28)->setVisible(allow_scanning);
    info_shields = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_SHIELDS", 0.4, tr("science", "Shields"), "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);
    info_hull = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_HULL", 0.4, tr("science", "Hull"), "");
    info_hull->setSize(GuiElement::GuiSizeMax, 30);

    // Full scan data

    // Draw and hide the sidebar pager.
    sidebar_pager = new GuiSelector(info_sidebar, "SIDEBAR_PAGER", [this](int index, string value) {});
    sidebar_pager->setSize(GuiElement::GuiSizeMax, 50)->hide();

    // If the server uses frequencies, add the Tactical sidebar page.
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        sidebar_pager->addEntry(tr("scienceTab", "Tactical"), "Tactical");
    }

    // Add sidebar page for systems.
    sidebar_pager->addEntry(tr("scienceTab", "Systems"), "Systems");

    // Add sidebar page for a description.
    sidebar_pager->addEntry(tr("scienceTab", "Description"), "Description");

    // Default the pager to the first item.
    sidebar_pager->setSelectionIndex(0);

    // Prep and hide the frequency graphs.
    info_shield_frequency = new GuiFrequencyCurve(info_sidebar, "SCIENCE_SHIELD_FREQUENCY", false, true);
    info_shield_frequency->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info_beam_frequency = new GuiFrequencyCurve(info_sidebar, "SCIENCE_BEAM_FREQUENCY", true, false);
    info_beam_frequency->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Show shield and beam frequencies only if enabled by the server.
    if (!gameGlobalInfo->use_beam_shield_frequencies)
    {
        info_shield_frequency->hide();
        info_beam_frequency->hide();
    }

    // List each system's status.
    for(int n = 0; n < ShipSystem::COUNT; n++)
    {
        info_system[n] = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_SYSTEM_" + string(n), 0.75, getLocaleSystemName(ShipSystem::Type(n)), "-");
        info_system[n]->setSize(GuiElement::GuiSizeMax, 30);
        info_system[n]->hide();
    }

    // Prep and hide the description text area.
    info_description = new GuiScrollFormattedText(info_sidebar, "SCIENCE_DESC", "");
    info_description->setTextSize(28)->setMargins(20, 0, 0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();

    // Prep and hide the database view.
    database_view = new DatabaseViewComponent(this);
    database_view
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->hide()
        ->setAttribute("padding", "20");

    // Pad top of details column if crew screen selection controls are visible,
    // and bottom of item list column to prevent overlap with probe/radar view
    // selectors.
    int details_padding = 0;
    if (my_player_info)
    {
        if (my_player_info->main_screen_control != 0) details_padding = 120;
        else if (my_player_info->countTotalPlayerPositions() > 1) details_padding = 70;
    }
    database_view
        ->setDetailsPadding(details_padding)
        ->setItemsPadding(120);

    // Draw the zoom slider.
    zoom_slider = new GuiSlider(radar_view, "", lrr ? lrr->long_range : 30000.0f, lrr ? lrr->short_range : 5000.0f, lrr ? lrr->long_range : 30000.0f, [this](float value)
    {
        if (auto lrr = my_spaceship.getComponent<LongRangeRadar>())
            zoom_label->setText(tr("scienceButton", "Zoom: {zoom}x").format({{"zoom", string(lrr->long_range / value, 1)}}));
        science_radar->setDistance(value);
    });
    zoom_slider->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(250, 50);
    zoom_label = new GuiLabel(zoom_slider, "", "Zoom: 1.0x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // View controls.
    GuiElement* view_controls = new GuiElement(radar_view, "VIEW_CONTROLS");
    view_controls
        ->setPosition(20.0f, -20.0f, sp::Alignment::BottomLeft)
        ->setSize(200.0f, 150.0f)
        ->setAttribute("layout", "verticalbottom");

    // Probe view button.
    probe_view_button = new GuiToggleButton(view_controls, "PROBE_VIEW", tr("scienceButton", "Probe View"),
        [this](bool value)
        {
            auto rl = my_spaceship.getComponent<RadarLink>();
            if (value && rl && rl->linked_entity)
            {
                if (auto transform = rl->linked_entity.getComponent<sp::Transform>())
                {
                    science_radar->hide();
                    probe_radar->show();
                    probe_radar->setViewPosition(transform->getPosition())->show();
                }
            }
            else
            {
                probe_view_button->setValue(false);
                science_radar->show();
                probe_radar->hide();
            }
        }
    );
    probe_view_button->setSize(200.0f, 50.0f)->disable();

    // Radar/database view toggle, create only on Science/Ops (allow_scanning).
    view_mode_selection = new GuiListbox(view_controls, "VIEW_SELECTION",
        [this](int index, string value)
        {
            radar_view->setVisible(index == 0);
            background_gradient->setVisible(index == 0);
            database_view->setVisible(index == 1);
        }
    );
    view_mode_selection
        ->setOptions({tr("scienceButton", "Radar"), tr("scienceButton", "Database")})
        ->setSelectionIndex(0)
        ->setSize(200.0f, 100.0f)
        ->setVisible(allow_scanning);

    // Scanning dialog, create only on Science/Ops.
    if (allow_scanning) new GuiScanningDialog(this, "SCANNING_DIALOG");
}

void ScienceScreen::onDraw(sp::RenderTarget& renderer)
{
    GuiOverlay::onDraw(renderer);
    if (!isVisible())
        return;

    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    science_radar->setVisible(lrr != nullptr);
    if (!lrr)
        return;
    auto rl = my_spaceship.getComponent<RadarLink>();

    float view_distance = science_radar->getDistance();
    float mouse_wheel_delta = keys.zoom_in.getValue() - keys.zoom_out.getValue();
    if (mouse_wheel_delta!=0)
    {
        view_distance *= (1.0f - (mouse_wheel_delta * 0.1f));
    }
    view_distance = std::min(view_distance, lrr->long_range);
    view_distance = std::max(view_distance, lrr->short_range);
    if (view_distance!=science_radar->getDistance() || previous_long_range_radar != lrr->long_range || previous_short_range_radar != lrr->short_range)
    {
        previous_short_range_radar = lrr->long_range;
        previous_long_range_radar = lrr->short_range;
        science_radar->setDistance(view_distance);
        // Keep the zoom slider in sync.
        zoom_slider->setValue(view_distance)->setRange(lrr->long_range, lrr->short_range);
        zoom_label->setText(tr("scienceButton", "Zoom: {zoom}x").format({{"zoom", string(lrr->long_range / view_distance, 1)}}));
    }

    if (probe_view_button->getValue() && rl && rl->linked_entity)
    {
        auto probe_transform = rl->linked_entity.getComponent<sp::Transform>();
        auto target_transform = targets.get().getComponent<sp::Transform>();
        if (!probe_transform || !target_transform || glm::length2(probe_transform->getPosition() - target_transform->getPosition()) > 5000.0f * 5000.0f)
            targets.clear();
    }else{
        auto my_transform = my_spaceship.getComponent<sp::Transform>();
        if (!my_transform || RadarBlockSystem::isRadarBlockedFrom(my_transform->getPosition(), targets.get(), lrr->short_range))
            targets.clear();
    }

    // Responsive layout for custom button sidebar. 1440x900 vpixels is 16:10, so this would roughly be the threshold.

    int current_width = getRect().size.x;
    sidebar_selector->setVisible(current_width < 1435 && (sidebar_selector->getSelectionIndex() > 0 || custom_function_sidebar->hasEntries()));
    if (current_width < 1435 || !custom_function_sidebar->hasEntries())
    {
        info_sidebar->setPosition(-20, 170, sp::Alignment::TopRight);
        sidebar_selector->setPosition(-20, 120, sp::Alignment::TopRight);
        custom_function_sidebar->setVisible(sidebar_selector->getSelectionIndex() == 1);
        custom_function_sidebar->setPosition(-20, 210, sp::Alignment::TopRight);
        info_sidebar->setVisible(sidebar_selector->getSelectionIndex() == 0);
    }
    else
    {
        info_sidebar->setPosition(-20, 170, sp::Alignment::TopRight);
        sidebar_selector->setPosition(-20, 120, sp::Alignment::TopRight);
        custom_function_sidebar->setPosition(-280, 170, sp::Alignment::TopRight);
        custom_function_sidebar->show();
        info_sidebar->show();
    }

    info_callsign->setValue("-");
    info_distance->setValue("-");
    info_heading->setValue("-");
    info_relspeed->setValue("-");
    info_faction->setValue("-");
    info_type->setValue("-");
    info_shields->setValue("-");
    info_hull->setValue("-");
    info_shield_frequency->setFrequency(-1)->hide();
    info_beam_frequency->setFrequency(-1)->hide();
    info_description->hide();
    info_type_button->hide();
    sidebar_pager->hide();

    for(int n = 0; n < ShipSystem::COUNT; n++)
        info_system[n]->setValue("-")->hide();

    if (rl && rl->linked_entity)
    {
        probe_view_button->enable();
        auto probe_transform = rl->linked_entity.getComponent<sp::Transform>();
        if (probe_transform)
            probe_radar->setViewPosition(probe_transform->getPosition());
    }
    else
    {
        probe_view_button->disable();
        probe_view_button->setValue(false);
        science_radar->show();
        probe_radar->hide();
    }

    if (targets.get())
    {
        auto target = targets.get();

        auto my_transform = my_spaceship.getComponent<sp::Transform>();
        auto target_transform = target.getComponent<sp::Transform>();

        if (my_transform && target_transform) {
            auto position_diff = target_transform->getPosition() - my_transform->getPosition();
            float distance = glm::length(position_diff);
            float heading = vec2ToAngle(position_diff) - 270;

            while(heading < 0) heading += 360;

            info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
            info_heading->setValue(string(int(heading)));

            auto my_physics = my_spaceship.getComponent<sp::Physics>();
            auto target_physics = target.getComponent<sp::Physics>();
            if (my_physics && target_physics) {
                float rel_velocity = dot(target_physics->getVelocity(), position_diff / distance) - dot(my_physics->getVelocity(), position_diff / distance);

                if (std::abs(rel_velocity) < 0.01f)
                    rel_velocity = 0.0f;
                info_relspeed->setValue(tr("science", "{relative_speed}/min").format({{"relative_speed", string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K}}));
            }
        }
        if (auto cs = target.getComponent<CallSign>())
            info_callsign->setValue(cs->callsign);

        auto scanstate_component = target.getComponent<ScanState>();
        auto scanstate = scanstate_component ? scanstate_component->getStateFor(my_spaceship) : ScanState::State::FullScan;

        auto sd = target.getComponent<ScienceDescription>();
        string description = "";
        if (sd)
        {
            switch(scanstate) {
            case ScanState::State::NotScanned: description = sd->not_scanned; break;
            case ScanState::State::FriendOrFoeIdentified: description = sd->friend_or_foe_identified; break;
            case ScanState::State::SimpleScan: description = sd->simple_scan; break;
            case ScanState::State::FullScan: description = sd->full_scan; break;
            }
        }
        if (!description.empty()) {
            info_description->setText(description)->show();

            if (sidebar_pager->indexByValue("Description") < 0)
            {
                sidebar_pager->addEntry("Description", "Description");
            }
        }
        else
        {
            sidebar_pager->removeEntry(sidebar_pager->indexByValue("Description"));
            if (sidebar_pager->getSelectionIndex() < 0)
                sidebar_pager->setSelectionIndex(0);
        }

        string sidebar_pager_selection = sidebar_pager->getSelectionValue();

        // On a simple scan or deeper, show the faction, ship type, shields,
        // hull integrity, and database reference button.
        if (scanstate >= ScanState::State::SimpleScan)
        {
            auto faction = Faction::getInfo(target);
            info_faction->setValue(faction.locale_name);
            if (auto tn = target.getComponent<TypeName>())
                info_type->setValue(tn->localized);
            info_type_button->show();
            if (auto shields = target.getComponent<Shields>()) {
                string str = "";
                for(size_t n=0; n<shields->entries.size(); n++) {
                    if (n > 0)
                        str += ":";
                    str += string(int(shields->entries[n].level));
                }
                info_shields->setValue(str);
            }
            if (auto hull = target.getComponent<Hull>())
                info_hull->setValue(int(ceil(hull->current)));
        }

        // On a full scan, show tactical and systems data (if any), and its
        // description (if one is set).
        if (scanstate >= ScanState::State::FullScan)
        {
            sidebar_pager->setVisible(sidebar_pager->entryCount() > 1);

            // Check sidebar pager state.
            if (sidebar_pager_selection == "Tactical")
            {
                info_shield_frequency->show();
                info_beam_frequency->show();

                for(int n = 0; n < ShipSystem::COUNT; n++)
                {
                    info_system[n]->hide();
                }

                info_description->hide();
            }
            else if (sidebar_pager_selection == "Systems")
            {
                info_shield_frequency->hide();
                info_beam_frequency->hide();

                for(int n = 0; n < ShipSystem::COUNT; n++)
                {
                    info_system[n]->show();
                }

                info_description->hide();
            }
            else if (sidebar_pager_selection == "Description")
            {
                info_shield_frequency->hide();
                info_beam_frequency->hide();

                for(int n = 0; n < ShipSystem::COUNT; n++)
                {
                    info_system[n]->hide();
                }

                info_description->show();
            }
            else
            {
                LOG(WARNING) << "Invalid pager state: " << sidebar_pager_selection;
            }

            // If beam and shield frequencies are enabled on the server,
            // populate their graphs.
            if (gameGlobalInfo->use_beam_shield_frequencies)
            {
                auto shieldsystem = target.getComponent<Shields>();
                info_shield_frequency->setFrequency(shieldsystem ? shieldsystem->frequency : -1);
                auto beamsystem = target.getComponent<BeamWeaponSys>();
                info_beam_frequency->setFrequency(beamsystem ? beamsystem->frequency : -1);

                // Show on graph information that target has no shields instead of frequencies. 
                info_shield_frequency->setEnemyHasEquipment(shieldsystem);

                // Show on graph information that target has no beams instad of frequencies. 
                info_beam_frequency->setEnemyHasEquipment(beamsystem);
            }

            // Show the status of each subsystem.
            for(int n = 0; n < ShipSystem::COUNT; n++)
            {
                auto sys = ShipSystem::get(target, ShipSystem::Type(n));
                if (sys) {
                    float system_health = sys->health;
                    info_system[n]->setValue(string(int(system_health * 100.0f)) + "%")->setBackColor(glm::u8vec4(255, 127.5f * (system_health + 1), 127.5f * (system_health + 1), 255));
                }
            }
        }
    }

    // If the target is a waypoint, show its heading and distance, and our
    // velocity toward it.
    else if (targets.getWaypointIndex() >= 0)
    {
        sidebar_pager->hide();
        if (auto waypoints = my_spaceship.getComponent<Waypoints>()) {
            if (auto transform = my_spaceship.getComponent<sp::Transform>()) {
                if (auto waypoint_position = waypoints->get(targets.getWaypointIndex())) {
                    auto position_diff = waypoint_position.value() - transform->getPosition();
                    float distance = glm::length(position_diff);
                    float heading = vec2ToAngle(position_diff) - 270;

                    while(heading < 0) heading += 360;

                    float rel_velocity = 0.0;
                    if (auto physics = my_spaceship.getComponent<sp::Physics>())
                        rel_velocity = -dot(physics->getVelocity(), position_diff / distance);

                    if (std::abs(rel_velocity) < 0.01f)
                        rel_velocity = 0.0;

                    info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
                    info_heading->setValue(string(int(heading)));
                    info_relspeed->setValue(tr("science", "{relative_speed}/min").format({{"relative_speed", string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K}}));
                }
            }
        }
    }
}

void ScienceScreen::onUpdate()
{
    if (my_spaceship
        && my_spaceship.hasComponent<ScienceScanner>()
        && (!allow_scanning || my_spaceship.getComponent<ScienceScanner>()->delay == 0.0f))
    {
        // Initiate a scan on scannable objects.
        if (keys.science_scan_object.getDown())
        {
            auto obj = targets.get();

            // Allow scanning only if the object is scannable, and if the player
            // isn't already scanning something.
            auto scanstate = obj.getComponent<ScanState>();
            if (scanstate && scanstate->getStateFor(my_spaceship) != ScanState::State::FullScan)
            {
                my_player_info->commandScan(obj);
                return;
            }
        }

        // Cycle selection through scannable objects.
        if (keys.science_select_next_scannable.getDown())
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
            {
                auto lrr = my_spaceship.getComponent<LongRangeRadar>();
                targets.setNext(transform->getPosition(), lrr ? lrr->long_range : 25000.0f, TargetsContainer::ESelectionType::Scannable);
            }
        }
    }
}

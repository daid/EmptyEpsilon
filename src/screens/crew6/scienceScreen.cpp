#include "scienceScreen.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
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
#include "screenComponents/radarZoomSlider.h"
#include "screenComponents/rawScannerDataRadarOverlay.h"
#include "screenComponents/scanTargetButton.h"
#include "screenComponents/frequencyCurve.h"
#include "screenComponents/scanningDialog.h"
#include "screenComponents/databaseView.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/theme.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_image.h"

ScienceScreen::ScienceScreen(GuiContainer* owner, CrewPosition crew_position)
: GuiOverlay(owner, "SCIENCE_SCREEN", GuiTheme::getColor("background"))
{
    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    targets.setAllowWaypointSelection();

    // Render the radar shadow and background decorations.
    background_gradient = new GuiImage(this, "BACKGROUND_GRADIENT", "");
    background_gradient->setTextureThemed("background.gradient_offset")->setPosition(glm::vec2(105, 0), sp::Alignment::CenterLeft)->setSize(1200, 900);

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiledThemed("background.crosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Draw the radar.
    radar_view = new GuiElement(this, "RADAR_VIEW");
    radar_view->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Draw the science radar.
    science_radar = new GuiRadarView(radar_view, "SCIENCE_RADAR", lrr ? lrr->long_range : DEFAULT_MAX_ZOOM_DISTANCE, &targets);
    science_radar->setPosition(120, 0, sp::Alignment::CenterLeft)->setSize(900,GuiElement::GuiSizeMax);
    science_radar->setRangeIndicatorStepSize(DEFAULT_MIN_ZOOM_DISTANCE)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
    science_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) { // down
            if (auto scanner = my_spaceship.getComponent<ScienceScanner>())
                if (scanner->delay > 0.0f)
                    return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr,
        [this](float value, glm::vec2 position) { // wheel
            doRadarZoom(value);
        }
    );
    science_radar->setAutoRotating(PreferencesManager::get("science_radar_lock","0")=="1");
    new RawScannerDataRadarOverlay(science_radar, "");

    // Draw and hide the probe radar.
    probe_radar = new GuiRadarView(radar_view, "PROBE_RADAR", PROBE_ZOOM_DISTANCE, &targets);
    probe_radar->setPosition(120, 0, sp::Alignment::CenterLeft)->setSize(900,GuiElement::GuiSizeMax)->hide();
    probe_radar->setAutoCentering(false)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NoFogOfWar);
    probe_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            if (auto scanner = my_spaceship.getComponent<ScienceScanner>())
                if (scanner->delay > 0.0f)
                    return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr, nullptr
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

    // Scan button.
    scan_button = new GuiScanTargetButton(info_sidebar, "SCAN_BUTTON", &targets);
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
    info_type_button = new GuiButton(info_type, "SCIENCE_TYPE_BUTTON", tr("scienceButton", "DB"),
        [this]()
        {
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
        }
    );
    info_type_button->setTextSize(20)->setPosition(0, 1, sp::Alignment::TopLeft)->setSize(50, 28);
    info_shields = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_SHIELDS", 0.4, tr("science", "Shields"), "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);
    info_hull = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_HULL", 0.4, tr("science", "Hull"), "");
    info_hull->setSize(GuiElement::GuiSizeMax, 30);

    // Full scan data sidebar.
    // Draw and hide the sidebar pager. Tabs are populated dynamically in onDraw.
    sidebar_pager = new GuiSelector(info_sidebar, "SIDEBAR_PAGER", [](int index, string value) {});
    sidebar_pager
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->hide();

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
    for (int n = 0; n < ShipSystem::COUNT; n++)
    {
        info_system[n] = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_SYSTEM_" + string(n), 0.75f, getLocaleSystemName(ShipSystem::Type(n)), "-");
        info_system[n]
            ->setSize(GuiElement::GuiSizeMax, 30.0f)
            ->hide();
    }

    // Prep and hide the description text area.
    info_description = new GuiScrollFormattedText(info_sidebar, "SCIENCE_DESC", "");
    info_description
        ->setTextSize(28.0f)
        ->setMargins(20.0f, 0.0f, 0.0f, 0.0f)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->hide();

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

    // Probe view button
    probe_view_button = new GuiToggleButton(radar_view, "PROBE_VIEW", tr("scienceButton", "Probe view"),
        [this](bool value)
        {
            auto rl = my_spaceship.getComponent<RadarLink>();
            if (value && rl && rl->linked_entity)
            {
                auto transform = rl->linked_entity.getComponent<sp::Transform>();
                if (transform)
                {
                    science_radar->hide();
                    probe_radar
                        ->setViewPosition(transform->getPosition())
                        ->show();
                }
            }
            else
            {
                probe_view_button->setValue(false);
                science_radar->show();
                probe_radar->hide();
            }
    });
    probe_view_button
        ->setPosition(20.0f, -120.0f, sp::Alignment::BottomLeft)
        ->setSize(200.0f, 50.0f)
        ->disable();

    // Draw the zoom slider.
    float lrr_long = lrr ? lrr->long_range : DEFAULT_MAX_ZOOM_DISTANCE;
    float lrr_short = lrr ? lrr->short_range : DEFAULT_MIN_ZOOM_DISTANCE;
    zoom_slider = new GuiRadarZoomSlider(radar_view, "RADAR_ZOOM", lrr_short, lrr_long, lrr_long, science_radar);
    zoom_slider
        ->setPosition(-20.0f, -20.0f, sp::Alignment::BottomRight)
        ->setSize(250.0f, 50.0f);

    // Radar/database view toggle.
    view_mode_selection = new GuiListbox(this, "VIEW_SELECTION",
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
        ->setPosition(20.0f, -20.0f, sp::Alignment::BottomLeft)
        ->setSize(200.0f, 100.0f);

    // Scanning dialog.
    new GuiScanningDialog(this, "SCANNING_DIALOG");
}

void ScienceScreen::doRadarZoom(float value)
{
    float view_distance = std::clamp(
        science_radar->getDistance() * (1.0f - value * 0.1f),
        previous_short_range_radar,
        previous_long_range_radar
    );
    science_radar->setDistance(view_distance);
    zoom_slider->setValue(view_distance);
}

void ScienceScreen::onDraw(sp::RenderTarget& renderer)
{
    GuiOverlay::onDraw(renderer);
    if (!isVisible()) return;

    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    science_radar->setVisible(lrr != nullptr);
    if (!lrr) return;

    auto rl = my_spaceship.getComponent<RadarLink>();
    float view_distance = science_radar->getDistance();
    float key_zoom_delta = keys.zoom_in.getValue() - keys.zoom_out.getValue();

    if (key_zoom_delta != 0) view_distance *= (1.0f - (key_zoom_delta * 0.1f));

    // No std::clamp in case short_range > long_range.
    view_distance = std::min(view_distance, lrr->long_range);
    view_distance = std::max(view_distance, lrr->short_range);

    // Update radar view distances and zoom range if changed.
    if (view_distance != science_radar->getDistance()
        || previous_long_range_radar != lrr->long_range
        || previous_short_range_radar != lrr->short_range)
    {
        previous_short_range_radar = lrr->short_range;
        previous_long_range_radar = lrr->long_range;
        zoom_slider
            ->setRange(lrr->long_range, lrr->short_range)
            ->setValue(view_distance);
    }

    // If in probe view to a radar-linked entity, clear target selection if
    // target is out of probe view range.
    if (probe_view_button->getValue() && rl && rl->linked_entity)
    {
        auto probe_transform = rl->linked_entity.getComponent<sp::Transform>();
        auto target_transform = targets.get().getComponent<sp::Transform>();
        if (!probe_transform || !target_transform || glm::length2(probe_transform->getPosition() - target_transform->getPosition()) > 5000.0f * 5000.0f)
            targets.clear();
    }
    // Otherwise, clear target if target is radar blocked/out of range or if we
    // don't have a transform (exploded or internally docked).
    else
    {
        auto my_transform = my_spaceship.getComponent<sp::Transform>();
        if (!my_transform || RadarBlockSystem::isRadarBlockedFrom(my_transform->getPosition(), targets.get(), lrr->short_range))
            targets.clear();
    }

    // Responsive layout for custom button sidebar. 1440x900 vpixels is 16:10,
    // so this would roughly be the threshold.
    const int current_width = getRect().size.x;
    sidebar_selector->setVisible(current_width < 1435 && (sidebar_selector->getSelectionIndex() > 0 || custom_function_sidebar->hasEntries()));
    if (current_width < 1435 || !custom_function_sidebar->hasEntries())
    {
        info_sidebar->setPosition(-20.0f, 170.0f, sp::Alignment::TopRight);
        sidebar_selector->setPosition(-20.0f, 120.0f, sp::Alignment::TopRight);
        custom_function_sidebar->setVisible(sidebar_selector->getSelectionIndex() == 1);
        custom_function_sidebar->setPosition(-20.0f, 210.0f, sp::Alignment::TopRight);
        info_sidebar->setVisible(sidebar_selector->getSelectionIndex() == 0);
    }
    else
    {
        info_sidebar->setPosition(-20.0f, 170.0f, sp::Alignment::TopRight);
        sidebar_selector->setPosition(-20.0f, 120.0f, sp::Alignment::TopRight);
        custom_function_sidebar->setPosition(-280.0f, 170.0f, sp::Alignment::TopRight);
        custom_function_sidebar->show();
        info_sidebar->show();
    }

    // Reset scan info.
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

    for (int n = 0; n < ShipSystem::COUNT; n++)
        info_system[n]->setValue("-")->hide();

    // Manage probe view button state.
    probe_view_button->setVisible(rl);
    if (rl && rl->linked_entity)
    {
        probe_view_button->enable();
        if (auto probe_transform = rl->linked_entity.getComponent<sp::Transform>())
            probe_radar->setViewPosition(probe_transform->getPosition());
    }
    else
    {
        probe_view_button->disable();
        probe_view_button->setValue(false);
        science_radar->show();
        probe_radar->hide();
    }

    auto target = targets.get();
    if (target)
    {
        auto my_transform = my_spaceship.getComponent<sp::Transform>();
        auto target_transform = target.getComponent<sp::Transform>();

        if (my_transform && target_transform)
        {
            auto position_diff = target_transform->getPosition() - my_transform->getPosition();
            float distance = glm::length(position_diff);
            float heading = vec2ToAngle(position_diff) - 270.0f;

            while (heading < 0) heading += 360;

            info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
            info_heading->setValue(string(int(heading)));

            auto my_physics = my_spaceship.getComponent<sp::Physics>();
            auto target_physics = target.getComponent<sp::Physics>();
            if (my_physics && target_physics && distance > 0.0f) {
                float rel_velocity = dot(target_physics->getVelocity(), position_diff / distance) - dot(my_physics->getVelocity(), position_diff / distance);

                if (std::abs(rel_velocity) < 0.01f)
                    rel_velocity = 0.0f;
                info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K + "/min");
            }
        }

        if (auto cs = target.getComponent<CallSign>())
            info_callsign->setValue(cs->callsign);

        auto scanstate_component = target.getComponent<ScanState>();
        auto scanstate = scanstate_component ? scanstate_component->getStateFor(my_spaceship) : ScanState::State::FullScan;

        string description = "";
        if (auto sd = target.getComponent<ScienceDescription>())
        {
            switch (scanstate)
            {
            case ScanState::State::NotScanned: description = sd->not_scanned; break;
            case ScanState::State::FriendOrFoeIdentified: description = sd->friend_or_foe_identified; break;
            case ScanState::State::SimpleScan: description = sd->simple_scan; break;
            case ScanState::State::FullScan: description = sd->full_scan; break;
            }
        }
        if (!description.empty())
            info_description->setText(description)->show();

        // On a simple scan or deeper, show the faction, ship type, shields,
        // hull integrity, and database reference button.
        if (scanstate >= ScanState::State::SimpleScan)
        {
            auto faction = Faction::getInfo(target);
            info_faction->setValue(faction.locale_name);

            if (auto tn = target.getComponent<TypeName>())
                info_type->setValue(tn->localized);

            info_type_button->show();

            if (auto shields = target.getComponent<Shields>())
            {
                string str = "";
                for (size_t n = 0; n < shields->entries.size(); n++)
                {
                    if (n > 0) str += ":";
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
            auto shields_system = target.getComponent<Shields>();
            auto beam_system = target.getComponent<BeamWeaponSys>();

            // Rebuild pager tabs in order based on what the target actually has.
            // Preserve the current tab when the same target is re-drawn; reset on
            // a new target so the first relevant tab is shown instead.
            bool target_changed = (target != previous_target);
            previous_target = target;
            string prev_selection = target_changed ? "" : sidebar_pager->getSelectionValue();
            sidebar_pager->clear();

            // Tactical: only if server uses frequencies and at least one of shields
            // (with a valid frequency) or beams is present.
            if (gameGlobalInfo->use_beam_shield_frequencies
                && ((shields_system && shields_system->frequency != -1) || beam_system))
                sidebar_pager->addEntry(tr("scienceTab", "Tactical"), "Tactical");

            // Systems: only if target has any ship systems.
            bool has_systems = false;
            for (int n = 0; n < ShipSystem::COUNT; n++)
            {
                if (ShipSystem::get(target, ShipSystem::Type(n)))
                {
                    has_systems = true;
                    break;
                }
            }
            if (has_systems)
                sidebar_pager->addEntry(tr("scienceTab", "Systems"), "Systems");

            // Description: only if there is description text.
            if (!description.empty())
                sidebar_pager->addEntry(tr("scienceTab", "Description"), "Description");

            // Restore the previous tab if it still exists; otherwise prefer
            // Description if available, then fall back to the first tab.
            int prev_idx = sidebar_pager->indexByValue(prev_selection);
            if (prev_idx >= 0)
                sidebar_pager->setSelectionIndex(prev_idx);
            else if (sidebar_pager->entryCount() > 0)
            {
                int desc_idx = sidebar_pager->indexByValue("Description");
                sidebar_pager->setSelectionIndex(desc_idx >= 0 ? desc_idx : 0);
            }

            string sidebar_pager_selection = sidebar_pager->getSelectionValue();

            sidebar_pager->setVisible(sidebar_pager->entryCount() > 1);

            // Check sidebar pager state.
            if (sidebar_pager_selection == "Tactical")
            {
                info_shield_frequency->show();
                info_beam_frequency->show();

                for (int n = 0; n < ShipSystem::COUNT; n++)
                    info_system[n]->hide();

                info_description->hide();
            }
            else if (sidebar_pager_selection == "Systems")
            {
                info_shield_frequency->hide();
                info_beam_frequency->hide();

                for (int n = 0; n < ShipSystem::COUNT; n++)
                    info_system[n]->show();

                info_description->hide();
            }
            else if (sidebar_pager_selection == "Description")
            {
                info_shield_frequency->hide();
                info_beam_frequency->hide();

                for (int n = 0; n < ShipSystem::COUNT; n++)
                    info_system[n]->hide();

                info_description->show();
            }
            else if (!sidebar_pager_selection.empty())
                LOG(Warning, "Invalid pager state: ", sidebar_pager_selection);

            // If beam and shield frequencies are enabled on the server,
            // populate their graphs.
            if (gameGlobalInfo->use_beam_shield_frequencies)
            {
                info_shield_frequency
                    ->setFrequency(shields_system ? shields_system->frequency : -1)
                    ->setEnemyHasEquipment(shields_system);

                info_beam_frequency
                    ->setFrequency(beam_system ? beam_system->frequency : -1)
                    ->setEnemyHasEquipment(beam_system);
            }

            // Show the status of each subsystem.
            for (int n = 0; n < ShipSystem::COUNT; n++)
            {
                if (auto sys = ShipSystem::get(target, ShipSystem::Type(n)))
                {
                    const float system_health = sys->health;
                    info_system[n]
                        ->setValue(string(static_cast<int>(system_health * 100.0f)) + "%")
                        ->setBackColor(glm::u8vec4(255, static_cast<int>(127.5f * (system_health + 1)), static_cast<int>(127.5f * (system_health + 1)), 255));
                }
            }
        }
    }

    // If the target is a waypoint, show its heading and distance, and our
    // velocity toward it.
    else if (targets.getWaypointIndex() >= 0)
    {
        sidebar_pager->hide();
        if (auto waypoints = my_spaceship.getComponent<Waypoints>())
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
            {
                if (auto waypoint_position = waypoints->get(targets.getWaypointIndex()))
                {
                    auto position_diff = waypoint_position.value() - transform->getPosition();
                    float distance = glm::length(position_diff);
                    float heading = vec2ToAngle(position_diff) - 270.0f;

                    while (heading < 0.0f) heading += 360.0f;

                    info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
                    info_heading->setValue(string(static_cast<int>(heading)));

                    if (distance > 0.0f)
                    {
                        float rel_velocity = 0.0f;
                        if (auto physics = my_spaceship.getComponent<sp::Physics>())
                            rel_velocity = -dot(physics->getVelocity(), position_diff / distance);

                        if (std::abs(rel_velocity) < 0.01f) rel_velocity = 0.0f;
                        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K + "/min");
                    }
                }
            }
        }
    }
}

void ScienceScreen::onUpdate()
{
    if (my_spaceship)
    {
        // Initiate a scan on scannable objects.
        if (keys.science_scan_object.getDown() &&
            my_spaceship.hasComponent<ScienceScanner>() &&
            my_spaceship.getComponent<ScienceScanner>()->delay == 0.0f)
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
        if (keys.science_select_next_scannable.getDown() &&
            my_spaceship.hasComponent<ScienceScanner>() &&
            my_spaceship.getComponent<ScienceScanner>()->delay == 0.0f)
        {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
            {
                auto lrr = my_spaceship.getComponent<LongRangeRadar>();
                targets.setNext(transform->getPosition(), lrr ? lrr->long_range : DEFAULT_MAX_ZOOM_DISTANCE, TargetsContainer::ESelectionType::Scannable);
            }
        }

        // Open radar view.
        if (keys.science_open_radar.getDown())
        {
            view_mode_selection->setSelectionIndex(0);
            radar_view->show();
            background_gradient->show();
            database_view->hide();
        }

        // Open database view.
        if (keys.science_open_database.getDown())
        {
            view_mode_selection->setSelectionIndex(1);
            radar_view->hide();
            background_gradient->hide();
            database_view->show();
        }

        // Open database entry for the selected target.
        if (keys.science_open_database_target.getDown())
        {
            auto target = targets.get();
            auto scanstate_component = target.getComponent<ScanState>();
            auto scanstate = scanstate_component ? scanstate_component->getStateFor(my_spaceship) : ScanState::State::FullScan;
            if (auto tn = target.getComponent<TypeName>())
            {
                if (scanstate >= ScanState::State::SimpleScan
                    && (database_view->findAndDisplayEntry(tn->type_name) || database_view->findAndDisplayEntry(tn->localized)))
                {
                    view_mode_selection->setSelectionIndex(1);
                    radar_view->hide();
                    background_gradient->hide();
                    database_view->show();
                }
            }
        }

        // Navigate the sidebar tab selector. (scanning, custom functions)
        if (keys.science_sidebar_next.getDown() && sidebar_selector->isVisible())
        {
            const int count = sidebar_selector->entryCount();
            if (count > 0)
                sidebar_selector->setSelectionIndex((sidebar_selector->getSelectionIndex() + 1) % count);
        }
        if (keys.science_sidebar_prev.getDown() && sidebar_selector->isVisible())
        {
            const int count = sidebar_selector->entryCount();
            if (count > 0)
                sidebar_selector->setSelectionIndex((sidebar_selector->getSelectionIndex() + count - 1) % count);
        }

        // Navigate the sidebar pager. (tactical, systems, description)
        if (keys.science_sidebar_pager_next.getDown() && sidebar_pager->isVisible())
        {
            const int count = sidebar_pager->entryCount();
            if (count > 0)
                sidebar_pager->setSelectionIndex((sidebar_pager->getSelectionIndex() + 1) % count);
        }
        if (keys.science_sidebar_pager_prev.getDown() && sidebar_pager->isVisible())
        {
            const int count = sidebar_pager->entryCount();
            if (count > 0)
                sidebar_pager->setSelectionIndex((sidebar_pager->getSelectionIndex() + count - 1) % count);
        }
    }
}

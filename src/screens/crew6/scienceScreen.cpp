#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "scienceScreen.h"
#include "scienceDatabase.h"
#include "spaceObjects/nebula.h"

#include "screenComponents/radarView.h"
#include "screenComponents/rawScannerDataRadarOverlay.h"
#include "screenComponents/scanTargetButton.h"
#include "screenComponents/frequencyCurve.h"
#include "screenComponents/scanningDialog.h"
#include "screenComponents/databaseView.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_slider.h"

ScienceScreen::ScienceScreen(GuiContainer* owner, ECrewPosition crew_position)
: GuiOverlay(owner, "SCIENCE_SCREEN", colorConfig.background)
{
    targets.setAllowWaypointSelection();

    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(this, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradientOffset");

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Draw the radar.
    radar_view = new GuiElement(this, "RADAR_VIEW");
    radar_view->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Draw the science radar.
    science_radar = new GuiRadarView(radar_view, "SCIENCE_RADAR", my_spaceship ? my_spaceship->getLongRangeRadarRange() : 30000.0, &targets);
    science_radar->setPosition(-270, 0, ACenterRight)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    science_radar->setRangeIndicatorStepSize(5000.0)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
    science_radar->setCallbacks(
        [this](sf::Vector2f position) {
            if (!my_spaceship || my_spaceship->scanning_delay > 0.0)
                return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr
    );
    new RawScannerDataRadarOverlay(science_radar, "", my_spaceship->getLongRangeRadarRange());

    // Draw and hide the probe radar.
    probe_radar = new GuiRadarView(radar_view, "PROBE_RADAR", 5000, &targets);
    probe_radar->setPosition(-270, 0, ACenterRight)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();
    probe_radar->setAutoCentering(false)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NoFogOfWar);
    probe_radar->setCallbacks(
        [this](sf::Vector2f position) {
            if (!my_spaceship || my_spaceship->scanning_delay > 0.0)
                return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr
    );
    new RawScannerDataRadarOverlay(probe_radar, "", 5000);

    sidebar_selector = new GuiSelector(radar_view, "", [this](int index, string value)
    {
        info_sidebar->setVisible(index == 0);    
        custom_function_sidebar->setVisible(index == 1);
    });
    sidebar_selector->setOptions({"Scanning", "Other"});
    sidebar_selector->setSelectionIndex(0);
    sidebar_selector->setPosition(-20, 120, ATopRight)->setSize(250, 50);

    // Target scan data sidebar.
    info_sidebar = new GuiAutoLayout(radar_view, "SIDEBAR", GuiAutoLayout::LayoutVerticalTopToBottom);
    info_sidebar->setPosition(-20, 170, ATopRight)->setSize(250, GuiElement::GuiSizeMax);

    custom_function_sidebar = new GuiCustomShipFunctions(radar_view, crew_position, "");
    custom_function_sidebar->setPosition(-20, 170, ATopRight)->setSize(250, GuiElement::GuiSizeMax)->hide();

    // Scan button.
    scan_button = new GuiScanTargetButton(info_sidebar, "SCAN_BUTTON", &targets);
    scan_button->setSize(GuiElement::GuiSizeMax, 50);

    // Simple scan data.
    info_callsign = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_CALLSIGN", 0.4, "Callsign", "");
    info_callsign->setSize(GuiElement::GuiSizeMax, 30);
    info_distance = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_DISTANCE", 0.4, "Distance", "");
    info_distance->setSize(GuiElement::GuiSizeMax, 30);
    info_bearing = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_BEARING", 0.4, "Bearing", "");
    info_bearing->setSize(GuiElement::GuiSizeMax, 30);
    info_relspeed = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_REL_SPEED", 0.4, "Rel. Speed", "");
    info_relspeed->setSize(GuiElement::GuiSizeMax, 30);
    info_faction = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_FACTION", 0.4, "Faction", "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);
    info_type = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_TYPE", 0.4, "Type", "");
    info_type->setSize(GuiElement::GuiSizeMax, 30);
    info_type_button = new GuiButton(info_type, "SCIENCE_TYPE_BUTTON", "DB", [this]() {
        P<SpaceShip> ship = targets.get();
        if (ship)
        {
            if (database_view->findAndDisplayEntry(ship->getTypeName()))
            {
                view_mode_selection->setSelectionIndex(1);
                setViewModeSelectionToggle(1);
            }
        }
    });
    info_type_button->setTextSize(20)->setPosition(0, 1, ATopLeft)->setSize(50, 28);
    info_shields = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_SHIELDS", 0.4, "Shields", "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);
    info_hull = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_HULL", 0.4, "Hull", "");
    info_hull->setSize(GuiElement::GuiSizeMax, 30);

    // Full scan data

    // Draw and hide the sidebar pager.
    sidebar_pager = new GuiSelector(info_sidebar, "SIDEBAR_PAGER", [this](int index, string value) {});
    sidebar_pager->setSize(GuiElement::GuiSizeMax, 50)->hide();

    // If the server uses frequencies, add the Tactical sidebar page.
    if (gameGlobalInfo->use_beam_shield_frequencies)
        sidebar_pager->addEntry("Tactical", "Tactical");

    // Add sidebar page for systems.
    sidebar_pager->addEntry("Systems", "Systems");

    // Add sidebar page for a description.
    sidebar_pager->addEntry("Description", "Description");

    // If the ship has detailed signals on radar, add a sidebar page for them.
    if (my_spaceship->has_signal_radar)
        sidebar_pager->addEntry("Signals", "Signals");

    // Default the pager to the first item.
    sidebar_pager->setSelectionIndex(0);

    // Prep and hide the frequency graphs.
    info_shield_frequency = new GuiFrequencyCurve(info_sidebar, "SCIENCE_SHIELD_FREQUENCY", false, true);
    info_shield_frequency->setSize(GuiElement::GuiSizeMax, 150);
    info_beam_frequency = new GuiFrequencyCurve(info_sidebar, "SCIENCE_BEAM_FREQUENCY", true, false);
    info_beam_frequency->setSize(GuiElement::GuiSizeMax, 150);

    // Show shield and beam frequencies only if enabled by the server.
    if (!gameGlobalInfo->use_beam_shield_frequencies)
    {
        info_shield_frequency->hide();
        info_beam_frequency->hide();
    }

    // List each system's status.
    for(int n = 0; n < SYS_COUNT; n++)
    {
        info_system[n] = new GuiKeyValueDisplay(info_sidebar, "SCIENCE_SYSTEM_" + string(n), 0.75, getLocaleSystemName(ESystem(n)), "-");
        info_system[n]->setSize(GuiElement::GuiSizeMax, 30);
        info_system[n]->hide();
    }

    // Prep and hide the description text area.
    info_description = new GuiScrollText(info_sidebar, "SCIENCE_DESC", "");
    info_description->setTextSize(28)->setMargins(20, 20, 0, 0)->setSize(GuiElement::GuiSizeMax, 400)->hide();

    // Prep and hide the detailed signal bands.
    info_electrical_signal_band = new GuiSignalQualityIndicator(info_sidebar, "ELECTRICAL_SIGNAL");
    info_electrical_signal_band->showGreen(false)->showBlue(false)->setSize(GuiElement::GuiSizeMax, 80)->hide();
    info_electrical_signal_label = new GuiLabel(info_electrical_signal_band, "", "Electrical", 30);
    info_electrical_signal_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    info_gravity_signal_band = new GuiSignalQualityIndicator(info_sidebar, "GRAVITY_SIGNAL");
    info_gravity_signal_band->showRed(false)->showBlue(false)->setSize(GuiElement::GuiSizeMax, 80)->hide();
    info_gravity_signal_label = new GuiLabel(info_gravity_signal_band, "", "Gravitational", 30);
    info_gravity_signal_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    info_biological_signal_band = new GuiSignalQualityIndicator(info_sidebar, "BIOLOGICAL_SIGNAL");
    info_biological_signal_band->showRed(false)->showGreen(false)->setSize(GuiElement::GuiSizeMax, 80)->hide();
    info_biological_signal_label = new GuiLabel(info_biological_signal_band, "", "Biological", 30);
    info_biological_signal_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Prep and hide the database view.
    database_view = new DatabaseViewComponent(this);
    database_view->hide()->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Probe view button
    probe_view_button = new GuiToggleButton(radar_view, "PROBE_VIEW", "Probe View", [this](bool value){
        P<ScanProbe> probe;

        if (game_server)
            probe = game_server->getObjectById(my_spaceship->linked_science_probe_id);
        else
            probe = game_client->getObjectById(my_spaceship->linked_science_probe_id);
        
        if (value && probe)
        {
            sf::Vector2f probe_position = probe->getPosition();
            science_radar->hide();
            probe_radar->show();
            probe_radar->setViewPosition(probe_position)->show();
        } else {
            probe_view_button->setValue(false);
            science_radar->show();
            probe_radar->hide();
        }
    });
    probe_view_button->setPosition(20, -120, ABottomLeft)->setSize(200, 50)->disable();

    // Draw the zoom slider.
    zoom_slider = new GuiSlider(radar_view, "", my_spaceship->getLongRangeRadarRange(), my_spaceship->getShortRangeRadarRange(), my_spaceship->getLongRangeRadarRange(), [this](float value)
    {
        if (my_spaceship)
            zoom_label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(my_spaceship->getLongRangeRadarRange() / value, 1)}}));
        science_radar->setDistance(value);
    });
    zoom_slider->setPosition(-20, -20, ABottomRight)->setSize(250, 50);
    zoom_label = new GuiLabel(zoom_slider, "", "Zoom: 1.0x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Radar signal details toggle.
    signal_details_toggle = new GuiToggleButton(this, "SIGNAL_DETAILS_TOGGLE", "Signal Details", [this](bool value){ setSignalDetailsToggle(value); });
    signal_details_toggle->setPosition(-270, -20, ABottomRight)->setSize(200, 50)->setVisible(my_spaceship->has_signal_radar);

    // Visual objects (radar trace) toggle.
    signal_details_visual_button = new GuiToggleButton(this, "SIGNAL_DETAILS_VISUAL", "V", [this](bool value){
        setVisualDetailsToggle(value);
    });
    signal_details_visual_button->setValue(false)->setPosition(-420, -70, ABottomRight)->setSize(50, 50)->setVisible(false);

    // Electrical view toggle.
    signal_details_electrical_button = new GuiToggleButton(this, "SIGNAL_DETAILS_ELECTRICAL", "E", [this](bool value){
        setElectricalDetailsToggle(value);
    });
    signal_details_electrical_button->setValue(true)->setPosition(-370, -70, ABottomRight)->setSize(50, 50)->setVisible(false);
    signal_details_electrical_button->setColors(colorConfig.button_red);

    // Gravity view toggle.
    signal_details_gravity_button = new GuiToggleButton(this, "SIGNAL_DETAILS_GRAVITY", "G", [this](bool value){
        setGravityDetailsToggle(value);
    });
    signal_details_gravity_button->setValue(false)->setPosition(-320, -70, ABottomRight)->setSize(50, 50)->setVisible(false);
    signal_details_gravity_button->setColors(colorConfig.button_green);

    // Biological view toggle.
    signal_details_biological_button = new GuiToggleButton(this, "SIGNAL_DETAILS_BIOLOGICAL", "B", [this](bool value){
        setBiologicalDetailsToggle(value);
    });
    signal_details_biological_button->setValue(false)->setPosition(-270, -70, ABottomRight)->setSize(50, 50)->setVisible(false);
    signal_details_biological_button->setColors(colorConfig.button_blue);

    // Radar/database view toggle.
    view_mode_selection = new GuiListbox(this, "VIEW_SELECTION", [this](int index, string value) { setViewModeSelectionToggle(index); });
    view_mode_selection->setOptions({"Radar", "Database"})->setSelectionIndex(0)->setPosition(20, -20, ABottomLeft)->setSize(200, 100);

    // Scanning dialog.
    new GuiScanningDialog(this, "SCANNING_DIALOG");
}

void ScienceScreen::setViewModeSelectionToggle(int index)
{
    radar_view->setVisible(index == 0);
    background_gradient->setVisible(index == 0);
    database_view->setVisible(index == 1);

    // Switching to database view resets signal details if available.
    if (my_spaceship->has_signal_radar)
    {
        signal_details_toggle->setValue(false)->setVisible(index == 0);
        setSignalDetailsToggle(false);
        signal_details_visual_button->setVisible(false);
        signal_details_electrical_button->setVisible(false);
        signal_details_gravity_button->setVisible(false);
        signal_details_biological_button->setVisible(false);
    }
}

void ScienceScreen::setSignalDetailsToggle(bool value)
{
    if (my_spaceship->has_signal_radar)
    {
        // Toggle visibility of signal lens toggles.
        signal_details_visual_button->setValue(true)->setVisible(value);
        signal_details_electrical_button->setValue(false)->setVisible(value);
        signal_details_gravity_button->setValue(false)->setVisible(value);
        signal_details_biological_button->setValue(false)->setVisible(value);

        // Toggle and reset signal details.
        science_radar->setSignalDetails(value);
        probe_radar->setSignalDetails(value);
        science_radar->setVisualObjects(true)->setSignalElectrical(false)->setSignalGravity(false)->setSignalBiological(false);
        probe_radar->setVisualObjects(true)->setSignalElectrical(false)->setSignalGravity(false)->setSignalBiological(false);
    }
}

void ScienceScreen::setVisualDetailsToggle(bool value)
{
    if (my_spaceship->has_signal_radar && science_radar->getSignalDetails())
    {
        science_radar->setVisualObjects(value)->setSignalElectrical(!value)->setSignalGravity(!value)->setSignalBiological(!value);
        probe_radar->setVisualObjects(value)->setSignalElectrical(!value)->setSignalGravity(!value)->setSignalBiological(!value);
        signal_details_electrical_button->setValue(!value);
        signal_details_gravity_button->setValue(!value);
        signal_details_biological_button->setValue(!value);
    }
}

void ScienceScreen::setElectricalDetailsToggle(bool value)
{
    if (my_spaceship->has_signal_radar && science_radar->getSignalDetails())
    {
        science_radar->setSignalElectrical(value)->setVisualObjects(false);
        probe_radar->setSignalElectrical(value)->setVisualObjects(false);
        signal_details_visual_button->setValue(false);
    }
}

void ScienceScreen::setGravityDetailsToggle(bool value)
{
    if (my_spaceship->has_signal_radar && science_radar->getSignalDetails())
    {
        science_radar->setSignalGravity(value)->setVisualObjects(false);
        probe_radar->setSignalGravity(value)->setVisualObjects(false);
        signal_details_visual_button->setValue(false);
    }
}

void ScienceScreen::setBiologicalDetailsToggle(bool value)
{
    if (my_spaceship->has_signal_radar && science_radar->getSignalDetails())
    {
        science_radar->setSignalBiological(value)->setVisualObjects(false);
        probe_radar->setSignalBiological(value)->setVisualObjects(false);
        signal_details_visual_button->setValue(false);
    }
}

void ScienceScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
    P<ScanProbe> probe;

    // Handle mouse wheel
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0 && my_spaceship)
    {
        float view_distance = science_radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        if (view_distance > my_spaceship->getLongRangeRadarRange())
            view_distance = my_spaceship->getLongRangeRadarRange();
        if (view_distance < my_spaceship->getShortRangeRadarRange())
            view_distance = my_spaceship->getShortRangeRadarRange();
        science_radar->setDistance(view_distance);
        // Keep the zoom slider in sync.
        zoom_slider->setValue(view_distance);
        zoom_label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(my_spaceship->getLongRangeRadarRange() / view_distance, 1)}}));
    }

    // Draw only if we're looking at our own ship.
    if (!my_spaceship)
        return;

    // Use local data to determine which probe is linked.
    if (game_server)
        probe = game_server->getObjectById(my_spaceship->linked_science_probe_id);
    else
        probe = game_client->getObjectById(my_spaceship->linked_science_probe_id);

    // Clear our selected target if it is hidden by a nebula or its shadow,
    // or if we're in probe view and the object is out of range.
    if (probe_view_button->getValue() && probe)
    {
        if (targets.get() && (probe->getPosition() - targets.get()->getPosition()) > 5000.0f)
            targets.clear();
    } else {
        if (targets.get() && Nebula::blockedByNebula(my_spaceship->getPosition(), targets.get()->getPosition()))
            targets.clear();
    }
    
    // Show the custom function sidebar if any entries are present.
    sidebar_selector->setVisible(sidebar_selector->getSelectionIndex() > 0 || custom_function_sidebar->hasEntries());

    // Initialize info fields.
    info_callsign->setValue("-");
    info_distance->setValue("-");
    info_bearing->setValue("-");
    info_relspeed->setValue("-");
    info_faction->setValue("-");
    info_type->setValue("-");
    info_shields->setValue("-");
    info_hull->setValue("-");
    info_shield_frequency->setFrequency(-1)->hide();
    info_beam_frequency->setFrequency(-1)->hide();
    info_description->hide();
    info_electrical_signal_band->hide();
    info_gravity_signal_band->hide();
    info_biological_signal_band->hide();
    info_type_button->hide();

    for(int n = 0; n < SYS_COUNT; n++)
        info_system[n]->setValue("-")->hide();

    // Show probe view if enabled.
    if (probe)
    {
        probe_view_button->enable();
        probe_radar->setViewPosition(probe->getPosition());
    } else {
        probe_view_button->disable();
        probe_view_button->setValue(false);
        science_radar->show();
        probe_radar->hide();
    }

    // Populate data based on our current target.
    if (targets.get())
    {
        P<SpaceObject> obj = targets.get();
        P<SpaceShip> ship = obj;
        P<SpaceStation> station = obj;

        sf::Vector2f position_diff = obj->getPosition() - my_spaceship->getPosition();
        float distance = sf::length(position_diff);
        float bearing = sf::vector2ToAngle(position_diff) - 270;

        while(bearing < 0) bearing += 360;

        float rel_velocity = dot(obj->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);

        if (fabs(rel_velocity) < 0.01)
            rel_velocity = 0.0;

        info_callsign->setValue(obj->getCallSign());
        info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
        info_bearing->setValue(string(int(bearing)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K + "/min");

        string description = obj->getDescriptionFor(my_spaceship);
        string sidebar_pager_selection = sidebar_pager->getSelectionValue();
        RawRadarSignatureInfo radar_info;

        if (my_spaceship->has_signal_radar)
        {
            // If our ship has detailed signal radar, add the Signals page to
            // the sidebar.
            if (!sidebar_pager->indexByValue("Signals"))
                sidebar_pager->addEntry("Signals", "Signals");

            // Get the target's detailed radar signature information.
            // If it's a ship, get its dynamic values.
            if (ship)
                radar_info = ship->getDynamicRadarSignatureInfo();
            else
                radar_info = obj->getRadarSignatureInfo();
        } else {
            // Otherwise, remove the page from the sidebar.
            sidebar_pager->removeEntry(sidebar_pager->indexByValue("Signals"));
        }

        if (description.size() > 0)
        {
            // If the target has a description, add a page for it to the sidebar.
            if (!sidebar_pager->indexByValue("Description"))
                sidebar_pager->addEntry("Description", "Description");

            // Populate the description.
            info_description->setText(description)->show();
        } else {
            // Otherwise, remove the page from the sidebar.
            sidebar_pager->removeEntry(sidebar_pager->indexByValue("Description"));
        }

        // If the target is a ship, show additional information about the ship
        // based on how deeply we've scanned it.
        if (ship)
        {
            // On a simple scan or deeper, show the faction, ship type,
            // shields, hull integrity, and database reference button.
            if (ship->getScannedStateFor(my_spaceship) >= SS_SimpleScan)
            {
                info_faction->setValue(factionInfo[obj->getFactionId()]->getLocaleName());
                info_type->setValue(ship->getTypeName());
                info_type_button->show();
                info_shields->setValue(ship->getShieldDataString());
                info_hull->setValue(int(ship->getHull()));
            }

            // On a full scan, show tactical and systems data (if any), and its
            // description (if one is set).
            if (ship->getScannedStateFor(my_spaceship) >= SS_FullScan)
            {
                // If beam and shield frequencies are enabled on the server,
                // populate their graphs.
                if (gameGlobalInfo->use_beam_shield_frequencies)
                {
                    info_shield_frequency->setFrequency(ship->shield_frequency);
                    info_beam_frequency->setFrequency(ship->beam_frequency);
                }
                
                // Show the status of each subsystem.
                for(int n = 0; n < SYS_COUNT; n++)
                {
                    float system_health = ship->systems[n].health;
                    info_system[n]->setValue(string(int(system_health * 100.0f)) + "%")->setColor(sf::Color(255, 127.5 * (system_health + 1), 127.5 * (system_health + 1), 255));
                }
            }
        } else {
            // If the target isn't a ship, populate only basic info.
            info_faction->setValue(factionInfo[obj->getFactionId()]->getLocaleName());

            // If the target is a station, populate basic tactical info.
            if (station)
            {
                info_type->setValue(station->template_name);
                info_shields->setValue(station->getShieldDataString());
                info_hull->setValue(int(station->getHull()));
            }
        }

        // Show the sidebar pager.
        sidebar_pager->setVisible(sidebar_pager->entryCount() > 1);

        // Check sidebar pager state.
        info_shield_frequency->hide();
        info_beam_frequency->hide();

        for(int n = 0; n < SYS_COUNT; n++)
            info_system[n]->hide();

        info_description->hide();

        info_electrical_signal_band->hide();
        info_gravity_signal_band->hide();
        info_biological_signal_band->hide();

        if (sidebar_pager_selection == "Tactical")
        {
            info_shield_frequency->show();
            info_beam_frequency->show();
        } else if (sidebar_pager_selection == "Systems") {
            for(int n = 0; n < SYS_COUNT; n++)
                info_system[n]->show();
        } else if (sidebar_pager_selection == "Description") {
            info_description->show();
        } else if (sidebar_pager_selection == "Signals") {
            info_electrical_signal_band->show();
            info_gravity_signal_band->show();
            info_biological_signal_band->show();

            // Calculate signal noise for unscanned objects more than SRRR away.
            float distance_variance = 0.0f;
            float signal = 0.0f;

            if (distance > my_spaceship->getShortRangeRadarRange() && !obj->isScannedBy(my_spaceship))
                distance_variance = (random(0.01f, (distance - my_spaceship->getShortRangeRadarRange())) / (my_spaceship->getLongRangeRadarRange() - my_spaceship->getShortRangeRadarRange())) / 10;

            // Calculate their waveforms.
            signal = std::max(0.0f, radar_info.electrical - distance_variance);
            info_electrical_signal_band->setMaxAmp(signal);
            info_electrical_signal_band->setNoiseError(std::max(0.0f, (signal - 1.0f) / 10));
            info_electrical_signal_label->setText("Electrical: " + string(signal) + " MJ");

            signal = std::max(0.0f, radar_info.gravity - distance_variance);
            info_gravity_signal_band->setMaxAmp(signal);
            info_gravity_signal_band->setPeriodError(std::max(0.0f, (signal - 1.0f) / 10));
            info_gravity_signal_label->setText("Gravitational: " + string(signal) + " dN");

            signal = std::max(0.0f, radar_info.biological - distance_variance);
            info_biological_signal_band->setMaxAmp(signal);
            info_biological_signal_band->setPhaseError(std::max(0.0f, (signal - 1.0f) / 10));
            info_biological_signal_label->setText("Biological: " + string(signal) + " um");
        } else {
            LOG(WARNING) << "Invalid pager state: " << sidebar_pager_selection;
        }
    } else if (targets.getWaypointIndex() >= 0) {
        // If the target is a waypoint, hide the sidebar pager.
        sidebar_pager->hide();

        // Show the waypoint's bearing and distance, and our velocity toward
        // it.
        sf::Vector2f position_diff = my_spaceship->waypoints[targets.getWaypointIndex()] - my_spaceship->getPosition();
        float distance = sf::length(position_diff);
        float bearing = sf::vector2ToAngle(position_diff) - 270;

        while(bearing < 0) bearing += 360;

        float rel_velocity = -dot(my_spaceship->getVelocity(), position_diff / distance);

        if (fabs(rel_velocity) < 0.01)
            rel_velocity = 0.0;

        info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
        info_bearing->setValue(string(int(bearing)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K + "/min");
    } else {
        // Hide the sidebar pager if we don't have a target.
        sidebar_pager->hide();
    }

    // If this ship has detailed signal radar and all buttons are off,
    // enable visual only.
    if (my_spaceship->has_signal_radar &&
        !signal_details_visual_button->getValue() &&
        !signal_details_electrical_button->getValue() &&
        !signal_details_gravity_button->getValue() &&
        !signal_details_biological_button->getValue())
    {
        setVisualDetailsToggle(true);
        signal_details_visual_button->setValue(true);
    }
}

void ScienceScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "SCIENCE" && my_spaceship)
    {
        // Initiate a scan on scannable objects.
        if (key.hotkey == "SCAN_OBJECT" &&
            my_spaceship->scanning_delay == 0.0)
        {
            P<SpaceObject> obj = targets.get();

            // Allow scanning only if the object is scannable, and if the player
            // isn't already scanning something.
            if (obj &&
                obj->canBeScannedBy(my_spaceship))
            {
                my_spaceship->commandScan(obj);
                return;
            }
        }

        // Cycle selection through scannable objects.
        if (key.hotkey == "NEXT_SCANNABLE_OBJECT" &&
            my_spaceship->scanning_delay == 0.0)
        {
            bool current_found = false;
            for (P<SpaceObject> obj : space_object_list)
            {
                // If this object is the current object, flag and skip it.
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }

                // If this object is my ship or not visible due to a Nebula,
                // skip it.
                if (obj == my_spaceship ||
                    Nebula::blockedByNebula(my_spaceship->getPosition(), obj->getPosition()))
                    continue;

                // If this is a scannable object and the currently selected
                // object, and it remains in radar range, continue to set it.
                if (current_found &&
                    sf::length(obj->getPosition() - my_spaceship->getPosition()) < science_radar->getDistance() &&
                    obj->canBeScannedBy(my_spaceship))
                {
                    targets.set(obj);
                    return;
                }
            }

            // Advance to the next object.
            for (P<SpaceObject> obj : space_object_list)
            {
                if (obj == targets.get() ||
                    obj == my_spaceship ||
                    Nebula::blockedByNebula(my_spaceship->getPosition(), obj->getPosition()))
                    continue;

                if (sf::length(obj->getPosition() - my_spaceship->getPosition()) < science_radar->getDistance() &&
                    obj->canBeScannedBy(my_spaceship))
                {
                    targets.set(obj);
                    return;
                }
            }
        }

        // Signal details toggles.
        if (my_spaceship->has_signal_radar && view_mode_selection->getSelectionIndex() == 0)
        {
            if (key.hotkey == "TOGGLE_SIGNAL_DETAILS")
            {
                if (science_radar->isVisible() || probe_radar->isVisible())
                {
                    bool new_value = !signal_details_toggle->getValue();
                    setSignalDetailsToggle(new_value);
                    signal_details_toggle->setValue(new_value);
                }
                return;
            }

            if (key.hotkey == "TOGGLE_VISUAL_DETAILS")
            {
                if (signal_details_toggle->getValue() && (science_radar->isVisible() || probe_radar->isVisible()))
                {
                    bool new_value = !signal_details_visual_button->getValue();
                    setVisualDetailsToggle(new_value);
                    signal_details_visual_button->setValue(new_value);
                }
                return;
            }

            if (key.hotkey == "TOGGLE_ELECTRICAL_DETAILS")
            {
                if (signal_details_toggle->getValue() && (science_radar->isVisible() || probe_radar->isVisible()))
                {
                    bool new_value = !signal_details_electrical_button->getValue();
                    setElectricalDetailsToggle(new_value);
                    signal_details_electrical_button->setValue(new_value);
                }
                return;
            }

            if (key.hotkey == "TOGGLE_GRAVITY_DETAILS")
            {
                if (signal_details_toggle->getValue() && (science_radar->isVisible() || probe_radar->isVisible()))
                {
                    bool new_value = !signal_details_gravity_button->getValue();
                    setGravityDetailsToggle(new_value);
                    signal_details_gravity_button->setValue(new_value);
                }
                return;
            }

            if (key.hotkey == "TOGGLE_BIOLOGICAL_DETAILS")
            {
                if (signal_details_toggle->getValue() && (science_radar->isVisible() || probe_radar->isVisible()))
                {
                    bool new_value = !signal_details_biological_button->getValue();
                    setBiologicalDetailsToggle(new_value);
                    signal_details_biological_button->setValue(new_value);
                }
                return;
            }
        }
    }
}

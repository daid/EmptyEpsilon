#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "scienceScreen.h"
#include "spaceObjects/nebula.h"

#include "screenComponents/radarView.h"
#include "screenComponents/rawScannerDataRadarOverlay.h"
#include "screenComponents/scanTargetButton.h"
#include "screenComponents/frequencyCurve.h"
#include "screenComponents/scanningDialog.h"
#include "screenComponents/databaseView.h"
#include "screenComponents/alertOverlay.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_slider.h"

ScienceScreen::ScienceScreen(GuiContainer* owner)
: GuiOverlay(owner, "SCIENCE_SCREEN", colorConfig.background)
{
    targets.setAllowWaypointSelection();

#ifndef __APPLE__
    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(this, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradientOffset");
#endif
    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    radar_view = new GuiElement(this, "RADAR_VIEW");
    radar_view->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    science_radar = new GuiRadarView(radar_view, "SCIENCE_RADAR", gameGlobalInfo->long_range_radar_range, &targets);
    science_radar->setPosition(-270, 0, ACenterRight)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    science_radar->setRangeIndicatorStepSize(5000.0)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
    science_radar->setCallbacks(
        [this](sf::Vector2f position) {
            if (!my_spaceship || my_spaceship->scanning_delay > 0.0)
                return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr
    );
    new RawScannerDataRadarOverlay(science_radar, "", gameGlobalInfo->long_range_radar_range);

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

    GuiAutoLayout* sidebar = new GuiAutoLayout(radar_view, "SIDE_BAR", GuiAutoLayout::LayoutVerticalTopToBottom);
    sidebar->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiScanTargetButton(sidebar, "SCAN_BUTTON", &targets))->setSize(GuiElement::GuiSizeMax, 50);

    info_callsign = new GuiKeyValueDisplay(sidebar, "SCIENCE_CALLSIGN", 0.4, "Callsign", "");
    info_callsign->setSize(GuiElement::GuiSizeMax, 30);
    info_distance = new GuiKeyValueDisplay(sidebar, "SCIENCE_DISTANCE", 0.4, "Distance", "");
    info_distance->setSize(GuiElement::GuiSizeMax, 30);
    info_heading = new GuiKeyValueDisplay(sidebar, "SCIENCE_DISTANCE", 0.4, "Heading", "");
    info_heading->setSize(GuiElement::GuiSizeMax, 30);
    info_relspeed = new GuiKeyValueDisplay(sidebar, "SCIENCE_REL_SPEED", 0.4, "Rel.Speed", "");
    info_relspeed->setSize(GuiElement::GuiSizeMax, 30);

    info_faction = new GuiKeyValueDisplay(sidebar, "SCIENCE_FACTION", 0.4, "Faction", "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);
    info_type = new GuiKeyValueDisplay(sidebar, "SCIENCE_TYPE", 0.4, "Type", "");
    info_type->setSize(GuiElement::GuiSizeMax, 30);
    info_type_button = new GuiButton(info_type, "SCIENCE_TYPE_BUTTON", "DB", [this]() {
        P<SpaceShip> ship = targets.get();
        if (ship)
        {
            if (database_view->findAndDisplayEntry(ship->getTypeName()))
            {
                view_mode_selection->setSelectionIndex(1);
                radar_view->hide();
                background_gradient->hide();
                database_view->show();
            }
        }
    });
    info_type_button->setTextSize(20)->setPosition(0, 1, ATopRight)->setSize(50, 28);
    info_shields = new GuiKeyValueDisplay(sidebar, "SCIENCE_SHIELDS", 0.4, "Shields", "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);
    info_hull = new GuiKeyValueDisplay(sidebar, "SCIENCE_HULL", 0.4, "Hull", "");
    info_hull->setSize(GuiElement::GuiSizeMax, 30);

    info_shield_frequency = new GuiFrequencyCurve(sidebar, "SCIENCE_SHIELD_FREQUENCY", false, true);
    info_shield_frequency->setSize(GuiElement::GuiSizeMax, 75);
    info_beam_frequency = new GuiFrequencyCurve(sidebar, "SCIENCE_SHIELD_FREQUENCY", true, false);
    info_beam_frequency->setSize(GuiElement::GuiSizeMax, 75);

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
        }else{
            probe_view_button->setValue(false);
            science_radar->show();
            probe_radar->hide();
        }
    });
    probe_view_button->setPosition(20, -120, ABottomLeft)->setSize(200, 50)->disable();

    zoom_slider = new GuiSlider(radar_view, "", gameGlobalInfo->long_range_radar_range, 5000.0, gameGlobalInfo->long_range_radar_range, [this](float value)
    {
        zoom_label->setText("Zoom: " + string(gameGlobalInfo->long_range_radar_range / value, 1) + "x");
        science_radar->setDistance(value);
    });
    zoom_slider->setPosition(-20, -20, ABottomRight)->setSize(250, 50);
    zoom_label = new GuiLabel(zoom_slider, "", "Zoom: 1.0x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    if (!gameGlobalInfo->use_beam_shield_frequencies)
    {
        info_shield_frequency->hide();
        info_beam_frequency->hide();
    }

    for(int n=0; n<SYS_COUNT; n++)
    {
        info_system[n] = new GuiKeyValueDisplay(sidebar, "SCIENCE_SYSTEM_" + string(n), 0.75, getSystemName(ESystem(n)), "-");
        info_system[n]->setSize(GuiElement::GuiSizeMax, 30);
        info_system[n]->hide();
    }

    info_description = new GuiScrollText(sidebar, "SCIENCE_DESC", "");
    info_description->setTextSize(20)->hide()->setSize(GuiElement::GuiSizeMax, 400);

    database_view = new DatabaseViewComponent(this);
    database_view->hide()->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    view_mode_selection = new GuiListbox(this, "VIEW_SELECTION", [this](int index, string value) {
        radar_view->setVisible(index == 0);
        background_gradient->setVisible(index == 0);
        database_view->setVisible(index == 1);
    });
    view_mode_selection->setOptions({"Radar", "Database"})->setSelectionIndex(0)->setPosition(20, -20, ABottomLeft)->setSize(200, 100);

    new GuiScanningDialog(this, "SCANNING_DIALOG");
}

void ScienceScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
    P<ScanProbe> probe;

    ///Handle mouse wheel
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0)
    {
        float view_distance = science_radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        if (view_distance > gameGlobalInfo->long_range_radar_range)
            view_distance = gameGlobalInfo->long_range_radar_range;
        if (view_distance < 5000.0f)
            view_distance = 5000.0f;
        science_radar->setDistance(view_distance);
        // Keep the zoom slider in sync.
        zoom_slider->setValue(view_distance);
        zoom_label->setText("Zoom: " + string(gameGlobalInfo->long_range_radar_range / view_distance, 1) + "x");
    }

    if (!my_spaceship)
        return;

    if (game_server)
        probe = game_server->getObjectById(my_spaceship->linked_science_probe_id);
    else
        probe = game_client->getObjectById(my_spaceship->linked_science_probe_id);

    if (probe_view_button->getValue() && probe)
    {
        if (targets.get() && (probe->getPosition() - targets.get()->getPosition()) > 5000.0f)
            targets.clear();
    }else{
        if (targets.get() && Nebula::blockedByNebula(my_spaceship->getPosition(), targets.get()->getPosition()))
            targets.clear();
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

    for(int n=0; n<SYS_COUNT; n++)
        info_system[n]->setValue("-")->hide();

    if (probe)
    {
        probe_view_button->enable();
        probe_radar->setViewPosition(probe->getPosition());
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
        P<SpaceObject> obj = targets.get();
        P<SpaceShip> ship = obj;
        P<SpaceStation> station = obj;

        sf::Vector2f position_diff = obj->getPosition() - my_spaceship->getPosition();
        float distance = sf::length(position_diff);
        float heading = sf::vector2ToAngle(position_diff) - 270;
        while(heading < 0) heading += 360;
        float rel_velocity = dot(obj->getVelocity(), position_diff / distance) - dot(my_spaceship->getVelocity(), position_diff / distance);
        if (fabs(rel_velocity) < 0.01)
            rel_velocity = 0.0;

        info_callsign->setValue(obj->getCallSign());
        info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
        info_heading->setValue(string(int(heading)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K + "/min");

        if (ship)
        {
            if (ship->getScannedStateFor(my_spaceship) >= SS_SimpleScan)
            {
                info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
                info_type->setValue(ship->getTypeName());
                info_shields->setValue(ship->getShieldDataString());
                info_hull->setValue(int(ship->getHull()));
                info_type_button->show();
            }
            if (ship->getScannedStateFor(my_spaceship) >= SS_FullScan)
            {
                if (gameGlobalInfo->use_beam_shield_frequencies)
                {
                    info_shield_frequency->setFrequency(ship->shield_frequency)->show();
                    info_beam_frequency->setFrequency(ship->beam_frequency)->show();
                }
                for(int n=0; n<SYS_COUNT; n++)
                {
                    info_system[n]->setValue(string(int(ship->systems[n].health * 100.0f)) + "%");
                    info_system[n]->show();
                }
            }
        }else{
            info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
            if (station)
            {
                info_type->setValue(station->template_name);
                info_shields->setValue(station->getShieldDataString());
                info_hull->setValue(int(station->getHull()));
            }
        }
        string description = obj->getDescription();
        if (description.size() > 0)
        {
            info_description->setText(description)->show();
        }
    }else if (targets.getWaypointIndex() >= 0)
    {
        sf::Vector2f position_diff = my_spaceship->waypoints[targets.getWaypointIndex()] - my_spaceship->getPosition();
        float distance = sf::length(position_diff);
        float heading = sf::vector2ToAngle(position_diff) - 270;
        while(heading < 0) heading += 360;
        float rel_velocity = -dot(my_spaceship->getVelocity(), position_diff / distance);
        if (fabs(rel_velocity) < 0.01)
            rel_velocity = 0.0;

        info_distance->setValue(string(distance / 1000.0f, 1) + DISTANCE_UNIT_1K);
        info_heading->setValue(string(int(heading)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + DISTANCE_UNIT_1K + "/min");
    }
}

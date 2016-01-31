#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "scienceScreen.h"
#include "spaceObjects/nebula.h"

#include "screenComponents/radarView.h"
#include "screenComponents/scanTargetButton.h"
#include "screenComponents/frequencyCurve.h"
#include "screenComponents/scanningDialog.h"
#include "screenComponents/databaseView.h"

ScienceScreen::ScienceScreen(GuiContainer* owner)
: GuiOverlay(owner, "SCIENCE_SCREEN", sf::Color::Black)
{
    targets.setAllowWaypointSelection();

    radar_view = new GuiElement(this, "RADAR_VIEW");
    radar_view->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    radar = new GuiRadarView(radar_view, "SCIENCE_RADAR", gameGlobalInfo->long_range_radar_range, &targets);
    radar->setPosition(20, 0, ACenterLeft)->setSize(GuiElement::GuiSizeMatchHeight, GuiElement::GuiSizeMax);
    radar->setRangeIndicatorStepSize(5000.0)->longRange()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            if (!my_spaceship || my_spaceship->scanning_delay > 0.0)
                return;

            targets.setToClosestTo(position, 1000, TargetsContainer::Selectable);
        }, nullptr, nullptr
    );

    GuiAutoLayout* sidebar = new GuiAutoLayout(radar_view, "SIDE_BAR", GuiAutoLayout::LayoutVerticalTopToBottom);
    sidebar->setPosition(-20, 50, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
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
    info_shields = new GuiKeyValueDisplay(sidebar, "SCIENCE_SHIELDS", 0.4, "Shields", "");
    info_shields->setSize(GuiElement::GuiSizeMax, 30);

    info_shield_frequency = new GuiFrequencyCurve(sidebar, "SCIENCE_SHIELD_FREQUENCY", false, true);
    info_shield_frequency->setSize(GuiElement::GuiSizeMax, 100);
    info_beam_frequency = new GuiFrequencyCurve(sidebar, "SCIENCE_SHIELD_FREQUENCY", true, false);
    info_beam_frequency->setSize(GuiElement::GuiSizeMax, 100);

    probe_view_button = new GuiButton(radar_view, "LINK_TO_SCIENCE", "Probe View", [this](){
        P<ScanProbe> probe;

        if (game_server)
            probe = game_server->getObjectById(my_spaceship->linked_object);
        else
            probe = game_client->getObjectById(my_spaceship->linked_object);

        if(probe && !my_spaceship->science_link)
        {
            sf::Vector2f probe_position = probe->getPosition();
            my_spaceship->science_link = true;
            radar->setAutoCentering(false);
            radar->setViewPosition(probe_position);
            radar->setDistance(5000);
            radar->setFogOfWarStyle(GuiRadarView::FriendlysShortRangeFogOfWar);
            probe_view_button->setText("Back to ship");
        }else if(my_spaceship->science_link)
        {
            my_spaceship->science_link = false;
            radar->setAutoCentering(true);
            radar->setDistance(gameGlobalInfo->long_range_radar_range);
            probe_view_button->setText("Probe View");
            radar->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
        }

    });
    probe_view_button->setPosition(-20, -70, ABottomRight)->setSize(250, 50)->disable();

    (new GuiSelector(radar_view, "ZOOM_SELECT", [this](int index, string value) {
        float zoom_amount = 1 + 0.5 * index ;
        if(!my_spaceship->science_link)
        radar->setDistance(gameGlobalInfo->long_range_radar_range / zoom_amount);
    }))->setOptions({"Zoom: 1x", "Zoom: 1.5x", "Zoom: 2x", "Zoom: 2.5x", "Zoom: 3x"})->setSelectionIndex(0)->setPosition(-20, -20, ABottomRight)->setSize(250, 50);

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

    (new GuiListbox(this, "VIEW_SELECTION", [this](int index, string value) {
        radar_view->setVisible(index == 0);
        database_view->setVisible(index == 1);
    }))->setOptions({"Radar", "Database"})->setSelectionIndex(0)->setPosition(20, -20, ABottomLeft)->setSize(200, 100);

    new GuiScanningDialog(this, "SCANNING_DIALOG");
}

void ScienceScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
    P<ScanProbe> probe;

    ///Handle mouse wheel
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0 && !my_spaceship->science_link)
    {
        float view_distance = radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        if (view_distance > gameGlobalInfo->long_range_radar_range)
            view_distance = gameGlobalInfo->long_range_radar_range;
        if (view_distance < 5000.0f)
            view_distance = 5000.0f;
        radar->setDistance(view_distance);
    }

    if (game_server)
            probe = game_server->getObjectById(my_spaceship->linked_object);
        else
            probe = game_client->getObjectById(my_spaceship->linked_object);

    if (!my_spaceship)
        return;
    if (targets.get() && Nebula::blockedByNebula(my_spaceship->getPosition(), targets.get()->getPosition()) && !my_spaceship->science_link)
        targets.clear();

    info_callsign->setValue("-");
    info_distance->setValue("-");
    info_heading->setValue("-");
    info_relspeed->setValue("-");
    info_faction->setValue("-");
    info_type->setValue("-");
    info_shields->setValue("-");
    info_shield_frequency->setFrequency(-1)->hide();
    info_beam_frequency->setFrequency(-1)->hide();
    info_description->hide();

    for(int n=0; n<SYS_COUNT; n++)
        info_system[n]->setValue("-")->hide();

    if (probe)
    {
        probe_view_button->enable();
    }
    else
    {
        probe_view_button->disable();

        //if the probe is not valid and the view is still on the probe, return to normal view
        if (my_spaceship->science_link && !observation_point)
        {
            my_spaceship->science_link = false;
            radar->setAutoCentering(true);
            radar->setDistance(gameGlobalInfo->long_range_radar_range);
            probe_view_button->setText("Probe View");
            radar->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
        }

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
        info_distance->setValue(string(distance / 1000.0f, 1) + "km");
        info_heading->setValue(string(int(heading)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + "km/min");

        if (ship)
        {
            if (ship->scanned_by_player >= SS_SimpleScan)
            {
                info_faction->setValue(factionInfo[obj->getFactionId()]->getName());
                info_type->setValue(ship->getTypeName());
                info_shields->setValue(ship->getShieldDataString());
            }
            if (ship->scanned_by_player >= SS_FullScan)
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

        info_distance->setValue(string(distance / 1000.0f, 1) + "km");
        info_heading->setValue(string(int(heading)));
        info_relspeed->setValue(string(rel_velocity / 1000.0f * 60.0f, 1) + "km/min");
    }
}

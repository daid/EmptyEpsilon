#include "relayScreen.h"
#include "i18n.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"
#include "ecs/query.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/probe.h"
#include "components/hacking.h"
#include "components/scanning.h"
#include "components/radar.h"
#include "components/name.h"

#include "screenComponents/radarView.h"
#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"
#include "screenComponents/hackingDialog.h"
#include "screenComponents/customShipFunctions.h"
#include "screenComponents/alertLevelButton.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"

//TODO: This function does not belong here.
static bool canHack(sp::ecs::Entity entity)
{
    auto scanstate = entity.getComponent<ScanState>();
    //TODO: Check if there are actually hackable systems.
    if (scanstate && scanstate->getStateFor(my_spaceship) == ScanState::State::NotScanned)
        return true;
    return Faction::getRelation(entity, my_spaceship) != FactionRelation::Friendly;
}

RelayScreen::RelayScreen(GuiContainer* owner, bool allow_comms)
: GuiOverlay(owner, "RELAY_SCREEN", colorConfig.background)
{
    targets.setAllowWaypointSelection();
    radar = new GuiRadarView(this, "RELAY_RADAR", 50000.0f, &targets);
    radar->longRange()->enableWaypoints()->enableCallsigns()->setStyle(GuiRadarView::Rectangular)->setFogOfWarStyle(GuiRadarView::FriendlysShortRangeFogOfWar);
    radar->setAutoCentering(false);
    radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) { //down
            if (mode == TargetSelection && targets.getWaypointIndex() > -1) {
                if (auto waypoints = my_spaceship.getComponent<Waypoints>()) {
                    if (auto waypoint_position = waypoints->get(targets.getWaypointIndex())) {
                        if (glm::length(waypoint_position.value() - position) < 1000.0f) {
                            mode = MoveWaypoint;
                            drag_waypoint_index = targets.getWaypointIndex();
                        }
                    }
                }
            }
            mouse_down_position = position;
        },
        [this](glm::vec2 position) { //drag
            if (mode == TargetSelection)
                radar->setViewPosition(radar->getViewPosition() - (position - mouse_down_position));
            if (mode == MoveWaypoint && my_spaceship)
                my_player_info->commandMoveWaypoint(drag_waypoint_index, position);
        },
        [this](glm::vec2 position) { //up
            switch(mode)
            {
            case TargetSelection:
                targets.setToClosestTo(position, 1000, TargetsContainer::Targetable);
                break;
            case WaypointPlacement:
                if (my_spaceship)
                    my_player_info->commandAddWaypoint(position);
                mode = TargetSelection;
                option_buttons->show();
                break;
            case MoveWaypoint:
                mode = TargetSelection;
                targets.setWaypointIndex(drag_waypoint_index);
                break;
            case LaunchProbe:
                if (my_spaceship)
                    my_player_info->commandLaunchProbe(position);
                mode = TargetSelection;
                option_buttons->show();
                break;
            }
        }
    );

    if (auto transform = my_spaceship.getComponent<sp::Transform>())
        radar->setViewPosition(transform->getPosition());

    auto sidebar = new GuiElement(this, "SIDE_BAR");
    sidebar->setPosition(-20, 150, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    info_callsign = new GuiKeyValueDisplay(sidebar, "SCIENCE_CALLSIGN", 0.4, tr("Callsign"), "");
    info_callsign->setSize(GuiElement::GuiSizeMax, 30);

    info_faction = new GuiKeyValueDisplay(sidebar, "SCIENCE_FACTION", 0.4, tr("Faction"), "");
    info_faction->setSize(GuiElement::GuiSizeMax, 30);

    zoom_slider = new GuiSlider(this, "ZOOM_SLIDER", 50000.0f, 6250.0f, 50000.0f, [this](float value) {
        zoom_label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(50000.0f / value, 1.0f)}}));
        radar->setDistance(value);
    });
    zoom_slider->setPosition(20, -70, sp::Alignment::BottomLeft)->setSize(250, 50);
    zoom_label = new GuiLabel(zoom_slider, "", "Zoom: 1.0x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Option buttons for comms, waypoints, and probes.
    option_buttons = new GuiElement(this, "BUTTONS");
    option_buttons->setPosition(20, 50, sp::Alignment::TopLeft)->setSize(250, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    // Open comms button.
    (new GuiOpenCommsButton(option_buttons, "OPEN_COMMS_BUTTON", tr("Open comms"), &targets, allow_comms))->setSize(GuiElement::GuiSizeMax, 50);

    // Hack target
    hack_target_button = new GuiButton(option_buttons, "HACK_TARGET", tr("Start hacking"), [this](){
        auto target = targets.get();
        if (canHack(target)) {
            hacking_dialog->open(target);
        }
    });
    hack_target_button->setSize(GuiElement::GuiSizeMax, 50);

    // Link probe to science button.
    link_to_science_button = new GuiToggleButton(option_buttons, "LINK_TO_SCIENCE", tr("Link to Science"), [this](bool value){
        if (value)
        {
            my_player_info->commandSetScienceLink(targets.get());
        }
        else
        {
            my_player_info->commandClearScienceLink();
        }
    });
    link_to_science_button->setSize(GuiElement::GuiSizeMax, 50)->setVisible(my_spaceship.hasComponent<LongRangeRadar>() && my_spaceship.hasComponent<ScanProbeLauncher>());

    // Manage waypoints.
    (new GuiButton(option_buttons, "WAYPOINT_PLACE_BUTTON", tr("Place Waypoint"), [this]() {
        mode = WaypointPlacement;
        option_buttons->hide();
    }))->setSize(GuiElement::GuiSizeMax, 50);

    delete_waypoint_button = new GuiButton(option_buttons, "WAYPOINT_DELETE_BUTTON", tr("Delete Waypoint"), [this]() {
        if (my_spaceship && targets.getWaypointIndex() >= 0)
        {
            my_player_info->commandRemoveWaypoint(targets.getWaypointIndex());
        }
    });
    delete_waypoint_button->setSize(GuiElement::GuiSizeMax, 50);

    // Launch probe button.
    launch_probe_button = new GuiButton(option_buttons, "LAUNCH_PROBE_BUTTON", tr("Launch Probe"), [this]() {
        mode = LaunchProbe;
        option_buttons->hide();
    });
    launch_probe_button->setSize(GuiElement::GuiSizeMax, 50)->setVisible(my_spaceship.hasComponent<ScanProbeLauncher>());

    // Center on ship
    center_button = new GuiToggleButton(option_buttons, "CENTER_ON_SHIP", tr("Center On Ship"), [this](bool value) {
        if(!my_spaceship) return;
        radar->setAutoCentering(value);
    });
    center_button->setSize(GuiElement::GuiSizeMax, 50);

    // Reputation display.
    info_reputation = new GuiKeyValueDisplay(option_buttons, "INFO_REPUTATION", 0.4f, tr("Reputation") + ":", "");
    info_reputation->setSize(GuiElement::GuiSizeMax, 40);

    // Scenario clock display.
    info_clock = new GuiKeyValueDisplay(option_buttons, "INFO_CLOCK", 0.4f, tr("Clock") + ":", "");
    info_clock->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiAlertLevelSelect(this, ""))->setPosition(-20, -70, sp::Alignment::BottomRight)->setSize(300, GuiElement::GuiSizeMax)->setAttribute("layout", "verticalbottom");

    auto position = allow_comms ? CrewPosition::relayOfficer : CrewPosition::altRelay;
    (new GuiCustomShipFunctions(this, position, ""))->setPosition(-20, 240, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);

    hacking_dialog = new GuiHackingDialog(this, "");

    if (allow_comms)
    {
        new ShipsLog(this);
        (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
}

void RelayScreen::onDraw(sp::RenderTarget& renderer)
{
    ///Handle mouse wheel
    float mouse_wheel_delta = keys.zoom_in.getValue() - keys.zoom_out.getValue();
    if (mouse_wheel_delta != 0.0f)
    {
        float view_distance = radar->getDistance() * (1.0f - (mouse_wheel_delta * 0.1f));
        if (view_distance > 50000.0f)
            view_distance = 50000.0f;
        if (view_distance < 6250.0f)
            view_distance = 6250.0f;
        radar->setDistance(view_distance);
        // Keep the zoom slider in sync.
        zoom_slider->setValue(view_distance);
        zoom_label->setText("Zoom: " + string(50000.0f / view_distance, 1.0f) + "x");
    }
    ///!

    GuiOverlay::onDraw(renderer);

    info_faction->setValue("-");

    // If the player has a target and the player isn't destroyed...
    if (targets.get() && my_spaceship)
    {
        // Check each object to determine whether the target is still within
        // shared radar range of a friendly object.
        auto target = targets.get();
        bool near_friendly = false;

        // For each SpaceObject on the map...
        if (auto target_transform = target.getComponent<sp::Transform>()) {
            for(auto [entity, ssrr, transform] : sp::ecs::Query<ShareShortRangeRadar, sp::Transform>())
            {
                if (Faction::getRelation(my_spaceship, entity) != FactionRelation::Friendly)
                    continue;

                // Set the targetable radius to getShortRangeRadarRange() if the
                // object's a ShipTemplateBasedObject. Otherwise, default to 5U.
                float r = entity.getComponent<LongRangeRadar>() ? entity.getComponent<LongRangeRadar>()->short_range : 5000.0f;

                // If the target is within the short-range radar range/5U of the
                // object, consider it near a friendly object.
                
                if (glm::length2(transform.getPosition() - target_transform->getPosition()) < r * r)
                {
                    near_friendly = true;
                    break;
                }
            }
        }

        if (!near_friendly)
        {
            // If the target is no longer near a friendly object, unset it as
            // the target, and close any open hacking dialogs.
            targets.clear();
            hacking_dialog->hide();
        }
    }

    if (targets.get())
    {
        auto target = targets.get();

        if (auto cs = target.getComponent<CallSign>())
            info_callsign->setValue(cs->callsign);

        auto faction = Faction::getInfo(target);
        auto scanstate = target.getComponent<ScanState>();
        if (!scanstate || scanstate->getStateFor(my_spaceship) >= ScanState::State::SimpleScan)
            info_faction->setValue(faction.locale_name);

        if (auto arl = target.getComponent<AllowRadarLink>())
        {
            if (arl->owner == my_spaceship) {
                auto rl = my_spaceship.getComponent<RadarLink>();
                if (rl)
                    link_to_science_button->setValue(rl->linked_entity == target);
                link_to_science_button->enable();
            } else {
                link_to_science_button->setValue(false);
                link_to_science_button->disable();
            }
        }
        else
        {
            link_to_science_button->setValue(false);
            link_to_science_button->disable();
        }
        if (canHack(target))
        {
            hack_target_button->enable();
        }else{
            hack_target_button->disable();
        }
    }else{
        hack_target_button->disable();
        link_to_science_button->disable();
        link_to_science_button->setValue(false);
        info_callsign->setValue("-");
    }
    if (my_spaceship)
    {
        // Toggle ship capabilities.
        auto spl = my_spaceship.getComponent<ScanProbeLauncher>();
        launch_probe_button->setVisible(spl);
        launch_probe_button->setEnable(spl ? spl->stock > 0 : false);
        link_to_science_button->setVisible(my_spaceship.hasComponent<LongRangeRadar>() && spl);
        hack_target_button->setVisible(my_spaceship.hasComponent<HackingDevice>());

        info_reputation->setValue(string(Faction::getInfo(my_spaceship).reputation_points, 0));

        // Update mission clock
        info_clock->setValue(gameGlobalInfo->getMissionTime());

        if (auto spl = my_spaceship.getComponent<ScanProbeLauncher>())
            launch_probe_button->setText(tr("Launch Probe") + " (" + string(spl->stock) + ")");
    }

    if (targets.getWaypointIndex() >= 0)
        delete_waypoint_button->enable();
    else
        delete_waypoint_button->disable();
}

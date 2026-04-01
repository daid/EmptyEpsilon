#include "spectatorScreen.h"
#include "main.h"
#include "gameGlobalInfo.h"
#include "i18n.h"
#include "multiplayer_server.h"
#include "playerInfo.h"
#include "ecs/query.h"
#include "components/name.h"
#include "components/hull.h"
#include "components/shields.h"
#include "components/collision.h"
#include "systems/collision.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/radarView.h"
#include "screenComponents/radarZoomSlider.h"
#include "screenComponents/helpOverlay.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_togglebutton.h"

SpectatorScreen::SpectatorScreen(RenderLayer* render_layer)
: GuiCanvas(render_layer)
{
    main_radar = new GuiRadarView(this, "MAIN_RADAR", LONG_RANGE_DISTANCE, nullptr);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster()->enableTargetProjections(nullptr)->setAutoCentering(false)->enableCallsigns();
    main_radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    main_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) { this->onMouseDown(position); },
        [this](glm::vec2 position) { this->onMouseDrag(position); },
        [this](glm::vec2 position) { this->onMouseUp(position); },
        [this](float value, glm::vec2 position) { this->onMouseWheel(value, position); }
    );

    ui_toggle = new GuiToggleButton(this, "UI_TOGGLE", "", [this](bool value) {
        toggleUI();
    });
    ui_toggle->setIcon("redicule.png")->setSize(30, 30)->setPosition(0, 0, sp::Alignment::TopLeft);
    ui_toggle->setAttribute("margin", "20");

    camera_lock_controls = new GuiElement(this, "CAMERA_LOCK_CONTROLS");
    camera_lock_controls->setPosition(0, 0, sp::Alignment::BottomLeft)->hide();
    camera_lock_controls->setAttribute("layout", "vertical");
    camera_lock_controls->setAttribute("padding", "20");

    // Let the screen operator select a player ship to lock the camera onto.
    (new GuiLabel(camera_lock_controls, "CAMERA_LOCK_SELECTOR_LABEL", tr("spectator", "Select player ship as target"), 12.0f)
    )->addBackground()->setSize(GuiElement::GuiSizeMax, 20);
    camera_lock_selector = new GuiSelector(camera_lock_controls, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        if (auto ship = sp::ecs::Entity::fromString(value))
        {
            target = ship;

            if (main_radar->getAutoCentering())
            {
                if (target.hasComponent<sp::Transform>())
                    main_radar->setAutoCenterTarget(target);
            }
        }
    });
    camera_lock_selector->setSelectionIndex(0)->setSize(300, 50);

    info_layout = new GuiElement(this, "INFO_LAYOUT");
    info_layout->setPosition(0, 0, sp::Alignment::TopRight)->setSize(350, GuiElement::GuiSizeMax)->hide();
    info_layout->setAttribute("layout", "vertical");
    info_layout->setAttribute("padding", "20");

    info_coordinates = new GuiElement(info_layout, "INFO_COORDINATES");
    info_coordinates->setSize(GuiElement::GuiSizeMax, 20)->setAttribute("layout", "horizontal");
    info_coordinates_x = new GuiKeyValueDisplay(info_coordinates, "INFO_COORDINATES_X", 0.2f, "X", "");
    info_coordinates_x->setTextSize(12.0f)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info_coordinates_y = new GuiKeyValueDisplay(info_coordinates, "INFO_COORDINATES_Y", 0.2f, "Y", "");
    info_coordinates_y->setTextSize(12.0f)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info_coordinates_sector = new GuiKeyValueDisplay(info_coordinates, "INFO_COORDINATES_SECTOR", 0.5f, tr("spectate", "Sector"), "");
    info_coordinates_sector->setTextSize(12.0f)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info_clock = new GuiKeyValueDisplay(info_coordinates, "INFO_CLOCK", 0.375f, tr("Clock"), "");
    info_clock->setTextSize(12.0f)->setSize(GuiElement::GuiSizeMax, 20);

    info_position = new GuiKeyValueDisplay(info_layout, "INFO_POSITION", 0.25f, tr("gmTweak", "Position"), "");
    info_position->setSize(GuiElement::GuiSizeMax, 30);

    info_position_lock = new GuiToggleButton(info_position, "INFO_POSITION_LOCK", tr("spectate", "Follow"), [this](bool value) {
        if (target.getComponent<sp::Transform>())
        {
            main_radar->setAutoCenterTarget(target);
            main_radar->setAutoCentering(value);
        }
    });
    info_position_lock->setTextSize(16)->setSize(50, 27)->setPosition(0, 0, sp::Alignment::CenterRight);

    zoom_slider = new GuiRadarZoomSlider(this, "ZOOM_SLIDER", MIN_ZOOM_DISTANCE, MAX_ZOOM_DISTANCE, LONG_RANGE_DISTANCE, main_radar);
    zoom_slider
        ->setZoomReference(LONG_RANGE_DISTANCE)
        ->setLabelPrecision(3)
        ->setPosition(0.0f, 0.0f, sp::Alignment::BottomRight)
        ->setSize(350.0f, 50.0f)
        ->hide()
        ->setAttribute("margin", "20");

    new GuiIndicatorOverlays(this);

    keyboard_help = new GuiHelpOverlay(this, tr("hotkey_F1", "Keyboard Shortcuts"));
    bool show_additional_shortcuts_string = false;
    string keyboard_help_text = "";

    for (const auto& category : {tr("hotkey_menu", "Spectator view"), tr("hotkey_menu", "Top-down view")})
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory(tr(category)))
        {
            if (binding->isBound())
                keyboard_help_text += binding->getLabel() + ": " + binding->getHumanReadableKeyName(0) + "\n";
            else
                show_additional_shortcuts_string = true;
        }
    }

    if (show_additional_shortcuts_string)
        keyboard_help_text += "\n" + tr("More shortcuts available in settings") + "\n";

    keyboard_help->setText(keyboard_help_text);
    keyboard_help->moveToFront();

    new GuiIndicatorOverlays(this);
}

void SpectatorScreen::toggleUI()
{
    camera_lock_controls->setVisible(!camera_lock_controls->isVisible());
    info_layout->setVisible(!info_layout->isVisible());
    zoom_slider->setVisible(!zoom_slider->isVisible());
    ui_toggle->setValue(camera_lock_controls->isVisible());
}

void SpectatorScreen::update(float delta)
{
    auto view_position = main_radar->getViewPosition();
    float view_distance = main_radar->getDistance();
    float mouse_wheel_delta = keys.zoom_in.getContinuousValue() + keys.zoom_in.getAxis0Value() + keys.zoom_in.getAxis1Value()
        - keys.zoom_out.getContinuousValue() - keys.zoom_out.getAxis0Value() - keys.zoom_out.getAxis1Value();
    if (mouse_wheel_delta != 0.0f)
        view_distance *= (1.0f - (mouse_wheel_delta * 0.1f));
    if (keys.zoom_in.isDiscreteStepDown() || keys.zoom_in.isRepeatReady())
        view_distance = view_distance * 0.9f;
    if (keys.zoom_out.isDiscreteStepDown() || keys.zoom_out.isRepeatReady())
        view_distance = view_distance * 1.1f;
    view_distance = std::clamp(view_distance, MIN_ZOOM_DISTANCE, MAX_ZOOM_DISTANCE);
    if (view_distance != main_radar->getDistance())
    {
        main_radar->setDistance(view_distance);
        if (view_distance < SHORT_RANGE_DISTANCE) main_radar->shortRange();
        else main_radar->longRange();
        zoom_slider->setValue(view_distance);
    }

    if (keys.help.getDown())
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());

    if (keys.topdown.toggle_ui.getDown())
        toggleUI();

    if (keys.topdown.lock_camera.getDown())
    {
        main_radar->setAutoCentering(!main_radar->getAutoCentering());
        info_position_lock->setValue(main_radar->getAutoCentering());
    }

    if (keys.topdown.previous_player_ship.isDiscreteStepDown() || keys.topdown.previous_player_ship.isRepeatReady())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() - 1);
        if (camera_lock_selector->getSelectionIndex() < 0)
            camera_lock_selector->setSelectionIndex(camera_lock_selector->entryCount() - 1);
        if (auto ship = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()))) main_radar->setAutoCenterTarget(ship);
    }

    if (keys.topdown.next_player_ship.isDiscreteStepDown() || keys.topdown.next_player_ship.isRepeatReady())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
        if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
            camera_lock_selector->setSelectionIndex(0);
        if (auto ship = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()))) main_radar->setAutoCenterTarget(ship);
    }

    if (!main_radar->getAutoCentering())
    {
        float pan_up = std::max(keys.topdown.pan_up.getContinuousValue() + keys.topdown.pan_up.getAxis0Value() + keys.topdown.pan_up.getAxis1Value(), (float)keys.topdown.pan_up.get());
        float pan_dn = std::max(keys.topdown.pan_down.getContinuousValue() + keys.topdown.pan_down.getAxis0Value() + keys.topdown.pan_down.getAxis1Value(), (float)keys.topdown.pan_down.get());
        float pan_lt = std::max(keys.topdown.pan_left.getContinuousValue() + keys.topdown.pan_left.getAxis0Value() + keys.topdown.pan_left.getAxis1Value(), (float)keys.topdown.pan_left.get());
        float pan_rt = std::max(keys.topdown.pan_right.getContinuousValue() + keys.topdown.pan_right.getAxis0Value() + keys.topdown.pan_right.getAxis1Value(), (float)keys.topdown.pan_right.get());
        float pan_x = pan_rt - pan_lt;
        float pan_y = pan_dn - pan_up;
        if (pan_x != 0.0f || pan_y != 0.0f)
            main_radar->setViewPosition(view_position + glm::vec2(pan_x, pan_y) * main_radar->getDistance() * 0.01f);
    }

    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection(getRenderLayer());
    }

    if (keys.pause.getDown())
        if (game_server && !gameGlobalInfo->getVictoryFaction()) engine->setGameSpeed(engine->getGameSpeed() > 0.0f ? 0.0f : 1.0f);

    if (keys.spectator_show_callsigns.getDown())
        main_radar->showCallsigns(!main_radar->getCallsigns());

    // Add and remove entries from the player ship list.
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
    {
        if (camera_lock_selector->indexByValue(entity.toString()) == -1) {
            string label;
            if (auto tn = entity.getComponent<TypeName>())
                label = tn->type_name;
            if (auto cs = entity.getComponent<CallSign>())
                label += " " + cs->callsign;
            camera_lock_selector->addEntry(label, entity.toString());
        }
    }
    for(int n=0; n<camera_lock_selector->entryCount(); n++) {
        if (!sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(n)))
            camera_lock_selector->removeEntry(n);
    }

    // Update mission clock
    info_clock->setValue(gameGlobalInfo->getMissionTime());

    // Update coordinates
    info_coordinates_x->setValue(string(view_position.x));
    info_coordinates_y->setValue(string(view_position.y));
    info_coordinates_sector->setValue(tr("spectator", "{sector}").format({
        {"sector", getSectorName(view_position)}
    }));

    // Update target info, if a target's selected.
    auto target_transform = target.getComponent<sp::Transform>();
    if (target != sp::ecs::Entity() && target_transform)
    {
        std::unordered_map<string, string> selection_info;
        std::unordered_map<string, string> info;

        if (target_transform)
            info_position->setValue(string(target_transform->getPosition().x) + ", " + string(target_transform->getPosition().y))->show();
        else
            info_position->hide();
        if (auto cs = target.getComponent<CallSign>())
            info[trMark("gm_info", "Callsign")] = cs->callsign;
        if (target.hasComponent<Faction>())
        {
            auto& faction_info = Faction::getInfo(target);
            info[trMark("gm_info", "Faction")] = faction_info.locale_name;
        }
        if (auto tn = target.getComponent<TypeName>())
            info[trMark("gm_info", "Type")] = tn->localized;
        if (auto shields = target.getComponent<Shields>())
        {
            string shields_value = "";
            for (Shields::Shield& shield : shields->entries)
                shields_value += string(shield.percentage()) + "% ";
            info[trMark("gm_info", "Shields")] = shields_value;
        }
        if (auto hull = target.getComponent<Hull>())
            info[trMark("gm_info", "Hull")] = string(int(100.0f * hull->current / hull->max)) + "%";

        for (auto i = info.begin(); i != info.end(); i++)
            selection_info[i->first] = i->second;

        // Target info
        unsigned int cnt = 0;
        for (std::unordered_map<string, string>::iterator i = selection_info.begin(); i != selection_info.end(); i++)
        {
            if (cnt == info_items.size())
            {
                info_items.push_back(new GuiKeyValueDisplay(info_layout, "INFO_" + string(cnt), 0.25f, i->first, i->second));
                info_items[cnt]->setSize(GuiElement::GuiSizeMax, 30);
            }
            else
            {
                info_items[cnt]->show();
                info_items[cnt]->setKey(tr("gm_info", i->first))->setValue(i->second);
            }
            cnt++;
        }

        while (cnt < info_items.size())
        {
            info_items[cnt]->hide();
            cnt++;
        }
    }
    else
    {
        info_position_lock->setValue(false);
        target = sp::ecs::Entity();
        main_radar->setAutoCenterTarget(target);
        main_radar->setAutoCentering(false);
        info_position->hide();
        unsigned int cnt = 0;
        while (cnt < info_items.size())
        {
            info_items[cnt]->hide();
            cnt++;
        }
    }
}

void SpectatorScreen::onMouseDown(glm::vec2 position)
{
    drag_start_position = position;
    drag_previous_position = position;
    dragging = false;
}

void SpectatorScreen::onMouseDrag(glm::vec2 position)
{
    if (!main_radar->getAutoCentering())
    {
        dragging = true;
        main_radar->setViewPosition(main_radar->getViewPosition() - (position - drag_previous_position));
        position -= (position - drag_previous_position);
        drag_previous_position = position;
    }
}

void SpectatorScreen::onMouseUp(glm::vec2 position)
{
    // Clear current target on click unless locked
    if (!main_radar->getAutoCentering() && target != sp::ecs::Entity() && !dragging)
    {
        target = sp::ecs::Entity();
        main_radar->setAutoCenterTarget(target);
    }
    dragging = false;

    glm::vec2 target_position;

    for (auto entity : sp::CollisionSystem::queryArea(position - (glm::vec2{300.0f, 300.0f} * main_radar->getDistance() / LONG_RANGE_DISTANCE), position + (glm::vec2{300.0f, 300.0f} * main_radar->getDistance() / LONG_RANGE_DISTANCE)))
    {
        if (auto transform = entity.getComponent<sp::Transform>())
        {
            if (target == sp::ecs::Entity() || glm::length(position - transform->getPosition()) < glm::length(position - target_position))
            {
                target = entity;
                target_position = transform->getPosition();
                if (main_radar->getAutoCentering())
                    main_radar->setAutoCenterTarget(target);
                return;
            }
        }
    }

    // If nothing's targeted, disable any active autocentering
    if (target == sp::ecs::Entity())
    {
        main_radar->setAutoCentering(false);
        info_position_lock->setValue(false);
    }
}

void SpectatorScreen::onMouseWheel(float value, glm::vec2 position)
{
    // Calculate the new zoom level.
    const float view_distance = std::clamp(
        main_radar->getDistance() * (1.0f - value * 0.1f),
        MIN_ZOOM_DISTANCE,
        MAX_ZOOM_DISTANCE
    );

    // Get the world coordinates under the pointer before zooming.
    const glm::vec2 world_position_before_zoom = main_radar->screenToWorld(position);

    // Set the new zoom level.
    main_radar->setDistance(view_distance);
    zoom_slider->setValue(view_distance);

    // Adjust the radar's view position to keep the world coordinates
    // under the pointer consistent.
    main_radar->setViewPosition(main_radar->getViewPosition() + world_position_before_zoom - main_radar->screenToWorld(position));
}

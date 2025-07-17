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
    main_radar = new GuiRadarView(this, "MAIN_RADAR", 50000.0f, nullptr);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster()->enableTargetProjections(nullptr)->setAutoCentering(false)->enableCallsigns();
    main_radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    main_radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) { this->onMouseDown(position); },
        [this](glm::vec2 position) { this->onMouseDrag(position); },
        [this](glm::vec2 position) { this->onMouseUp(position); }
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

    zoom_slider = new GuiSlider(this, "ZOOM_SLIDER", 100000.0f, 5000.0f, 50000.0f, [this](float value) {
        zoom_label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(50000.0f / value, 2.0f)}}));
        main_radar->setDistance(value);
    });
    zoom_slider->setPosition(0, 0, sp::Alignment::BottomRight)->setSize(350, 50)->hide();
    zoom_slider->setAttribute("margin", "20");
    zoom_label = new GuiLabel(zoom_slider, "ZOOM_SLIDER_LABEL", "Zoom: 1.0x", 30);
    zoom_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    new GuiIndicatorOverlays(this);

    keyboard_help = new GuiHelpOverlay(this, tr("hotkey_F1", "Keyboard Shortcuts"));
    string keyboard_topdown = "";

    for (auto binding : sp::io::Keybinding::listAllByCategory("Top-down View"))
        keyboard_topdown += tr("hotkey_F1", "{label}: {button}\n").format({{"label", binding->getLabel()}, {"button", binding->getHumanReadableKeyName(0)}});

    keyboard_help->setText(keyboard_topdown);
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
    float mouse_wheel_delta = keys.zoom_in.getValue() - keys.zoom_out.getValue();
    if (mouse_wheel_delta != 0.0f)
    {
        float view_distance = main_radar->getDistance() * (1.0f - (mouse_wheel_delta * 0.1f));
        if (view_distance > 100000)
            view_distance = 100000;
        if (view_distance < 5000)
            view_distance = 5000;
        main_radar->setDistance(view_distance);
        if (view_distance < 10000)
            main_radar->shortRange();
        else
            main_radar->longRange();
        // Keep the zoom slider in sync.
        zoom_slider->setValue(view_distance);
        zoom_label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(50000.0f / view_distance, 2.0f)}}));
    }

    if (keys.help.getDown())
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());

    if (keys.topdown.toggle_ui.getDown())
        toggleUI();

    if (keys.topdown.lock_camera.getDown())
        main_radar->setAutoCentering(!main_radar->getAutoCentering());

    if (keys.topdown.previous_player_ship.getDown())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() - 1);
        if (camera_lock_selector->getSelectionIndex() < 0)
            camera_lock_selector->setSelectionIndex(camera_lock_selector->entryCount() - 1);
        if (auto ship = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()))) main_radar->setAutoCenterTarget(ship);
    }

    if (keys.topdown.next_player_ship.getDown())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
        if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
            camera_lock_selector->setSelectionIndex(0);
        if (auto ship = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()))) main_radar->setAutoCenterTarget(ship);
    }

    if (keys.topdown.pan_up.get())
    {
        if (!main_radar->getAutoCentering())
            main_radar->setViewPosition(glm::vec2(view_position.x, view_position.y - main_radar->getDistance() * 0.01f));
    }

    if (keys.topdown.pan_left.get())
    {
        if (!main_radar->getAutoCentering())
            main_radar->setViewPosition(glm::vec2(view_position.x - main_radar->getDistance() * 0.01f, view_position.y));
    }

    if (keys.topdown.pan_down.get())
    {
        if (!main_radar->getAutoCentering())
            main_radar->setViewPosition(glm::vec2(view_position.x, view_position.y + main_radar->getDistance() * 0.01f));
    }

    if (keys.topdown.pan_right.get())
    {
        if (!main_radar->getAutoCentering())
            main_radar->setViewPosition(glm::vec2(view_position.x + main_radar->getDistance() * 0.01f, view_position.y));
    }

    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection(getRenderLayer());
    }

    if (keys.pause.getDown())
        if (game_server) engine->setGameSpeed(0.0);

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

    for (auto entity : sp::CollisionSystem::queryArea(position - (glm::vec2{300.0f, 300.0f} * main_radar->getDistance() / 50000.0f), position + (glm::vec2{300.0f, 300.0f} * main_radar->getDistance() / 50000.0f)))
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

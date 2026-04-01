#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "topDownScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "multiplayer_client.h"
#include "components/collision.h"
#include "components/name.h"
#include "i18n.h"
#include "ecs/query.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/scrollingBanner.h"
#include "screenComponents/helpOverlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

TopDownScreen::TopDownScreen(RenderLayer* render_layer)
: GuiCanvas(render_layer)
{
    // Create a full-screen viewport and draw callsigns on ships.
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->showCallsigns();
    viewport->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Set the camera's vertical position/zoom.
    camera_position.z = 7000.0f;

    // Let the screen operator select a player ship to lock the camera onto.
    camera_lock_selector = new GuiSelector(this, "CAMERA_LOCK_SELECTOR", [this](int index, string value) {
        auto ship = sp::ecs::Entity::fromString(value);
        if (ship)
            target = ship;
    });
    camera_lock_selector->setSelectionIndex(0)->setPosition(20, -80, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();

    // Toggle whether to lock onto a player ship.
    camera_lock_toggle = new GuiToggleButton(this, "CAMERA_LOCK_TOGGLE", tr("button", "Lock camera on ship"), [this](bool value) {});
    camera_lock_toggle->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(300, 50)->hide();

    new GuiIndicatorOverlays(this);

    (new GuiScrollingBanner(this))->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, 100);

    keyboard_help = new GuiHelpOverlay(viewport, tr("hotkey_F1", "Keyboard Shortcuts"));
    string keyboard_topdown = "";

    for (auto binding : sp::io::Keybinding::listAllByCategory("Top-down view"))
        keyboard_topdown += tr("hotkey_F1", "{label}: {button}\n").format({{"label", binding->getLabel()}, {"button", binding->getHumanReadableKeyName(0)}});

    keyboard_help->setText(keyboard_topdown);
    keyboard_help->moveToFront();

    // Lock onto the first player ship to start.
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>()) {
        target = entity;
        camera_lock_toggle->setValue(true);
        break;
    }
}

void TopDownScreen::onMouseWheelScroll(glm::vec2 position, float value)
{
    if (!executeScrollOnElement(position, value))
        pending_zoom += value;
}

void TopDownScreen::update(float delta)
{
    // If this is a client and it is disconnected, exit.
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
        return;
    }

    // Enable mouse wheel zoom.
    float mouse_wheel_delta = keys.zoom_in.getContinuousValue() + keys.zoom_in.getAxis0Value() + keys.zoom_in.getAxis1Value()
        - keys.zoom_out.getContinuousValue() - keys.zoom_out.getAxis0Value() - keys.zoom_out.getAxis1Value() + pending_zoom;
    pending_zoom = 0.0f;
    if (mouse_wheel_delta != 0.0f)
    {
        camera_position.z *= (1.0f - mouse_wheel_delta * 0.1f);
        if (camera_position.z > 10000) camera_position.z = 10000;
        if (camera_position.z < 1000) camera_position.z = 1000;
    }
    if (keys.zoom_in.isDiscreteStepDown() || keys.zoom_in.isRepeatReady())
        camera_position.z = std::max(1000.0f, camera_position.z * 0.9f);
    if (keys.zoom_out.isDiscreteStepDown() || keys.zoom_out.isRepeatReady())
        camera_position.z = std::min(10000.0f, camera_position.z * 1.1f);

    if (keys.help.getDown())
    {
        // Toggle keyboard help.
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());
    }

    if (keys.topdown.toggle_ui.getDown())
    {
        if (camera_lock_toggle->isVisible() || camera_lock_selector->isVisible())
        {
            camera_lock_toggle->hide();
            camera_lock_selector->hide();
        }
        else {
            camera_lock_toggle->show();
            camera_lock_selector->show();
        }
    }

    if (keys.topdown.toggle_callsigns.getDown())
    {
        viewport->toggleCallsigns();
    }

    if (keys.topdown.lock_camera.getDown())
    {
        camera_lock_toggle->setValue(!camera_lock_toggle->getValue());
    }

    if (keys.topdown.previous_player_ship.isDiscreteStepDown() || keys.topdown.previous_player_ship.isRepeatReady())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() - 1);
        if (camera_lock_selector->getSelectionIndex() < 0)
            camera_lock_selector->setSelectionIndex(camera_lock_selector->entryCount() - 1);
        target = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()));
    }

    if (keys.topdown.next_player_ship.isDiscreteStepDown() || keys.topdown.next_player_ship.isRepeatReady())
    {
        camera_lock_selector->setSelectionIndex(camera_lock_selector->getSelectionIndex() + 1);
        if (camera_lock_selector->getSelectionIndex() >= camera_lock_selector->entryCount())
            camera_lock_selector->setSelectionIndex(0);
        target = sp::ecs::Entity::fromString(camera_lock_selector->getEntryValue(camera_lock_selector->getSelectionIndex()));
    }

    if (!camera_lock_toggle->getValue())
    {
        float pan_up = std::max(keys.topdown.pan_up.getContinuousValue() + keys.topdown.pan_up.getAxis0Value() + keys.topdown.pan_up.getAxis1Value(), (float)keys.topdown.pan_up.get());
        float pan_dn = std::max(keys.topdown.pan_down.getContinuousValue() + keys.topdown.pan_down.getAxis0Value() + keys.topdown.pan_down.getAxis1Value(), (float)keys.topdown.pan_down.get());
        float pan_lt = std::max(keys.topdown.pan_left.getContinuousValue() + keys.topdown.pan_left.getAxis0Value() + keys.topdown.pan_left.getAxis1Value(), (float)keys.topdown.pan_left.get());
        float pan_rt = std::max(keys.topdown.pan_right.getContinuousValue() + keys.topdown.pan_right.getAxis0Value() + keys.topdown.pan_right.getAxis1Value(), (float)keys.topdown.pan_right.get());
        camera_position.y += (pan_dn - pan_up) * (3 * delta * camera_position.z) / 10;
        camera_position.x += (pan_rt - pan_lt) * (3 * delta * camera_position.z) / 10;
    }

    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection(getRenderLayer());
    }

    if (keys.pause.getDown())
        if (game_server && !gameGlobalInfo->getVictoryFaction()) engine->setGameSpeed(engine->getGameSpeed() > 0.0f ? 0.0f : 1.0f);

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

    // Enforce a top-down view with up pointing toward heading 0.
    camera_yaw = -90.0f;
    camera_pitch = 90.0f;

    // If locked onto a player ship, move the camera along with it.
    if (camera_lock_toggle->getValue() && target)
    {
        if (auto transform = target.getComponent<sp::Transform>()) {
            auto target_position = transform->getPosition();

            camera_position.x = target_position.x;
            camera_position.y = target_position.y;
        }
    }
}

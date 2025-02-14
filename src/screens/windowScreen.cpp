#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "windowScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "multiplayer_client.h"
#include "components/collision.h"

#include "screenComponents/viewport3d.h"
#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/shipDestroyedPopup.h"

WindowScreen::WindowScreen(RenderLayer* render_layer, float angle, uint8_t flags)
: GuiCanvas(render_layer), angle(angle)
{
    viewport = new GuiViewport3D(this, "VIEWPORT");
    if (flags & flag_callsigns)
      viewport->showCallsigns();
    if (flags & flag_headings)
      viewport->showHeadings();
    if (flags & flag_spacedust)
      viewport->showSpacedust();
    viewport->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    new GuiShipDestroyedPopup(this);

    new GuiIndicatorOverlays(this);
}

void WindowScreen::update(float delta)
{
    angle += (keys.helms_turn_right.getValue() - keys.helms_turn_left.getValue()) * 5.0f;

    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection(getRenderLayer());
    }
    if (keys.pause.getDown())
    {
        if (game_server)
            engine->setGameSpeed(0.0);
    }

    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
        return;
    }

    if (auto transform = my_spaceship.getComponent<sp::Transform>())
    {
        camera_yaw = transform->getRotation() + angle;
        camera_pitch = 0.0f;

        auto physics = my_spaceship.getComponent<sp::Physics>();
        auto radius = 300.0f;
        if (physics)
            radius = physics->getSize().x;
        auto position = transform->getPosition() + rotateVec2(glm::vec2(radius, 0), camera_yaw);

        camera_position.x = position.x + 1.0f; // small offset to prevent camera glitches on some models
        camera_position.y = position.y;
        camera_position.z = 0.0;
    }
}

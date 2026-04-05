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
    angle += (keys.helms_turn_right.getContinuousValue() - keys.helms_turn_left.getContinuousValue()) * 5.0f;
    angle += (keys.helms_turn_right.getAxis0Value() - keys.helms_turn_left.getAxis0Value()) * 5.0f;
    angle += (keys.helms_turn_right.getAxis1Value() - keys.helms_turn_left.getAxis1Value()) * 5.0f;
    if (keys.helms_turn_right.isDiscreteStepDown() || keys.helms_turn_right.isRepeatReady()) angle += 5.0f;
    if (keys.helms_turn_left.isRepeatReady()) angle -= 5.0f;

    if (keys.escape.getDown())
    {
        destroy();
        returnToShipSelection(getRenderLayer());
    }

    if (keys.pause.getDown())
        if (game_server && !gameGlobalInfo->getVictoryFaction()) engine->setGameSpeed(engine->getGameSpeed() > 0.0f ? 0.0f : 1.0f);

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

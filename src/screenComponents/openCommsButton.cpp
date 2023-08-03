#include "openCommsButton.h"

#include "targetsContainer.h"
#include "playerInfo.h"
#include "components/comms.h"


GuiOpenCommsButton::GuiOpenCommsButton(GuiContainer* owner, string id, string name, TargetsContainer* targets)
: GuiButton(owner, id, name, [this]() {
    if (my_spaceship && this->targets->get())
        my_player_info->commandOpenTextComm(this->targets->get());
}), targets(targets)
{
}

void GuiOpenCommsButton::onDraw(sp::RenderTarget& renderer)
{
    disable();
    auto transmitter = my_spaceship.getComponent<CommsTransmitter>();
    if (transmitter && transmitter->state == CommsTransmitter::State::Inactive)
    {
        auto receiver = targets->get().getComponent<CommsReceiver>();
        if (receiver)
            enable();
    }
    GuiButton::onDraw(renderer);
}

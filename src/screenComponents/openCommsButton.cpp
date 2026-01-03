#include "openCommsButton.h"
#include <i18n.h>
#include "targetsContainer.h"
#include "playerInfo.h"
#include "components/comms.h"


GuiOpenCommsButton::GuiOpenCommsButton(GuiContainer* owner, string id, string name, TargetsContainer* targets, bool allow_comms)
: GuiButton(owner, id, name, [this]() {
    if (my_spaceship && this->targets->get())
        my_player_info->commandOpenTextComm(this->targets->get());
}), targets(targets), allow_comms(allow_comms)
{
}

void GuiOpenCommsButton::onDraw(sp::RenderTarget& renderer)
{
    disable();
    // Indicate the comms state on the comms button, or hide the button if this
    // ship lacks a comms transmitter.
    auto transmitter = my_spaceship.getComponent<CommsTransmitter>();
    setVisible(transmitter);
    if (transmitter && isVisible())
    {
        if (transmitter->state == CommsTransmitter::State::Inactive)
        {
            auto target = targets->get();
            if (target.hasComponent<CommsReceiver>() || target.hasComponent<CommsTransmitter>())
            {
                enable();
                setText(allow_comms ? tr("Open comms") : tr("Link to comms"));
            }
            else setText(tr("No comms reception"));
        }
        else setText(tr("Transmitting..."));
    }

    GuiButton::onDraw(renderer);
}

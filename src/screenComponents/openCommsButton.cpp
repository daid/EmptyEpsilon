#include <libintl.h>

#include "playerInfo.h"
#include "openCommsButton.h"

GuiOpenCommsButton::GuiOpenCommsButton(GuiContainer* owner, string id, TargetsContainer* targets)
: GuiButton(owner, id, gettext("Open comms"), [this]() {
    if (my_spaceship && this->targets->get())
        my_spaceship->commandOpenTextComm(this->targets->get());
}), targets(targets)
{
}

void GuiOpenCommsButton::onDraw(sf::RenderTarget& window)
{
    disable();
    if (targets->get() && my_spaceship && my_spaceship->isCommsInactive())
    {
        if (P<SpaceShip>(targets->get()) || P<SpaceStation>(targets->get()))
            enable();
    }
    GuiButton::onDraw(window);
}

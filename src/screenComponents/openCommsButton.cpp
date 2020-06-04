#include "openCommsButton.h"

#include "targetsContainer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

GuiOpenCommsButton::GuiOpenCommsButton(GuiContainer* owner, string id, string name, TargetsContainer* targets, P<PlayerSpaceship> targetSpaceship)
: GuiButton(owner, id, name, [this]() {
    if (target_spaceship && this->targets->get())
        target_spaceship->commandOpenTextComm(this->targets->get());
}), targets(targets), target_spaceship(targetSpaceship)
{
}

void GuiOpenCommsButton::onDraw(sf::RenderTarget& window)
{
    disable();
    if (targets->get() && target_spaceship && target_spaceship->isCommsInactive())
    {
        if (P<SpaceShip>(targets->get()) || P<SpaceStation>(targets->get()))
            enable();
    }
    GuiButton::onDraw(window);
}

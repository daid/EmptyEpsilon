#include "openCommsButton.h"

#include "targetsContainer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

GuiOpenCommsButton::GuiOpenCommsButton(GuiContainer* owner, string id, TargetsContainer* targets)
: GuiButton(owner, id, "Open comms", [this]() {
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


void GuiOpenCommsButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "RELAY" && my_spaceship)
    {
        if (key.hotkey == "OPEN_COMM")
        {
			if (this->targets->get())
				my_spaceship->commandOpenTextComm(this->targets->get());
		}
	}
}

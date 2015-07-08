#include "playerInfo.h"
#include "scanTargetButton.h"

GuiScanTargetButton::GuiScanTargetButton(GuiContainer* owner, string id, TargetsContainer* targets)
: GuiElement(owner, id), targets(targets)
{
    button = new GuiButton(this, id + "_BUTTON", "Scan", [this]() {
        if (my_spaceship && this->targets && this->targets->entries.size() > 0)
            my_spaceship->commandScan(this->targets->entries[0]);
    });
    button->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    progress = new GuiProgressbar(this, id + "_PROGRESS", 0, PlayerSpaceship::max_scanning_delay, 0.0);
    progress->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}
    
void GuiScanTargetButton::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;

    if (my_spaceship->scanning_delay > 0.0)
    {
        progress->show();
        progress->setValue(my_spaceship->scanning_delay);
        button->hide();
    }
    else
    {
        P<SpaceShip> ship;
        if (targets && targets->entries.size() > 0)
            ship = targets->entries[0];
        
        if (ship && ship->scanned_by_player < SS_FullScan)
            button->show();
        else
            button->hide();
        progress->hide();
    }
}

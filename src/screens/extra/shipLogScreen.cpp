#include "shipLogScreen.h"
#include "playerInfo.h"

ShipLogScreen::ShipLogScreen(GuiContainer* owner)
: GuiOverlay(owner, "SHIP_LOG_SCREEN", sf::Color::Black)
{
    log_text = new GuiScrollText(this, "SHIP_LOG", "");
    log_text->setPosition(50, 50)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void ShipLogScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        log_text->setText(string("\n").join(my_spaceship->getShipsLog()));
    }
}

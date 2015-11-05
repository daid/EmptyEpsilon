#include "databaseScreen.h"

#include "screenComponents/databaseView.h"

DatabaseScreen::DatabaseScreen(GuiContainer* owner)
: GuiOverlay(owner, "DATABASE_SCREEN", sf::Color::Black)
{
    (new DatabaseViewComponent(this))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

#include "databaseScreen.h"
#include "scienceDatabase.h"

#include "screenComponents/databaseView.h"

DatabaseScreen::DatabaseScreen(GuiContainer* owner)
: GuiOverlay(owner, "DATABASE_SCREEN", colorConfig.background)
{
    (new DatabaseViewComponent(this))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

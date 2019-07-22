#include "databaseScreen.h"
#include "scienceDatabase.h"

#include "screenComponents/databaseView.h"
#include "screenComponents/customShipFunctions.h"

DatabaseScreen::DatabaseScreen(GuiContainer* owner)
: GuiOverlay(owner, "DATABASE_SCREEN", colorConfig.background)
{
    (new DatabaseViewComponent(this))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiCustomShipFunctions(this, databaseView, "", my_spaceship))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

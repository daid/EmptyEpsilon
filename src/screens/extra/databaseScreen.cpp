#include "databaseScreen.h"

#include "screenComponents/databaseView.h"
#include "screenComponents/customShipFunctions.h"
#include "gui/theme.h"

DatabaseScreen::DatabaseScreen(GuiContainer* owner)
: GuiOverlay(owner, "DATABASE_SCREEN", GuiTheme::getColor("background"))
{
    (new DatabaseViewComponent(this))->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiCustomShipFunctions(this, CrewPosition::databaseView, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

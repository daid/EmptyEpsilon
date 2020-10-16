#include <i18n.h>
#include "databaseScreen.h"
#include "scienceDatabase.h"

#include "screenComponents/databaseView.h"
#include "screenComponents/customShipFunctions.h"

DatabaseScreen::DatabaseScreen(GuiContainer* owner)
: GuiOverlay(owner, "DATABASE_SCREEN", colorConfig.background)
{
    database_view = new DatabaseViewComponent(this, 50, true);
    database_view->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    link_to_main = new GuiLinkScienceButton(this, "LINK_TO_MAIN", tr("button", "Link to Main"), database_view);
    link_to_main->setPosition(20, -20, ABottomLeft)->setSize(200, 50)->disable();

    (new GuiCustomShipFunctions(this, databaseView, ""))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

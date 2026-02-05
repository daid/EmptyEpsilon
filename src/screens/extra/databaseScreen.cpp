#include "databaseScreen.h"
#include "playerInfo.h"

#include "screenComponents/databaseView.h"
#include "screenComponents/customShipFunctions.h"

DatabaseScreen::DatabaseScreen(GuiContainer* owner)
: GuiOverlay(owner, "DATABASE_SCREEN", colorConfig.background)
{
    // Render background decorations.
    (new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255}))
        ->setTextureTiled("gui/background/crosses.png");

    // Render database.
    DatabaseViewComponent* dvc = new DatabaseViewComponent(this);
    dvc->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    dvc->setAttribute("padding", "20");

    // Pad top of details column if crew screen selection controls are visible.
    int details_padding = 0;
    if (my_player_info)
    {
        if (my_player_info->main_screen_control != 0) details_padding = 120;
        else if (my_player_info->countTotalPlayerPositions() > 1) details_padding = 70;
    }
    dvc->setDetailsPadding(details_padding);

    // Render Databse View custom ship functions.
    (new GuiCustomShipFunctions(this, CrewPosition::databaseView, "DB_CUSTOM_SHIP_FUNCTIONS"))
        ->setSize(250.0f, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopRight)
        ->setAttribute("padding", "0, 20, 120, 0");
}

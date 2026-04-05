#include "commsScreen.h"

#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/theme.h"


CommsScreen::CommsScreen(GuiContainer* owner)
: GuiOverlay(owner, "COMMS_SCREEN", GuiTheme::getColor("background"))
{
    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiCustomShipFunctions(this, CrewPosition::commsOnly, ""))
        ->setPosition(-20.0f, 140.0f, sp::Alignment::TopRight)
        ->setSize(250.0f, 7000.0f);
}

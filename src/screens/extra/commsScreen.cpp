#include "commsScreen.h"

#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"
#include "gui/theme.h"

CommsScreen::CommsScreen(GuiContainer* owner)
: BaseShipScreen(owner, "COMMS_SCREEN")
{
    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

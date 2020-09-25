#include "commsScreen.h"

#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"


CommsScreen::CommsScreen(GuiContainer* owner)
: GuiOverlay(owner, "COMMS_SCREEN", colorConfig.background)
{
    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

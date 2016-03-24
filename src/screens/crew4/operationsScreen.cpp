#include "operationsScreen.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

OperationScreen::OperationScreen(GuiContainer* owner)
: ScienceScreen(owner)
{
    (new GuiOpenCommsButton(this, "OPEN_COMMS_BUTTON", &targets))->setPosition(20, 20, ATopLeft)->setSize(250, 50);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

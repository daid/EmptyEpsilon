#include "operationsScreen.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

OperationScreen::OperationScreen(GuiContainer* owner)
: ScienceScreen(owner)
{
    (new GuiOpenCommsButton(this->radar_view, "OPEN_COMMS_BUTTON", &targets))->setPosition(-270, -20, ABottomRight)->setSize(200, 50);
    (new GuiCommsOverlay(this->radar_view))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

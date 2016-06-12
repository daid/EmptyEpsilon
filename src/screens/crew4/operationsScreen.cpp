#include "operationsScreen.h"

#include "screens/crew6/scienceScreen.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"

OperationScreen::OperationScreen(GuiContainer* owner)
: GuiOverlay(owner, "", colorConfig.background)
{
    ScienceScreen* science = new ScienceScreen(this);
    science->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, 0, 0, 50);
    (new GuiOpenCommsButton(science->radar_view, "OPEN_COMMS_BUTTON", &science->targets))->setPosition(-270, -20, ABottomRight)->setSize(200, 50);
    
    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

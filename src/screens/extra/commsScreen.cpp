#include "commsScreen.h"

#include "screenComponents/commsOverlay.h"
#include "screenComponents/shipsLogControl.h"
#include "gui/theme.h"

CommsScreen::CommsScreen(GuiContainer* owner)
: GuiOverlay(owner, "COMMS_SCREEN", GuiTheme::getColor("background"))
{
    new ShipsLog(this);
    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

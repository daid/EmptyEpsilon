#include "engineeringAdvancedScreen.h"

#include "screenComponents/shieldsEnableButton.h"

EngineeringAdvancedScreen::EngineeringAdvancedScreen(GuiContainer* owner)
: EngineeringScreen(owner)
{
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(-20, -420, ABottomRight)->setSize(320, 50);
}

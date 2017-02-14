#include "engineeringAdvancedScreen.h"

#include "screenComponents/shieldsEnableButton.h"

EngineeringAdvancedScreen::EngineeringAdvancedScreen(GuiContainer* owner)
: EngineeringScreen(owner)
{
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(20, 370, ATopLeft)->setSize(240, 50);
}

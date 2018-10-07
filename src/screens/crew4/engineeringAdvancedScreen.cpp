#include "engineeringAdvancedScreen.h"

#include "screenComponents/shieldsEnableButton.h"
#include "playerInfo.h"

EngineeringAdvancedScreen::EngineeringAdvancedScreen(GuiContainer* owner)
: EngineeringScreen(owner, engineeringAdvanced)
{
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE", my_spaceship))->setPosition(20, 370, ATopLeft)->setSize(240, 50);
}

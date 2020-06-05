#include "engineeringAdvancedScreen.h"

#include "gameGlobalInfo.h"
#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shieldsEnableButton.h"

EngineeringAdvancedScreen::EngineeringAdvancedScreen(GuiContainer* owner)
: EngineeringScreen(owner, engineeringAdvanced)
{
	if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        //The shield frequency selection includes a shield enable button.
        (new GuiShieldFrequencySelect(this, "SHIELD_FREQ"))->setPosition(20, 310, ATopLeft)->setSize(240, 100);
    }else{
        (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(20, 310, ATopLeft)->setSize(240, 50);
    }
}

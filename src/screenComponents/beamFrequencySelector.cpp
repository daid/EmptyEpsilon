#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "beamFrequencySelector.h"

GuiBeamFrequencySelector::GuiBeamFrequencySelector(GuiContainer* owner, string id)
: GuiSelector(owner, id, [](int index, string value) { if (my_spaceship) my_spaceship->commandSetBeamFrequency(index); })
{
    for(int n=0; n<=SpaceShip::max_frequency; n++)
        addEntry(frequencyToString(n), frequencyToString(n));
    if (my_spaceship)
        setSelectionIndex(my_spaceship->beam_frequency);
    if (!gameGlobalInfo->use_beam_shield_frequencies)
        hide();
}

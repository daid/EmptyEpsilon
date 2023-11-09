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

void GuiBeamFrequencySelector::onUpdate()
{
    if (my_spaceship && gameGlobalInfo->use_beam_shield_frequencies && isVisible())
    {
        if (keys.weapons_beam_frequence_increase.getDown())
        {
            if (getSelectionIndex() >= (int)entries.size() - 1)
                setSelectionIndex(0);
            else
                setSelectionIndex(getSelectionIndex() + 1);
            callback();
        }
        if (keys.weapons_beam_frequence_decrease.getDown())
        {
            if (getSelectionIndex() <= 0)
                setSelectionIndex(entries.size() - 1);
            else
                setSelectionIndex(getSelectionIndex() - 1);
        }
    }
}

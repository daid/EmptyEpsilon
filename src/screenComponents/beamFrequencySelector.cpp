#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/playerSpaceship.h"
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

void GuiBeamFrequencySelector::onHotkey(const HotkeyResult& key)
{
    if (key.category == "WEAPONS" && my_spaceship && gameGlobalInfo->use_beam_shield_frequencies)
    {
        if (key.hotkey == "BEAM_FREQUENCY_INCREASE")
        {
            if (getSelectionIndex() >= (int)entries.size() - 1)
                setSelectionIndex(0);
            else
                setSelectionIndex(getSelectionIndex() + 1);
            callback();
        }
        if (key.hotkey == "BEAM_FREQUENCY_DECREASE")
        {
            if (getSelectionIndex() <= 0)
                setSelectionIndex(entries.size() - 1);
            else
                setSelectionIndex(getSelectionIndex() - 1);
        }
    }
}

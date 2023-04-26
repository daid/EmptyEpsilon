#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "beamFrequencySelector.h"

#include "components/beamweapon.h"

GuiBeamFrequencySelector::GuiBeamFrequencySelector(GuiContainer* owner, string id)
: GuiSelector(owner, id, [](int index, string value) { if (my_spaceship) my_player_info->commandSetBeamFrequency(index); })
{
    for(int n=0; n<=SpaceShip::max_frequency; n++)
        addEntry(frequencyToString(n), frequencyToString(n));
    if (my_spaceship) {
        auto beamweapons = my_spaceship.getComponent<BeamWeaponSys>();
        if (beamweapons)
            setSelectionIndex(beamweapons->frequency);
    }
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

#include "beamFrequencySelector.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"

#include "components/beamweapon.h"

GuiBeamFrequencySelector::GuiBeamFrequencySelector(GuiContainer* owner, string id)
: GuiSelector(owner, id, [](int index, string value) { if (my_spaceship) my_player_info->commandSetBeamFrequency(index); })
{
    for (int n = 0; n <= BeamWeaponSys::max_frequency; n++)
        addEntry(frequencyToString(n), frequencyToString(n));
}

void GuiBeamFrequencySelector::onUpdate()
{
    if (!my_spaceship) return;
    auto beam_weapons = my_spaceship.getComponent<BeamWeaponSys>();
    setVisible(beam_weapons && gameGlobalInfo->use_beam_shield_frequencies);
    if (!isVisible()) return;

    // Handle inc/dec keybinds.
    if (keys.weapons_beam_frequence_increase.getDown())
    {
        if (getSelectionIndex() >= static_cast<int>(entries.size()) - 1)
            setSelectionIndex(0);
        else
            setSelectionIndex(getSelectionIndex() + 1);

        callback();
    }

    if (keys.weapons_beam_frequence_decrease.getDown())
    {
        if (getSelectionIndex() <= 0)
            setSelectionIndex(static_cast<int>(entries.size()) - 1);
        else
            setSelectionIndex(getSelectionIndex() - 1);

        callback();
    }

    // Sync selector to current beam frequency.
    if (beam_weapons->frequency != getSelectionIndex())
        setSelectionIndex(beam_weapons->frequency);
}

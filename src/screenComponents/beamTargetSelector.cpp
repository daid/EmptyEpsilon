#include <i18n.h>
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "beamTargetSelector.h"

#include "components/beamweapon.h"

GuiBeamTargetSelector::GuiBeamTargetSelector(GuiContainer* owner, string id)
: GuiSelector(owner, id, [](int index, string value) { if (my_spaceship) my_spaceship->commandSetBeamSystemTarget(ESystem(index + SYS_None)); })
{
    addEntry(tr("target","Hull"), "-1");
    for(int n=0; n<SYS_COUNT; n++)
        addEntry(getLocaleSystemName(ESystem(n)), string(n));
    if (my_spaceship) {
        auto beamweapons = my_spaceship->entity.getComponent<BeamWeaponSys>();
        if (beamweapons)
            setSelectionIndex(beamweapons->system_target - SYS_None);
    }
    if (!gameGlobalInfo->use_system_damage)
        hide();
}

void GuiBeamTargetSelector::onUpdate()
{
    if (my_spaceship && gameGlobalInfo->use_system_damage && isVisible())
    {
        if (keys.weapons_beam_subsystem_target_next.getDown())
        {
            if (getSelectionIndex() >= (int)entries.size() - 1)
                setSelectionIndex(0);
            else
                setSelectionIndex(getSelectionIndex() + 1);
            callback();
        }
        if (keys.weapons_beam_subsystem_target_previous.getDown())
        {
            if (getSelectionIndex() <= 0)
                setSelectionIndex(entries.size() - 1);
            else
                setSelectionIndex(getSelectionIndex() - 1);
        }
    }
}

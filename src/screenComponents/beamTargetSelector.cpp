#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "beamTargetSelector.h"

GuiBeamTargetSelector::GuiBeamTargetSelector(GuiContainer* owner, string id)
: GuiSelector(owner, id, [](int index, string value) { if (my_spaceship) my_spaceship->commandSetBeamSystemTarget(ESystem(index + SYS_None)); })
{
    addEntry("Hull", "-1");
    for(int n=0; n<SYS_COUNT; n++)
        addEntry(getSystemName(ESystem(n)), string(n));
    if (my_spaceship)
        setSelectionIndex(my_spaceship->beam_system_target - SYS_None);
    if (!gameGlobalInfo->use_system_damage)
        hide();
}

#include <i18n.h>
#include "linkScienceButton.h"
#include "playerInfo.h"
#include "scienceDatabase.h"
#include "spaceObjects/playerSpaceship.h"

GuiLinkScienceButton::GuiLinkScienceButton(GuiContainer* owner, string id, string text, DatabaseViewComponent* database_view)
: GuiToggleButton(owner, id, text, [this](bool active) { click(active); })
{
    this->database_view = database_view;
}

void GuiLinkScienceButton::click(bool active)
{
    if (!my_spaceship)
        return;
    P<ScienceDatabase> entry = database_view->getSelectedEntry();

    if (!entry)
        return;

    int32_t entry_id = entry->getMultiplayerId();
    if (entry_id == my_spaceship->shared_science_database_id)
    {
        // this entry is already selected. So unlink it.
        entry_id = -1;
    }

    my_spaceship->commandSetDatabaseLink(entry_id);
}


void GuiLinkScienceButton::onUpdate()
{
    if (!my_spaceship)
            return;

    if (!database_view)
        return;

    P<ScienceDatabase> entry = database_view->getSelectedEntry();
    setVisible(database_view->isVisible());
    setEnable(entry && entry->hasContent());
    setValue(entry && entry->getMultiplayerId() == my_spaceship->shared_science_database_id);
}

#ifndef DATABASE_SCREEN_H
#define DATABASE_SCREEN_H

#include "gui/gui2_overlay.h"
#include "shipTemplate.h"
#include "screenComponents/linkScienceButton.h"

class DatabaseScreen : public GuiOverlay
{
private:
    DatabaseViewComponent* database_view;
    GuiLinkScienceButton* link_to_main;
public:
    DatabaseScreen(GuiContainer* owner);
};

#endif//DATABASE_SCREEN_H

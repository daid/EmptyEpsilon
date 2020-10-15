#ifndef LINK_SCIENCE_BUTTON_H
#define LINK_SCIENCE_BUTTON_H

#include "gui/gui2_togglebutton.h"
#include "databaseView.h"

class GuiLinkScienceButton : public GuiToggleButton
{
public:
    GuiLinkScienceButton(GuiContainer* owner, string id, string text, DatabaseViewComponent* science_database);

    DatabaseViewComponent* database_view;

    virtual void onUpdate() override;
    void click(bool active);
};

#endif//LINK_SCIENCE_BUTTON_H
